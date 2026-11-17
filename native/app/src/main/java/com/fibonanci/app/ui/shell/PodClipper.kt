package com.fibonanci.app.ui.shell

import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Rect
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Outline
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.Shape
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.unit.Density
import androidx.compose.ui.unit.LayoutDirection
import kotlin.math.abs
import kotlin.math.atan2
import kotlin.math.sqrt

/// clip shape constraining the glass exactly to the pod geometry
class PodClipper(val isLeft: Boolean) : Shape {
    override fun createOutline(size: Size, layoutDirection: LayoutDirection, density: Density): Outline =
        Outline.Generic(PodBorderPainter.buildPath(size, isLeft, density.density))
}

/// fills the pod with translucent glass and strokes a crisp 1.2dp frosted border
class PodBorderPainter(val isLeft: Boolean) {
    fun DrawScope.paint() {
        val path = buildPath(size, isLeft, density)
        drawPath(path, Color(0xB813141C))
        drawPath(path, Color(0x33FFFFFF), style = Stroke(width = 1.2f * density))
    }

    companion object {
        // pxPerDp scales the fixed 34dp cutout radius
        fun buildPath(size: Size, isLeft: Boolean, pxPerDp: Float): Path {
            val path = Path()
            val w = size.width
            val h = size.height
            val r = h / 2f
            val cutoutRadius = 34f * pxPerDp

            if (isLeft) {
                path.moveTo(r, 0f)
                path.lineTo(w, 0f)
                // small counter-clockwise arc from (w, 0) to (w, h): center sits to the right
                arcBetweenVertical(path, w, 0f, h, cutoutRadius, centerToRight = true)
                path.lineTo(r, h)
                path.quadraticTo(0f, h, 0f, h - r)
                path.lineTo(0f, r)
                path.quadraticTo(0f, 0f, r, 0f)
            } else {
                path.moveTo(0f, 0f)
                path.lineTo(w - r, 0f)
                path.quadraticTo(w, 0f, w, r)
                path.lineTo(w, h - r)
                path.quadraticTo(w, h, w - r, h)
                path.lineTo(0f, h)
                // small counter-clockwise arc from (0, h) to (0, 0): center sits to the left
                arcBetweenVertical(path, 0f, h, 0f, cutoutRadius, centerToRight = false)
            }
            path.close()
            return path
        }

        // port of flutter arcToPoint(clockwise: false, largeArc: false) for a vertical chord at x
        private fun arcBetweenVertical(path: Path, x: Float, fromY: Float, toY: Float, radius: Float, centerToRight: Boolean) {
            val half = abs(toY - fromY) / 2f
            // flutter scales the radius up when the chord does not fit
            val rad = maxOf(radius, half)
            val d = sqrt(rad * rad - half * half)
            val center = Offset(if (centerToRight) x + d else x - d, (fromY + toY) / 2f)
            val start = Math.toDegrees(atan2((fromY - center.y).toDouble(), (x - center.x).toDouble())).toFloat()
            val end = Math.toDegrees(atan2((toY - center.y).toDouble(), (x - center.x).toDouble())).toFloat()
            var sweep = end - start
            // counter-clockwise on screen = negative sweep
            while (sweep > 0f) sweep -= 360f
            while (sweep <= -360f) sweep += 360f
            path.arcTo(Rect(center, rad), start, sweep, false)
        }
    }
}
