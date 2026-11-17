package com.fibonanci.app.data

import androidx.room.withTransaction
import com.fibonanci.app.core.notification.expandPackageAliases
import com.fibonanci.app.core.nowMillis
import com.fibonanci.app.data.db.AppDatabase
import com.fibonanci.app.data.db.CategoryEntry
import com.fibonanci.app.data.db.NotificationRuleEntry
import com.fibonanci.app.data.db.PocketEntry
import com.fibonanci.app.data.db.ProfileEntry
import com.fibonanci.app.data.db.SubscriptionEntry
import com.fibonanci.app.data.db.TRANSFER_CATEGORY_ID
import com.fibonanci.app.data.db.TransactionEntry
import com.fibonanci.app.data.db.WalletEntry
import com.fibonanci.app.data.db.defaultCategoriesSeed
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import org.json.JSONArray
import org.json.JSONObject
import java.util.UUID
import kotlin.math.abs

// single entry point for every read and balance-safe mutation of the encrypted local database.
class FinanceRepository(private val db: AppDatabase) {
    private val dao = db.dao()
    private val prepareLock = Mutex()
    private var isPrepared = false

    // called whenever the set of notification-bound packages changes (wired to the listener whitelist)
    var onAllowedPackagesChanged: suspend () -> Unit = {}

    private fun newId() = UUID.randomUUID().toString()

    // ---------------------------------------------------------------- startup

    // seeds the default categories into a fresh database; every public call waits for it once.
    private suspend fun prepare() {
        if (isPrepared) return
        prepareLock.withLock {
            if (isPrepared) return
            db.withTransaction {
                dao.getProfiles() // forces the file open so the creation flag is known
                if (db.wasJustCreated) defaultCategoriesSeed(nowMillis()).forEach { dao.upsertCategory(it) }
            }
            isPrepared = true
        }
    }

    // ---------------------------------------------------------------- wallets & categories

    fun watchWallets(profileId: String? = null): Flow<List<WalletEntry>> = dao.watchWallets(profileId)
    fun watchCategories(): Flow<List<CategoryEntry>> = dao.watchCategories()

    suspend fun getWallets(profileId: String? = null): List<WalletEntry> {
        prepare()
        return dao.getWallets(profileId)
    }

    suspend fun getAllActiveWallets(): List<WalletEntry> = getWallets(null)

    suspend fun getCategories(): List<CategoryEntry> {
        prepare()
        return dao.getCategories()
    }

    suspend fun getAllCategories(): List<CategoryEntry> {
        prepare()
        return dao.getAllCategories()
    }

    suspend fun insertWallet(wallet: WalletEntry) = dao.insertWallet(wallet)

    suspend fun updateWalletBalance(walletId: String, newBalance: Double, accountNumber: String? = null) {
        val wallet = dao.getWallet(walletId) ?: return
        // a null account number keeps the stored one, a blank one clears it
        val nextAccount = if (accountNumber == null) wallet.accountNumber else accountNumber.trim().ifEmpty { null }
        dao.updateWallet(wallet.copy(balance = newBalance, accountNumber = nextAccount, updatedAt = nowMillis(), isSynced = false))
    }

    suspend fun addWallet(
        name: String,
        type: String,
        accountNumber: String? = null,
        initialBalance: Double,
        colorHex: String,
        iconName: String,
        boundPackageName: String? = null,
        profileId: String? = null,
    ) {
        val now = nowMillis()
        val walletId = newId()
        val effProfileId = profileId ?: dao.getActiveProfile()?.id ?: error("Belum ada profil aktif")
        dao.insertWallet(
            WalletEntry(
                id = walletId,
                profileId = effProfileId,
                name = name,
                type = type,
                accountNumber = accountNumber?.trim()?.ifEmpty { null },
                balance = initialBalance,
                colorHex = colorHex,
                iconName = iconName,
                createdAt = now,
                updatedAt = now,
            )
        )
        if (!boundPackageName.isNullOrBlank()) {
            upsertNotificationRule(walletId, boundPackageName.trim())
            onAllowedPackagesChanged()
        }
    }

    suspend fun deleteWallet(walletId: String) {
        db.withTransaction {
            val now = nowMillis()
            val wallet = dao.getWallet(walletId)
            if (wallet != null) dao.updateWallet(wallet.copy(isDeleted = true, updatedAt = now, isSynced = false))
            dao.deleteNotificationRulesForWallet(walletId, now)
        }
        onAllowedPackagesChanged()
    }

    // ---------------------------------------------------------------- notification rules

    fun watchNotificationRules(profileId: String? = null): Flow<List<NotificationRuleEntry>> = dao.watchNotificationRules(profileId)
    suspend fun getNotificationRules(profileId: String? = null): List<NotificationRuleEntry> = dao.getNotificationRules(profileId)
    suspend fun getNotificationRulesForWallet(walletId: String): List<NotificationRuleEntry> = dao.getNotificationRulesForWallet(walletId)

    suspend fun getNotificationRuleForPackage(packageName: String, profileId: String? = null): NotificationRuleEntry? {
        val aliases = expandPackageAliases(packageName).map { it.lowercase() }.toSet()
        if (aliases.isEmpty()) return null
        val activeWalletIds = getAllActiveWallets().map { it.id }.toSet()
        val matching = dao.getEnabledNotificationRules()
            .filter { it.packageName.lowercase() in aliases && it.walletId in activeWalletIds }
        if (matching.isEmpty()) return null
        return matching.firstOrNull { profileId != null && it.profileId == profileId } ?: matching.first()
    }

    suspend fun getActiveNotificationPackages(): List<String> {
        prepare()
        return dao.getEnabledNotificationRules().flatMap { expandPackageAliases(it.packageName) }.distinct()
    }

    private suspend fun upsertNotificationRule(walletId: String, packageName: String, isEnabled: Boolean = true, profileId: String? = null) {
        val now = nowMillis()
        val effProfileId = profileId ?: dao.getWallet(walletId)?.profileId
        val aliases = expandPackageAliases(packageName).toList()
        dao.deleteOtherRulesForWallet(walletId, aliases, now)
        val existing = dao.getNotificationRuleForPackages(aliases)
        if (existing != null) {
            dao.updateNotificationRule(
                existing.copy(packageName = packageName, walletId = walletId, profileId = effProfileId, isEnabled = isEnabled, updatedAt = now, isSynced = false)
            )
        } else {
            dao.insertNotificationRule(
                NotificationRuleEntry(id = newId(), packageName = packageName, walletId = walletId, profileId = effProfileId, isEnabled = isEnabled, createdAt = now, updatedAt = now)
            )
        }
    }

    suspend fun bindWalletToPackage(walletId: String, packageName: String, isEnabled: Boolean = true, profileId: String? = null) {
        upsertNotificationRule(walletId, packageName, isEnabled, profileId)
        onAllowedPackagesChanged()
    }

    suspend fun unbindPackage(packageName: String) {
        dao.deleteNotificationRulesForPackages(expandPackageAliases(packageName).toList(), nowMillis())
        onAllowedPackagesChanged()
    }

    // ---------------------------------------------------------------- transactions

    fun watchRecentTransactions(profileId: String? = null, limit: Int = 50): Flow<List<TransactionEntry>> = dao.watchTransactions(profileId, limit)

    suspend fun getTransactions(profileId: String? = null, limit: Int = 50): List<TransactionEntry> {
        prepare()
        return dao.getTransactions(profileId, limit)
    }

    suspend fun getTransactionById(id: String): TransactionEntry? = dao.getTransaction(id)
    suspend fun findActiveTransactionsByExternalRef(ref: String): List<TransactionEntry> = dao.getTransactionsByExternalRef(ref)

    private suspend fun setBalance(wallet: WalletEntry, balance: Double, now: Long) {
        dao.updateWallet(wallet.copy(balance = balance, updatedAt = now, isSynced = false))
    }

    // applies (sign = 1) or reverts (sign = -1) the effect a transaction has on wallet balances.
    private suspend fun applyToWallets(walletId: String, type: String, amount: Double, destinationWalletId: String?, sign: Int, now: Long) {
        val wallet = dao.getWallet(walletId) ?: return
        if (type == "expense" || type == "transfer") {
            setBalance(wallet, wallet.balance - sign * amount, now)
            if (type == "transfer" && destinationWalletId != null && destinationWalletId != walletId) {
                val dest = dao.getWallet(destinationWalletId)
                if (dest != null) setBalance(dest, dest.balance + sign * amount, now)
            }
        } else if (type == "income") {
            setBalance(wallet, wallet.balance + sign * amount, now)
        }
    }

    suspend fun logTransactionWithBalanceMutation(tx: TransactionEntry) {
        db.withTransaction {
            val wallet = dao.getWallet(tx.walletId) ?: error("Rekening tidak ditemukan")
            dao.insertTransaction(if (tx.profileId != null) tx else tx.copy(profileId = wallet.profileId))
            applyToWallets(tx.walletId, tx.type, tx.amount, tx.destinationWalletId, 1, nowMillis())
        }
    }

    suspend fun addTransaction(
        walletId: String,
        categoryId: String,
        amount: Double,
        type: String,
        destinationWalletId: String? = null,
        notes: String? = null,
        transactionDate: Long? = null,
        source: String = "manual",
        externalRef: String? = null,
        profileId: String? = null,
    ) {
        val now = nowMillis()
        val effProfileId = profileId ?: dao.getWallet(walletId)?.profileId ?: dao.getActiveProfile()?.id ?: error("Belum ada profil aktif")
        logTransactionWithBalanceMutation(
            TransactionEntry(
                id = newId(),
                walletId = walletId,
                profileId = effProfileId,
                categoryId = categoryId,
                amount = amount,
                type = type,
                destinationWalletId = destinationWalletId,
                notes = notes?.ifEmpty { null },
                transactionDate = transactionDate ?: now,
                source = source,
                externalRef = externalRef,
                createdAt = now,
                updatedAt = now,
            )
        )
    }

    suspend fun transferCrossProfileFunds(
        sourceWalletId: String,
        destinationWalletId: String,
        amount: Double,
        notes: String? = null,
        transactionDate: Long? = null,
        source: String = "manual",
    ) {
        db.withTransaction {
            require(amount > 0) { "Nominal transfer harus lebih besar dari 0" }
            val now = nowMillis()
            val txDate = transactionDate ?: now
            val sourceWallet = dao.getWallet(sourceWalletId) ?: error("Rekening asal tidak ditemukan")
            val destWallet = dao.getWallet(destinationWalletId) ?: error("Rekening tujuan tidak ditemukan")

            setBalance(sourceWallet, sourceWallet.balance - amount, now)
            setBalance(destWallet, destWallet.balance + amount, now)

            val sourceProfileName = sourceWallet.profileId?.let { dao.getProfile(it) }?.username ?: "Profil Pribadi"
            val destProfileName = destWallet.profileId?.let { dao.getProfile(it) }?.username ?: "Profil Tujuan"
            val transferRef = "cross_profile_${newId()}"
            val cleanNote = if (!notes.isNullOrBlank()) " • ${notes.trim()}" else ""

            // the pair shares one external ref so deleting either side reverses the other
            dao.insertTransaction(
                TransactionEntry(
                    id = newId(),
                    walletId = sourceWallet.id,
                    destinationWalletId = destWallet.id,
                    profileId = sourceWallet.profileId,
                    categoryId = TRANSFER_CATEGORY_ID,
                    amount = amount,
                    type = "expense",
                    notes = "Transfer ke $destProfileName (${destWallet.name})$cleanNote",
                    transactionDate = txDate,
                    source = source,
                    externalRef = transferRef,
                    createdAt = now,
                    updatedAt = now,
                )
            )
            dao.insertTransaction(
                TransactionEntry(
                    id = newId(),
                    walletId = destWallet.id,
                    destinationWalletId = sourceWallet.id,
                    profileId = destWallet.profileId,
                    categoryId = TRANSFER_CATEGORY_ID,
                    amount = amount,
                    type = "income",
                    notes = "Transfer masuk dari $sourceProfileName (${sourceWallet.name})$cleanNote",
                    transactionDate = txDate,
                    source = source,
                    externalRef = transferRef,
                    createdAt = now,
                    updatedAt = now,
                )
            )
        }
    }

    private suspend fun findLinkedPocket(tx: TransactionEntry): PocketEntry? {
        val ref = tx.externalRef
        if (ref != null && ref.startsWith("pocket_") && !ref.startsWith("pocket_close_")) {
            return dao.getPocket(ref.removePrefix("pocket_"))?.takeIf { !it.isDeleted }
        }
        val note = tx.notes ?: ""
        if (!note.contains("Kantong ")) return null
        return dao.getPockets(null).firstOrNull { note.contains("Kantong ${it.name}") }
    }

    // keeps a pocket's amount in step when one of its deposit/withdrawal transactions is edited or removed.
    private suspend fun adjustLinkedPocket(tx: TransactionEntry, now: Long, isRevert: Boolean, overrideAmount: Double? = null) {
        val pocket = findLinkedPocket(tx) ?: return
        val amt = overrideAmount ?: tx.amount
        val isDeposit = tx.type == "transfer" || (tx.notes ?: "").startsWith("Setoran ke Kantong")
        val delta = if (isDeposit == isRevert) -amt else amt
        dao.updatePocket(pocket.copy(currentAmount = (pocket.currentAmount + delta).coerceAtLeast(0.0), updatedAt = now, isSynced = false))
    }

    private suspend fun reverseCrossProfileSibling(tx: TransactionEntry, now: Long) {
        val ref = tx.externalRef
        if (ref == null || !ref.startsWith("cross_profile_")) return
        val pair = dao.getTransactionsByExternalRef(ref).firstOrNull { it.id != tx.id } ?: return
        dao.updateTransaction(pair.copy(isDeleted = true, updatedAt = now, isSynced = false))
        val wallet = dao.getWallet(pair.walletId) ?: return
        setBalance(wallet, if (pair.type == "income") wallet.balance - pair.amount else wallet.balance + pair.amount, now)
    }

    suspend fun deleteTransaction(transactionId: String) {
        db.withTransaction {
            val tx = dao.getTransaction(transactionId) ?: error("Transaksi tidak ditemukan")
            val now = nowMillis()
            dao.updateTransaction(tx.copy(isDeleted = true, updatedAt = now, isSynced = false))
            applyToWallets(tx.walletId, tx.type, tx.amount, tx.destinationWalletId, -1, now)
            reverseCrossProfileSibling(tx, now)
            adjustLinkedPocket(tx, now, isRevert = true)

            // removing a bill payment re-opens the bill it paid
            val ref = tx.externalRef
            if (ref != null && ref.startsWith("sub_")) {
                val sub = dao.getSubscription(ref.removePrefix("sub_"))
                if (sub != null && !sub.isDeleted) {
                    dao.updateSubscription(
                        sub.copy(paidCycles = (sub.paidCycles - 1).coerceIn(0, 9999), lastPaidDate = null, status = "active", updatedAt = now, isSynced = false)
                    )
                }
            }
        }
    }

    suspend fun updateTransaction(
        transactionId: String,
        newWalletId: String,
        newAmount: Double,
        newType: String,
        newCategoryId: String,
        newDestinationWalletId: String? = null,
        newNotes: String? = null,
    ) {
        db.withTransaction {
            val oldTx = dao.getTransaction(transactionId) ?: error("Transaksi tidak ditemukan")
            val now = nowMillis()
            applyToWallets(oldTx.walletId, oldTx.type, oldTx.amount, oldTx.destinationWalletId, -1, now)
            adjustLinkedPocket(oldTx, now, isRevert = true)

            val targetWallet = dao.getWallet(newWalletId) ?: error("Rekening tidak ditemukan")
            applyToWallets(newWalletId, newType, newAmount, newDestinationWalletId, 1, now)
            val updated = oldTx.copy(
                profileId = targetWallet.profileId,
                walletId = newWalletId,
                categoryId = newCategoryId,
                amount = newAmount,
                type = newType,
                destinationWalletId = if (newType == "transfer") newDestinationWalletId else null,
                notes = newNotes,
                updatedAt = now,
                isSynced = false,
            )
            adjustLinkedPocket(updated, now, isRevert = false, overrideAmount = newAmount)
            dao.updateTransaction(updated)
        }
    }

    // ---------------------------------------------------------------- subscriptions

    fun watchActiveSubscriptions(profileId: String? = null): Flow<List<SubscriptionEntry>> = dao.watchSubscriptions(profileId)

    suspend fun getSubscriptions(profileId: String? = null): List<SubscriptionEntry> {
        prepare()
        return dao.getSubscriptions(profileId)
    }

    suspend fun getAutoDeductSubscriptions(): List<SubscriptionEntry> {
        prepare()
        return dao.getAutoDeductSubscriptions()
    }

    suspend fun addSubscription(
        title: String,
        cost: Double,
        dueDay: Int,
        walletId: String,
        categoryId: String,
        autoDeduct: Boolean = false,
        billingCycle: String = "monthly",
        isInstallment: Boolean = false,
        totalCycles: Int? = null,
        deadlineDate: Long? = null,
        profileId: String? = null,
    ) {
        val now = nowMillis()
        val effProfileId = profileId ?: dao.getWallet(walletId)?.profileId ?: dao.getActiveProfile()?.id ?: error("Belum ada profil aktif")
        dao.insertSubscription(
            SubscriptionEntry(
                id = newId(),
                walletId = walletId,
                profileId = effProfileId,
                categoryId = categoryId,
                title = title,
                cost = cost,
                billingCycle = billingCycle,
                dueDay = dueDay,
                autoDeduct = autoDeduct,
                status = "active",
                isInstallment = isInstallment,
                totalCycles = totalCycles,
                paidCycles = 0,
                deadlineDate = deadlineDate,
                createdAt = now,
                updatedAt = now,
            )
        )
    }

    suspend fun updateSubscription(
        subscriptionId: String,
        title: String,
        cost: Double,
        dueDay: Int,
        walletId: String,
        categoryId: String,
        autoDeduct: Boolean = false,
        billingCycle: String = "monthly",
        status: String = "active",
        isInstallment: Boolean = false,
        totalCycles: Int? = null,
        paidCycles: Int = 0,
        deadlineDate: Long? = null,
    ) {
        val sub = dao.getSubscription(subscriptionId) ?: return
        dao.updateSubscription(
            sub.copy(
                title = title,
                cost = cost,
                dueDay = dueDay,
                walletId = walletId,
                categoryId = categoryId,
                autoDeduct = autoDeduct,
                billingCycle = billingCycle,
                status = status,
                isInstallment = isInstallment,
                totalCycles = totalCycles,
                paidCycles = paidCycles,
                deadlineDate = deadlineDate,
                updatedAt = nowMillis(),
            )
        )
    }

    suspend fun markSubscriptionAsPaid(subscriptionId: String, actualAmount: Double? = null, paymentDate: Long? = null) {
        db.withTransaction {
            val sub = dao.getSubscription(subscriptionId)
            if (sub == null || sub.isDeleted || sub.status == "completed") return@withTransaction
            val effectiveCost = if (actualAmount != null && actualAmount > 0) actualAmount else sub.cost
            if (effectiveCost <= 0) return@withTransaction
            val now = paymentDate ?: nowMillis()
            val newPaidCycles = sub.paidCycles + 1
            val hasTenor = sub.isInstallment && sub.totalCycles != null
            val isComplete = hasTenor && newPaidCycles >= sub.totalCycles!!

            dao.updateSubscription(
                sub.copy(
                    lastPaidDate = now,
                    paidCycles = newPaidCycles,
                    status = if (isComplete) "completed" else sub.status,
                    updatedAt = now,
                    isSynced = false,
                )
            )

            val baseNote = if (hasTenor) "Pembayaran Cicilan ($newPaidCycles/${sub.totalCycles}): ${sub.title}" else "Pembayaran Tagihan: ${sub.title}"
            val notes = if (abs(effectiveCost - sub.cost) > 0.01) "$baseNote (Diskon/Penyesuaian dari ${sub.cost.toLong()})" else baseNote
            logTransactionWithBalanceMutation(
                TransactionEntry(
                    id = newId(),
                    profileId = sub.profileId,
                    walletId = sub.walletId,
                    categoryId = sub.categoryId,
                    amount = effectiveCost,
                    type = "expense",
                    notes = notes,
                    externalRef = "sub_${sub.id}",
                    transactionDate = now,
                    source = "subscription_recurring",
                    createdAt = now,
                    updatedAt = now,
                )
            )
        }
    }

    suspend fun deleteSubscription(subscriptionId: String) {
        db.withTransaction {
            val sub = dao.getSubscription(subscriptionId) ?: return@withTransaction
            dao.updateSubscription(sub.copy(isDeleted = true, status = "cancelled", updatedAt = nowMillis(), isSynced = false))
            // payments made for this bill are rolled back with it
            for (tx in dao.getAllActiveTransactions()) {
                val n = tx.notes ?: ""
                val isLinked = tx.externalRef == "sub_${sub.id}" ||
                    (tx.source == "subscription_recurring" &&
                        (n == "Pembayaran Tagihan: ${sub.title}" ||
                            n.startsWith("Pembayaran Tagihan: ${sub.title} (") ||
                            (n.startsWith("Pembayaran Cicilan (") && n.contains(": ${sub.title}"))))
                if (isLinked) deleteTransaction(tx.id)
            }
        }
    }

    // ---------------------------------------------------------------- pockets

    fun watchPockets(profileId: String? = null): Flow<List<PocketEntry>> = dao.watchPockets(profileId)

    suspend fun getPockets(profileId: String? = null): List<PocketEntry> {
        prepare()
        return dao.getPockets(profileId)
    }

    suspend fun addPocket(
        name: String,
        type: String,
        targetAmount: Double? = null,
        initialAmount: Double = 0.0,
        colorHex: String,
        iconName: String,
        targetDate: Long? = null,
        linkedWalletId: String? = null,
        notes: String? = null,
        profileId: String? = null,
    ) {
        db.withTransaction {
            val now = nowMillis()
            val pocketId = newId()
            val effProfileId = profileId ?: dao.getActiveProfile()?.id ?: error("Belum ada profil aktif")
            // an initial deposit without a chosen wallet is taken from the profile's first wallet
            val fundingWalletId = linkedWalletId
                ?: if (initialAmount > 0) dao.getWallets(effProfileId).firstOrNull()?.id else null
            dao.insertPocket(
                PocketEntry(
                    id = pocketId,
                    profileId = effProfileId,
                    name = name,
                    type = type,
                    targetAmount = targetAmount,
                    currentAmount = initialAmount,
                    colorHex = colorHex,
                    iconName = iconName,
                    targetDate = targetDate,
                    linkedWalletId = fundingWalletId,
                    notes = notes,
                    createdAt = now,
                    updatedAt = now,
                )
            )
            if (initialAmount > 0 && fundingWalletId != null) {
                val sourceWallet = dao.getWallet(fundingWalletId)
                if (sourceWallet != null) setBalance(sourceWallet, sourceWallet.balance - initialAmount, now)
                dao.insertTransaction(
                    TransactionEntry(
                        id = newId(),
                        profileId = effProfileId,
                        walletId = fundingWalletId,
                        categoryId = TRANSFER_CATEGORY_ID,
                        amount = initialAmount,
                        type = "transfer",
                        notes = "Setoran ke Kantong $name (Awal)",
                        externalRef = "pocket_$pocketId",
                        transactionDate = now,
                        createdAt = now,
                        updatedAt = now,
                    )
                )
            }
        }
    }

    suspend fun updatePocket(
        pocketId: String,
        name: String,
        type: String,
        targetAmount: Double? = null,
        colorHex: String,
        iconName: String,
        targetDate: Long? = null,
        linkedWalletId: String? = null,
        notes: String? = null,
    ) {
        val pocket = dao.getPocket(pocketId) ?: return
        dao.updatePocket(
            pocket.copy(
                name = name,
                type = type,
                targetAmount = targetAmount,
                colorHex = colorHex,
                iconName = iconName,
                targetDate = targetDate,
                linkedWalletId = linkedWalletId,
                notes = notes,
                updatedAt = nowMillis(),
                isSynced = false,
            )
        )
    }

    suspend fun deletePocket(pocketId: String) {
        db.withTransaction {
            val now = nowMillis()
            val pocket = dao.getPocket(pocketId) ?: return@withTransaction
            if (pocket.currentAmount > 0) {
                // the remaining amount flows back to the linked wallet, else any wallet of the profile
                val wallets = getAllActiveWallets()
                val target = wallets.firstOrNull { it.id == pocket.linkedWalletId }
                    ?: wallets.firstOrNull { it.profileId == pocket.profileId }
                    ?: wallets.firstOrNull()
                if (target != null) {
                    setBalance(target, target.balance + pocket.currentAmount, now)
                    dao.insertTransaction(
                        TransactionEntry(
                            id = newId(),
                            profileId = pocket.profileId ?: target.profileId,
                            walletId = target.id,
                            categoryId = TRANSFER_CATEGORY_ID,
                            amount = pocket.currentAmount,
                            type = "income",
                            notes = "Penarikan dari Kantong ${pocket.name} (Penutupan)",
                            externalRef = "pocket_close_${pocket.id}",
                            transactionDate = now,
                            createdAt = now,
                            updatedAt = now,
                        )
                    )
                }
            }
            dao.updatePocket(pocket.copy(currentAmount = 0.0, isDeleted = true, updatedAt = now, isSynced = false))
        }
    }

    suspend fun transferPocketFunds(pocketId: String, walletId: String, amount: Double, isDepositToPocket: Boolean, notes: String? = null) {
        db.withTransaction {
            require(amount > 0) { "Nominal transfer harus lebih besar dari 0" }
            val now = nowMillis()
            val pocket = dao.getPocket(pocketId)?.takeIf { !it.isDeleted } ?: error("Kantong tidak ditemukan atau telah dihapus")
            val wallet = dao.getWallet(walletId)?.takeIf { !it.isDeleted } ?: error("Rekening tidak ditemukan atau telah dihapus")
            val linkedWalletId = pocket.linkedWalletId ?: walletId

            if (isDepositToPocket) {
                check(wallet.balance >= amount) { "Saldo rekening tidak mencukupi untuk setoran" }
                setBalance(wallet, wallet.balance - amount, now)
                dao.updatePocket(pocket.copy(currentAmount = pocket.currentAmount + amount, linkedWalletId = linkedWalletId, updatedAt = now, isSynced = false))
            } else {
                check(pocket.currentAmount >= amount) { "Saldo kantong tidak mencukupi untuk penarikan" }
                dao.updatePocket(pocket.copy(currentAmount = pocket.currentAmount - amount, linkedWalletId = linkedWalletId, updatedAt = now, isSynced = false))
                setBalance(wallet, wallet.balance + amount, now)
            }
            dao.insertTransaction(
                TransactionEntry(
                    id = newId(),
                    profileId = wallet.profileId ?: pocket.profileId,
                    walletId = walletId,
                    categoryId = TRANSFER_CATEGORY_ID,
                    amount = amount,
                    type = if (isDepositToPocket) "transfer" else "income",
                    notes = notes ?: if (isDepositToPocket) "Setoran ke Kantong ${pocket.name}" else "Penarikan dari Kantong ${pocket.name}",
                    externalRef = "pocket_${pocket.id}",
                    transactionDate = now,
                    createdAt = now,
                    updatedAt = now,
                )
            )
        }
    }

    // ---------------------------------------------------------------- profiles

    fun watchProfiles(): Flow<List<ProfileEntry>> = dao.watchProfiles()

    suspend fun getProfiles(): List<ProfileEntry> {
        prepare()
        return dao.getProfiles()
    }

    suspend fun getActiveProfile(): ProfileEntry? {
        prepare()
        return dao.getActiveProfile()
    }

    suspend fun getProfileById(id: String): ProfileEntry? = dao.getProfile(id)

    private suspend fun requireFreeUsername(username: String, exceptProfileId: String?) {
        val taken = dao.getProfiles().any { it.id != exceptProfileId && it.username.equals(username, ignoreCase = true) }
        require(!taken) { "Username @$username sudah digunakan" }
    }

    suspend fun addProfile(
        username: String,
        fullName: String,
        email: String? = null,
        phone: String? = null,
        avatarPath: String? = null,
        occupation: String? = null,
        bio: String? = null,
        currency: String = "IDR",
        monthlyIncomeTarget: Double? = null,
        setActive: Boolean = false,
    ) {
        val cleanUsername = username.trim().replace("@", "")
        requireFreeUsername(cleanUsername, null)
        val now = nowMillis()
        db.withTransaction {
            if (setActive) dao.deactivateProfiles(now)
            dao.insertProfile(
                ProfileEntry(
                    id = newId(),
                    username = cleanUsername,
                    fullName = fullName,
                    email = email,
                    phone = phone,
                    avatarPath = avatarPath ?: "preset:avatar_1",
                    occupation = occupation,
                    bio = bio,
                    currency = currency,
                    monthlyIncomeTarget = monthlyIncomeTarget,
                    isActive = setActive,
                    createdAt = now,
                    updatedAt = now,
                )
            )
        }
    }

    suspend fun updateProfile(
        profileId: String,
        username: String,
        fullName: String,
        email: String? = null,
        phone: String? = null,
        avatarPath: String? = null,
        occupation: String? = null,
        bio: String? = null,
        currency: String = "IDR",
        monthlyIncomeTarget: Double? = null,
    ) {
        val cleanUsername = username.trim().replace("@", "")
        requireFreeUsername(cleanUsername, profileId)
        val profile = dao.getProfile(profileId) ?: return
        dao.updateProfile(
            profile.copy(
                username = cleanUsername,
                fullName = fullName,
                email = email,
                phone = phone,
                avatarPath = avatarPath,
                occupation = occupation,
                bio = bio,
                currency = currency,
                monthlyIncomeTarget = monthlyIncomeTarget,
                updatedAt = nowMillis(),
                isSynced = false,
            )
        )
    }

    // deleting a profile soft-deletes everything it owns; the last profile is replaced by a fresh default one.
    suspend fun deleteProfile(profileId: String) {
        db.withTransaction {
            val now = nowMillis()
            val profile = dao.getProfile(profileId)
            if (profile != null) dao.updateProfile(profile.copy(isDeleted = true, isActive = false, updatedAt = now))
            val remaining = dao.getProfiles()
            val wipeAll = remaining.isEmpty()
            dao.deleteWalletsOfProfile(profileId, wipeAll, now)
            dao.deleteTransactionsOfProfile(profileId, wipeAll, now)
            dao.deleteSubscriptionsOfProfile(profileId, wipeAll, now)
            dao.deletePocketsOfProfile(profileId, wipeAll, now)
            dao.deleteNotificationRulesOfProfile(profileId, wipeAll, now)
            if (!wipeAll && remaining.none { it.isActive }) {
                dao.updateProfile(remaining.first().copy(isActive = true, updatedAt = now))
            }
        }
    }

    // first run: creates the user's own profile and the wallet they start with.
    suspend fun completeOnboarding(
        fullName: String,
        username: String,
        occupation: String?,
        monthlyIncomeTarget: Double?,
        walletName: String,
        walletType: String,
        walletBalance: Double,
    ) {
        prepare()
        db.withTransaction {
            val now = nowMillis()
            val profileId = newId()
            dao.deactivateProfiles(now)
            dao.insertProfile(
                ProfileEntry(
                    id = profileId,
                    username = username.trim().replace("@", ""),
                    fullName = fullName.trim(),
                    avatarPath = "preset:avatar_1",
                    occupation = occupation,
                    monthlyIncomeTarget = monthlyIncomeTarget,
                    isActive = true,
                    createdAt = now,
                    updatedAt = now,
                )
            )
            dao.insertWallet(
                WalletEntry(
                    id = newId(),
                    profileId = profileId,
                    name = walletName.trim(),
                    type = walletType,
                    balance = walletBalance,
                    colorHex = "#4ADE80",
                    iconName = "wallet",
                    createdAt = now,
                    updatedAt = now,
                )
            )
        }
    }

    suspend fun setActiveProfile(profileId: String) {
        db.withTransaction {
            val now = nowMillis()
            dao.deactivateProfiles(now)
            val profile = dao.getProfile(profileId)
            if (profile != null) dao.updateProfile(profile.copy(isActive = true, updatedAt = now))
        }
    }

    // ---------------------------------------------------------------- categories & data tools

    suspend fun addCategory(name: String, type: String, iconName: String = "category", colorHex: String = "#D4F442") {
        val now = nowMillis()
        dao.upsertCategory(CategoryEntry(id = newId(), name = name.trim(), type = type, iconName = iconName, colorHex = colorHex, createdAt = now, updatedAt = now))
    }

    suspend fun deleteCategory(categoryId: String) = dao.softDeleteCategory(categoryId, nowMillis())

    suspend fun clearProfileTransactions(profileId: String) {
        db.withTransaction {
            val now = nowMillis()
            dao.deleteTransactionsOfProfile(profileId, false, now)
            dao.zeroWalletBalances(profileId, now)
            dao.zeroPocketAmounts(profileId, now)
        }
    }

    private suspend fun JSONObject.restoreEach(key: String, save: suspend (JSONObject) -> Unit) {
        val items = optJSONArray(key) ?: return
        for (i in 0 until items.length()) {
            val item = items.optJSONObject(i) ?: continue
            save(item)
        }
    }

    suspend fun restoreJsonBackup(data: JSONObject) {
        db.withTransaction {
            data.restoreEach("profiles") { dao.upsertProfile(profileFromJson(it)) }
            data.restoreEach("categories") { dao.upsertCategory(categoryFromJson(it)) }
            data.restoreEach("wallets") { dao.upsertWallet(walletFromJson(it)) }
            data.restoreEach("pockets") { dao.upsertPocket(pocketFromJson(it)) }
            data.restoreEach("subscriptions") { dao.upsertSubscription(subscriptionFromJson(it)) }
            data.restoreEach("transactions") { dao.upsertTransaction(transactionFromJson(it)) }
        }
    }

    // exports the active profile's data in the shape restoreJsonBackup reads.
    suspend fun exportJsonBackup(): JSONObject {
        val profileId = getActiveProfile()?.id
        return JSONObject()
            .put("profiles", JSONArray(dao.getProfiles().map { it.toJson() }))
            .put("categories", JSONArray(dao.getCategories().map { it.toJson() }))
            .put("wallets", JSONArray(dao.getWallets(profileId).map { it.toJson() }))
            .put("pockets", JSONArray(dao.getPockets(profileId).map { it.toJson() }))
            .put("subscriptions", JSONArray(dao.getVisibleSubscriptions(profileId).map { it.toJson() }))
            .put("transactions", JSONArray(dao.getTransactions(profileId, 5000).map { it.toJson() }))
    }
}
