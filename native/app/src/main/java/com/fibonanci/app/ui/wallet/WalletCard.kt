package com.fibonanci.app.ui.wallet

import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.SizeTransform
import androidx.compose.animation.core.CubicBezierEasing
import androidx.compose.animation.core.Easing
import androidx.compose.animation.core.animateDpAsState
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.slideInVertically
import androidx.compose.animation.slideOutVertically
import androidx.compose.animation.togetherWith
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.dropShadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.luminance
import androidx.compose.ui.graphics.shadow.Shadow
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.DpOffset
import androidx.compose.ui.unit.dp
import androidx.compose.ui.util.lerp
import com.fibonanci.app.data.db.WalletEntry

private val cardBodyCurve = CubicBezierEasing(0.16f, 1.0f, 0.3f, 1.0f)
private val easeOutCurve = CubicBezierEasing(0.25f, 0.1f, 0.25f, 1.0f)

// Interval(0.15, 1.0, curve: Curves.easeOut)
private val fadeIntervalEasing = Easing { f -> if (f <= 0.15f) 0f else easeOutCurve.transform((f - 0.15f) / 0.85f) }

// standalone atm physical card matching the swiss-editorial modernist card design
@Composable
fun WalletCard(
    wallet: WalletEntry,
    index: Int,
    fmt: (Double) -> String,
    cardH: Dp,
    isLifted: Boolean = false,
    showBottomLayout: Boolean = false,
    animate: Boolean = true,
    theme: ModernistCardTheme? = null,
    allWallets: List<WalletEntry>? = null,
    modifier: Modifier = Modifier,
) {
    val resolvedTheme = resolveWalletTheme(wallet, index, allWallets = allWallets, explicitTheme = theme)
    val config = ModernistCardConfig.forTheme(resolvedTheme)
    val badgeText = resolveWalletNetworkBadge(wallet, resolvedTheme)
    val accountNumberDisplay = WalletCardAtmComponents.formatAccountNumber(wallet)
    val isDark = config.backgroundColor.luminance() < 0.35f

    // animated container: height and shadow lerp over 240ms
    val animatedHeight by animateDpAsState(cardH, tween(240), label = "cardHeight")
    val lift by animateFloatAsState(if (isLifted) 1f else 0f, tween(240), label = "cardLift")

    val shape = RoundedCornerShape(26.dp)
    val borderColor = (if (isDark) Color.White else Color.Black).copy(alpha = if (isDark) 0.14f else 0.08f)
    val painter = ModernistCardPainter(resolvedTheme, config.primaryGraphicColor, config.secondaryGraphicColor)

    Box(
        modifier
            .fillMaxWidth()
            .height(animatedHeight)
            // lifted: two shadows; resting: one shadow
            .dropShadow(
                shape,
                Shadow(
                    radius = lerp(18f, 26f, lift).dp,
                    color = Color.Black.copy(alpha = lerp(0.45f, 0.55f, lift)),
                    spread = lerp(1f, 2f, lift).dp,
                    offset = DpOffset(0.dp, lerp(8f, 14f, lift).dp),
                ),
            )
            .dropShadow(
                shape,
                Shadow(
                    radius = 18.dp * lift,
                    color = config.backgroundColor.copy(alpha = 0.25f * lift),
                    offset = DpOffset(0.dp, 6.dp * lift),
                ),
            )
            .clip(shape)
            .background(config.backgroundColor)
            .border(0.9.dp, borderColor, shape),
    ) {
        Canvas(Modifier.fillMaxSize()) { with(painter) { paint() } }
        Box(Modifier.fillMaxSize().padding(start = 22.dp, top = 20.dp, end = 22.dp, bottom = 18.dp)) {
            Box(Modifier.fillMaxSize().padding(top = 26.dp)) {
                if (!animate) {
                    CardBody(showBottomLayout, wallet, fmt, accountNumberDisplay, config, isDark)
                } else {
                    AnimatedContent(
                        targetState = showBottomLayout,
                        contentAlignment = Alignment.TopStart,
                        transitionSpec = {
                            (fadeIn(tween(260, easing = fadeIntervalEasing)) +
                                slideInVertically(tween(260, easing = cardBodyCurve)) { (it * 0.20f).toInt() }) togetherWith
                                (fadeOut(tween(260, easing = easeOutCurve)) +
                                    slideOutVertically(tween(260, easing = easeOutCurve)) { (it * 0.20f).toInt() }) using
                                SizeTransform(clip = false)
                        },
                        label = "cardBody",
                    ) { expanded ->
                        CardBody(expanded, wallet, fmt, accountNumberDisplay, config, isDark)
                    }
                }
            }
            Box(Modifier.fillMaxWidth()) { WalletCardRows.buildHeaderRow(wallet.name, badgeText, config) }
        }
    }
}

@Composable
private fun CardBody(
    expanded: Boolean,
    wallet: WalletEntry,
    fmt: (Double) -> String,
    accountNumberDisplay: String,
    config: ModernistCardConfig,
    isDark: Boolean,
) {
    if (expanded) {
        Column(Modifier.fillMaxSize()) {
            Spacer(Modifier.weight(3f))
            Row { WalletCardAtmComponents.buildChip(config.textColor, isDark) }
            Spacer(Modifier.weight(4f))
            WalletCardRows.buildBottomRow(
                balance = wallet.balance,
                fmt = fmt,
                accountNumberDisplay = accountNumberDisplay,
                config = config,
            )
        }
    } else {
        Box(Modifier.fillMaxWidth().padding(top = 2.dp)) {
            WalletCardRows.buildPeekBalanceRow(wallet.balance, fmt, config)
        }
    }
}
