package com.fibonanci.app.ui.profile

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.RowScope
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.fibonanci.app.core.format.AppCurrency
import com.fibonanci.app.ui.LocalFinance
import com.fibonanci.app.ui.theme.AppColors
import androidx.compose.runtime.getValue
import androidx.lifecycle.compose.collectAsStateWithLifecycle

class ProfileWaveChartPainter(
    val scores: List<Double>,
    val strokeColor: Color = AppColors.neoChartreuse,
) {
    fun DrawScope.paint() {
        if (scores.isEmpty()) return
        val w = size.width
        val h = size.height
        val n = scores.size
        val points = (0 until n).map { i ->
            val x = if (n == 1) w / 2f else w * (i.toFloat() / (n - 1))
            val s = scores[i].coerceIn(0.0, 100.0).toFloat()
            Offset(x, h * (0.88f - 0.76f * (s / 100f)))
        }
        val path = Path().apply { moveTo(points.first().x, points.first().y) }
        if (points.size == 1) {
            path.lineTo(w, points.first().y)
        } else {
            for (i in 0 until points.size - 1) {
                val p0 = points[i]
                val p1 = points[i + 1]
                val midX = (p0.x + p1.x) / 2f
                path.cubicTo(midX, p0.y, midX, p1.y, p1.x, p1.y)
            }
        }
        val fillPath = Path().apply {
            addPath(path)
            lineTo(w, h)
            lineTo(0f, h)
            close()
        }
        drawPath(
            fillPath,
            Brush.verticalGradient(listOf(strokeColor.copy(alpha = 0.35f), strokeColor.copy(alpha = 0f)), startY = 0f, endY = h),
        )
        drawPath(path, strokeColor, style = Stroke(width = 2.dp.toPx(), cap = StrokeCap.Round))
        var peakIdx = 0
        var maxScore = scores[0]
        for (i in 1 until scores.size) {
            if (scores[i] >= maxScore) {
                maxScore = scores[i]
                peakIdx = i
            }
        }
        val peak = points[peakIdx]
        drawCircle(strokeColor.copy(alpha = 0.35f), radius = 5.dp.toPx(), center = peak)
        drawCircle(strokeColor, radius = 2.5.dp.toPx(), center = peak)
    }
}

class FinancialShieldPainter {
    fun DrawScope.paint() {
        val w = size.width
        val h = size.height
        val path = Path().apply {
            moveTo(w * 0.5f, 0f)
            lineTo(w, h * 0.25f)
            lineTo(w * 0.82f, h * 0.75f)
            lineTo(w * 0.5f, h)
            lineTo(w * 0.18f, h * 0.75f)
            lineTo(0f, h * 0.25f)
            close()
        }
        drawPath(path, AppColors.neoChartreuse)
        val check = Path().apply {
            moveTo(w * 0.32f, h * 0.50f)
            lineTo(w * 0.46f, h * 0.65f)
            lineTo(w * 0.70f, h * 0.35f)
        }
        drawPath(check, Color(0xFF0C0D11), style = Stroke(width = 1.6.dp.toPx(), cap = StrokeCap.Round))
    }
}

private val ink = Color(0xFF0C0D11)

@Composable
fun ProfileFinancialTimelinePill(
    realBalance: Double,
    pendingBills: Double,
    safeToSpend: Double,
) {
    val state by LocalFinance.current.state.collectAsStateWithLifecycle()
    val code = state.profile.currency
    Row(
        modifier = Modifier
            .background(AppColors.neoChartreuse, RoundedCornerShape(22.dp))
            .padding(horizontal = 14.dp, vertical = 7.dp),
    ) {
        TimelineCol("SALDO RIIL", AppCurrency.formatCompact(realBalance, code)) { TrackSegment(4, true, 0) }
        TimelineCol("TAGIHAN", AppCurrency.formatCompact(pendingBills, code)) { TrackSegment(2, true, 2) }
        TimelineCol("SISA AMAN", AppCurrency.formatCompact(safeToSpend, code)) { TrackSegment(0, true, 4) }
    }
}

@Composable
private fun TrackDot() {
    Box(Modifier.size(1.8.dp).background(ink, CircleShape))
}

@Composable
private fun TrackSegment(leadingDots: Int, hasSolidBar: Boolean, trailingDots: Int) {
    Row(
        modifier = Modifier.height(3.dp),
        horizontalArrangement = Arrangement.Center,
        verticalAlignment = Alignment.CenterVertically,
    ) {
        repeat(leadingDots) {
            TrackDot()
            Spacer(Modifier.width(2.2.dp))
        }
        if (hasSolidBar) Box(Modifier.size(26.dp, 2.5.dp).background(ink, RoundedCornerShape(1.dp)))
        repeat(trailingDots) {
            Spacer(Modifier.width(2.2.dp))
            TrackDot()
        }
    }
}

@Composable
private fun RowScope.TimelineCol(title: String, value: String, track: @Composable () -> Unit) {
    Column(modifier = Modifier.weight(1f), horizontalAlignment = Alignment.CenterHorizontally) {
        Text(title, style = jakarta(9.5.sp, FontWeight.ExtraBold, ink, letterSpacing = 0.3.sp))
        Spacer(Modifier.height(3.dp))
        track()
        Spacer(Modifier.height(3.dp))
        Text(value, style = jakarta(9.5.sp, FontWeight.Bold, ink, tabular = true))
    }
}

// proportional three-dot multitasking indicator
@Composable
fun ProportionalThreeDots(onTap: () -> Unit) {
    Box(
        modifier = Modifier
            .size(44.dp, 24.dp)
            .clickable(interactionSource = remember { MutableInteractionSource() }, indication = null, onClick = onTap),
        contentAlignment = Alignment.Center,
    ) {
        Row {
            repeat(3) { i ->
                Box(
                    Modifier
                        .padding(start = if (i > 0) 5.5.dp else 0.dp)
                        .size(7.dp)
                        .background(Color(0xFF8E92A0), CircleShape),
                )
            }
        }
    }
}
