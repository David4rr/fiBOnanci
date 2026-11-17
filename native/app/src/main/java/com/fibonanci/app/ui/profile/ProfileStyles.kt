package com.fibonanci.app.ui.profile

import androidx.compose.animation.core.CubicBezierEasing
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.TextUnit
import androidx.compose.ui.unit.sp
import com.fibonanci.app.ui.theme.PlusJakartaSans

// flutter curve constants used by the profile screens
internal object FlutterCurves {
    val easeOutCubic = CubicBezierEasing(0.215f, 0.61f, 0.355f, 1f)
    val easeInCubic = CubicBezierEasing(0.55f, 0.055f, 0.675f, 0.19f)
    val easeInOut = CubicBezierEasing(0.42f, 0f, 0.58f, 1f)
    val easeOutBack = CubicBezierEasing(0.175f, 0.885f, 0.32f, 1.275f)
    val smoothPage = CubicBezierEasing(0.22f, 1f, 0.36f, 1f)
}

// google fonts plus jakarta sans text style
internal fun jakarta(
    fontSize: TextUnit,
    fontWeight: FontWeight = FontWeight.Normal,
    color: Color = Color.Unspecified,
    letterSpacing: TextUnit = 0.sp,
    tabular: Boolean = false,
): TextStyle = TextStyle(
    fontFamily = PlusJakartaSans,
    fontSize = fontSize,
    fontWeight = fontWeight,
    color = color,
    letterSpacing = letterSpacing,
    fontFeatureSettings = if (tabular) "tnum" else null,
)
