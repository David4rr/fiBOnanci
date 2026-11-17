package com.fibonanci.app.ui.wallet

import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Rect
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.graphics.drawscope.Stroke
import kotlin.math.cos
import kotlin.math.sin

// all fixed lengths are logical pixels, scaled by density like flutter does
object ModernistPaintersBase {
    fun paintTerracottaDisks(scope: DrawScope, primaryColor: Color) = with(scope) {
        val w = size.width
        val h = size.height
        val centerY = h * 0.52f
        val radius = h * 0.38f

        val path1 = Path().apply {
            arcTo(Rect(Offset(w * 0.28f, centerY), radius), 90f, 180f, false)
            close()
        }
        drawPath(path1, primaryColor)

        val path2 = Path().apply {
            arcTo(Rect(Offset(w * 0.50f, centerY), radius), 90f, 180f, false)
            close()
        }
        drawPath(path2, primaryColor)

        drawCircle(primaryColor, radius, Offset(w * 0.74f, centerY))
    }

    fun paintSageHatching(scope: DrawScope, primaryColor: Color) = with(scope) {
        val u = density
        val color = primaryColor.copy(alpha = 0.65f)
        val lineCount = 9
        val startX = size.width * 0.52f
        val startY = size.height * 0.16f
        val length = 46f * u
        for (i in 0 until lineCount) {
            val y = startY + i * 4.2f * u
            drawLine(color, Offset(startX, y), Offset(startX + length, y), strokeWidth = 2.4f * u, cap = StrokeCap.Round)
        }
    }

    fun paintPeriwinkleOvals(scope: DrawScope, primaryColor: Color) = with(scope) {
        val u = density
        val color = primaryColor.copy(alpha = 0.55f)
        val stroke = Stroke(width = 3f * u)
        val center = Offset(size.width * 0.78f, size.height * 0.32f)
        drawOval(color, Offset(center.x - 17f * u, center.y - 13f * u), Size(34f * u, 26f * u), style = stroke)
        drawOval(color, Offset(center.x - 9f * u, center.y - 7f * u), Size(18f * u, 14f * u), style = stroke)
    }

    fun paintNeonSunburst(scope: DrawScope) = with(scope) {
        val u = density
        val center = Offset(size.width * 0.54f, size.height * 0.22f)
        drawCircle(Color(0xFFFF9E00).copy(alpha = 0.75f), 12f * u, center)

        val rayColor = Color(0xFFFF9E00).copy(alpha = 0.45f)
        for (i in 0 until 8) {
            val angle = i * Math.PI / 4
            val c = cos(angle).toFloat()
            val s = sin(angle).toFloat()
            val p1 = center + Offset(c * 15f * u, s * 15f * u)
            val p2 = center + Offset(c * 22f * u, s * 22f * u)
            drawLine(rayColor, p1, p2, strokeWidth = 1.6f * u)
        }
    }

    fun paintOatmealWaves(scope: DrawScope, primaryColor: Color) = with(scope) {
        val w = size.width
        val h = size.height
        val path = Path().apply {
            moveTo(w * 0.4f, h * 0.5f)
            quadraticTo(w * 0.6f, h * 0.3f, w * 0.85f, h * 0.55f)
        }
        drawPath(path, primaryColor.copy(alpha = 0.5f), style = Stroke(width = 2f * density))
    }

    fun paintGeometricCurves(scope: DrawScope, primaryColor: Color) = with(scope) {
        val w = size.width
        val h = size.height
        val path = Path().apply {
            moveTo(w * 0.45f, 0f)
            quadraticTo(w * 0.6f, h * 0.6f, w, h * 0.4f)
            lineTo(w, 0f)
            close()
        }
        drawPath(path, primaryColor.copy(alpha = 0.4f))
    }
}
