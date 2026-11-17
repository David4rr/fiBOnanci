package com.fibonanci.app.ui.wallet

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.TransformOrigin
import androidx.compose.ui.layout.layout
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.Constraints
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.fibonanci.app.ui.common.PeekableBalanceText
import com.fibonanci.app.ui.theme.PlusJakartaSans

object WalletCardRows {
    @Composable
    fun buildNetworkBadge(text: String, config: ModernistCardConfig) {
        Box(
            Modifier
                .background(config.textColor, RoundedCornerShape(7.dp))
                .padding(horizontal = 8.dp, vertical = 3.5.dp),
        ) {
            Text(
                text,
                style = TextStyle(
                    fontFamily = PlusJakartaSans,
                    fontSize = 9.5.sp,
                    fontWeight = FontWeight.W900,
                    color = config.backgroundColor,
                    letterSpacing = 0.6.sp,
                ),
            )
        }
    }

    @Composable
    fun buildHeaderRow(walletName: String, badgeText: String, config: ModernistCardConfig) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Text(
                walletName,
                modifier = Modifier.weight(1f),
                style = TextStyle(
                    fontFamily = PlusJakartaSans,
                    fontSize = 18.sp,
                    fontWeight = FontWeight.W800,
                    color = config.textColor,
                    letterSpacing = (-0.4).sp,
                ),
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
            )
            Spacer(Modifier.width(10.dp))
            buildNetworkBadge(badgeText, config)
        }
    }

    @Composable
    fun buildPeekBalanceRow(balance: Double, fmt: (Double) -> String, config: ModernistCardConfig) {
        Row(
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Text(
                "SALDO TERSEDIA",
                style = TextStyle(
                    fontFamily = PlusJakartaSans,
                    fontSize = 9.5.sp,
                    fontWeight = FontWeight.W700,
                    letterSpacing = 0.8.sp,
                    color = config.textColor.copy(alpha = 0.65f),
                ),
            )
            Spacer(Modifier.width(8.dp))
            Box(Modifier.weight(1f, fill = false)) {
                PeekableBalanceText(
                    text = fmt(balance),
                    style = TextStyle(
                        fontFamily = PlusJakartaSans,
                        fontSize = 14.5.sp,
                        fontWeight = FontWeight.W800,
                        color = config.textColor,
                        letterSpacing = (-0.5).sp,
                        fontFeatureSettings = "tnum",
                    ),
                    textAlign = TextAlign.Right,
                    mainAxisAlignment = Arrangement.End,
                )
            }
        }
    }

    @Composable
    fun buildBottomRow(
        balance: Double,
        fmt: (Double) -> String,
        accountNumberDisplay: String,
        config: ModernistCardConfig,
    ) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Column(Modifier.weight(1f)) {
                // fitted box with scale down, anchored center left
                Box(Modifier.scaleDownToFitWidth()) {
                    PeekableBalanceText(
                        text = fmt(balance),
                        style = TextStyle(
                            fontFamily = PlusJakartaSans,
                            fontSize = 23.sp,
                            fontWeight = FontWeight.W800,
                            color = config.textColor,
                            letterSpacing = (-0.8).sp,
                            fontFeatureSettings = "tnum",
                        ),
                    )
                }
                Spacer(Modifier.height(2.dp))
                Text(
                    "Saldo Tersedia",
                    style = TextStyle(
                        fontFamily = PlusJakartaSans,
                        fontSize = 11.sp,
                        fontWeight = FontWeight.W600,
                        color = config.textColor.copy(alpha = 0.65f),
                    ),
                )
            }
            Spacer(Modifier.width(8.dp))
            Column(horizontalAlignment = Alignment.End) {
                WalletCardAtmComponents.buildContactlessIcon(config.textColor)
                Spacer(Modifier.height(5.dp))
                Text(
                    accountNumberDisplay,
                    style = TextStyle(
                        fontFamily = PlusJakartaSans,
                        fontSize = 11.5.sp,
                        fontWeight = FontWeight.W700,
                        color = config.textColor.copy(alpha = 0.75f),
                        letterSpacing = if (accountNumberDisplay == "-") 0.sp else 1.sp,
                        fontFeatureSettings = "tnum",
                    ),
                )
            }
        }
    }

    // measures the child unconstrained in width and scales it down when it overflows (BoxFit.scaleDown)
    private fun Modifier.scaleDownToFitWidth(): Modifier = this
        .layout { measurable, constraints ->
            val placeable = measurable.measure(constraints.copy(minWidth = 0, maxWidth = Constraints.Infinity))
            val maxW = constraints.maxWidth
            val scale = if (constraints.hasBoundedWidth && placeable.width > maxW) maxW.toFloat() / placeable.width else 1f
            val w = (placeable.width * scale).toInt()
            val h = (placeable.height * scale).toInt()
            layout(w, h) {
                placeable.placeWithLayer(0, 0) {
                    scaleX = scale
                    scaleY = scale
                    transformOrigin = TransformOrigin(0f, 0f)
                }
            }
        }
}
