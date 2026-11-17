package com.fibonanci.app.ui.pocket

import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.EaseOutCubic
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.gestures.detectHorizontalDragGestures
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.rememberUpdatedState
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.text.rememberTextMeasurer
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.fibonanci.app.core.format.AppCurrency
import com.fibonanci.app.core.nowMillis
import com.fibonanci.app.data.db.TransactionEntry
import com.fibonanci.app.domain.CashflowAnalyticsService
import com.fibonanci.app.ui.LocalFinance
import com.fibonanci.app.ui.theme.AppColors
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import java.util.Locale
import kotlin.math.abs
import kotlin.math.roundToInt

private val pocketChartFilters = listOf("1M", "1B", "1T", "Semua")

// compact, minimalist stock-like chart card representing total pocket balance trajectory.
@Composable
fun PocketStockChartCard(
    currentTotal: Double,
    pocketsCount: Int,
    transactions: List<TransactionEntry>,
    referenceDate: Long? = null,
    modifier: Modifier = Modifier,
) {
    val vm = LocalFinance.current
    val state by vm.state.collectAsStateWithLifecycle()
    val haptics = LocalHapticFeedback.current
    val scope = rememberCoroutineScope()
    val textMeasurer = rememberTextMeasurer()

    var selectedFilter by rememberSaveable { mutableStateOf("1M") }
    var scrubbedIndex by remember { mutableStateOf<Int?>(null) }
    val anim = remember { Animatable(0f) }

    // replay on first show and whenever the total or transaction count changes
    LaunchedEffect(currentTotal, transactions.size) {
        anim.snapTo(0f)
        anim.animateTo(1f, tween(650, easing = EaseOutCubic))
    }

    fun onFilterChanged(filter: String) {
        if (selectedFilter == filter) return
        haptics.performHapticFeedback(HapticFeedbackType.TextHandleMove)
        selectedFilter = filter
        scrubbedIndex = null
        scope.launch {
            anim.snapTo(0f)
            anim.animateTo(1f, tween(650, easing = EaseOutCubic))
        }
    }

    var refDate = referenceDate
    if (refDate == null && transactions.isNotEmpty()) {
        val latest = transactions.maxOf { it.transactionDate }
        if (abs((nowMillis() - latest) / 86_400_000L) > 4) refDate = latest
    }

    val trend = CashflowAnalyticsService.computePocketTrendSeries(
        currentTotal = currentTotal,
        transactions = transactions,
        filter = selectedFilter,
        referenceDate = refDate,
    )

    val values = trend.values
    val isUpward = trend.isUpward
    val themeColor = if (isUpward) AppColors.neoMint else AppColors.statusDeficit

    val scrubbed = scrubbedIndex
    val displayBalance = if (scrubbed != null && scrubbed < values.size) values[scrubbed] else trend.currentBalance
    val scrubbedLabel = if (scrubbed != null && scrubbed < trend.labels.size) trend.labels[scrubbed] else null

    val delta = trend.delta
    val pct = trend.percentChange
    val deltaSign = if (delta >= 0) "+" else ""
    val deltaFormatted = "$deltaSign${AppCurrency.format(delta, state.profile.currency)}"
    val pctFormatted = "$deltaSign${String.format(Locale.US, "%.1f", pct)}%"

    val valuesCount by rememberUpdatedState(values.size)

    fun handleTouch(x: Float, width: Float) {
        val count = valuesCount
        if (count <= 0 || width <= 0f) return
        val dx = if (count > 1) width / (count - 1) else width
        val nearest = (x / dx).roundToInt().coerceIn(0, count - 1)
        if (scrubbedIndex != nearest) {
            haptics.performHapticFeedback(HapticFeedbackType.TextHandleMove)
            scrubbedIndex = nearest
        }
    }

    fun clearTouch() {
        if (scrubbedIndex != null) scrubbedIndex = null
    }

    Column(
        modifier = modifier
            .fillMaxWidth()
            .background(AppColors.canvasCardSurface, RoundedCornerShape(20.dp))
            .border(1.dp, AppColors.canvasBorder, RoundedCornerShape(20.dp))
            .padding(start = 16.dp, top = 14.dp, end = 16.dp, bottom = 10.dp),
    ) {
        PocketStockChartHeader(
            displayBalance = displayBalance,
            themeColor = themeColor,
            isUpward = isUpward,
            pctFormatted = pctFormatted,
            deltaFormatted = deltaFormatted,
            pocketsCount = pocketsCount,
            scrubbedIndex = scrubbedIndex,
            scrubbedLabel = scrubbedLabel,
            selectedFilter = selectedFilter,
            filters = pocketChartFilters,
            onFilterChanged = ::onFilterChanged,
        )
        Spacer(Modifier.height(12.dp))
        Canvas(
            modifier = Modifier
                .fillMaxWidth()
                .height(90.dp)
                .pointerInput(Unit) {
                    detectHorizontalDragGestures(
                        onDragStart = { handleTouch(it.x, size.width.toFloat()) },
                        onDragEnd = { clearTouch() },
                        onDragCancel = { clearTouch() },
                        onHorizontalDrag = { change, _ -> handleTouch(change.position.x, size.width.toFloat()) },
                    )
                }
                .pointerInput(Unit) {
                    detectTapGestures(
                        onPress = { pos ->
                            handleTouch(pos.x, size.width.toFloat())
                            if (tryAwaitRelease()) {
                                scope.launch {
                                    delay(1500)
                                    if (scrubbedIndex != null) clearTouch()
                                }
                            }
                        },
                    )
                },
        ) {
            with(
                PocketSplinePainter(
                    values = values,
                    labels = trend.labels,
                    lineColor = themeColor,
                    touchedIndex = scrubbedIndex,
                    progress = anim.value,
                    textMeasurer = textMeasurer,
                ),
            ) { paint() }
        }
    }
}
