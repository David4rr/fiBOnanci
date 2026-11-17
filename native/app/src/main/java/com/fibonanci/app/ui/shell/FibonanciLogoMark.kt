package com.fibonanci.app.ui.shell

import android.graphics.BlurMaskFilter
import androidx.compose.animation.core.CubicBezierEasing
import androidx.compose.animation.core.Easing
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.size
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Rect
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Paint
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.graphics.nativeCanvas
import androidx.compose.ui.graphics.drawscope.scale
import androidx.compose.ui.graphics.drawscope.withTransform
import androidx.compose.ui.graphics.drawscope.drawIntoCanvas
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.fibonanci.app.ui.theme.AppColors
import kotlin.math.PI
import kotlin.math.pow
import kotlin.math.sin

// flutter curves used across the shell
internal val EaseOutCubic = CubicBezierEasing(0.215f, 0.61f, 0.355f, 1.0f)
internal val EaseInCubic = CubicBezierEasing(0.55f, 0.055f, 0.675f, 0.19f)
internal val EaseInOutCubic = CubicBezierEasing(0.645f, 0.045f, 0.355f, 1.0f)
internal val EaseOutBack = CubicBezierEasing(0.175f, 0.885f, 0.32f, 1.275f)
internal val EaseOut = CubicBezierEasing(0.0f, 0.0f, 0.58f, 1.0f)
internal val ElasticOut = Easing { t ->
    val period = 0.4f
    val s = period / 4f
    2f.pow(-10f * t) * sin((t - s) * (PI.toFloat() * 2f) / period) + 1f
}

/// pure mathematical "the phi vault" logo mark: central pillar flanked by
/// two symmetrical vault gates with fibonacci proportions (34, 55, 89, 210).
@Composable
fun FibonanciLogoMark(
    modifier: Modifier = Modifier,
    size: Dp = 64.dp,
    morphProgress: Float = 1f,
    showGlow: Boolean = false,
    color: Color? = null,
) {
    val progress = morphProgress.coerceIn(0f, 1f)
    Canvas(modifier.size(size)) {
        drawPhiVault(progress, showGlow, color)
    }
}

private val leftGatePath = Path().apply {
    moveTo(97f, 39f)
    // semicircle r=89 counter-clockwise through the left side
    arcTo(Rect(Offset(97f, 128f), 89f), -90f, -180f, false)
    lineTo(97f, 183f)
    // semicircle r=55 clockwise back up through the left side
    arcTo(Rect(Offset(97f, 128f), 55f), 90f, 180f, false)
    close()
}

private val rightGatePath = Path().apply {
    moveTo(159f, 39f)
    arcTo(Rect(Offset(159f, 128f), 89f), -90f, 180f, false)
    lineTo(159f, 183f)
    arcTo(Rect(Offset(159f, 128f), 55f), 90f, -180f, false)
    close()
}

private val defaultBrush = Brush.linearGradient(
    colors = listOf(AppColors.neoMint, AppColors.neoChartreuse),
    start = Offset(128f - 89f, 128f - 89f),
    end = Offset(128f + 89f, 128f + 89f),
)

private fun DrawScope.drawPhiVault(progress: Float, showGlow: Boolean, overrideColor: Color?) {
    val s = size.width / 256f
    scale(s, s, pivot = Offset.Zero) {
        val cx = 128f
        val cy = 128f
        val pillarT = EaseOutCubic.transform((progress / 0.55f).coerceIn(0f, 1f))
        val gateT = EaseOutBack.transform(((progress - 0.25f) / 0.75f).coerceIn(0f, 1f))

        if (showGlow && progress > 0.08f) {
            val glowColor = (overrideColor ?: AppColors.neoChartreuse).copy(alpha = 0.20f * progress)
            // flutter blur sigma -> android blur radius, in scaled canvas units (mask filter respects the ctm)
            val sigma = 256f * 0.26f
            val radius = ((sigma - 0.5f) / 0.57735f).coerceAtLeast(0.1f)
            drawIntoCanvas { canvas ->
                val paint = Paint().asFrameworkPaint().apply {
                    isAntiAlias = true
                    this.color = glowColor.toArgb()
                    maskFilter = BlurMaskFilter(radius, BlurMaskFilter.Blur.NORMAL)
                }
                canvas.nativeCanvas.drawCircle(cx, cy, 256f * 0.36f * progress, paint)
            }
        }

        if (pillarT > 0.01f) {
            val pillarH = 210f * pillarT
            val cornerRadius = 17f.coerceIn(1f, maxOf(1f, pillarH * 0.5f))
            val topLeft = Offset(cx - 17f, cy - pillarH / 2f)
            val pillarSize = Size(34f, pillarH)
            if (overrideColor != null) {
                drawRoundRect(overrideColor, topLeft, pillarSize, CornerRadius(cornerRadius))
            } else {
                drawRoundRect(defaultBrush, topLeft, pillarSize, CornerRadius(cornerRadius))
            }
        }

        if (gateT > 0.01f) {
            val gateOffset = (1f - gateT) * 24f
            val gateScale = 0.72f + (1f - 0.72f) * gateT
            for ((path, dx) in listOf(leftGatePath to gateOffset, rightGatePath to -gateOffset)) {
                withTransform({
                    translate(cx, cy)
                    scale(gateScale, gateScale, pivot = Offset.Zero)
                    translate(-cx + dx, -cy)
                }) {
                    if (overrideColor != null) drawPath(path, overrideColor) else drawPath(path, defaultBrush)
                }
            }
        }
    }
}
