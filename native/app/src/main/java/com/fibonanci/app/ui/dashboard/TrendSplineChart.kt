package com.fibonanci.app.ui.dashboard

import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.EaseOutCubic
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.gestures.awaitEachGesture
import androidx.compose.foundation.gestures.awaitFirstDown
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.rememberTextMeasurer
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.AppTypography
import com.fibonanci.app.ui.theme.PlusJakartaSans
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import java.util.Locale
import kotlin.math.abs
import kotlin.math.max
import kotlin.math.roundToInt

// lightweight interactive 30-day spline chart with animated entry and touch scrubbing.
@Composable
fun TrendSplineChart(
    values: List<Double>? = null,
    incomeValues: List<Double>? = null,
    expenseValues: List<Double>? = null,
    labels: List<String>,
    lineColor: Color = AppColors.neoMint,
    headline: String? = null,
    subtitle: String? = null,
    height: Dp = 130.dp,
    embedded: Boolean = false,
    modifier: Modifier = Modifier,
) {
    val isDual = incomeValues != null && expenseValues != null
    var touchedIndex by remember { mutableStateOf<Int?>(null) }
    val count = if (isDual) max(incomeValues!!.size, expenseValues!!.size) else (values?.size ?: 0)
    val progress = remember { Animatable(0f) }
    LaunchedEffect(Unit) { progress.animateTo(1f, tween(750, easing = EaseOutCubic)) }
    val textMeasurer = rememberTextMeasurer()
    val scope = rememberCoroutineScope()

    val content: @Composable () -> Unit = {
        Column {
            Row(Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
                if (headline != null) {
                    Text(
                        headline,
                        style = AppTypography.listTitle.copy(
                            fontSize = if (embedded) 11.sp else 13.sp,
                            fontWeight = if (embedded) FontWeight.W600 else FontWeight.W700,
                            color = if (embedded) AppColors.textMuted else AppColors.textWhite,
                        ),
                        overflow = TextOverflow.Ellipsis,
                        maxLines = 1,
                        modifier = Modifier.weight(1f),
                    )
                } else {
                    Spacer(Modifier.weight(1f))
                }
                Spacer(Modifier.width(8.dp))
                val touched = touchedIndex
                if (touched != null && touched < count) {
                    ScrubbingBadge(touched, labels, isDual, values, incomeValues, expenseValues, lineColor)
                } else if (isDual && !embedded) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        LegendDot(AppColors.neoMint, "Masuk")
                        Spacer(Modifier.width(10.dp))
                        LegendDot(AppColors.neoCoral, "Keluar")
                    }
                } else if (subtitle != null) {
                    Text(subtitle, style = AppTypography.badgeLabel.copy(color = if (embedded) AppColors.textMuted else lineColor, fontSize = 10.sp))
                }
            }
            Spacer(Modifier.height(if (embedded) 8.dp else 12.dp))
            BoxWithConstraints(Modifier.fillMaxWidth()) {
                val chartWidthPx = constraints.maxWidth.toFloat()
                fun handleTouch(x: Float) {
                    if (count <= 1 || chartWidthPx <= 0f) return
                    val fraction = (x / chartWidthPx).coerceIn(0f, 1f)
                    val index = (fraction * (count - 1)).roundToInt().coerceIn(0, count - 1)
                    if (touchedIndex != index) touchedIndex = index
                }
                fun clearTouch() {
                    if (touchedIndex != null) touchedIndex = null
                }
                Canvas(
                    Modifier
                        .fillMaxWidth()
                        .height(height)
                        .pointerInput(count, chartWidthPx) {
                            awaitEachGesture {
                                val down = awaitFirstDown(requireUnconsumed = false)
                                handleTouch(down.position.x)
                                var dragged = false
                                while (true) {
                                    val event = awaitPointerEvent()
                                    val change = event.changes.firstOrNull { it.id == down.id } ?: break
                                    if (!change.pressed) break
                                    if (!dragged && abs(change.position.x - down.position.x) > viewConfiguration.touchSlop) dragged = true
                                    if (dragged) {
                                        handleTouch(change.position.x)
                                        change.consume()
                                    }
                                }
                                if (dragged) {
                                    clearTouch()
                                } else {
                                    scope.launch {
                                        delay(1200)
                                        clearTouch()
                                    }
                                }
                            }
                        },
                ) {
                    with(
                        SplineChartPainter(
                            values = values,
                            incomeValues = incomeValues,
                            expenseValues = expenseValues,
                            labels = labels,
                            lineColor = lineColor,
                            touchedIndex = touchedIndex,
                            progress = progress.value,
                            textMeasurer = textMeasurer,
                        ),
                    ) { paint() }
                }
            }
        }
    }

    if (embedded) {
        Box(modifier) { content() }
        return
    }
    Box(
        modifier
            .background(AppColors.canvasCardSurface, RoundedCornerShape(20.dp))
            .border(1.dp, AppColors.canvasBorder, RoundedCornerShape(20.dp))
            .padding(start = 16.dp, top = 14.dp, end = 16.dp, bottom = 12.dp),
    ) { content() }
}

@Composable
private fun ScrubbingBadge(
    index: Int,
    labels: List<String>,
    isDual: Boolean,
    values: List<Double>?,
    incomeValues: List<Double>?,
    expenseValues: List<Double>?,
    lineColor: Color,
) {
    val dateStr = if (index < labels.size && labels[index].isNotEmpty()) labels[index] else "H-${30 - index}"
    val badge = Modifier
        .background(AppColors.canvasInputSearch, RoundedCornerShape(10.dp))
        .border(0.8.dp, AppColors.canvasBorder, RoundedCornerShape(10.dp))
        .padding(horizontal = 8.dp, vertical = 3.dp)
    if (isDual) {
        val inAmt = if (index < incomeValues!!.size) incomeValues[index] else 0.0
        val exAmt = if (index < expenseValues!!.size) expenseValues[index] else 0.0
        Row(badge, verticalAlignment = Alignment.CenterVertically) {
            Text("$dateStr • ", style = TextStyle(fontFamily = PlusJakartaSans, color = AppColors.textMuted, fontSize = 10.sp, fontWeight = FontWeight.W600))
            Text("+${compactIdr(inAmt)} ", style = TextStyle(fontFamily = PlusJakartaSans, color = AppColors.neoMint, fontSize = 10.sp, fontWeight = FontWeight.Bold))
            Text("-${compactIdr(exAmt)}", style = TextStyle(fontFamily = PlusJakartaSans, color = AppColors.neoCoral, fontSize = 10.sp, fontWeight = FontWeight.Bold))
        }
    } else {
        val amt = if (index < values!!.size) values[index] else 0.0
        Box(badge) {
            Text("$dateStr: ${compactIdr(amt)}", style = TextStyle(fontFamily = PlusJakartaSans, color = lineColor, fontSize = 10.sp, fontWeight = FontWeight.Bold))
        }
    }
}

@Composable
private fun LegendDot(color: Color, label: String) {
    Row(verticalAlignment = Alignment.CenterVertically) {
        Box(Modifier.size(7.dp).background(color, CircleShape))
        Spacer(Modifier.width(4.dp))
        Text(label, style = TextStyle(fontFamily = PlusJakartaSans, color = color, fontSize = 10.sp, fontWeight = FontWeight.W600))
    }
}

// port of NumberFormat.compactSimpleCurrency(locale: 'id_ID'): "Rp1,2 rb", "Rp15 jt", "Rp1,5 M", "Rp2 T"
private fun compactIdr(value: Double): String {
    val sign = if (value < 0) "-" else ""
    val abs = abs(value)
    val (divisor, suffix) = when {
        abs >= 1e12 -> 1e12 to " T"
        abs >= 1e9 -> 1e9 to " M"
        abs >= 1e6 -> 1e6 to " jt"
        abs >= 1e3 -> 1e3 to " rb"
        else -> 1.0 to ""
    }
    val scaled = abs / divisor
    val number = if (divisor > 1.0 && scaled < 10) {
        String.format(Locale.US, "%.1f", scaled).removeSuffix(".0").replace('.', ',')
    } else {
        scaled.roundToInt().toString()
    }
    return "${sign}Rp$number$suffix"
}
