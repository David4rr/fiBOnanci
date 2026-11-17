package com.fibonanci.app.core.notification

import com.fibonanci.app.core.nowMillis
import com.fibonanci.app.data.FinanceRepository
import com.fibonanci.app.data.db.WalletEntry
import java.util.UUID

// resolves or auto-provisions the appropriate wallet for an incoming notification
object NotificationWalletResolver {
    suspend fun resolve(
        repository: FinanceRepository,
        pkg: String,
        title: String,
        text: String,
        activeProfileId: String? = null,
    ): WalletEntry? {
        val wallets = repository.getAllActiveWallets()
        if (wallets.isEmpty()) return null

        val lowText = "$title $text".lowercase()

        // tier 1: matching account number (suffix or exact number) across all profiles
        matchAccountNumber(wallets, lowText)?.let { return it }

        val activeProf = if (activeProfileId != null) null else repository.getActiveProfile()
        val effectiveProfileId = activeProfileId ?: activeProf?.id

        // tier 2: user-configured notification rule
        if (effectiveProfileId != null) {
            val rule = repository.getNotificationRuleForPackage(pkg, profileId = effectiveProfileId)
            if (rule != null) {
                wallets.firstOrNull { it.id == rule.walletId }?.let { return it }
            }
        }
        val generalRule = repository.getNotificationRuleForPackage(pkg)
        if (generalRule != null) {
            wallets.firstOrNull { it.id == generalRule.walletId }?.let { return it }
        }

        // tier 3: keyword / provider heuristic (prioritizing active profile)
        val profileWallets = if (effectiveProfileId != null) wallets.filter { it.profileId == effectiveProfileId } else emptyList()
        val searchPool = profileWallets.ifEmpty { wallets }

        matchProvider(pkg, lowText, searchPool)?.let { return it }

        // fallback search across all wallets if not found in profile wallets
        if (profileWallets.isNotEmpty()) {
            matchProvider(pkg, lowText, wallets)?.let { return it }
        }

        // special shopeepay auto-provisioning
        if (pkg.contains("shopee") || lowText.contains("shopee")) {
            val shopeeWallets = wallets.filter { it.name.lowercase().contains("shopee") }
            if (shopeeWallets.isNotEmpty()) return shopeeWallets.first()
            return autoProvisionShopeePay(repository, effectiveProfileId)
        }

        // 4. check if notification text names a wallet
        for (w in searchPool) {
            if (lowText.contains(w.name.lowercase())) return w
        }
        for (w in wallets) {
            if (lowText.contains(w.name.lowercase())) return w
        }

        return searchPool.firstOrNull() ?: wallets.first()
    }

    private val nonDigits = Regex("[^0-9]")

    private fun matchAccountNumber(wallets: List<WalletEntry>, lowText: String): WalletEntry? {
        for (w in wallets) {
            val acc = w.accountNumber?.replace(nonDigits, "") ?: ""
            if (acc.length >= 3) {
                // full exact account number match
                if (acc.length >= 5 && lowText.contains(acc)) return w
                // last 4 digits suffix match (e.g. *1234, ...1234, rek 1234)
                val suffix = if (acc.length >= 4) acc.substring(acc.length - 4) else acc
                val patterns = listOf(
                    Regex("""(?:rekening|rek\.?|a\/c|account|no\.?\s*rek)\s*(?:\*+|\.{2,}|x+)?\s*$suffix"""),
                    Regex("""(?:\*+|\.{2,}|x+)$suffix"""),
                )
                for (p in patterns) {
                    if (p.containsMatchIn(lowText)) return w
                }
            }
        }
        return null
    }

    private val providers: List<Pair<List<String>, List<String>>> = listOf(
        listOf("seabank", "bke", "digitalbank", "sea.bank") to listOf("seabank", "sea bank"),
        listOf("bcadigital", "blu") to listOf("blu"),
        listOf("mybca") to listOf("mybca", "bca"),
        listOf("bca") to listOf("bca"),
        listOf("mandiri", "livin") to listOf("mandiri", "livin"),
        listOf("jago") to listOf("jago"),
        listOf("krom") to listOf("krom"),
        listOf("brimo", "bri") to listOf("bri", "brimo"),
        listOf("wondr", "bni") to listOf("bni", "wondr"),
        listOf("bsi", "byond") to listOf("bsi", "byond"),
        listOf("bnc", "neobank", "bankneo") to listOf("neo", "bnc"),
        listOf("btpn", "jenius") to listOf("jenius", "btpn"),
        listOf("allo") to listOf("allo"),
        listOf("linebank") to listOf("line"),
        listOf("superbank", "bankfama") to listOf("superbank"),
        listOf("cimb", "octo") to listOf("cimb", "octo"),
        listOf("permata") to listOf("permata"),
        listOf("danamon", "dbank") to listOf("danamon", "d-bank", "dbank"),
        listOf("banksaqu") to listOf("saqu"),
        listOf("flip") to listOf("flip"),
        listOf("ovo") to listOf("ovo"),
        listOf("dana") to listOf("dana"),
        listOf("gojek", "gopay") to listOf("gopay", "gojek"),
        listOf("shopee") to listOf("shopee"),
        listOf("mwallet", "linkaja") to listOf("linkaja"),
    )

    private fun matchProvider(pkg: String, lowText: String, list: List<WalletEntry>): WalletEntry? {
        val lowPkg = pkg.lowercase()
        for ((pkgTokens, walletTokens) in providers) {
            if (pkgTokens.any { lowPkg.contains(it) }) {
                return list.firstOrNull { w ->
                    val name = w.name.lowercase()
                    walletTokens.any { k -> name.contains(k) || name.replace(" ", "").contains(k) }
                }
            }
        }
        for ((_, walletTokens) in providers) {
            if (walletTokens.any { lowText.contains(it) }) {
                val match = list.firstOrNull { w -> walletTokens.any { k -> w.name.lowercase().contains(k) } }
                if (match != null) return match
            }
        }
        return null
    }

    private suspend fun autoProvisionShopeePay(repository: FinanceRepository, activeProfileId: String?): WalletEntry {
        val now = nowMillis()
        val wallet = WalletEntry(
            id = UUID.randomUUID().toString(),
            profileId = activeProfileId,
            name = "ShopeePay",
            type = "ewallet",
            balance = 0.0,
            colorHex = "#EE4D2D",
            iconName = "shopping_bag",
            createdAt = now,
            updatedAt = now,
        )
        repository.insertWallet(wallet)
        return wallet
    }
}
