package com.fibonanci.app.ui.wallet

import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.graphics.drawscope.Stroke

// contactless payment wave painter (•)))
class ContactlessPainter(val color: Color) {
    fun DrawScope.paint() {
        val u = density
        val stroke = Stroke(width = 1.8f * u, cap = StrokeCap.Round)
        val base = Offset(2f * u, size.height / 2)

        // dot
        drawCircle(color, 1.4f * u, base)

        // waves at radius 4.5, 8.5, 12.5
        for (r in listOf(4.5f, 8.5f, 12.5f)) {
            val radius = r * u
            drawArc(
                color = color,
                startAngle = -45f,
                sweepAngle = 90f,
                useCenter = false,
                topLeft = Offset(base.x - radius, base.y - radius),
                size = Size(radius * 2, radius * 2),
                style = stroke,
            )
        }
    }
}
