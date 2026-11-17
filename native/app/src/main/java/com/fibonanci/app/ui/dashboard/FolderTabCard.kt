package com.fibonanci.app.ui.dashboard

import androidx.compose.foundation.background
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Outline
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.Shape
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.unit.Density
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.LayoutDirection
import androidx.compose.ui.unit.dp

// signature asymmetric file folder tab shape. radius and step are in dp.
data class FolderTabClipper(
    val tabWidthFactor: Float = 0.54f,
    val cornerRadius: Float = 22f,
    val stepDepth: Float = 16f,
) : Shape {
    fun getClip(size: Size, density: Density): Path {
        val path = Path()
        val tabW = size.width * tabWidthFactor
        val r = cornerRadius * density.density
        val s = stepDepth * density.density
        val w = size.width
        val h = size.height

        // start at bottom left
        path.moveTo(0f, h - r)
        path.quadraticTo(0f, h, r, h)

        // bottom right
        path.lineTo(w - r, h)
        path.quadraticTo(w, h, w, h - r)

        // right edge up to tab drop shoulder
        path.lineTo(w, s + r)
        path.quadraticTo(w, s, w - r, s)

        // flat middle ridge
        path.lineTo(tabW + r, s)

        // smooth s-curve down from tab top to shoulder
        path.cubicTo(tabW + r * 0.25f, s, tabW, 0f, tabW - r * 0.75f, 0f)

        // top left tab shoulder
        path.lineTo(r, 0f)
        path.quadraticTo(0f, 0f, 0f, r)

        path.close()
        return path
    }

    override fun createOutline(size: Size, layoutDirection: LayoutDirection, density: Density): Outline =
        Outline.Generic(getClip(size, density))
}

// strokes the exact folder tab border path. border width in dp.
class FolderTabBorderPainter(
    val clipper: FolderTabClipper = FolderTabClipper(),
    val borderColor: Color = Color(0xFF2E3244),
    val borderWidth: Float = 1.2f,
) {
    fun DrawScope.paint() {
        val path = clipper.getClip(size, this)
        drawPath(path, borderColor, style = Stroke(width = borderWidth * density))
    }
}

@Composable
fun FolderTabCard(
    backgroundColor: Color,
    gradient: Brush? = null,
    width: Dp? = null,
    height: Dp? = 145.dp,
    onTap: (() -> Unit)? = null,
    padding: PaddingValues = PaddingValues(16.dp),
    modifier: Modifier = Modifier,
    content: @Composable () -> Unit,
) {
    var mod = modifier.graphicsLayer {}
    if (onTap != null) {
        mod = mod.pointerInput(onTap) { detectTapGestures(onTap = { onTap() }) }
    }
    if (width != null) mod = mod.width(width)
    if (height != null) mod = mod.height(height)
    mod = mod.clip(FolderTabClipper()).background(backgroundColor)
    if (gradient != null) mod = mod.background(gradient)
    Box(mod.padding(padding)) { content() }
}
