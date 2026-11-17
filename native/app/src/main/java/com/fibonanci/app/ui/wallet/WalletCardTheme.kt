package com.fibonanci.app.ui.wallet

import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.luminance
import com.fibonanci.app.data.db.WalletEntry
import kotlin.math.abs

// complete dynamic palette of all 20 curated themes, ordered for maximum visual contrast
val kDynamicModernistThemes: List<ModernistCardTheme> = listOf(
    ModernistCardTheme.fiberInternet,
    ModernistCardTheme.utilitiesLemon,
    ModernistCardTheme.streamingCinematic,
    ModernistCardTheme.aiCloudProductivity,
    ModernistCardTheme.tokyoMidnight,
    ModernistCardTheme.fitnessLifestyle,
    ModernistCardTheme.audioEmerald,
    ModernistCardTheme.solarAmber,
    ModernistCardTheme.monochromeStark,
    ModernistCardTheme.arcticGlacier,
    ModernistCardTheme.copperPatina,
    ModernistCardTheme.cyberNeon,
    ModernistCardTheme.recurringSmartBill,
    ModernistCardTheme.cobaltVault,
    ModernistCardTheme.matchaZen,
    ModernistCardTheme.terracottaSunset,
    ModernistCardTheme.lavenderDusk,
    ModernistCardTheme.housingLiving,
    ModernistCardTheme.blushPop,
    ModernistCardTheme.nordicPine,
)

private fun accentFor(theme: ModernistCardTheme): Color {
    val config = ModernistCardConfig.forTheme(theme)
    return if (config.backgroundColor.luminance() < 0.35f) config.primaryGraphicColor else config.backgroundColor
}

// curated list of wallet accent colors matching the expanded dynamic themes
val kWalletColors: List<Color> = kDynamicModernistThemes.map { accentFor(it) }

fun getWalletColor(index: Int, colorHex: String? = null): Color {
    if (colorHex != null && colorHex != "#10B981" && colorHex != "#10b981") {
        val parsed = ("FF" + colorHex.replaceFirst("#", "")).toLongOrNull(16)
        if (parsed != null) return Color(parsed.toInt())
    }
    return accentFor(kDynamicModernistThemes[abs(index) % kDynamicModernistThemes.size])
}

fun resolveWalletTheme(
    wallet: WalletEntry,
    index: Int,
    allWallets: List<WalletEntry>? = null,
    explicitTheme: ModernistCardTheme? = null,
): ModernistCardTheme {
    if (explicitTheme != null) return explicitTheme

    if (!allWallets.isNullOrEmpty()) {
        val walletIdx = allWallets.indexOfFirst { it.id == wallet.id }
        val effectiveIdx = if (walletIdx >= 0) walletIdx else index
        return kDynamicModernistThemes[abs(effectiveIdx) % kDynamicModernistThemes.size]
    }

    return kDynamicModernistThemes[abs(index) % kDynamicModernistThemes.size]
}

fun resolveWalletNetworkBadge(wallet: WalletEntry, theme: ModernistCardTheme): String =
    when (wallet.type.lowercase()) {
        "ewallet" -> "E-WALLET"
        "cash" -> "KAS TUNAI"
        "investment" -> "INVESTASI"
        else -> "BANK"
    }
