package com.fibonanci.app.ui.wallet

import androidx.compose.ui.graphics.Color

// preset theme for the swiss-editorial modernist cards
enum class ModernistCardTheme {
    streamingCinematic,
    audioEmerald,
    utilitiesLemon,
    fiberInternet,
    aiCloudProductivity,
    housingLiving,
    fitnessLifestyle,
    recurringSmartBill,
    tokyoMidnight,
    solarAmber,
    arcticGlacier,
    cyberNeon,
    matchaZen,
    terracottaSunset,
    monochromeStark,
    lavenderDusk,
    cobaltVault,
    blushPop,
    nordicPine,
    copperPatina,
}

// unified configuration for modernist cards matching the physical atm reference
data class ModernistCardConfig(
    val backgroundColor: Color,
    val primaryGraphicColor: Color,
    val secondaryGraphicColor: Color,
    val textColor: Color,
    val badgeColor: Color,
    val networkBadgeText: String,
) {
    companion object {
        fun forTheme(theme: ModernistCardTheme): ModernistCardConfig = when (theme) {
            ModernistCardTheme.streamingCinematic -> ModernistCardConfig(
                Color(0xFF1E1418), Color(0xFFE50914), Color(0xFFFF5252), Color(0xFFFFFFFF), Color(0xFFE50914), "STREAMING",
            )
            ModernistCardTheme.audioEmerald -> ModernistCardConfig(
                Color(0xFF7CB88D), Color(0xFF183820), Color(0xFF67A578), Color(0xFF0F2615), Color(0xFF0F2615), "AUDIO",
            )
            ModernistCardTheme.utilitiesLemon -> ModernistCardConfig(
                Color(0xFFF3F76E), Color(0xFFE2E658), Color(0xFF20221A), Color(0xFF1A1C16), Color(0xFF1A1C16), "UTILITY",
            )
            ModernistCardTheme.fiberInternet -> ModernistCardConfig(
                Color(0xFF9EACF0), Color(0xFF1E2856), Color(0xFF8697E6), Color(0xFF151C3E), Color(0xFF151C3E), "INTERNET",
            )
            ModernistCardTheme.aiCloudProductivity -> ModernistCardConfig(
                Color(0xFFE5E3DC), Color(0xFFE84E38), Color(0xFFE84E38), Color(0xFF181A1E), Color(0xFF181A1E), "PRO CLOUD",
            )
            ModernistCardTheme.housingLiving -> ModernistCardConfig(
                Color(0xFF56626A), Color(0xFF455057), Color(0xFF75838B), Color(0xFFFFFFFF), Color(0xFFFFFFFF), "HOUSING",
            )
            ModernistCardTheme.fitnessLifestyle -> ModernistCardConfig(
                Color(0xFFF0715B), Color(0xFFE05640), Color(0xFFF89280), Color(0xFFFFFFFF), Color(0xFFFFFFFF), "FITNESS",
            )
            ModernistCardTheme.recurringSmartBill -> ModernistCardConfig(
                Color(0xFFDDD9D0), Color(0xFF333333), Color(0xFF555555), Color(0xFF222222), Color(0xFF222222), "RECURRING",
            )
            ModernistCardTheme.tokyoMidnight -> ModernistCardConfig(
                Color(0xFF0D1326), Color(0xFF3B82F6), Color(0xFF60A5FA), Color(0xFFE2E8F0), Color(0xFF3B82F6), "MIDNIGHT",
            )
            ModernistCardTheme.solarAmber -> ModernistCardConfig(
                Color(0xFFF59E0B), Color(0xFFB45309), Color(0xFFFDE68A), Color(0xFF451A03), Color(0xFF78350F), "SOLAR",
            )
            ModernistCardTheme.arcticGlacier -> ModernistCardConfig(
                Color(0xFFE0F2FE), Color(0xFF0284C7), Color(0xFFBAE6FD), Color(0xFF0C4A6E), Color(0xFF0369A1), "GLACIER",
            )
            ModernistCardTheme.cyberNeon -> ModernistCardConfig(
                Color(0xFF1E1035), Color(0xFFEC4899), Color(0xFF06B6D4), Color(0xFFFDF4FF), Color(0xFFEC4899), "CYBER",
            )
            ModernistCardTheme.matchaZen -> ModernistCardConfig(
                Color(0xFFD1E7D0), Color(0xFF3B6E44), Color(0xFFA3D1A5), Color(0xFF1B3821), Color(0xFF2E5936), "MATCHA",
            )
            ModernistCardTheme.terracottaSunset -> ModernistCardConfig(
                Color(0xFF993D29), Color(0xFFFDBA74), Color(0xFFEA580C), Color(0xFFFFF7ED), Color(0xFFFDBA74), "SUNSET",
            )
            ModernistCardTheme.monochromeStark -> ModernistCardConfig(
                Color(0xFF18181B), Color(0xFFFAFAFA), Color(0xFF71717A), Color(0xFFFAFAFA), Color(0xFFFAFAFA), "BAUHAUS",
            )
            ModernistCardTheme.lavenderDusk -> ModernistCardConfig(
                Color(0xFFDDD6FE), Color(0xFF6D28D9), Color(0xFFC4B5FD), Color(0xFF3B0764), Color(0xFF5B21B6), "LAVENDER",
            )
            ModernistCardTheme.cobaltVault -> ModernistCardConfig(
                Color(0xFF1D4ED8), Color(0xFF93C5FD), Color(0xFF3B82F6), Color(0xFFEFF6FF), Color(0xFFDBEAFE), "COBALT",
            )
            ModernistCardTheme.blushPop -> ModernistCardConfig(
                Color(0xFFFCE7F3), Color(0xFFDB2777), Color(0xFFF472B6), Color(0xFF831843), Color(0xFFBE185D), "BLUSH",
            )
            ModernistCardTheme.nordicPine -> ModernistCardConfig(
                Color(0xFF143026), Color(0xFF34D399), Color(0xFF059669), Color(0xFFECFDF5), Color(0xFF10B981), "NORDIC",
            )
            ModernistCardTheme.copperPatina -> ModernistCardConfig(
                Color(0xFF78350F), Color(0xFFF59E0B), Color(0xFF2DD4BF), Color(0xFFFEF3C7), Color(0xFFF59E0B), "COPPER",
            )
        }
    }
}
