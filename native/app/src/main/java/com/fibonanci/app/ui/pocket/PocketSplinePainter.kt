package com.fibonanci.app.ui.pocket

import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.text.TextMeasurer
import com.fibonanci.app.ui.dashboard.SplineCanvasHelper
import kotlin.math.min

// textMeasurer is needed by compose to draw the bottom labels.
class PocketSplinePainter(
    val values: List<Double>,
    val labels: List<String>,
    val lineColor: Color,
    val touchedIndex: Int? = null,
    val progress: Float,
    val textMeasurer: TextMeasurer,
) {
    fun DrawScope.paint() {
        val bottomLabelHeight = 16f * density
        val chartHeight = size.height - bottomLabelHeight
        if (chartHeight <= 0f || values.isEmpty()) return

        val n = values.size
        val minVal = values.min()
        val maxVal = values.max()

        val topPad = 8f * density
        val bottomPad = 6f * density
        val plotH = chartHeight - topPad - bottomPad
        val dx = if (n > 1) size.width / (n - 1) else size.width

        val points = calcPoints(n, dx, minVal, maxVal, topPad, plotH, size.width)

        val touched = touchedIndex
        if (touched != null && touched < n) {
            SplineCanvasHelper.drawScrubLine(this, points[touched].x, chartHeight)
        }
        SplineCanvasHelper.drawSplineCurve(this, points, chartHeight, lineColor, progress = progress, withGradient = true, activeIndex = touchedIndex)
        SplineCanvasHelper.drawBottomLabels(this, size, points, labels, bottomLabelHeight, textMeasurer, topOffset = 2f * density)
    }

    private fun calcPoints(n: Int, dx: Float, minVal: Double, maxVal: Double, topPad: Float, plotH: Float, totalWidth: Float): List<Offset> {
        val baseMin = min(0.0, minVal)
        val isFlat = (maxVal - minVal) == 0.0
        val range = if ((maxVal - baseMin) <= 0) 1.0 else (maxVal - baseMin)
        return List(n) { i ->
            val v = values[i]
            val norm = if (v <= 0) 0.0 else (if (isFlat) 0.65 else ((v - baseMin) / range).coerceIn(0.0, 1.0))
            val x = if (n > 1) i * dx else totalWidth / 2
            val baseTargetY = topPad + (1f - norm.toFloat()) * plotH
            val y = plotH + topPad - ((plotH + topPad - baseTargetY) * progress)
            Offset(x, y)
        }
    }
}
