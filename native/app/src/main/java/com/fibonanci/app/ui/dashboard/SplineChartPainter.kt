package com.fibonanci.app.ui.dashboard

import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.StrokeJoin
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.text.TextMeasurer
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.drawText
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.sp
import com.fibonanci.app.ui.theme.AppColors
import kotlin.math.max

// all canvas math runs in px; dart logical sizes are scaled by density.
class SplineChartPainter(
    val values: List<Double>? = null,
    val incomeValues: List<Double>? = null,
    val expenseValues: List<Double>? = null,
    val labels: List<String>,
    val lineColor: Color,
    val touchedIndex: Int? = null,
    val progress: Float = 1f,
    val textMeasurer: TextMeasurer,
) {
    fun DrawScope.paint() {
        val bottomLabelHeight = 22f * density
        val chartHeight = size.height - bottomLabelHeight
        if (chartHeight <= 0f) return

        val isDual = incomeValues != null && expenseValues != null
        if (isDual) {
            paintDual(this, chartHeight, bottomLabelHeight)
        } else if (!values.isNullOrEmpty()) {
            paintSingle(this, chartHeight, bottomLabelHeight, values, lineColor)
        }
    }

    private fun paintDual(scope: DrawScope, chartHeight: Float, bottomLabelHeight: Float) {
        val inc = incomeValues!!
        val exp = expenseValues!!
        val n = max(inc.size, exp.size)
        if (n == 0) return

        var maxVal = 0.0
        for (v in inc) if (v > maxVal) maxVal = v
        for (v in exp) if (v > maxVal) maxVal = v
        if (maxVal == 0.0) maxVal = 1.0

        val topPad = 10f * scope.density
        val bottomPad = 8f * scope.density
        val plotH = chartHeight - topPad - bottomPad
        val width = scope.size.width
        val dx = if (n > 1) width / (n - 1) else width

        val incPoints = calcPoints(inc, n, dx, 0.0, maxVal, topPad, plotH, width)
        val expPoints = calcPoints(exp, n, dx, 0.0, maxVal, topPad, plotH, width)

        val touched = touchedIndex
        if (touched != null && touched < n) {
            SplineCanvasHelper.drawScrubLine(scope, incPoints[touched].x, chartHeight)
        }
        SplineCanvasHelper.drawSplineCurve(scope, incPoints, chartHeight, AppColors.neoMint, progress = progress, withGradient = true, withGlow = true, activeIndex = touchedIndex, centerDotColor = AppColors.canvasCardSurface)
        SplineCanvasHelper.drawSplineCurve(scope, expPoints, chartHeight, AppColors.neoCoral, progress = progress, withGradient = false, withGlow = true, activeIndex = touchedIndex, centerDotColor = AppColors.canvasCardSurface)
        SplineCanvasHelper.drawBottomLabels(scope, scope.size, incPoints, labels, bottomLabelHeight, textMeasurer, topOffset = 6f * scope.density)
    }

    private fun paintSingle(scope: DrawScope, chartHeight: Float, bottomLabelHeight: Float, vals: List<Double>, color: Color) {
        val n = vals.size
        val minVal = vals.min()
        val maxVal = vals.max()

        val topPad = 10f * scope.density
        val bottomPad = 8f * scope.density
        val plotH = chartHeight - topPad - bottomPad
        val width = scope.size.width
        val dx = if (n > 1) width / (n - 1) else width

        val points = calcPoints(vals, n, dx, minVal, maxVal, topPad, plotH, width)

        val touched = touchedIndex
        if (touched != null && touched < n) {
            SplineCanvasHelper.drawScrubLine(scope, points[touched].x, chartHeight)
        }
        SplineCanvasHelper.drawSplineCurve(scope, points, chartHeight, color, progress = progress, withGradient = true, withGlow = true, activeIndex = touchedIndex, centerDotColor = AppColors.canvasCardSurface)
        SplineCanvasHelper.drawBottomLabels(scope, scope.size, points, labels, bottomLabelHeight, textMeasurer, topOffset = 6f * scope.density)
    }

    private fun calcPoints(vals: List<Double>, n: Int, dx: Float, minVal: Double, maxVal: Double, topPad: Float, plotH: Float, totalWidth: Float): List<Offset> {
        val points = ArrayList<Offset>(n)
        val range = if (maxVal - minVal == 0.0) 1.0 else maxVal - minVal
        for (i in 0 until n) {
            val v = if (i < vals.size) vals[i] else 0.0
            val norm = ((v - minVal) / range).coerceIn(0.0, 1.0).toFloat()
            val x = if (n > 1) i * dx else totalWidth / 2f
            val baseTargetY = topPad + (1f - norm) * plotH
            val y = plotH + topPad - ((plotH + topPad - baseTargetY) * progress)
            points.add(Offset(x, y))
        }
        return points
    }
}

// geometry args are px; stroke widths and radii are dart logical values scaled by density.
object SplineCanvasHelper {
    private val labelStyle = TextStyle(color = AppColors.textMuted, fontSize = 9.2.sp, fontWeight = FontWeight.W600)

    fun drawScrubLine(scope: DrawScope, x: Float, chartHeight: Float) {
        scope.drawLine(AppColors.canvasBorder, Offset(x, 0f), Offset(x, chartHeight), strokeWidth = 1.1f * scope.density)
    }

    fun drawSplineCurve(
        scope: DrawScope,
        points: List<Offset>,
        chartHeight: Float,
        color: Color,
        progress: Float,
        withGradient: Boolean = true,
        withGlow: Boolean = false,
        activeIndex: Int? = null,
        centerDotColor: Color = Color.White,
    ) {
        if (points.isEmpty()) return
        val d = scope.density
        val path = Path().apply { moveTo(points[0].x, points[0].y) }
        val fillPath = Path().apply {
            moveTo(points[0].x, chartHeight)
            lineTo(points[0].x, points[0].y)
        }
        for (i in 0 until points.size - 1) {
            val p0 = points[i]
            val p1 = points[i + 1]
            val cx = (p0.x + p1.x) / 2f
            path.cubicTo(cx, p0.y, cx, p1.y, p1.x, p1.y)
            fillPath.cubicTo(cx, p0.y, cx, p1.y, p1.x, p1.y)
        }
        fillPath.lineTo(points.last().x, chartHeight)
        fillPath.close()
        if (withGradient) {
            val brush = Brush.verticalGradient(
                listOf(color.copy(alpha = (0.23f * progress).coerceIn(0f, 1f)), color.copy(alpha = 0.01f)),
                startY = 0f,
                endY = chartHeight,
            )
            scope.drawPath(fillPath, brush)
        }
        if (withGlow) {
            scope.drawPath(path, color.copy(alpha = 0.25f), style = Stroke(width = 3.5f * d, cap = StrokeCap.Round, join = StrokeJoin.Round))
        }
        scope.drawPath(path, color, style = Stroke(width = 2.1f * d, cap = StrokeCap.Round, join = StrokeJoin.Round))
        val idx = activeIndex ?: (points.size - 1)
        if (idx < points.size) {
            val pt = points[idx]
            scope.drawCircle(color.copy(alpha = 0.30f), 6.5f * d, pt)
            scope.drawCircle(color, 3.6f * d, pt)
            scope.drawCircle(centerDotColor, 1.6f * d, pt)
        }
    }

    fun drawBottomLabels(
        scope: DrawScope,
        size: Size,
        points: List<Offset>,
        labels: List<String>,
        labelHeight: Float,
        textMeasurer: TextMeasurer,
        topOffset: Float = 2f,
    ) {
        if (labels.isEmpty()) return
        var i = 0
        while (i < labels.size && i < points.size) {
            if (labels[i].isNotEmpty()) {
                val layout = textMeasurer.measure(labels[i], labelStyle)
                val w = layout.size.width.toFloat()
                val x = (points[i].x - w / 2f).coerceIn(0f, max(0f, size.width - w))
                scope.drawText(layout, topLeft = Offset(x, size.height - labelHeight + topOffset))
            }
            i++
        }
    }
}
