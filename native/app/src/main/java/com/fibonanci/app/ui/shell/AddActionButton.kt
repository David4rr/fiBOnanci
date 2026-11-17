package com.fibonanci.app.ui.shell

import android.graphics.BlurMaskFilter
import android.view.HapticFeedbackConstants
import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.gestures.awaitEachGesture
import androidx.compose.foundation.gestures.awaitFirstDown
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.Add
import androidx.compose.material3.Icon
import androidx.compose.runtime.Composable
import androidx.compose.runtime.MutableState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.rememberUpdatedState
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Rect
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Paint
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.graphics.drawscope.drawIntoCanvas
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.graphics.nativeCanvas
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.layout.boundsInWindow
import androidx.compose.ui.layout.onGloballyPositioned
import androidx.compose.ui.platform.LocalView
import androidx.compose.ui.unit.dp
import com.fibonanci.app.ui.theme.AppColors
import kotlinx.coroutines.launch

/// interactive 3d tilt & slingshot add button.
object AddActionButton {
    // window bounds (px) of the 56dp button box, null until laid out
    var anchorRect: Rect? = null
    val isMenuOpen: MutableState<Boolean> = mutableStateOf(false)
}

private fun lerp(a: Float, b: Float, t: Float) = a + (b - a) * t

// flutter tween sequence: 0.88 -> 1.10 (35), 1.10 -> 0.98 (35), 0.98 -> 1.0 (30)
private fun scaleSequence(t: Float): Float = when {
    t < 0.35f -> lerp(0.88f, 1.10f, EaseOutCubic.transform(t / 0.35f))
    t < 0.70f -> lerp(1.10f, 0.98f, EaseInOutCubic.transform((t - 0.35f) / 0.35f))
    else -> lerp(0.98f, 1.0f, EaseOutCubic.transform(((t - 0.70f) / 0.30f).coerceIn(0f, 1f)))
}

@Composable
fun AddActionButton(
    onPressed: () -> Unit,
    onLongPress: (() -> Unit)? = null,
    modifier: Modifier = Modifier,
) {
    val view = LocalView.current
    val scope = rememberCoroutineScope()
    val currentOnPressed by rememberUpdatedState(onPressed)
    val controller = remember { Animatable(0f) }

    var tiltOffset by remember { mutableStateOf(Offset.Zero) }
    var slingshotStart by remember { mutableStateOf(Offset.Zero) }
    var isPressed by remember { mutableStateOf(false) }

    val menuOpen by AddActionButton.isMenuOpen

    Box(
        modifier
            .size(56.dp)
            .onGloballyPositioned { AddActionButton.anchorRect = it.boundsInWindow() },
    ) {
        if (!menuOpen) Box(
            Modifier
                .size(56.dp)
                .pointerInput(Unit) {
                    val radius = 28.dp.toPx()
                    fun handlePointer(p: Offset) {
                        val dx = ((p.x - radius) / radius).coerceIn(-1f, 1f)
                        val dy = ((p.y - radius) / radius).coerceIn(-1f, 1f)
                        tiltOffset = Offset(dx, dy)
                    }
                    fun restart() {
                        scope.launch {
                            controller.snapTo(0f)
                            controller.animateTo(1f, tween(550, easing = LinearEasing))
                        }
                    }
                    awaitEachGesture {
                        // pan down
                        val down = awaitFirstDown(requireUnconsumed = false)
                        isPressed = true
                        handlePointer(down.position)
                        view.performHapticFeedback(HapticFeedbackConstants.CLOCK_TICK)
                        var cancelled = false
                        while (true) {
                            val event = awaitPointerEvent()
                            val change = event.changes.firstOrNull { it.id == down.id } ?: event.changes.first()
                            if (change.isConsumed && change.pressed) {
                                cancelled = true
                                break
                            }
                            if (!change.pressed) break
                            // pan update
                            handlePointer(change.position)
                            change.consume()
                        }
                        if (cancelled) {
                            isPressed = false
                            slingshotStart = tiltOffset
                            restart()
                        } else {
                            // pan end: slingshot
                            isPressed = false
                            slingshotStart = tiltOffset
                            view.performHapticFeedback(HapticFeedbackConstants.KEYBOARD_TAP)
                            currentOnPressed()
                            if (!AddActionButton.isMenuOpen.value) restart()
                        }
                    }
                },
            contentAlignment = Alignment.Center,
        ) {
            val isAnimating = controller.isRunning
            val effectiveTilt = when {
                isAnimating -> {
                    val e = ElasticOut.transform(controller.value)
                    Offset(lerp(slingshotStart.x, 0f, e), lerp(slingshotStart.y, 0f, e))
                }
                isPressed -> tiltOffset
                else -> Offset.Zero
            }
            val scale = if (isAnimating) scaleSequence(controller.value) else if (isPressed) 0.88f else 1.0f
            val tiltX = effectiveTilt.x
            val tiltY = effectiveTilt.y
            val rotationTurns = 0.25f * EaseOutBack.transform(controller.value)
            val pressed = isPressed

            Box(
                Modifier
                    .size(56.dp)
                    .graphicsLayer {
                        // flutter perspective entry 0.0025 == camera at 400 logical px
                        cameraDistance = 400f * density
                        rotationX = Math.toDegrees((-tiltY * 0.40f).toDouble()).toFloat()
                        rotationY = Math.toDegrees((tiltX * 0.40f).toDouble()).toFloat()
                        translationX = tiltX * 3f * density
                        translationY = tiltY * 3f * density
                        scaleX = scale
                        scaleY = scale
                    }
                    .drawBehind {
                        drawCircleShadow(
                            color = AppColors.neoChartreuse.copy(alpha = if (pressed) 0.45f else 0.35f),
                            blurRadius = if (pressed) 10f else 16f,
                            spread = if (pressed) -3f else -2f,
                            offset = Offset(-tiltX * 6f, (if (pressed) 2f else 4f) - tiltY * 6f),
                        )
                        drawCircleShadow(
                            color = Color.Black.copy(alpha = 0.30f),
                            blurRadius = if (pressed) 6f else 12f,
                            spread = 0f,
                            offset = Offset(-tiltX * 4f, (if (pressed) 2f else 4f) - tiltY * 4f),
                        )
                    }
                    .background(AppColors.neoChartreuse, CircleShape)
                    .drawBehind {
                        val c = Offset(size.width / 2f * (1f - tiltX * 0.65f), size.height / 2f * (1f - tiltY * 0.65f))
                        drawCircle(
                            brush = Brush.radialGradient(
                                colors = listOf(Color.White.copy(alpha = 0.28f), Color.Transparent, Color.Black.copy(alpha = 0.12f)),
                                center = c,
                                radius = size.minDimension * 0.85f,
                            ),
                        )
                    },
                contentAlignment = Alignment.Center,
            ) {
                Icon(
                    imageVector = Icons.Rounded.Add,
                    contentDescription = null,
                    tint = AppColors.textDarkPrimary,
                    modifier = Modifier
                        .graphicsLayer {
                            rotationZ = rotationTurns * 360f
                            translationX = tiltX * 2f * density
                            translationY = tiltY * 2f * density
                        }
                        .size(30.dp),
                )
            }
        }
    }
}

// flutter BoxShadow on a circle: blurRadius/spread/offset in dp
private fun DrawScope.drawCircleShadow(color: Color, blurRadius: Float, spread: Float, offset: Offset) {
    val radius = size.minDimension / 2f + spread * density
    // flutter sigma = blur * 0.5 + 0.5; android blur radius ~= (sigma - 0.5) / 0.57735
    val sigma = blurRadius * 0.5f + 0.5f
    val blurPx = ((sigma - 0.5f) / 0.57735f * density).coerceAtLeast(0.1f)
    drawIntoCanvas { canvas ->
        val paint = Paint().asFrameworkPaint().apply {
            isAntiAlias = true
            this.color = color.toArgb()
            maskFilter = BlurMaskFilter(blurPx, BlurMaskFilter.Blur.NORMAL)
        }
        canvas.nativeCanvas.drawCircle(center.x + offset.x * density, center.y + offset.y * density, radius, paint)
    }
}
