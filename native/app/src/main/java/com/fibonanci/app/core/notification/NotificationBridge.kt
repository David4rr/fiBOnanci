package com.fibonanci.app.core.notification

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.provider.Settings
import android.service.notification.NotificationListenerService
import androidx.core.app.NotificationManagerCompat
import com.fibonanci.app.core.nowMillis
import com.fibonanci.app.data.FinanceRepository
import com.fibonanci.app.data.db.TransactionEntry
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.util.Locale
import java.util.UUID

data class InstalledApp(val packageName: String, val appName: String)

object NotificationBridge {
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main.immediate)
    private var isProcessingPending = false

    val pendingCountNotifier: StateFlow<Int> get() = NotificationInbox.pendingCount
    val pendingCount: Int get() = NotificationInbox.pendingCount.value

    fun isPermissionGranted(context: Context): Boolean = try {
        NotificationManagerCompat.getEnabledListenerPackages(context.applicationContext)
            .contains(context.applicationContext.packageName)
    } catch (_: Exception) {
        false
    }

    fun openPermissionSettings(context: Context) {
        try {
            val intent = Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS)
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            context.startActivity(intent)
        } catch (_: Exception) {
        }
    }

    // requests a rebind of the listener service when access is already granted
    fun ensureNotificationListenerBound(context: Context) {
        try {
            val app = context.applicationContext
            if (NotificationManagerCompat.getEnabledListenerPackages(app).contains(app.packageName)) {
                NotificationListenerService.requestRebind(ComponentName(app, FibonanciNotificationListener::class.java))
            }
        } catch (_: Exception) {
        }
    }

    fun getPendingRawNotifications(): List<Map<String, Any?>> = NotificationInbox.getPendingRawNotifications()
    fun removePendingNotification(raw: Map<String, Any?>) = NotificationInbox.removePendingNotification(raw)
    fun confirmNotification(item: Map<String, Any?>) = NotificationInbox.confirmNotification(item)
    suspend fun rejectNotification(item: Map<String, Any?>, repository: FinanceRepository) =
        NotificationInbox.rejectNotification(item, repository)
    fun clearPendingNotifications() = NotificationInbox.clearPendingNotifications()

    suspend fun syncAllowedPackages(context: Context, repository: FinanceRepository) {
        try {
            val activePackages = repository.getActiveNotificationPackages()
            FibonanciNotificationListener.setDynamicWhitelist(context.applicationContext, activePackages)
        } catch (_: Exception) {
        }
    }

    var cachedInstalledBankApps: List<InstalledApp>? = null
        private set

    suspend fun getInstalledBankApps(context: Context): List<InstalledApp> = try {
        val pm = context.applicationContext.packageManager
        val parsed = withContext(Dispatchers.IO) {
            try {
                pm.getInstalledApplications(0).map { app ->
                    InstalledApp(packageName = app.packageName, appName = pm.getApplicationLabel(app).toString())
                }
            } catch (_: Exception) {
                emptyList()
            }
        }.sortedBy { it.appName }
        if (parsed.isNotEmpty()) cachedInstalledBankApps = parsed
        parsed
    } catch (_: Exception) {
        cachedInstalledBankApps ?: emptyList()
    }

    fun startListening(
        context: Context,
        repository: FinanceRepository,
        onAutoLogged: ((String) -> Unit)? = null,
    ) {
        val app = context.applicationContext
        scope.launch {
            syncAllowedPackages(app, repository)
            processPendingNotifications(app, repository, onAutoLogged)
        }
        FibonanciNotificationListener.liveNotificationListener = { payload ->
            scope.launch { handleRawNotification(payload, repository, onAutoLogged) }
        }
    }

    fun onAppResumed(
        context: Context,
        repository: FinanceRepository,
        onAutoLogged: ((String) -> Unit)? = null,
    ) {
        val app = context.applicationContext
        scope.launch {
            syncAllowedPackages(app, repository)
            processPendingNotifications(app, repository, onAutoLogged)
        }
    }

    fun stopListening() {
        FibonanciNotificationListener.liveNotificationListener = null
    }

    private suspend fun processPendingNotifications(
        context: Context,
        repository: FinanceRepository,
        onAutoLogged: ((String) -> Unit)?,
    ) {
        if (isProcessingPending) return
        isProcessingPending = true
        try {
            val pending = withContext(Dispatchers.IO) { FibonanciNotificationListener.getAndClearPending(context) }
            for (item in pending) {
                handleRawNotification(item, repository, onAutoLogged)
            }
        } catch (_: Exception) {
        } finally {
            isProcessingPending = false
        }
    }

    suspend fun handleRawNotification(
        raw: Map<String, Any?>,
        repository: FinanceRepository,
        onAutoLogged: ((String) -> Unit)? = null,
    ) {
        val pkg = raw["package"] as? String ?: ""
        val title = raw["title"] as? String ?: ""
        val text = raw["text"] as? String ?: ""
        val ts = (raw["timestamp"] as? Number)?.toLong()

        val parsed = NotificationParser.parse(packageName = pkg, title = title, body = text, timestamp = ts) ?: return

        val targetWallet = NotificationWalletResolver.resolve(repository = repository, pkg = pkg, title = title, text = text)
            ?: return

        val categories = repository.getAllCategories()
        val defaultCat = categories.firstOrNull { it.type == parsed.type } ?: categories.first()
        val now = nowMillis()

        val externalRef = parsed.externalRef
        if (externalRef != null) {
            val existing = repository.findActiveTransactionsByExternalRef(externalRef)
            if (existing.isNotEmpty()) return
        }
        val txId = UUID.randomUUID().toString()
        repository.logTransactionWithBalanceMutation(
            TransactionEntry(
                id = txId,
                walletId = targetWallet.id,
                categoryId = defaultCat.id,
                amount = parsed.amount,
                type = parsed.type,
                notes = parsed.counterparty,
                source = "notification_auto",
                externalRef = externalRef,
                transactionDate = now,
                createdAt = now,
                updatedAt = now,
            ),
        )

        syncBalanceSnapshotIfPresent(text, repository, targetWallet.id)

        var profileName: String? = null
        val profileId = targetWallet.profileId
        if (profileId != null) {
            val prof = repository.getProfileById(profileId)
            profileName = prof?.fullName ?: prof?.username
        }

        val inboxItem = raw.toMutableMap()
        inboxItem["transactionId"] = txId
        inboxItem["amount"] = parsed.amount
        inboxItem["type"] = parsed.type
        inboxItem["counterparty"] = parsed.counterparty
        inboxItem["walletName"] = targetWallet.name
        inboxItem["walletId"] = targetWallet.id
        inboxItem["profileId"] = targetWallet.profileId
        inboxItem["profileName"] = profileName

        NotificationInbox.addPending(inboxItem)
        val prefix = if (profileName != null) "[$profileName] ${targetWallet.name}" else targetWallet.name
        val sign = if (parsed.type == "income") "+" else "-"
        val amountText = String.format(Locale.US, "%.0f", parsed.amount)
        onAutoLogged?.invoke("$prefix: ${sign}Rp $amountText (${parsed.counterparty})")
    }

    // fire-and-forget like the dart version
    private fun syncBalanceSnapshotIfPresent(text: String, repository: FinanceRepository, walletId: String) {
        scope.launch {
            val exactBal = NotificationTextSanitizer.extractBalance(text)
            if (exactBal != null && exactBal > 0) {
                repository.updateWalletBalance(walletId, exactBal)
            }
        }
    }
}
