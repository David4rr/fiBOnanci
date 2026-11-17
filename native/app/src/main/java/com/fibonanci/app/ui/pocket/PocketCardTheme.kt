package com.fibonanci.app.ui.pocket

import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.luminance
import com.fibonanci.app.data.db.PocketEntry
import com.fibonanci.app.ui.theme.AppColors
import kotlin.math.abs

// dynamic theme configuration for kantong tabungan (savings pockets).
// guarantees that every card looks unique even when dozens of pockets exist.
data class PocketCardThemeConfig(
    val backgroundColor: Color,
    val primaryTextColor: Color,
    val secondaryTextColor: Color,
    val tertiaryTextColor: Color,
    val iconColor: Color,
    val iconBgColor: Color,
) {
    companion object {
        // curated solid flat neo-pastel & vibrant colors (no gradients).
        private val curatedSeeds = listOf(
            Color(0xFFD4F442), // neo-chartreuse
            Color(0xFF7DF24E), // neo-mint
            Color(0xFF26D9D9), // neo-cyan
            Color(0xFFFF7052), // neo-coral
            Color(0xFFA855F7), // amethyst
            Color(0xFF3B82F6), // electric cobalt
            Color(0xFFF59E0B), // solar amber
            Color(0xFFEC4899), // cyber pink
            Color(0xFF10B981), // emerald
            Color(0xFF8B5CF6), // royal purple
            Color(0xFF06B6D4), // glacier aqua
            Color(0xFFF97316), // vivid tangerine
        )

        // resolves a solid flat theme (no gradient) for a savings pocket.
        fun resolve(pocket: PocketEntry, index: Int, allPockets: List<PocketEntry>? = null): PocketCardThemeConfig {
            val effectiveIndex = if (!allPockets.isNullOrEmpty()) allPockets.indexOfFirst { it.id == pocket.id } else index
            val i = if (effectiveIndex >= 0) effectiveIndex else index

            val goldenHue = ((145.0 + (i * 137.508) + (abs(pocket.id.hashCode()) % 19)) % 360.0).toFloat()
            val solidColor = if (i < curatedSeeds.size) curatedSeeds[i] else Color.hsl(goldenHue, 0.78f, 0.72f)

            if (isDarkColor(solidColor)) {
                return PocketCardThemeConfig(
                    backgroundColor = solidColor,
                    primaryTextColor = AppColors.textWhite,
                    secondaryTextColor = Color.White.copy(alpha = 0.95f),
                    tertiaryTextColor = Color.White.copy(alpha = 0.75f),
                    iconColor = AppColors.textWhite,
                    iconBgColor = Color.White.copy(alpha = 0.18f),
                )
            }
            return PocketCardThemeConfig(
                backgroundColor = solidColor,
                primaryTextColor = AppColors.textDarkPrimary,
                secondaryTextColor = AppColors.textDarkPrimary,
                tertiaryTextColor = AppColors.textDarkSecondary,
                iconColor = AppColors.textDarkPrimary,
                iconBgColor = AppColors.cardIconBadgeBg,
            )
        }
    }
}

// same rule as flutter's ThemeData.estimateBrightnessForColor.
internal fun isDarkColor(color: Color): Boolean {
    val l = color.luminance() + 0.05f
    return l * l <= 0.15f
}
