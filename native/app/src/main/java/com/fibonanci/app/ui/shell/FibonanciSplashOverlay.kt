package com.fibonanci.app.ui.shell

import androidx.compose.foundation.background
import androidx.compose.foundation.gestures.awaitEachGesture
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.safeDrawing
import androidx.compose.foundation.layout.wrapContentSize
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Rect
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.layout.onGloballyPositioned
import androidx.compose.ui.layout.positionInWindow
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.lerp
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.withStyle
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.em
import androidx.compose.ui.unit.sp
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.AppTypography
import com.fibonanci.app.ui.theme.PlusJakartaSans
import kotlin.math.PI
import kotlin.math.roundToInt
import kotlin.math.sin

private val startTextStyle = TextStyle(
    fontFamily = PlusJakartaSans,
    fontSize = 28.sp,
    fontWeight = FontWeight.W700,
    letterSpacing = (-0.9).sp,
    lineHeight = 1.2.em,
    color = AppColors.textWhite,
)

private val subtitleStyle = TextStyle(
    fontFamily = PlusJakartaSans,
    fontSize = 10.sp,
    fontWeight = FontWeight.W800,
    letterSpacing = 2.2.sp,
)

private fun lerpF(a: Float, b: Float, t: Float) = a + (b - a) * t

/// presentation overlay for the splash gate with a shared-element flight for
/// both logo mark and wordmark from screen center to the dashboard header.
/// bounds are window coordinates in px.
@Composable
fun FibonanciSplashOverlay(
    animation: () -> Float,
    targetBounds: (() -> Rect?)? = null,
    targetTextBounds: (() -> Rect?)? = null,
    modifier: Modifier = Modifier,
) {
    val density = LocalDensity.current
    val topInsetPx = WindowInsets.safeDrawing.getTop(density)

    // cached once resolved, like the dart state
    var cachedDestOffset by remember { mutableStateOf<Offset?>(null) }
    var cachedDestSizePx by remember { mutableStateOf<Float?>(null) }
    var cachedDestTextOffset by remember { mutableStateOf<Offset?>(null) }
    var overlayOrigin by remember { mutableStateOf(Offset.Zero) }

    BoxWithConstraints(
        modifier.onGloballyPositioned { overlayOrigin = it.positionInWindow() },
    ) {
        val t = animation()
        val morphT = (t / 0.48f).coerceIn(0f, 1f)
        val pulseT = ((t - 0.28f) / 0.20f).coerceIn(0f, 1f)
        val logoPulse = 1f + sin(pulseT * PI.toFloat()) * 0.045f

        val textInT = EaseOutCubic.transform(((t - 0.20f) / 0.24f).coerceIn(0f, 1f))
        val subExitT = EaseInCubic.transform(((t - 0.48f) / 0.12f).coerceIn(0f, 1f))
        val subOpacity = (textInT * (1f - subExitT)).coerceIn(0f, 1f)

        val curtainExitT = EaseInOutCubic.transform(((t - 0.50f) / 0.44f).coerceIn(0f, 1f))
        val curtainOpacity = (1f - curtainExitT).coerceIn(0f, 1f)

        val flightT = ((t - 0.48f) / 0.48f).coerceIn(0f, 1f)
        val flightCurve = EaseInOutCubic.transform(flightT)

        // all geometry in dp, like flutter logical pixels
        val screenW = maxWidth.value
        val screenH = maxHeight.value
        val paddingTop = with(density) { topInsetPx.toDp().value }
        val startSize = 104f
        val startX = (screenW - startSize) / 2f
        val startY = (screenH - 182f) / 2f

        if (cachedDestOffset == null) {
            targetBounds?.invoke()?.let { r ->
                cachedDestOffset = with(density) {
                    Offset((r.left - overlayOrigin.x).toDp().value, (r.top - overlayOrigin.y).toDp().value)
                }
                cachedDestSizePx = r.width
            }
        }
        if (cachedDestTextOffset == null) {
            targetTextBounds?.invoke()?.let { r ->
                cachedDestTextOffset = with(density) {
                    Offset((r.left - overlayOrigin.x).toDp().value, (r.top - overlayOrigin.y).toDp().value)
                }
            }
        }
        val destOffset = cachedDestOffset ?: Offset(20f, paddingTop + 16f)
        val destSize = cachedDestSizePx?.let { with(density) { it.toDp().value } } ?: 24f
        val destTextOffset = cachedDestTextOffset ?: Offset(destOffset.x + destSize + 8f, destOffset.y - 1f)

        val currentSize = lerpF(startSize * logoPulse, destSize, flightCurve)
        val currentX = lerpF(startX, destOffset.x, flightCurve)
        val currentY = lerpF(startY, destOffset.y, flightCurve)
        val showGlow = t <= 0.48f

        val startTextWidth = 132f
        val startTextX = (screenW - startTextWidth) / 2f
        val startTextY = startY + startSize + 24f
        val initialSlideY = 12f * (1f - textInT)

        val currentTextX = lerpF(startTextX, destTextOffset.x, flightCurve)
        val currentTextY = lerpF(startTextY + initialSlideY, destTextOffset.y, flightCurve)
        val currentTextStyle = lerp(startTextStyle, AppTypography.heroGreeting, flightCurve)

        val blockTouches = t <= 0.70f
        Box(
            Modifier
                .fillMaxSize()
                .then(
                    if (blockTouches) {
                        Modifier.pointerInput(Unit) {
                            awaitEachGesture {
                                while (true) {
                                    val event = awaitPointerEvent()
                                    event.changes.forEach { it.consume() }
                                    if (event.changes.none { it.pressed }) break
                                }
                            }
                        }
                    } else {
                        Modifier
                    },
                ),
        ) {
            if (curtainOpacity > 0f) {
                Box(Modifier.fillMaxSize().background(AppColors.canvasBg.copy(alpha = curtainOpacity)))
            }
            if (subOpacity > 0f) {
                Text(
                    text = "φ 1.618 • ON-DEVICE VAULT",
                    textAlign = TextAlign.Center,
                    style = subtitleStyle.copy(color = AppColors.textMuted.copy(alpha = subOpacity)),
                    modifier = Modifier
                        .fillMaxWidth()
                        .offset(y = (startTextY + 38f + initialSlideY).dp),
                )
            }
            if (textInT > 0f) {
                val baseColor = currentTextStyle.color
                Text(
                    text = buildAnnotatedString {
                        append("fi")
                        withStyle(SpanStyle(color = AppColors.neoChartreuse.copy(alpha = textInT))) { append("BO") }
                        append("nanci")
                    },
                    style = currentTextStyle.copy(color = baseColor.copy(alpha = baseColor.alpha * textInT)),
                    softWrap = false,
                    maxLines = 1,
                    modifier = Modifier
                        .wrapContentSize(Alignment.TopStart, unbounded = true)
                        .offset { IntOffset(currentTextX.dp.roundToPx(), currentTextY.dp.roundToPx()) },
                )
            }
            FibonanciLogoMark(
                modifier = Modifier.offset { IntOffset(currentX.dp.roundToPx(), currentY.dp.roundToPx()) },
                size = currentSize.dp,
                morphProgress = morphT,
                showGlow = showGlow,
            )
        }
    }
}
