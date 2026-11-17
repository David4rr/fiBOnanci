package com.fibonanci.app.ui.subscription

import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.EaseOutCubic
import androidx.compose.animation.core.tween
import androidx.compose.foundation.gestures.Orientation
import androidx.compose.foundation.gestures.draggable
import androidx.compose.foundation.gestures.rememberDraggableState
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.key
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.unit.dp
import androidx.compose.ui.zIndex
import com.fibonanci.app.data.db.SubscriptionEntry
import com.fibonanci.app.data.db.WalletEntry
import kotlinx.coroutines.launch
import kotlin.math.abs
import kotlin.math.min
import kotlin.math.roundToInt

private const val CARD_HEIGHT = 215f

// tactile vertical card deck matching the physical atm card reference.
@Composable
fun SubscriptionStackedDeck(
    subscriptions: List<SubscriptionEntry>,
    wallets: List<WalletEntry>,
    onTapCard: (SubscriptionEntry, WalletEntry, Int) -> Unit,
) {
    val list = subscriptions
    if (list.isEmpty()) return

    val currentPage = remember { Animatable(0f) }
    val scope = rememberCoroutineScope()
    val density = LocalDensity.current

    fun snapTo(targetPage: Float) {
        val clamped = targetPage.coerceIn(0f, (list.size - 1).toFloat())
        scope.launch { currentPage.animateTo(clamped, tween(280, easing = EaseOutCubic)) }
    }

    LaunchedEffect(list.size) {
        if (currentPage.value >= list.size) snapTo((list.size - 1).toFloat())
    }

    val dragState = rememberDraggableState { deltaPx ->
        val deltaDp = deltaPx / density.density
        val next = (currentPage.value - deltaDp / 160f).coerceIn(-0.2f, list.size - 0.8f)
        scope.launch { currentPage.snapTo(next) }
    }

    BoxWithConstraints(
        modifier = Modifier
            .fillMaxSize()
            .draggable(
                state = dragState,
                orientation = Orientation.Vertical,
                onDragStarted = { currentPage.stop() },
                onDragStopped = { velocityPx ->
                    val velocity = -(velocityPx / density.density) / 1000f
                    snapTo((currentPage.value + velocity * 0.4f).roundToInt().toFloat())
                },
            ),
    ) {
        val totalHeight = if (constraints.hasBoundedHeight) maxHeight.value else 340f
        val centerY = (totalHeight - CARD_HEIGHT) / 2
        val page = currentPage.value

        Box(modifier = Modifier.fillMaxSize().padding(horizontal = 20.dp)) {
            for (i in list.indices) {
                val sub = list[i]
                val wallet = wallets.firstOrNull { it.id == sub.walletId } ?: wallets.first()
                val diff = i - page
                val absDiff = abs(diff)

                val top: Float
                val scale: Float
                if (diff < 0) {
                    top = centerY + (diff * 22f).coerceIn(-centerY + 10f, 0f)
                    scale = (1f + diff * 0.05f).coerceIn(0.85f, 1f)
                } else {
                    top = centerY + min(diff * 40f, centerY + 60f)
                    scale = (1f - diff * 0.04f).coerceIn(0.88f, 1f)
                }

                key(sub.id) {
                    Box(
                        modifier = Modifier
                            .zIndex(-absDiff)
                            .fillMaxWidth()
                            .offset(y = top.dp)
                            .graphicsLayer {
                                scaleX = scale
                                scaleY = scale
                            },
                    ) {
                        SubscriptionCard(
                            subscription = sub,
                            wallet = wallet,
                            indexOverride = i,
                            isFocused = absDiff < 0.35f,
                            onTap = {
                                if (absDiff < 0.35f) onTapCard(sub, wallet, i) else snapTo(i.toFloat())
                            },
                        )
                    }
                }
            }
        }
    }
}
