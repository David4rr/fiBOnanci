package com.fibonanci.app.ui.report

import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.EaseOutCubic
import androidx.compose.animation.core.tween
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.width
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberUpdatedState
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.fibonanci.app.core.format.AppCurrency
import com.fibonanci.app.ui.LocalFinance
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.PlusJakartaSans
import java.util.Locale
import kotlin.math.PI
import kotlin.math.atan2
import kotlin.math.max
import kotlin.math.min
import kotlin.math.sqrt

data class UnifiedDonutSlice(
    val categoryId: String,
    val name: String,
    val amount: Double,
    val percentage: Double,
    val txCount: Int,
    val isIncome: Boolean,
    val color: Color,
)

object CategoryDonutChart {
    private val incomePalette = listOf(AppColors.neoMint, AppColors.neoCyan, AppColors.neoChartreuse)
    private val expensePalette = listOf(AppColors.neoCoral, Color(0xFFF59E0B), AppColors.neoPurple, Color(0xFFEC4899), Color(0xFFEF4444))

    fun resolveSliceColor(hex: String, isIncome: Boolean, index: Int): Color {
        if (isIncome) return incomePalette[index % incomePalette.size]
        val cleaned = hex.replace("#", "")
        if (cleaned.length == 6) {
            val v = "FF$cleaned".toLongOrNull(16)
            if (v != null && cleaned.uppercase() != "64748B" && cleaned.uppercase() != "10B981") {
                return Color(v.toInt())
            }
        }
        return expensePalette[index % expensePalette.size]
    }
}

@Composable
fun CategoryDonutChart(
    slices: List<UnifiedDonutSlice>,
    totalIncome: Double,
    totalExpense: Double,
    savingsRate: Double,
    selectedIndex: Int?,
    onSelectIndex: (Int?) -> Unit,
) {
    val state by LocalFinance.current.state.collectAsStateWithLifecycle()
    val currency = state.profile.currency
    val totalFlow = totalIncome + totalExpense
    val activeIdx = if (selectedIndex != null && selectedIndex < slices.size) selectedIndex else null
    val selected = activeIdx?.let { slices[it] }
    val netCashflow = totalIncome - totalExpense
    val netColor = if (netCashflow >= 0) AppColors.neoMint else AppColors.neoCoral

    // restarts the entry sweep whenever the dart ValueKey('${totalFlow}_${slices.length}') changes
    val progress = remember("${totalFlow}_${slices.size}") { Animatable(0f) }
    LaunchedEffect(progress) { progress.animateTo(1f, tween(420, easing = EaseOutCubic)) }

    val currentSlices by rememberUpdatedState(slices)
    val currentSelected by rememberUpdatedState(selectedIndex)
    val currentOnSelect by rememberUpdatedState(onSelectIndex)
    val currentTotal by rememberUpdatedState(totalFlow)

    Box(
        Modifier
            .fillMaxWidth()
            .height(176.dp)
            .testTag("category_donut_chart")
            .pointerInput(Unit) {
                detectTapGestures(onPress = { pos ->
                    handleTapDown(pos, Size(size.width.toFloat(), size.height.toFloat()), currentSlices, currentTotal, currentSelected, currentOnSelect)
                })
            }
            .drawBehind { paintDonutRing(slices, totalFlow, progress.value, activeIdx) },
        contentAlignment = Alignment.Center,
    ) {
        Column(Modifier.width(124.dp), horizontalAlignment = Alignment.CenterHorizontally) {
            Text(
                selected?.name ?: "Arus Kas Bersih",
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
                textAlign = TextAlign.Center,
                style = TextStyle(fontFamily = PlusJakartaSans, fontSize = 10.5.sp, fontWeight = FontWeight.W500, color = AppColors.textMuted),
            )
            Spacer(Modifier.height(4.dp))
            Text(
                if (selected != null) {
                    "${if (selected.isIncome) "+" else "-"}${AppCurrency.format(selected.amount, currency)}"
                } else {
                    "${if (netCashflow > 0) "+" else ""}${AppCurrency.format(netCashflow, currency)}"
                },
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
                textAlign = TextAlign.Center,
                style = TextStyle(fontFamily = PlusJakartaSans, fontSize = 14.sp, fontWeight = FontWeight.W700, color = AppColors.textWhite, fontFeatureSettings = "tnum"),
            )
            Spacer(Modifier.height(3.dp))
            Text(
                if (selected != null) {
                    "${String.format(Locale.US, "%.1f", selected.percentage)}% Arus Kas"
                } else {
                    "Tabungan ${String.format(Locale.US, "%.0f", savingsRate)}%"
                },
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
                style = TextStyle(
                    fontFamily = PlusJakartaSans,
                    fontSize = 10.5.sp,
                    fontWeight = FontWeight.W600,
                    color = selected?.color ?: netColor,
                    fontFeatureSettings = "tnum",
                ),
            )
        }
    }
}

private fun handleTapDown(
    position: Offset,
    size: Size,
    slices: List<UnifiedDonutSlice>,
    totalFlow: Double,
    selectedIndex: Int?,
    onSelectIndex: (Int?) -> Unit,
) {
    if (slices.isEmpty() || totalFlow <= 0) return
    val dx = position.x - size.width / 2f
    val dy = position.y - size.height / 2f
    val dist = sqrt(dx * dx + dy * dy)
    val outerR = min(size.width, size.height) / 2f
    if (dist < outerR * 0.45f || dist > outerR * 1.05f) {
        onSelectIndex(null)
        return
    }
    var angle = atan2(dy.toDouble(), dx.toDouble()) + PI / 2
    if (angle < 0) angle += 2 * PI

    var cumulative = 0.0
    for (i in slices.indices) {
        val sweep = (slices[i].amount / totalFlow) * 2 * PI
        if (angle >= cumulative && angle <= cumulative + sweep) {
            onSelectIndex(if (selectedIndex == i) null else i)
            return
        }
        cumulative += sweep
    }
}

private fun DrawScope.paintDonutRing(slices: List<UnifiedDonutSlice>, totalFlow: Double, progress: Float, selectedIndex: Int?) {
    val d = density
    val c = Offset(size.width / 2f, size.height / 2f)
    val baseRadius = min(size.width, size.height) / 2f - 14f * d
    drawCircle(Color.White.copy(alpha = 0.04f), baseRadius, c, style = Stroke(width = 12f * d))
    if (slices.isEmpty() || totalFlow <= 0) return

    val gapRadians = if (slices.size > 1) 0.045 else 0.0
    var startAngle = -PI / 2
    for (i in slices.indices) {
        val item = slices[i]
        val rawSweep = (item.amount / totalFlow) * 2 * PI * progress
        val sweep = max(0.01, rawSweep - gapRadians)
        val isSelected = selectedIndex == i
        val isDimmed = selectedIndex != null && !isSelected
        val radius = if (isSelected) baseRadius + 2f * d else baseRadius
        drawArc(
            color = if (isDimmed) item.color.copy(alpha = 0.25f) else item.color,
            startAngle = Math.toDegrees(startAngle + gapRadians / 2).toFloat(),
            sweepAngle = Math.toDegrees(sweep).toFloat(),
            useCenter = false,
            topLeft = Offset(c.x - radius, c.y - radius),
            size = Size(radius * 2, radius * 2),
            style = Stroke(width = (if (isSelected) 16f else 12f) * d, cap = StrokeCap.Butt),
        )
        startAngle += rawSweep
    }
}
