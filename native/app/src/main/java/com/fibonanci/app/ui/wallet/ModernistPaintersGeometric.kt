package com.fibonanci.app.ui.wallet

import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.graphics.drawscope.Stroke

object ModernistPaintersGeometric {
    fun paintMonochromeStark(scope: DrawScope, primaryColor: Color, secondaryColor: Color) = with(scope) {
        val w = size.width
        val h = size.height
        val path = Path().apply {
            moveTo(w * 0.65f, 0f)
            lineTo(w * 0.90f, 0f)
            lineTo(w * 0.50f, h)
            lineTo(w * 0.25f, h)
            close()
        }
        drawPath(path, primaryColor.copy(alpha = 0.20f))

        val gridColor = secondaryColor.copy(alpha = 0.30f)
        for (i in 0 until 4) {
            val y = h * (0.25f + i * 0.18f)
            drawLine(gridColor, Offset(w * 0.55f, y), Offset(w * 0.92f, y), strokeWidth = 1f * density)
        }
    }

    fun paintLavenderDusk(scope: DrawScope, primaryColor: Color, secondaryColor: Color) = with(scope) {
        val u = density
        val center = Offset(size.width * 0.78f, size.height * 0.36f)
        drawCircle(primaryColor.copy(alpha = 0.40f), 22f * u, center)
        drawOval(
            secondaryColor.copy(alpha = 0.50f),
            Offset(center.x - 45f * u, center.y - 21f * u),
            Size(90f * u, 42f * u),
            style = Stroke(width = 1.6f * u),
        )
        drawCircle(primaryColor.copy(alpha = 0.25f), 12f * u, Offset(size.width * 0.58f, size.height * 0.50f))
    }

    fun paintCobaltVault(scope: DrawScope, primaryColor: Color, secondaryColor: Color) = with(scope) {
        val u = density
        val radarColor = secondaryColor.copy(alpha = 0.45f)
        val stroke = Stroke(width = 1.5f * u)
        val center = Offset(size.width * 0.80f, size.height * 0.40f)
        drawCircle(primaryColor.copy(alpha = 0.35f), 14f * u, center)
        drawCircle(radarColor, 32f * u, center, style = stroke)
        drawCircle(radarColor, 54f * u, center, style = stroke)
        drawLine(radarColor, Offset(center.x - 64f * u, center.y), Offset(center.x + 64f * u, center.y), strokeWidth = 1.5f * u)
        drawLine(radarColor, Offset(center.x, center.y - 64f * u), Offset(center.x, center.y + 64f * u), strokeWidth = 1.5f * u)
    }

    fun paintBlushPop(scope: DrawScope, primaryColor: Color, secondaryColor: Color) = with(scope) {
        val u = density
        val pillColor = primaryColor.copy(alpha = 0.35f)
        val center = Offset(size.width * 0.76f, size.height * 0.38f)
        val topLeft = Offset(center.x - 36f * u, center.y - 17f * u)
        val rectSize = Size(72f * u, 34f * u)
        val radius = CornerRadius(17f * u)
        drawRoundRect(pillColor, topLeft, rectSize, radius)
        drawRoundRect(secondaryColor.copy(alpha = 0.60f), topLeft, rectSize, radius, style = Stroke(width = 2f * u))
        drawCircle(pillColor, 10f * u, Offset(size.width * 0.58f, size.height * 0.60f))
    }

    fun paintNordicPine(scope: DrawScope, primaryColor: Color) = with(scope) {
        val w = size.width
        val h = size.height
        val color = primaryColor.copy(alpha = 0.45f)
        val stroke = Stroke(width = 1.4f * density, cap = StrokeCap.Round)

        val path1 = Path().apply {
            moveTo(w * 0.40f, 0f)
            cubicTo(w * 0.55f, h * 0.40f, w * 0.75f, h * 0.25f, w, h * 0.60f)
        }
        drawPath(path1, color, style = stroke)

        val path2 = Path().apply {
            moveTo(w * 0.50f, 0f)
            cubicTo(w * 0.65f, h * 0.50f, w * 0.85f, h * 0.35f, w, h * 0.80f)
        }
        drawPath(path2, color, style = stroke)

        val path3 = Path().apply {
            moveTo(w * 0.60f, 0f)
            cubicTo(w * 0.75f, h * 0.60f, w * 0.92f, h * 0.45f, w, h)
        }
        drawPath(path3, color, style = stroke)
    }

    fun paintCopperPatina(scope: DrawScope, primaryColor: Color, secondaryColor: Color) = with(scope) {
        val u = density
        val slashColor = primaryColor.copy(alpha = 0.45f)
        for (i in 0 until 5) {
            val startX = size.width * (0.60f + i * 0.08f)
            val startY = size.height * 0.15f
            drawLine(
                slashColor,
                Offset(startX, startY),
                Offset(startX - 28f * u, startY + 46f * u),
                strokeWidth = 3.5f * u,
                cap = StrokeCap.Round,
            )
        }
        drawCircle(secondaryColor.copy(alpha = 0.40f), 14f * u, Offset(size.width * 0.82f, size.height * 0.65f))
    }
}
