package com.fibonanci.app.fibonanci_app

import android.content.Intent
import android.provider.Settings
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

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        applyHighRefreshRate(true)
        smartInputHelper = SmartInputHelper(this)
        // 1. MethodChannel for Permission, 120Hz Display Mode & Pending Queue
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
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
                    val intent = Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS)
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    startActivity(intent)
                    result.success(true)
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
                    try {
                        val pm = packageManager
                        val installed = pm.getInstalledApplications(0)
                        val bankApps = mutableListOf<Map<String, String>>()
                        for (app in installed) {
                            val pkg = app.packageName
                            val label = pm.getApplicationLabel(app).toString()
                            bankApps.add(mapOf("packageName" to pkg, "appName" to label))
                        }
                        result.success(bankApps)
                    } catch (_: Exception) {
                        result.success(emptyList<Map<String, String>>())
                    }
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
        if (::smartInputHelper.isInitialized) {
            smartInputHelper.dispose()
        }
        super.onDestroy()
    }
}
