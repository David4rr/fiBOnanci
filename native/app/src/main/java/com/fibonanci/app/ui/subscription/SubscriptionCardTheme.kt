package com.fibonanci.app.ui.subscription

import androidx.compose.ui.graphics.Color
import com.fibonanci.app.ui.wallet.ModernistCardTheme
import kotlin.math.abs

enum class CardBadgeType { mastercard, jcb, gpay, amex, chip, diners }

data class SubscriptionCardThemeConfig(
    val backgroundColor: Color,
    val primaryGraphicColor: Color,
    val secondaryGraphicColor: Color,
    val textColor: Color,
    val badgeColor: Color,
    val networkBadgeText: String,
    val badgeType: CardBadgeType,
) {
    companion object {
        fun forTheme(theme: ModernistCardTheme): SubscriptionCardThemeConfig = when (theme) {
            ModernistCardTheme.streamingCinematic -> SubscriptionCardThemeConfig(
                Color(0xFF1E1418), Color(0xFFE50914), Color(0xFFFF5252), Color(0xFFFFFFFF),
                Color(0xFFE50914), "PREMIUM", CardBadgeType.mastercard,
            )
            ModernistCardTheme.audioEmerald -> SubscriptionCardThemeConfig(
                Color(0xFF7CB88D), Color(0xFF183820), Color(0xFF67A578), Color(0xFF0F2615),
                Color(0xFF0F2615), "AUDIO PASS", CardBadgeType.chip,
            )
            ModernistCardTheme.utilitiesLemon -> SubscriptionCardThemeConfig(
                Color(0xFFF3F76E), Color(0xFFE2E658), Color(0xFF20221A), Color(0xFF1A1C16),
                Color(0xFF1A1C16), "UTILITY", CardBadgeType.jcb,
            )
            ModernistCardTheme.fiberInternet -> SubscriptionCardThemeConfig(
                Color(0xFF9EACF0), Color(0xFF1E2856), Color(0xFF8697E6), Color(0xFF151C3E),
                Color(0xFF151C3E), "INTERNET", CardBadgeType.gpay,
            )
            ModernistCardTheme.aiCloudProductivity -> SubscriptionCardThemeConfig(
                Color(0xFFE5E3DC), Color(0xFFE84E38), Color(0xFFE84E38), Color(0xFF181A1E),
                Color(0xFF181A1E), "PRO CLOUD", CardBadgeType.mastercard,
            )
            ModernistCardTheme.housingLiving -> SubscriptionCardThemeConfig(
                Color(0xFF56626A), Color(0xFF455057), Color(0xFF75838B), Color(0xFFFFFFFF),
                Color(0xFFFFFFFF), "HOUSING", CardBadgeType.amex,
            )
            ModernistCardTheme.fitnessLifestyle -> SubscriptionCardThemeConfig(
                Color(0xFFF0715B), Color(0xFFE05640), Color(0xFFF89280), Color(0xFFFFFFFF),
                Color(0xFFFFFFFF), "FITNESS", CardBadgeType.mastercard,
            )
            ModernistCardTheme.recurringSmartBill -> SubscriptionCardThemeConfig(
                Color(0xFFDDD9D0), Color(0xFF333333), Color(0xFF555555), Color(0xFF222222),
                Color(0xFF222222), "RECURRING", CardBadgeType.chip,
            )
            ModernistCardTheme.tokyoMidnight -> SubscriptionCardThemeConfig(
                Color(0xFF0D1326), Color(0xFF3B82F6), Color(0xFF60A5FA), Color(0xFFE2E8F0),
                Color(0xFF3B82F6), "MIDNIGHT", CardBadgeType.jcb,
            )
            ModernistCardTheme.solarAmber -> SubscriptionCardThemeConfig(
                Color(0xFFF59E0B), Color(0xFFB45309), Color(0xFFFDE68A), Color(0xFF451A03),
                Color(0xFF78350F), "SOLAR", CardBadgeType.diners,
            )
            ModernistCardTheme.arcticGlacier -> SubscriptionCardThemeConfig(
                Color(0xFFE0F2FE), Color(0xFF0284C7), Color(0xFFBAE6FD), Color(0xFF0C4A6E),
                Color(0xFF0369A1), "GLACIER", CardBadgeType.chip,
            )
            ModernistCardTheme.cyberNeon -> SubscriptionCardThemeConfig(
                Color(0xFF1E1035), Color(0xFFEC4899), Color(0xFF06B6D4), Color(0xFFFDF4FF),
                Color(0xFFEC4899), "CYBER", CardBadgeType.gpay,
            )
            ModernistCardTheme.matchaZen -> SubscriptionCardThemeConfig(
                Color(0xFFD1E7D0), Color(0xFF3B6E44), Color(0xFFA3D1A5), Color(0xFF1B3821),
                Color(0xFF2E5936), "MATCHA", CardBadgeType.chip,
            )
            ModernistCardTheme.terracottaSunset -> SubscriptionCardThemeConfig(
                Color(0xFF993D29), Color(0xFFFDBA74), Color(0xFFEA580C), Color(0xFFFFF7ED),
                Color(0xFFFDBA74), "SUNSET", CardBadgeType.amex,
            )
            ModernistCardTheme.monochromeStark -> SubscriptionCardThemeConfig(
                Color(0xFF18181B), Color(0xFFFAFAFA), Color(0xFF71717A), Color(0xFFFAFAFA),
                Color(0xFFFAFAFA), "BAUHAUS", CardBadgeType.chip,
            )
            ModernistCardTheme.lavenderDusk -> SubscriptionCardThemeConfig(
                Color(0xFFDDD6FE), Color(0xFF6D28D9), Color(0xFFC4B5FD), Color(0xFF3B0764),
                Color(0xFF5B21B6), "LAVENDER", CardBadgeType.jcb,
            )
            ModernistCardTheme.cobaltVault -> SubscriptionCardThemeConfig(
                Color(0xFF1D4ED8), Color(0xFF93C5FD), Color(0xFF3B82F6), Color(0xFFEFF6FF),
                Color(0xFFDBEAFE), "COBALT", CardBadgeType.diners,
            )
            ModernistCardTheme.blushPop -> SubscriptionCardThemeConfig(
                Color(0xFFFCE7F3), Color(0xFFDB2777), Color(0xFFF472B6), Color(0xFF831843),
                Color(0xFFBE185D), "BLUSH", CardBadgeType.gpay,
            )
            ModernistCardTheme.nordicPine -> SubscriptionCardThemeConfig(
                Color(0xFF143026), Color(0xFF34D399), Color(0xFF059669), Color(0xFFECFDF5),
                Color(0xFF10B981), "NORDIC", CardBadgeType.chip,
            )
            ModernistCardTheme.copperPatina -> SubscriptionCardThemeConfig(
                Color(0xFF78350F), Color(0xFFF59E0B), Color(0xFF2DD4BF), Color(0xFFFEF3C7),
                Color(0xFFF59E0B), "COPPER", CardBadgeType.amex,
            )
        }

        fun forDynamic(
            theme: ModernistCardTheme,
            index: Int,
            seedId: String,
            walletName: String? = null,
            isInstallment: Boolean = false,
        ): SubscriptionCardThemeConfig {
            val baseConfig = forTheme(theme)
            val networkName = walletName?.uppercase() ?: (if (isInstallment) "CICILAN" else baseConfig.networkBadgeText)
            if (index < 20) return baseConfig.copy(networkBadgeText = networkName)

            val goldenHue = ((210.0 + index * 137.508 + (abs(seedId.hashCode()) % 29)) % 360.0).toFloat()
            val isDark = index % 2 == 0
            val bg = if (isDark) Color.hsl(goldenHue, 0.62f, 0.16f) else Color.hsl(goldenHue, 0.76f, 0.78f)
            val primaryG = if (isDark) Color.hsl((goldenHue + 35) % 360, 0.85f, 0.62f)
            else Color.hsl((goldenHue + 45) % 360, 0.80f, 0.32f)
            val secondaryG = if (isDark) Color.hsl((goldenHue + 175) % 360, 0.70f, 0.48f)
            else Color.hsl((goldenHue + 155) % 360, 0.65f, 0.42f)
            val txt = if (isDark) Color.White else Color(0xFF0A0B0E)

            return SubscriptionCardThemeConfig(
                backgroundColor = bg,
                primaryGraphicColor = primaryG,
                secondaryGraphicColor = secondaryG,
                textColor = txt,
                badgeColor = txt,
                networkBadgeText = networkName,
                badgeType = CardBadgeType.entries[index % CardBadgeType.entries.size],
            )
        }
    }
}
