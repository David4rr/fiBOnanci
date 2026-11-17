package com.fibonanci.app.ui.wallet

import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.graphics.drawscope.Stroke

object WalletPatternsGeometric {
    fun paintIsometricCircuit(scope: DrawScope, primaryColor: Color, secondaryColor: Color) = with(scope) {
        val u = density
        val w = size.width
        val h = size.height
        val gridColor = primaryColor.copy(alpha = 0.08f)
        val lineColor = primaryColor.copy(alpha = 0.22f)
        val dotColor = primaryColor.copy(alpha = 0.28f)
        val lineStroke = Stroke(width = 1.3f * u)

        val spacing = 32f * u
        var x = -h
        while (x < w + h) {
            drawLine(gridColor, Offset(x, 0f), Offset(x + h, h), strokeWidth = 0.8f * u)
            x += spacing
        }

        val trace1 = Path().apply {
            moveTo(w * 0.45f, 0f)
            lineTo(w * 0.65f, h * 0.35f)
            lineTo(w * 0.85f, h * 0.35f)
            lineTo(w * 0.95f, h * 0.55f)
        }
        drawPath(trace1, lineColor, style = lineStroke)
        drawCircle(dotColor, 3f * u, Offset(w * 0.95f, h * 0.55f))

        val trace2 = Path().apply {
            moveTo(w * 0.30f, h)
            lineTo(w * 0.50f, h * 0.65f)
            lineTo(w * 0.72f, h * 0.65f)
            lineTo(w * 0.80f, h * 0.80f)
        }
        drawPath(trace2, lineColor, style = lineStroke)
        drawCircle(dotColor, 3f * u, Offset(w * 0.80f, h * 0.80f))

        val trace3 = Path().apply {
            moveTo(w * 0.75f, 0f)
            lineTo(w * 0.88f, h * 0.22f)
            lineTo(w, h * 0.22f)
        }
        drawPath(trace3, lineColor, style = lineStroke)
        drawCircle(dotColor, 2.5f * u, Offset(w * 0.75f, 0f))
    }

    fun paintAngularPrismGeom(scope: DrawScope, primaryColor: Color, secondaryColor: Color) = with(scope) {
        val w = size.width
        val h = size.height
        val fill1 = primaryColor.copy(alpha = 0.12f)
        val fill2 = secondaryColor.copy(alpha = 0.06f)
        val lineColor = primaryColor.copy(alpha = 0.20f)
        val line = Stroke(width = 1.2f * density)

        val facet1 = Path().apply {
            moveTo(w * 0.60f, 0f)
            lineTo(w, 0f)
            lineTo(w, h * 0.70f)
            lineTo(w * 0.75f, h * 0.45f)
            close()
        }
        drawPath(facet1, fill1)
        drawPath(facet1, lineColor, style = line)

        val facet2 = Path().apply {
            moveTo(w * 0.40f, 0f)
            lineTo(w * 0.60f, 0f)
            lineTo(w * 0.75f, h * 0.45f)
            lineTo(w * 0.50f, h * 0.35f)
            close()
        }
        drawPath(facet2, fill2)
        drawPath(facet2, lineColor, style = line)

        val facet3 = Path().apply {
            moveTo(w * 0.30f, h)
            lineTo(w * 0.70f, h)
            lineTo(w * 0.85f, h * 0.60f)
            lineTo(w * 0.55f, h * 0.70f)
            close()
        }
        drawPath(facet3, fill2)
        drawPath(facet3, lineColor, style = line)
    }

    fun paintConstellationMatrix(scope: DrawScope, primaryColor: Color, secondaryColor: Color) = with(scope) {
        val u = density
        val w = size.width
        val h = size.height
        val dotLight = primaryColor.copy(alpha = 0.12f)
        val dotActive = primaryColor.copy(alpha = 0.28f)
        val lineColor = primaryColor.copy(alpha = 0.18f)
        val ringColor = primaryColor.copy(alpha = 0.15f)

        val cols = 7
        val rows = 4
        val startX = w * 0.40f
        val cellW = (w * 0.55f) / (cols - 1)
        val cellH = (h * 0.75f) / (rows - 1)

        for (r in 0 until rows) {
            for (c in 0 until cols) {
                drawCircle(dotLight, 1.2f * u, Offset(startX + c * cellW, h * 0.15f + r * cellH))
            }
        }

        val p1 = Offset(startX + 1 * cellW, h * 0.15f + 0 * cellH)
        val p2 = Offset(startX + 3 * cellW, h * 0.15f + 1 * cellH)
        val p3 = Offset(startX + 5 * cellW, h * 0.15f + 1 * cellH)
        val p4 = Offset(startX + 4 * cellW, h * 0.15f + 2 * cellH)
        val p5 = Offset(startX + 2 * cellW, h * 0.15f + 3 * cellH)

        val constellationPath = Path().apply {
            moveTo(p1.x, p1.y)
            lineTo(p2.x, p2.y)
            lineTo(p3.x, p3.y)
            lineTo(p4.x, p4.y)
            lineTo(p5.x, p5.y)
        }
        drawPath(constellationPath, lineColor, style = Stroke(width = 1f * u))

        for (pt in listOf(p1, p2, p3, p4, p5)) {
            drawCircle(dotActive, 3.2f * u, pt)
            drawCircle(ringColor, 6f * u, pt, style = Stroke(width = 1f * u))
        }
    }
}
