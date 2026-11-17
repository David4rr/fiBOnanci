package com.fibonanci.app.ui.simple

import androidx.compose.material3.ExperimentalMaterial3ExpressiveApi
import androidx.compose.material3.MaterialExpressiveTheme
import androidx.compose.material3.MotionScheme
import androidx.compose.material3.Typography
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.ExperimentalTextApi
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.Font
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontVariation
import androidx.compose.ui.text.font.FontWeight
import com.fibonanci.app.R

// material 3 color roles built from the atelier palette: warm graphite surfaces, bone text,
// one muted brass accent, terracotta for anything destructive.
private val atelierColors = darkColorScheme(
    primary = Color(0xFFC2A878),
    onPrimary = Color(0xFF241B08),
    primaryContainer = Color(0xFF453819),
    onPrimaryContainer = Color(0xFFF1DFB8),
    inversePrimary = Color(0xFF6E5A2C),
    secondary = Color(0xFFD3CABB),
    onSecondary = Color(0xFF2B2721),
    secondaryContainer = Color(0xFF37322B),
    onSecondaryContainer = Color(0xFFEDE6D8),
    tertiary = Color(0xFFD9A088),
    onTertiary = Color(0xFF3A1C10),
    tertiaryContainer = Color(0xFF54301F),
    onTertiaryContainer = Color(0xFFFBDCCF),
    background = Color(0xFF0E0D0C),
    onBackground = Color(0xFFEAE4D9),
    surface = Color(0xFF0E0D0C),
    onSurface = Color(0xFFEAE4D9),
    surfaceVariant = Color(0xFF2A2724),
    onSurfaceVariant = Color(0xFFB4AC9F),
    surfaceTint = Color(0xFFC2A878),
    inverseSurface = Color(0xFFEAE4D9),
    inverseOnSurface = Color(0xFF2B2824),
    error = Color(0xFFE39A80),
    onError = Color(0xFF45180A),
    errorContainer = Color(0xFF5E2B1A),
    onErrorContainer = Color(0xFFFFDACD),
    outline = Color(0xFF8C857A),
    outlineVariant = Color(0xFF2A2724),
    scrim = Color(0xFF000000),
    surfaceBright = Color(0xFF2E2B27),
    surfaceDim = Color(0xFF0E0D0C),
    surfaceContainerLowest = Color(0xFF090807),
    surfaceContainerLow = Color(0xFF131210),
    surfaceContainer = Color(0xFF161513),
    surfaceContainerHigh = Color(0xFF1F1D1A),
    surfaceContainerHighest = Color(0xFF292622),
)

@OptIn(ExperimentalTextApi::class)
private fun variableFont(resId: Int) = FontFamily(
    listOf(400, 500, 600, 700, 800).map { w ->
        Font(resId, weight = FontWeight(w), variationSettings = FontVariation.Settings(FontVariation.weight(w)))
    }
)

object AtelierFonts {
    val inter = variableFont(R.font.inter)
    // money figures: monospaced so digits line up and never jitter while they change
    val mono = variableFont(R.font.geist_mono)
}

private fun TextStyle.inter() = copy(fontFamily = AtelierFonts.inter)

@OptIn(ExperimentalMaterial3ExpressiveApi::class)
private val atelierTypography = Typography().let { base ->
    Typography(
        displayLarge = base.displayLarge.inter(),
        displayMedium = base.displayMedium.inter(),
        displaySmall = base.displaySmall.inter(),
        headlineLarge = base.headlineLarge.inter(),
        headlineMedium = base.headlineMedium.inter(),
        headlineSmall = base.headlineSmall.inter(),
        titleLarge = base.titleLarge.inter(),
        titleMedium = base.titleMedium.inter(),
        titleSmall = base.titleSmall.inter(),
        bodyLarge = base.bodyLarge.inter(),
        bodyMedium = base.bodyMedium.inter(),
        bodySmall = base.bodySmall.inter(),
        labelLarge = base.labelLarge.inter(),
        labelMedium = base.labelMedium.inter(),
        labelSmall = base.labelSmall.inter(),
        displayLargeEmphasized = base.displayLargeEmphasized.inter(),
        displayMediumEmphasized = base.displayMediumEmphasized.inter(),
        displaySmallEmphasized = base.displaySmallEmphasized.inter(),
        headlineLargeEmphasized = base.headlineLargeEmphasized.inter(),
        headlineMediumEmphasized = base.headlineMediumEmphasized.inter(),
        headlineSmallEmphasized = base.headlineSmallEmphasized.inter(),
        titleLargeEmphasized = base.titleLargeEmphasized.inter(),
        titleMediumEmphasized = base.titleMediumEmphasized.inter(),
        titleSmallEmphasized = base.titleSmallEmphasized.inter(),
        bodyLargeEmphasized = base.bodyLargeEmphasized.inter(),
        bodyMediumEmphasized = base.bodyMediumEmphasized.inter(),
        bodySmallEmphasized = base.bodySmallEmphasized.inter(),
        labelLargeEmphasized = base.labelLargeEmphasized.inter(),
        labelMediumEmphasized = base.labelMediumEmphasized.inter(),
        labelSmallEmphasized = base.labelSmallEmphasized.inter(),
    )
}

// the iblameraihan look: stock material 3 expressive (springy motion, emphasized type, default shapes)
// with the atelier colors.
@OptIn(ExperimentalMaterial3ExpressiveApi::class)
@Composable
fun AtelierTheme(content: @Composable () -> Unit) {
    MaterialExpressiveTheme(
        colorScheme = atelierColors,
        motionScheme = MotionScheme.expressive(),
        typography = atelierTypography,
        content = content,
    )
}
