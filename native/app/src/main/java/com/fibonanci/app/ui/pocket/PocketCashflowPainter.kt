package com.fibonanci.app.ui.pocket

import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.StrokeJoin
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.graphics.drawscope.Stroke

class PocketCashflowSplinePainter(
    val values: List<Double>,
    val lineColor: Color,
    val fillColor: Color,
    val progress: Float,
    val hasTransactions: Boolean,
) {
    fun DrawScope.paint() {
        val width = size.width
        val height = size.height
        if (width <= 0f || height <= 0f || values.isEmpty()) return
        val n = values.size
        val minVal = values.min()
        val maxVal = values.max()
        val isFlat = !hasTransactions || (maxVal - minVal) == 0.0

        val topPad = 4f * density
        val botPad = 4f * density
        val plotH = height - topPad - botPad
        val dx = if (n > 1) width / (n - 1) else width
        val range = if (isFlat) 1.0 else (maxVal - minVal)

        val points = List(n) { i ->
            val norm = if (isFlat) 0.5 else ((values[i] - minVal) / range).coerceIn(0.0, 1.0)
            val x = if (n > 1) i * dx else width / 2
            val targetY = topPad + (1f - norm.toFloat()) * plotH
            Offset(x, height - ((height - targetY) * progress))
        }

        val path = Path().apply { moveTo(points.first().x, points.first().y) }
        for (i in 0 until points.size - 1) {
            val p0 = points[i]
            val p1 = points[i + 1]
            val cx = (p0.x + p1.x) / 2
            path.cubicTo(cx, p0.y, cx, p1.y, p1.x, p1.y)
        }

        val fillPath = Path().apply {
            addPath(path)
            lineTo(points.last().x, height)
            lineTo(points.first().x, height)
            close()
        }
        drawPath(
            fillPath,
            brush = Brush.verticalGradient(listOf(fillColor, fillColor.copy(alpha = 0f)), startY = 0f, endY = height),
        )
        drawPath(
            path,
            color = lineColor,
            style = Stroke(width = 2f * density, cap = StrokeCap.Round, join = StrokeJoin.Round),
        )

        if (progress >= 0.7f) {
            val last = points.last()
            val alpha = ((progress - 0.7f) / 0.3f).coerceIn(0f, 1f)
            drawCircle(lineColor.copy(alpha = 0.35f * alpha), radius = 4f * density, center = last)
            drawCircle(lineColor.copy(alpha = alpha), radius = 2.2f * density, center = last)
            drawCircle(Color.White.copy(alpha = alpha), radius = 1f * density, center = last)
        }
    }
}
