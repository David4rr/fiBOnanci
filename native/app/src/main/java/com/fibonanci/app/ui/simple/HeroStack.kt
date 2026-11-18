@file:OptIn(ExperimentalMaterial3ExpressiveApi::class)

package com.fibonanci.app.ui.simple

import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.togetherWith
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.pager.HorizontalPager
import androidx.compose.foundation.pager.PagerDefaults
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.rounded.KeyboardArrowLeft
import androidx.compose.material.icons.automirrored.rounded.KeyboardArrowRight
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ExperimentalMaterial3ExpressiveApi
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.graphics.lerp
import androidx.compose.ui.layout.onSizeChanged
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.util.lerp
import com.fibonanci.app.core.format.AppCurrency
import com.fibonanci.app.core.toLocalDate
import com.fibonanci.app.ui.FinanceState
import java.time.LocalDate
import java.time.YearMonth
import java.time.format.DateTimeFormatter
import java.util.Locale
import kotlin.math.abs

// how far the widgets shrink while the stack is moving, like the iphone smart stack
private const val MOVING_SCALE = 0.92f
private const val WIDGET_COUNT = 2
private const val FLIP_DISTANCE = 0.35f

// room the calendar needs for six week rows; the hero grows to it so both widgets match
private val MIN_WIDGET_HEIGHT = 344.dp
private val DOT_SIZE = 6.dp
private val DOT_GAP = 6.dp
private val ACTIVE_DOT_WIDTH = 16.dp

// the hero slot as a smart stack: the safe-to-spend card in front, the daily cash flow
// calendar behind it. it swipes sideways because the list under it owns the vertical drag.
// the pager tracks the finger 1:1 and settles with a fling seeded by the release speed;
// everything else (the shrink, the frame, the dots) is read from the pager's position, so
// it can never drift from the drag, also when a swipe is caught and reversed
@Composable
fun HeroStack(state: FinanceState, modifier: Modifier = Modifier) {
    val pager = rememberPagerState { WIDGET_COUNT }
    var heroHeight by remember { mutableIntStateOf(0) }
    val density = LocalDensity.current
    val colors = MaterialTheme.colorScheme
    val frameShape = MaterialTheme.shapes.extraLarge
    // 0 at rest, 1 once a swipe is a quarter of the way to the next widget
    val moving = { (abs(pager.currentPageOffsetFraction) * 4f).coerceAtMost(1f) }

    Column(modifier, horizontalAlignment = Alignment.CenterHorizontally) {
        Box {
            // the frame the widgets sit in, only there while they move
            Box(
                Modifier
                    .matchParentSize()
                    .graphicsLayer { alpha = moving() }
                    .background(colors.surfaceContainerLow, frameShape)
                    .border(1.dp, colors.outlineVariant, frameShape),
            )
            HorizontalPager(
                state = pager,
                // the calendar is laid out before the first swipe, so the drag never waits for it
                beyondViewportPageCount = 1,
                verticalAlignment = Alignment.Top,
                // a slow drag flips once it is a bit over a third of the way; a flick flips from anywhere
                flingBehavior = PagerDefaults.flingBehavior(pager, snapPositionalThreshold = FLIP_DISTANCE),
            ) { page ->
                val widget = Modifier.graphicsLayer {
                    val scale = lerp(1f, MOVING_SCALE, moving())
                    scaleX = scale
                    scaleY = scale
                }
                if (page == 0) {
                    HeroCard(state, widget.heightIn(min = MIN_WIDGET_HEIGHT).onSizeChanged { heroHeight = it.height })
                } else {
                    DailyFlowCard(state, widget.height(with(density) { heroHeight.toDp() }))
                }
            }
        }
        Spacer(Modifier.height(10.dp))
        // the dot of the widget in front stretches into a pill; drawn, not laid out, so a
        // drag only repaints this strip
        Spacer(
            Modifier
                .size(width = ACTIVE_DOT_WIDTH + (DOT_SIZE + DOT_GAP) * (WIDGET_COUNT - 1), height = DOT_SIZE)
                .drawBehind {
                    val position = pager.currentPage + pager.currentPageOffsetFraction
                    var x = 0f
                    repeat(WIDGET_COUNT) { index ->
                        val front = (1f - abs(position - index)).coerceIn(0f, 1f)
                        val width = lerp(DOT_SIZE.toPx(), ACTIVE_DOT_WIDTH.toPx(), front)
                        drawRoundRect(
                            color = lerp(colors.onSurfaceVariant.copy(alpha = 0.35f), colors.onSurface, front),
                            topLeft = Offset(x, 0f),
                            size = Size(width, size.height),
                            cornerRadius = CornerRadius(size.height / 2f),
                        )
                        x += width + DOT_GAP.toPx()
                    }
                },
        )
    }
}

// a month of days, each with what came in minus what went out. transfers between the
// user's own wallets are left out: they are neither
@Composable
fun DailyFlowCard(state: FinanceState, modifier: Modifier = Modifier) {
    val today = remember { LocalDate.now() }
    var month by rememberSaveable { mutableStateOf(YearMonth.from(today)) }
    val monthTransactions = remember(state.transactions, month) {
        state.transactions.filter { it.type != "transfer" && YearMonth.from(it.transactionDate.toLocalDate()) == month }
    }
    val income = monthTransactions.filter { it.type == "income" }.sumOf { it.amount }
    val expense = monthTransactions.filter { it.type != "income" }.sumOf { it.amount }
    val netByDay = remember(monthTransactions) {
        monthTransactions
            .groupBy { it.transactionDate.toLocalDate().dayOfMonth }
            .mapValues { (_, list) -> list.sumOf { if (it.type == "income") it.amount else -it.amount } }
    }
    val colors = MaterialTheme.colorScheme
    val locale = remember { Locale.forLanguageTag("id-ID") }
    val effects = MaterialTheme.motionScheme.defaultEffectsSpec<Float>()

    Card(
        modifier = modifier.fillMaxWidth(),
        shape = MaterialTheme.shapes.extraLarge,
        colors = CardDefaults.cardColors(containerColor = colors.surfaceContainerHigh, contentColor = colors.onSurface),
    ) {
        Column(Modifier.fillMaxSize().padding(start = 16.dp, end = 16.dp, top = 8.dp, bottom = 16.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Text("Arus harian", Modifier.weight(1f).padding(start = 8.dp), style = MaterialTheme.typography.titleMedium)
                IconButton(onClick = { month = month.minusMonths(1) }) {
                    Icon(Icons.AutoMirrored.Rounded.KeyboardArrowLeft, contentDescription = "Bulan sebelumnya")
                }
                Text(month.format(DateTimeFormatter.ofPattern("MMM yyyy", locale)), style = MaterialTheme.typography.labelLarge)
                // there is nothing recorded in the future to show
                IconButton(onClick = { month = month.plusMonths(1) }, enabled = month < YearMonth.from(today)) {
                    Icon(Icons.AutoMirrored.Rounded.KeyboardArrowRight, contentDescription = "Bulan berikutnya")
                }
            }
            Row(Modifier.padding(horizontal = 8.dp), verticalAlignment = Alignment.CenterVertically) {
                Text("Bersih", Modifier.weight(1f), style = MaterialTheme.typography.bodyMedium, color = colors.onSurfaceVariant)
                Text(
                    money(state, abs(income - expense), flowSign(income - expense)),
                    style = MaterialTheme.typography.titleMedium.money(),
                    // the colour would give away the direction while the amounts are hidden
                    color = if (state.isBalanceHidden) colors.onSurface else flowColor(income - expense, colors.primary, colors.error, colors.onSurface),
                )
            }
            Text(
                "Masuk ${money(state, income)} · Keluar ${money(state, expense)}",
                Modifier.padding(horizontal = 8.dp),
                style = MaterialTheme.typography.labelMedium,
                color = colors.onSurfaceVariant,
                maxLines = 1,
            )
            Spacer(Modifier.height(8.dp))
            Row {
                // weeks start on monday here
                listOf("S", "S", "R", "K", "J", "S", "M").forEach { day ->
                    Text(day, Modifier.weight(1f), style = MaterialTheme.typography.labelSmall, color = colors.onSurfaceVariant, textAlign = TextAlign.Center)
                }
            }
            Spacer(Modifier.height(4.dp))
            AnimatedContent(
                targetState = month,
                modifier = Modifier.weight(1f),
                transitionSpec = { fadeIn(effects) togetherWith fadeOut(effects) },
                label = "flow-month",
            ) { shown ->
                // always six rows, so the days keep their size from one month to the next
                val leadingBlanks = shown.atDay(1).dayOfWeek.value - 1
                Column {
                    repeat(6) { week ->
                        Row(Modifier.weight(1f)) {
                            repeat(7) { column ->
                                val day = week * 7 + column - leadingBlanks + 1
                                Box(Modifier.weight(1f).fillMaxHeight().padding(1.dp), contentAlignment = Alignment.Center) {
                                    if (day in 1..shown.lengthOfMonth()) {
                                        // the totals above are for the month on screen, the cells for the one fading in or out
                                        val net = if (shown == month) netByDay[day] else null
                                        DayCell(state, day, net, isToday = shown.atDay(day) == today)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

// one day: its number, and under it the day's net flow when anything was recorded
@Composable
private fun DayCell(state: FinanceState, day: Int, net: Double?, isToday: Boolean) {
    val colors = MaterialTheme.colorScheme
    val tint = when {
        net == null -> Color.Transparent
        state.isBalanceHidden -> colors.onSurfaceVariant
        else -> flowColor(net, colors.primary, colors.error, colors.onSurfaceVariant)
    }
    val shape = MaterialTheme.shapes.small
    Column(
        Modifier
            .fillMaxSize()
            .background(tint.copy(alpha = if (net == null) 0f else 0.14f), shape)
            .then(if (isToday) Modifier.border(1.dp, colors.outline, shape) else Modifier),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center,
    ) {
        Text(day.toString(), style = MaterialTheme.typography.labelMedium, color = if (net == null && !isToday) colors.onSurfaceVariant else colors.onSurface)
        if (net != null) {
            val currency = state.profile.currency
            val figure = if (state.isBalanceHidden) "•••" else
                flowSign(net) + AppCurrency.formatCompact(abs(net), currency).removePrefix(AppCurrency.symbolFor(currency)).replace(" ", "").lowercase()
            Text(figure, style = MaterialTheme.typography.labelSmall.copy(fontSize = 9.sp, lineHeight = 11.sp), color = tint, maxLines = 1)
        }
    }
}

private fun flowSign(net: Double): String = if (net > 0) "+" else if (net < 0) "−" else ""

private fun flowColor(net: Double, gain: Color, loss: Color, even: Color): Color = if (net > 0) gain else if (net < 0) loss else even
