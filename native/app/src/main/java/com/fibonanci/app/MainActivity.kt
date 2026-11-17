package com.fibonanci.app

import android.content.Intent
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.SystemBarStyle
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.viewModels
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.fibonanci.app.core.notification.FibonanciNotificationListener
import com.fibonanci.app.core.notification.NotificationBridge
import com.fibonanci.app.core.security.SecurityVault
import com.fibonanci.app.core.smartinput.SmartInputBridge
import com.fibonanci.app.ui.FinanceViewModel
import com.fibonanci.app.ui.LocalFinance
import com.fibonanci.app.ui.AppRoot
import com.fibonanci.app.ui.common.IPhoneViewportContainer
import com.fibonanci.app.ui.common.LocalModalHost
import com.fibonanci.app.ui.common.ModalHost
import com.fibonanci.app.ui.theme.FibonanciTheme
import com.fibonanci.app.ui.transaction.LocalSmartInput
import kotlin.math.abs

class MainActivity : ComponentActivity() {
    private val vm: FinanceViewModel by viewModels()
    private lateinit var smartInput: SmartInputBridge

    override fun onCreate(savedInstanceState: Bundle?) {
        enableEdgeToEdge(
            statusBarStyle = SystemBarStyle.dark(android.graphics.Color.TRANSPARENT),
            navigationBarStyle = SystemBarStyle.dark(android.graphics.Color.TRANSPARENT),
        )
        super.onCreate(savedInstanceState)
        SecurityVault.applyPrivacyScreen(this, SecurityVault.isPrivacyScreenEnabled(this))
        NotificationBridge.ensureNotificationListenerBound(this)
        smartInput = SmartInputBridge(this)

        setContent {
            val state by vm.state.collectAsStateWithLifecycle()
            LaunchedEffect(state.isHighRefreshRate) { applyHighRefreshRate(state.isHighRefreshRate) }
            val host = remember { ModalHost() }

            FibonanciTheme {
                CompositionLocalProvider(
                    LocalFinance provides vm,
                    LocalModalHost provides host,
                    LocalSmartInput provides smartInput,
                ) {
                    IPhoneViewportContainer {
                        AppRoot()
                    }
                }
            }
        }
    }

    // picks the fastest (or the closest to 60hz) display mode at the current resolution
    private fun applyHighRefreshRate(enabled: Boolean) {
        val current = display?.mode ?: return
        val sameRes = display!!.supportedModes
            .filter { it.physicalWidth == current.physicalWidth && it.physicalHeight == current.physicalHeight }
        val target = if (enabled) sameRes.maxByOrNull { it.refreshRate } else sameRes.minByOrNull { abs(it.refreshRate - 60f) }
        if (target == null) return
        val params = window.attributes
        params.preferredDisplayModeId = target.modeId
        params.preferredRefreshRate = target.refreshRate
        window.attributes = params
    }

    override fun onResume() {
        super.onResume()
        FibonanciNotificationListener.isAppForeground = true
        NotificationBridge.ensureNotificationListenerBound(this)
    }

    override fun onPause() {
        FibonanciNotificationListener.isAppForeground = false
        super.onPause()
    }

    @Deprecated("needed for the confirm-device-credential fallback of the app lock")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (SecurityVault.onActivityResult(requestCode, resultCode)) return
        @Suppress("DEPRECATION")
        super.onActivityResult(requestCode, resultCode, data)
    }

    override fun onDestroy() {
        FibonanciNotificationListener.isAppForeground = false
        NotificationBridge.stopListening()
        smartInput.dispose()
        super.onDestroy()
    }
}
