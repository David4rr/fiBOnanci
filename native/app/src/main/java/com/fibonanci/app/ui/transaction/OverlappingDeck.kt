package com.fibonanci.app.ui.transaction

import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.EaseOutCubic
import androidx.compose.animation.core.animateDpAsState
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
import androidx.compose.runtime.getValue
import androidx.compose.runtime.key
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.fibonanci.app.core.toLocalDateTime
import com.fibonanci.app.data.db.CategoryEntry
import com.fibonanci.app.data.db.PocketEntry
import com.fibonanci.app.data.db.TransactionEntry
import com.fibonanci.app.data.db.WalletEntry
import com.fibonanci.app.domain.CashflowAnalyticsService
import com.fibonanci.app.ui.common.LocalModalHost
import kotlinx.coroutines.launch
import java.time.format.DateTimeFormatter
import kotlin.math.abs
import kotlin.math.ceil
import kotlin.math.floor
import kotlin.math.max
import kotlin.math.min

private const val CARD_STEP = 85f
private const val COLLAPSED_CARD_HEIGHT = 190f
private const val EXPANDED_CARD_HEIGHT = 295f
private const val EXPAND_DISPLACEMENT = 190f
private const val DOCK_STEP = 14f
private const val MAX_DOCKED_HEADERS = 4
private val subtitleDateFormat = DateTimeFormatter.ofPattern("dd MMM yyyy, HH:mm")

// interactive scrollable stacked card deck matching the apple wallet / passbook physics in the reference.
// onDownwardDrag / onDownwardDragEnd report px deltas / px-per-second velocities (positive = downward).
@Composable
fun StackedCardDeckScrollList(
    transactions: List<TransactionEntry>,
    allTransactions: List<TransactionEntry>? = null,
    wallets: List<WalletEntry>,
    categories: List<CategoryEntry>? = null,
    pockets: List<PocketEntry>? = null,
    expandedTxId: String? = null,
    onToggleExpand: ((String?) -> Unit)? = null,
    onManageTransaction: ((TransactionEntry) -> Unit)? = null,
    onDownwardDrag: ((Float) -> Unit)? = null,
    onDownwardDragEnd: ((Float) -> Unit)? = null,
    bottomPadding: Dp = 110.dp,
) {
    val list = transactions
    if (list.isEmpty()) return
    val host = LocalModalHost.current
    val density = LocalDensity.current
    val scope = rememberCoroutineScope()

    var scrollOffset by remember { mutableFloatStateOf(0f) }
    var isDraggingDownward by remember { mutableStateOf(false) }
    var internalExpandedId by remember { mutableStateOf(expandedTxId) }
    LaunchedEffect(expandedTxId) { internalExpandedId = expandedTxId }
    val fling = remember { Animatable(0f) }

    val currentExpandedId = if (onToggleExpand != null) expandedTxId else internalExpandedId
    val sourceTransactions = allTransactions ?: transactions

    BoxWithConstraints(Modifier.fillMaxSize()) {
        val viewportHeight = maxHeight.value
        val maxScroll = if (list.size <= 1) 0f else {
            val totalNatural = (list.size - 1) * CARD_STEP +
                (if (currentExpandedId != null) EXPAND_DISPLACEMENT + EXPANDED_CARD_HEIGHT else COLLAPSED_CARD_HEIGHT)
            max(0f, totalNatural - (viewportHeight - bottomPadding.value))
        }
        val expandedIdx = if (currentExpandedId != null) list.indexOfFirst { it.id == currentExpandedId } else -1
        val firstVis = (floor((scrollOffset - EXPANDED_CARD_HEIGHT) / CARD_STEP).toInt() - 2).coerceIn(0, list.size - 1)
        val lastVis = (ceil((scrollOffset + viewportHeight) / CARD_STEP).toInt() + 2).coerceIn(0, list.size - 1)
        val renderedIndices = buildSet {
            for (i in 0..min(MAX_DOCKED_HEADERS, list.size - 1)) add(i)
            for (i in firstVis..lastVis) add(i)
            if (expandedIdx >= 0 && expandedIdx < list.size) add(expandedIdx)
        }.sorted()

        val dragState = rememberDraggableState { deltaPx ->
            if (fling.isRunning) scope.launch { fling.stop() }
            if ((scrollOffset <= 0f && deltaPx > 0) || isDraggingDownward) {
                isDraggingDownward = true
                onDownwardDrag?.invoke(deltaPx)
                return@rememberDraggableState
            }
            val delta = with(density) { deltaPx.toDp().value }
            scrollOffset = (scrollOffset - delta).coerceIn(0f, maxScroll)
        }

        Box(
            Modifier
                .fillMaxSize()
                .draggable(
                    dragState,
                    Orientation.Vertical,
                    onDragStopped = { velocityPx ->
                        if (isDraggingDownward) {
                            isDraggingDownward = false
                            onDownwardDragEnd?.invoke(velocityPx)
                            return@draggable
                        }
                        val velocity = with(density) { velocityPx.toDp().value }
                        if (scrollOffset <= 0f && velocity > 0) {
                            onDownwardDragEnd?.invoke(velocityPx)
                            return@draggable
                        }
                        if (abs(velocity) > 100) {
                            val target = (scrollOffset - velocity * 0.22f).coerceIn(0f, maxScroll)
                            fling.snapTo(scrollOffset)
                            fling.animateTo(target, tween(320, easing = EaseOutCubic)) { scrollOffset = value }
                        }
                    },
                )
                .padding(start = 20.dp, end = 20.dp, bottom = bottomPadding),
        ) {
            for (i in renderedIndices) {
                val tx = list[i]
                key(tx.id) {
                    val isExpanded = currentExpandedId == tx.id
                    val wallet = wallets.firstOrNull { it.id == tx.walletId } ?: wallets.first()
                    val destWallet = tx.destinationWalletId?.let { d -> wallets.firstOrNull { it.id == d } }
                    val visual = TransactionVisualResolver.resolve(
                        tx = tx, categories = categories, pockets = pockets, destWalletName = destWallet?.name,
                    )
                    val weeklySpending = if (isExpanded) {
                        CashflowAnalyticsService.computeWeeklySpending(
                            sourceTransactions,
                            referenceDate = tx.transactionDate,
                            walletId = tx.walletId,
                            type = if (tx.type == "income") "income" else null,
                        )
                    } else null
                    val naturalTop = if (expandedIdx >= 0 && i > expandedIdx) i * CARD_STEP + EXPAND_DISPLACEMENT else i * CARD_STEP
                    val screenY = naturalTop - scrollOffset
                    val dockY = min(i, MAX_DOCKED_HEADERS) * DOCK_STEP
                    val top by animateDpAsState(max(screenY, dockY).dp, tween(200, easing = EaseOutCubic), label = "deckTop")
                    Box(Modifier.fillMaxWidth().offset(y = top)) {
                        OverlappingDeckItem(
                            title = visual.title,
                            category = visual.categoryLabel,
                            amount = tx.amount,
                            isExpense = tx.type == "expense" || tx.type == "transfer",
                            categoryColor = visual.cardColor,
                            iconData = visual.iconData,
                            isExpanded = isExpanded,
                            transactionDate = tx.transactionDate,
                            weeklySpending = weeklySpending,
                            subtitle = "${wallet.name}${if (destWallet != null) " → ${destWallet.name}" else ""} • ${tx.transactionDate.toLocalDateTime().format(subtitleDateFormat)}",
                            onTap = {
                                if (onToggleExpand != null) onToggleExpand(if (isExpanded) null else tx.id)
                                else internalExpandedId = if (isExpanded) null else tx.id
                            },
                            onManage = {
                                if (onManageTransaction != null) onManageTransaction(tx)
                                else showTransactionDetailModal(host, transaction = tx)
                            },
                        )
                    }
                }
            }
        }
    }
}
