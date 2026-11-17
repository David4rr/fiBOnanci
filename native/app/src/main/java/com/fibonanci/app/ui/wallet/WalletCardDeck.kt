package com.fibonanci.app.ui.wallet

import androidx.compose.animation.core.CubicBezierEasing
import androidx.compose.animation.core.animateDpAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.AccountBalanceWallet
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.key
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.times
import com.fibonanci.app.data.db.WalletEntry
import com.fibonanci.app.ui.common.CardlessEmptyView
import kotlinx.coroutines.delay

object WalletCardDeck {
    const val atmRatio: Float = 53.98f / 85.60f
    val peekHeight = 78.dp
}

private val easeOutCubic = CubicBezierEasing(0.215f, 0.61f, 0.355f, 1.0f)

// tactile stacked card deck with uniform peeking
@Composable
fun WalletCardDeck(
    wallets: List<WalletEntry>,
    fmt: (Double) -> String,
    liftedWalletId: String? = null,
    onSelectWallet: (WalletEntry) -> Unit,
    modifier: Modifier = Modifier,
) {
    var expandedWalletId by remember { mutableStateOf<String?>(null) }
    // bumping this restarts the 6s auto close timer; 0 means cancelled
    var autoCloseToken by remember { mutableIntStateOf(0) }
    val haptics = LocalHapticFeedback.current

    LaunchedEffect(autoCloseToken) {
        if (autoCloseToken == 0) return@LaunchedEffect
        delay(6000)
        if (expandedWalletId != null) expandedWalletId = null
    }

    // drop the expanded state when that wallet disappears
    LaunchedEffect(wallets) {
        if (expandedWalletId != null && wallets.none { it.id == expandedWalletId }) {
            autoCloseToken = 0
            expandedWalletId = null
        }
    }

    if (wallets.isEmpty()) {
        CardlessEmptyView(
            icon = Icons.Outlined.AccountBalanceWallet,
            title = "Belum Ada Rekening",
            description = "Belum ada rekening atau dompet digital yang terhubung.",
            hint = "Ketuk tombol + di bawah untuk menambahkan",
        )
        return
    }

    fun handleCardTap(wallet: WalletEntry) {
        haptics.performHapticFeedback(HapticFeedbackType.SegmentTick)
        val isBottomCard = wallets.last().id == wallet.id
        val isCurrentlyExpanded = expandedWalletId == wallet.id || (expandedWalletId == null && isBottomCard)
        if (wallets.size == 1 || isCurrentlyExpanded) {
            autoCloseToken = 0
            val wasUpperExpanded = expandedWalletId == wallet.id
            onSelectWallet(wallet)
            if (wasUpperExpanded) expandedWalletId = null
        } else if (isBottomCard) {
            autoCloseToken = 0
            expandedWalletId = null
        } else {
            expandedWalletId = wallet.id
            autoCloseToken += 1
        }
    }

    BoxWithConstraints(modifier.fillMaxWidth()) {
        val cardW = maxWidth
        val cardH = cardW * WalletCardDeck.atmRatio
        val peek = WalletCardDeck.peekHeight
        val rawExpandedIdx = if (expandedWalletId != null) wallets.indexOfFirst { it.id == expandedWalletId } else -1
        val expandedIndex = if (rawExpandedIdx >= 0 && rawExpandedIdx < wallets.size - 1) rawExpandedIdx else -1
        val activeIndex = if (expandedIndex >= 0) expandedIndex else wallets.size - 1
        val deckH = when {
            wallets.size == 1 -> cardH
            expandedIndex >= 0 -> (2 * cardH) + (wallets.size - 2) * peek + 16.dp
            else -> cardH + (wallets.size - 1) * peek
        }
        val animatedDeckH by animateDpAsState(deckH, tween(240, easing = easeOutCubic), label = "deckHeight")

        Box(Modifier.fillMaxWidth().height(animatedDeckH)) {
            wallets.forEachIndexed { i, wallet ->
                key(wallet.id) {
                    val isBottomCard = i == wallets.size - 1
                    val isSingleCard = wallets.size == 1
                    val isExpanded = isSingleCard || i == activeIndex
                    val shouldAnimate = !isSingleCard && (!isBottomCard || expandedIndex >= 0)
                    val topOffset = if (expandedIndex == -1 || i <= expandedIndex) {
                        i * peek
                    } else {
                        (i * peek) + (cardH - peek) + 16.dp
                    }
                    val animatedTop by animateDpAsState(topOffset, tween(240, easing = easeOutCubic), label = "cardTop")

                    // hero flight to the detail route is skipped; the card itself is unchanged
                    WalletCard(
                        wallet = wallet,
                        index = i,
                        allWallets = wallets,
                        fmt = fmt,
                        cardH = cardH,
                        isLifted = isExpanded,
                        showBottomLayout = isExpanded,
                        animate = shouldAnimate,
                        modifier = Modifier
                            .offset(y = animatedTop)
                            .clickable(
                                interactionSource = remember { MutableInteractionSource() },
                                indication = null,
                            ) { handleCardTap(wallet) },
                    )
                }
            }
        }
    }
}
