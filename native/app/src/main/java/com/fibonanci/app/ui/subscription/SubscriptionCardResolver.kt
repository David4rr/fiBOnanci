package com.fibonanci.app.ui.subscription

import com.fibonanci.app.data.db.SubscriptionEntry
import com.fibonanci.app.data.db.WalletEntry
import com.fibonanci.app.ui.wallet.ModernistCardTheme
import kotlin.math.abs

// dynamic theme & style resolver for recurring bills and installments.
object SubscriptionCardResolver {
    val kCardThemes: List<ModernistCardTheme> = listOf(
        ModernistCardTheme.cobaltVault,
        ModernistCardTheme.terracottaSunset,
        ModernistCardTheme.matchaZen,
        ModernistCardTheme.tokyoMidnight,
        ModernistCardTheme.solarAmber,
        ModernistCardTheme.cyberNeon,
        ModernistCardTheme.lavenderDusk,
        ModernistCardTheme.nordicPine,
        ModernistCardTheme.copperPatina,
        ModernistCardTheme.arcticGlacier,
        ModernistCardTheme.monochromeStark,
        ModernistCardTheme.blushPop,
        ModernistCardTheme.fiberInternet,
        ModernistCardTheme.aiCloudProductivity,
        ModernistCardTheme.utilitiesLemon,
        ModernistCardTheme.audioEmerald,
        ModernistCardTheme.housingLiving,
        ModernistCardTheme.fitnessLifestyle,
        ModernistCardTheme.recurringSmartBill,
        ModernistCardTheme.streamingCinematic,
    )

    fun resolve(
        title: String,
        seed: Int,
        index: Int? = null,
        allSubscriptions: List<SubscriptionEntry>? = null,
    ): ModernistCardTheme {
        if (!allSubscriptions.isNullOrEmpty()) {
            val subIdx = allSubscriptions.indexOfFirst { it.title == title }
            val effectiveIdx = if (subIdx >= 0) subIdx else (index ?: abs(seed))
            return kCardThemes[abs(effectiveIdx) % kCardThemes.size]
        }
        val effectiveIdx = index ?: abs(seed)
        return kCardThemes[abs(effectiveIdx) % kCardThemes.size]
    }

    fun resolveConfig(
        subscription: SubscriptionEntry,
        index: Int,
        wallet: WalletEntry? = null,
        allSubscriptions: List<SubscriptionEntry>? = null,
    ): SubscriptionCardThemeConfig {
        val theme = resolve(
            subscription.title,
            subscription.title.hashCode(),
            index = index,
            allSubscriptions = allSubscriptions,
        )
        return SubscriptionCardThemeConfig.forDynamic(
            theme = theme,
            index = index,
            seedId = subscription.id,
            walletName = wallet?.name,
            isInstallment = subscription.isInstallment,
        )
    }
}
