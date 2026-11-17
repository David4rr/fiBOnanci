package com.fibonanci.app.ui.theme

import androidx.compose.material3.LocalContentColor
import androidx.compose.material3.LocalTextStyle
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Typography
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle

// flutter ColorScheme.dark() with primary/surface overridden; the m3 roles that flutter
// resolves through fallbacks (containers, variants, outline, inverse) are spelled out here
private val fibonanciColorScheme = darkColorScheme(
    primary = AppColors.neoChartreuse,
    onPrimary = Color.Black,
    primaryContainer = AppColors.neoChartreuse,
    onPrimaryContainer = Color.Black,
    inversePrimary = Color.Black,
    secondary = Color(0xFF03DAC6),
    onSecondary = Color.Black,
    secondaryContainer = Color(0xFF03DAC6),
    onSecondaryContainer = Color.Black,
    tertiary = Color(0xFF03DAC6),
    onTertiary = Color.Black,
    tertiaryContainer = Color(0xFF03DAC6),
    onTertiaryContainer = Color.Black,
    background = AppColors.canvasBg,
    onBackground = Color.White,
    surface = AppColors.canvasCardSurface,
    onSurface = Color.White,
    surfaceVariant = AppColors.canvasCardSurface,
    onSurfaceVariant = Color.White,
    surfaceTint = AppColors.neoChartreuse,
    inverseSurface = Color.White,
    inverseOnSurface = AppColors.canvasCardSurface,
    error = Color(0xFFCF6679),
    onError = Color.Black,
    errorContainer = Color(0xFFCF6679),
    onErrorContainer = Color.Black,
    outline = Color.White,
    outlineVariant = Color.White,
    scrim = Color.Black,
    surfaceBright = AppColors.canvasCardSurface,
    surfaceContainer = AppColors.canvasCardSurface,
    surfaceContainerHigh = AppColors.canvasCardSurface,
    surfaceContainerHighest = AppColors.canvasCardSurface,
    surfaceContainerLow = AppColors.canvasCardSurface,
    surfaceContainerLowest = AppColors.canvasCardSurface,
    surfaceDim = AppColors.canvasCardSurface,
)

private fun TextStyle.jakarta() = copy(fontFamily = PlusJakartaSans)

// google fonts plusJakartaSansTextTheme over the dark text theme
private val fibonanciTypography = Typography().let { base ->
    Typography(
        displayLarge = base.displayLarge.jakarta(),
        displayMedium = base.displayMedium.jakarta(),
        displaySmall = base.displaySmall.jakarta(),
        headlineLarge = base.headlineLarge.jakarta(),
        headlineMedium = base.headlineMedium.jakarta(),
        headlineSmall = base.headlineSmall.jakarta(),
        titleLarge = base.titleLarge.jakarta(),
        titleMedium = base.titleMedium.jakarta(),
        titleSmall = base.titleSmall.jakarta(),
        bodyLarge = base.bodyLarge.jakarta(),
        bodyMedium = base.bodyMedium.jakarta(),
        bodySmall = base.bodySmall.jakarta(),
        labelLarge = base.labelLarge.jakarta(),
        labelMedium = base.labelMedium.jakarta(),
        labelSmall = base.labelSmall.jakarta(),
    )
}

@Composable
fun FibonanciTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = fibonanciColorScheme,
        typography = fibonanciTypography,
    ) {
        // flutter's default text style is bodyMedium
        CompositionLocalProvider(
            LocalContentColor provides Color.White,
            LocalTextStyle provides fibonanciTypography.bodyMedium,
            content = content,
        )
    }
}
