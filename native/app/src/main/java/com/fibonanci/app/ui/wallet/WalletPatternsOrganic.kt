package com.fibonanci.app.ui.wallet

import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.graphics.drawscope.Stroke

object WalletPatternsOrganic {
    fun paintTopographicContours(scope: DrawScope, primaryColor: Color, secondaryColor: Color) = with(scope) {
        val w = size.width
        val h = size.height
        val strokeColor = primaryColor.copy(alpha = 0.16f)
        val stroke = Stroke(width = 1.2f * density)

        val pathOuter = Path().apply {
            moveTo(w * 0.35f, 0f)
            cubicTo(w * 0.45f, h * 0.35f, w * 0.70f, h * 0.20f, w * 0.85f, h * 0.65f)
            cubicTo(w * 0.95f, h * 0.95f, w, h * 0.90f, w, h)
            lineTo(w, 0f)
            close()
        }
        drawPath(pathOuter, secondaryColor.copy(alpha = 0.07f))
        drawPath(pathOuter, strokeColor, style = stroke)

        val path1 = Path().apply {
            moveTo(w * 0.20f, 0f)
            cubicTo(w * 0.35f, h * 0.45f, w * 0.60f, h * 0.30f, w * 0.75f, h * 0.80f)
            cubicTo(w * 0.85f, h * 1.10f, w * 0.95f, h, w, h * 0.80f)
        }
        drawPath(path1, strokeColor, style = stroke)

        val path2 = Path().apply {
            moveTo(w * 0.10f, 0f)
            cubicTo(w * 0.22f, h * 0.55f, w * 0.50f, h * 0.45f, w * 0.65f, h * 0.95f)
            lineTo(w * 0.70f, h)
        }
        drawPath(path2, strokeColor, style = stroke)

        val path3 = Path().apply {
            moveTo(0f, h * 0.25f)
            cubicTo(w * 0.15f, h * 0.65f, w * 0.38f, h * 0.60f, w * 0.50f, h)
        }
        drawPath(path3, strokeColor, style = stroke)

        val hillPath = Path().apply {
            moveTo(0f, h * 0.70f)
            cubicTo(w * 0.12f, h * 0.75f, w * 0.20f, h * 0.90f, w * 0.25f, h)
        }
        drawPath(hillPath, strokeColor, style = stroke)
    }

    fun paintBauhausConcentric(scope: DrawScope, primaryColor: Color, secondaryColor: Color) = with(scope) {
        val w = size.width
        val h = size.height
        val strokeColor = primaryColor.copy(alpha = 0.15f)
        val stroke = Stroke(width = 1.4f * density)
        val center = Offset(w * 0.85f, h * 0.30f)

        drawCircle(secondaryColor.copy(alpha = 0.09f), h * 0.65f, center)
        for (i in 1..4) {
            drawCircle(strokeColor, h * 0.22f * i, center, style = stroke)
        }

        val counterCenter = Offset(w * 0.12f, h * 0.95f)
        drawCircle(strokeColor, h * 0.45f, counterCenter, style = stroke)
        drawCircle(strokeColor, h * 0.25f, counterCenter, style = stroke)
    }

    fun paintFluidWaveSplines(scope: DrawScope, primaryColor: Color, secondaryColor: Color) = with(scope) {
        val w = size.width
        val h = size.height
        val waveStrokeColor = primaryColor.copy(alpha = 0.18f)
        val waveStroke = Stroke(width = 1.3f * density)

        val path1 = Path().apply {
            moveTo(0f, h * 0.50f)
            cubicTo(w * 0.25f, h * 0.25f, w * 0.60f, h * 0.75f, w, h * 0.35f)
            lineTo(w, h)
            lineTo(0f, h)
            close()
        }
        drawPath(path1, secondaryColor.copy(alpha = 0.08f))

        val strokePath1 = Path().apply {
            moveTo(0f, h * 0.50f)
            cubicTo(w * 0.25f, h * 0.25f, w * 0.60f, h * 0.75f, w, h * 0.35f)
        }
        drawPath(strokePath1, waveStrokeColor, style = waveStroke)

        val path2 = Path().apply {
            moveTo(0f, h * 0.75f)
            cubicTo(w * 0.35f, h * 0.40f, w * 0.70f, h * 0.85f, w, h * 0.55f)
            lineTo(w, h)
            lineTo(0f, h)
            close()
        }
        drawPath(path2, secondaryColor.copy(alpha = 0.05f))

        val strokePath2 = Path().apply {
            moveTo(0f, h * 0.75f)
            cubicTo(w * 0.35f, h * 0.40f, w * 0.70f, h * 0.85f, w, h * 0.55f)
        }
        drawPath(strokePath2, waveStrokeColor, style = waveStroke)

        val ribbon = Path().apply {
            moveTo(w * 0.20f, 0f)
            cubicTo(w * 0.50f, h * 0.35f, w * 0.75f, h * 0.10f, w, h * 0.25f)
        }
        drawPath(ribbon, waveStrokeColor, style = waveStroke)
    }
}
