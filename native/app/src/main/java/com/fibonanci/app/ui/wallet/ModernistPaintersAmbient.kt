package com.fibonanci.app.ui.wallet

import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Rect
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.graphics.drawscope.Stroke

object ModernistPaintersAmbient {
    fun paintTokyoMidnight(scope: DrawScope, primaryColor: Color, secondaryColor: Color) = with(scope) {
        val u = density
        val w = size.width
        val h = size.height
        val lineColor = primaryColor.copy(alpha = 0.35f)
        val dotColor = secondaryColor.copy(alpha = 0.60f)

        val focal = Offset(w * 0.85f, -h * 0.2f)
        for (i in 0 until 6) {
            drawLine(lineColor, focal, Offset(w * (0.3f + i * 0.15f), h), strokeWidth = 1.2f * u)
        }

        val dots = listOf(
            Offset(w * 0.65f, h * 0.25f),
            Offset(w * 0.80f, h * 0.35f),
            Offset(w * 0.72f, h * 0.55f),
            Offset(w * 0.88f, h * 0.65f),
        )
        for (d in dots) drawCircle(dotColor, 2.2f * u, d)
    }

    fun paintSolarAmber(scope: DrawScope, primaryColor: Color, secondaryColor: Color) = with(scope) {
        val u = density
        val ringColor = primaryColor.copy(alpha = 0.40f)
        val center = Offset(size.width * 0.82f, size.height * 0.38f)
        drawCircle(secondaryColor.copy(alpha = 0.45f), 24f * u, center)
        drawCircle(ringColor, 44f * u, center, style = Stroke(width = 2f * u))
        drawCircle(ringColor, 68f * u, center, style = Stroke(width = 1.4f * u))
    }

    fun paintArcticGlacier(scope: DrawScope, primaryColor: Color, secondaryColor: Color) = with(scope) {
        val w = size.width
        val h = size.height
        val strokeColor = primaryColor.copy(alpha = 0.45f)
        val stroke = Stroke(width = 1.6f * density)

        val path1 = Path().apply {
            moveTo(w * 0.55f, 0f)
            lineTo(w * 0.85f, 0f)
            lineTo(w * 0.65f, h * 0.60f)
            close()
        }
        drawPath(path1, secondaryColor.copy(alpha = 0.35f))
        drawPath(path1, strokeColor, style = stroke)

        val path2 = Path().apply {
            moveTo(w * 0.70f, 0f)
            lineTo(w, h * 0.45f)
            lineTo(w * 0.78f, h * 0.85f)
            close()
        }
        drawPath(path2, strokeColor, style = stroke)
    }

    fun paintCyberNeon(scope: DrawScope, primaryColor: Color, secondaryColor: Color) = with(scope) {
        val u = density
        val w = size.width
        val h = size.height
        val path1 = Path().apply {
            moveTo(w * 0.45f, 0f)
            quadraticTo(w * 0.60f, h * 0.65f, w, h * 0.50f)
        }
        drawPath(path1, primaryColor.copy(alpha = 0.55f), style = Stroke(width = 3f * u, cap = StrokeCap.Round))

        val path2 = Path().apply {
            moveTo(w * 0.60f, 0f)
            quadraticTo(w * 0.75f, h * 0.45f, w, h * 0.85f)
        }
        drawPath(path2, secondaryColor.copy(alpha = 0.55f), style = Stroke(width = 2.4f * u, cap = StrokeCap.Round))
    }

    fun paintMatchaZen(scope: DrawScope, primaryColor: Color, secondaryColor: Color) = with(scope) {
        val u = density
        val pebbleColor = primaryColor.copy(alpha = 0.35f)
        val center1 = Offset(size.width * 0.78f, size.height * 0.32f)
        drawOval(pebbleColor, Offset(center1.x - 28f * u, center1.y - 19f * u), Size(56f * u, 38f * u))
        drawOval(
            secondaryColor.copy(alpha = 0.40f),
            Offset(center1.x - 40f * u, center1.y - 30f * u),
            Size(80f * u, 60f * u),
            style = Stroke(width = 1.8f * u),
        )
        val center2 = Offset(size.width * 0.62f, size.height * 0.62f)
        drawOval(pebbleColor, Offset(center2.x - 21f * u, center2.y - 14f * u), Size(42f * u, 28f * u))
    }

    fun paintTerracottaSunset(scope: DrawScope, primaryColor: Color, secondaryColor: Color) = with(scope) {
        val u = density
        val w = size.width
        val h = size.height
        val center = Offset(w * 0.76f, h * 0.55f)
        val path = Path().apply {
            arcTo(Rect(center, 46f * u), 180f, 180f, false)
            close()
        }
        drawPath(path, primaryColor.copy(alpha = 0.50f))
        drawLine(secondaryColor.copy(alpha = 0.60f), Offset(w * 0.45f, h * 0.55f), Offset(w, h * 0.55f), strokeWidth = 2f * u)
    }
}
