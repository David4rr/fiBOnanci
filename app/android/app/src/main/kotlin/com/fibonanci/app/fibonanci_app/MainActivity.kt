package com.fibonanci.app.fibonanci_app

import android.app.DownloadManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.Settings
import android.service.notification.NotificationListenerService
import androidx.core.app.NotificationManagerCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val METHOD_CHANNEL = "com.fibonanci.app/notification_service"
    private val EVENT_CHANNEL = "com.fibonanci.app/live_notifications"
    private val SMART_INPUT_CHANNEL = "com.fibonanci.app/smart_input"
    private lateinit var smartInputHelper: SmartInputHelper
    private var pendingAuthCallback: ((Boolean) -> Unit)? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        applyHighRefreshRate(true)
        SecurityVaultHelper.applyPrivacyScreen(
            this,
            SecurityVaultHelper.isPrivacyScreenEnabled(applicationContext)
        )
        ensureNotificationListenerBound()
        smartInputHelper = SmartInputHelper(this)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getDatabaseEncryptionKey" -> {
                    result.success(SecurityVaultHelper.getOrCreateDatabaseKey(applicationContext))
                }
                "getSecuritySettings" -> {
                    result.success(
                        mapOf(
                            "biometricLockEnabled" to SecurityVaultHelper.isBiometricLockEnabled(applicationContext),
                            "privacyScreenEnabled" to SecurityVaultHelper.isPrivacyScreenEnabled(applicationContext),
                            "isDeviceSecure" to SecurityVaultHelper.isDeviceSecure(applicationContext)
                        )
                    )
                }
                "setBiometricLockEnabled" -> {
                    val enabled = call.argument<Boolean>("enabled") ?: false
                    SecurityVaultHelper.setBiometricLockEnabled(applicationContext, enabled)
                    result.success(true)
                }
                "setPrivacyScreenEnabled" -> {
                    val enabled = call.argument<Boolean>("enabled") ?: false
                    SecurityVaultHelper.applyPrivacyScreen(this, enabled)
                    result.success(true)
                }
                "authenticateBiometric" -> {
                    val reason = call.argument<String>("reason") ?: "Gunakan sidik jari atau PIN untuk membuka fiBOnanci"
                    SecurityVaultHelper.authenticateUser(
                        this,
                        reason,
                        onResult = { ok -> runOnUiThread { result.success(ok) } },
                        registerPendingResult = { cb -> pendingAuthCallback = cb }
                    )
                }
                "setHighRefreshRate" -> {
                    val enabled = call.argument<Boolean>("enabled") ?: true
                    applyHighRefreshRate(enabled)
                    result.success(true)
                }
                "isPermissionGranted" -> {
                    val enabledPackages = NotificationManagerCompat.getEnabledListenerPackages(applicationContext)
                    val isGranted = enabledPackages.contains(applicationContext.packageName)
                    result.success(isGranted)
                }
                "openPermissionSettings" -> {
                    try {
                        val intent = Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS)
                        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        try {
                            val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                                data = Uri.fromParts("package", packageName, null)
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            }
                            startActivity(intent)
                            result.success(true)
                        } catch (e2: Exception) {
                            result.success(false)
                        }
                    }
                }
                "downloadApk" -> {
                    val url = call.argument<String>("url")
                    val fileName = call.argument<String>("fileName") ?: "fiBOnanci-update.apk"
                    if (!url.isNullOrBlank()) {
                        val ok = downloadApkViaDownloadManager(url, fileName)
                        result.success(ok)
                    } else {
                        result.success(false)
                    }
                }
                "getDeviceAbi" -> {
                    val abi = Build.SUPPORTED_ABIS.firstOrNull() ?: "arm64-v8a"
                    result.success(abi)
                }
                "openUrl" -> {
                    val url = call.argument<String>("url")
                    if (!url.isNullOrBlank()) {
                        if (isApkUrl(url)) {
                            val fileName = url.substringAfterLast("/").substringBefore("?").ifBlank { "fiBOnanci-update.apk" }
                            if (downloadApkViaDownloadManager(url, fileName)) {
                                result.success(true)
                                return@setMethodCallHandler
                            }
                        }
                        try {
                            val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
                            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            startActivity(intent)
                            result.success(true)
                        } catch (_: Exception) {
                            result.success(false)
                        }
                    } else {
                        result.success(false)
                    }
                }
                "getPendingNotifications" -> {
                    val pending = FibonanciNotificationListener.getAndClearPending(applicationContext)
                    result.success(pending)
                }
                "updateAllowedPackages" -> {
                    val packages = call.argument<List<String>>("packages") ?: emptyList()
                    FibonanciNotificationListener.setDynamicWhitelist(applicationContext, packages)
                    result.success(true)
                }
                "getInstalledBankApps" -> {
                    val pm = packageManager
                    Thread {
                        try {
                            val installed = pm.getInstalledApplications(0)
                            val bankApps = ArrayList<Map<String, String>>(installed.size)
                            for (app in installed) {
                                val pkg = app.packageName
                                val label = pm.getApplicationLabel(app).toString()
                                bankApps.add(mapOf("packageName" to pkg, "appName" to label))
                            }
                            bankApps.sortBy { it["appName"]?.lowercase() ?: "" }
                            runOnUiThread { result.success(bankApps) }
                        } catch (_: Exception) {
                            runOnUiThread { result.success(emptyList<Map<String, String>>()) }
                        }
                    }.start()
                }
                else -> result.notImplemented()
            }
        }

        // 2. EventChannel for Live Real-Time Notifications
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    FibonanciNotificationListener.liveNotificationListener = { payload ->
                        runOnUiThread {
                            events?.success(payload)
                        }
                    }
                }

                override fun onCancel(arguments: Any?) {
                    FibonanciNotificationListener.liveNotificationListener = null
                }
            }
        )

        // 3. MethodChannel for On-Device Voice & Photo OCR Smart Input
        val smartChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SMART_INPUT_CHANNEL)
        smartInputHelper.attachChannel(smartChannel)
        smartChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "startListening" -> {
                    val locale = call.argument<String>("locale") ?: "id-ID"
                    smartInputHelper.startHeadlessListening(locale, result)
                }
                "stopListening" -> {
                    smartInputHelper.stopHeadlessListening(result)
                }
                "cancelListening" -> {
                    smartInputHelper.cancelHeadlessListening(result)
                }
                "recognizeImageText" -> {
                    val path = call.argument<String>("path")
                    if (path.isNullOrBlank()) {
                        result.success(null)
                    } else {
                        smartInputHelper.recognizeImageText(path, result)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun isApkUrl(url: String): Boolean {
        val clean = url.substringBefore("?").lowercase()
        return clean.endsWith(".apk")
    }

    private fun downloadApkViaDownloadManager(url: String, fileName: String): Boolean {
        return try {
            val downloadManager = getSystemService(Context.DOWNLOAD_SERVICE) as? DownloadManager ?: return false
            val uri = Uri.parse(url)
            val request = DownloadManager.Request(uri).apply {
                setTitle("Pembaruan fiBOnanci")
                setDescription("Mengunduh $fileName...")
                setNotificationVisibility(DownloadManager.Request.VISIBILITY_VISIBLE_NOTIFY_COMPLETED)
                setDestinationInExternalPublicDir(Environment.DIRECTORY_DOWNLOADS, fileName)
                setMimeType("application/vnd.android.package-archive")
                setAllowedOverMetered(true)
                setAllowedOverRoaming(true)
            }
            downloadManager.enqueue(request)
            true
        } catch (_: Exception) {
            false
        }
    }

    private fun applyHighRefreshRate(enabled: Boolean) {
        try {
            @Suppress("DEPRECATION")
            val d = windowManager.defaultDisplay ?: return
            val modes = d.supportedModes
            if (modes.isEmpty()) return
            val cur = d.mode
            val sameRes = modes.filter { it.physicalWidth == cur.physicalWidth && it.physicalHeight == cur.physicalHeight }.ifEmpty { modes.toList() }
            val target = if (enabled) sameRes.maxByOrNull { it.refreshRate } else sameRes.minByOrNull { kotlin.math.abs(it.refreshRate - 60f) }
            if (target != null) {
                val params = window.attributes
                params.preferredDisplayModeId = target.modeId
                params.preferredRefreshRate = target.refreshRate
                window.attributes = params
            }
        } catch (_: Exception) {}
    }
    private fun ensureNotificationListenerBound() {
        try {
            val enabledPackages = NotificationManagerCompat.getEnabledListenerPackages(applicationContext)
            if (enabledPackages.contains(applicationContext.packageName)) {
                NotificationListenerService.requestRebind(
                    ComponentName(applicationContext, FibonanciNotificationListener::class.java)
                )
            }
        } catch (_: Exception) {}
    }

    override fun onResume() {
        super.onResume()
        FibonanciNotificationListener.isAppForeground = true
        ensureNotificationListenerBound()
    }

    override fun onPause() {
        FibonanciNotificationListener.isAppForeground = false
        super.onPause()
    }

    @Suppress("DEPRECATION")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode == SecurityVaultHelper.REQUEST_CONFIRM_CREDENTIAL) {
            val cb = pendingAuthCallback
            pendingAuthCallback = null
            cb?.invoke(resultCode == RESULT_OK)
            return
        }
        super.onActivityResult(requestCode, resultCode, data)
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        if (::smartInputHelper.isInitialized &&
            smartInputHelper.onRequestPermissionsResult(requestCode, grantResults)
        ) {
            return
        }
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
    }

    override fun onDestroy() {
        FibonanciNotificationListener.isAppForeground = false
        FibonanciNotificationListener.liveNotificationListener = null
        if (::smartInputHelper.isInitialized) {
            smartInputHelper.dispose()
        }
        super.onDestroy()
    }
}
