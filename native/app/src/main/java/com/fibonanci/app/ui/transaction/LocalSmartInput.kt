package com.fibonanci.app.ui.transaction

import androidx.compose.runtime.staticCompositionLocalOf
import com.fibonanci.app.core.smartinput.SmartInputBridge

// activity-bound smart input bridge, provided from MainActivity
val LocalSmartInput = staticCompositionLocalOf<SmartInputBridge> {
    error("LocalSmartInput not provided")
}
