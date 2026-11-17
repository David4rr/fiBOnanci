package com.fibonanci.app.ui.common

import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.EnterExitState
import androidx.compose.animation.ExperimentalAnimationApi
import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.EaseIn
import androidx.compose.animation.core.EaseInOut
import androidx.compose.animation.core.EaseOut
import androidx.compose.animation.core.EaseOutBack
import androidx.compose.animation.core.Easing
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.scaleIn
import androidx.compose.animation.scaleOut
import androidx.compose.animation.togetherWith
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.gestures.Orientation
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.gestures.draggable
import androidx.compose.foundation.gestures.rememberDraggableState
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.rounded.ArrowForward
import androidx.compose.material.icons.rounded.Delete
import androidx.compose.material.icons.rounded.KeyboardDoubleArrowRight
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.rememberUpdatedState
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.PlusJakartaSans
import kotlinx.coroutines.CoroutineStart
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlin.math.abs
import kotlin.math.roundToInt

private const val SLIDE_DURATION_MILLIS = 280

/**
 * tactile swipe-to-confirm button for irreversible actions: the thumb has to be slid
 * from left to right before [onSlideComplete] fires (which opens the confirmation dialog).
 */
@OptIn(ExperimentalAnimationApi::class)
@Composable
fun SlideToDeleteButton(
    label: String,
    onSlideComplete: () -> Unit,
    height: Dp = 52.dp,
    modifier: Modifier = Modifier,
) {
    val progress = remember { Animatable(0f) }
    val scope = rememberCoroutineScope()
    val haptics = LocalHapticFeedback.current
    val complete by rememberUpdatedState(onSlideComplete)
    var hapticTriggered by remember { mutableStateOf(false) }
    val density = LocalDensity.current
    val thumbSize = height - 8.dp

    // AnimationController.animateTo: duration scales with the remaining distance
    suspend fun animateTo(target: Float, easing: Easing) {
        val millis = (SLIDE_DURATION_MILLIS * abs(target - progress.value)).roundToInt()
        progress.animateTo(target, tween(millis, easing = easing))
    }

    fun resetSlide() {
        hapticTriggered = false
        scope.launch { animateTo(0f, EaseOutBack) }
    }

    fun finishSlide(easing: Easing) {
        scope.launch {
            animateTo(1f, easing)
            complete()
            delay(300)
            resetSlide()
        }
    }

    BoxWithConstraints(modifier.fillMaxWidth()) {
        val totalWidthPx = constraints.maxWidth.toFloat()
        val thumbPx = with(density) { thumbSize.toPx() }
        val maxDrag = totalWidthPx - thumbPx - with(density) { 8.dp.toPx() }
        val p = progress.value
        val outerShape = RoundedCornerShape(16.dp)

        Box(
            Modifier
                .fillMaxWidth()
                .height(height)
                .pointerInput(Unit) { detectTapGestures { finishSlide(EaseInOut) } }
                .draggable(
                    state = rememberDraggableState { delta ->
                        if (maxDrag <= 0f) return@rememberDraggableState
                        val next = (progress.value + delta / maxDrag).coerceIn(0f, 1f)
                        scope.launch(start = CoroutineStart.UNDISPATCHED) { progress.snapTo(next) }
                        if (next >= 0.75f && !hapticTriggered) {
                            hapticTriggered = true
                            haptics.performHapticFeedback(HapticFeedbackType.SegmentTick)
                        } else if (next < 0.75f && hapticTriggered) {
                            hapticTriggered = false
                        }
                    },
                    orientation = Orientation.Horizontal,
                    onDragStopped = {
                        if (progress.value >= 0.75f) {
                            haptics.performHapticFeedback(HapticFeedbackType.LongPress)
                            finishSlide(EaseOut)
                        } else {
                            resetSlide()
                        }
                    },
                )
                .background(AppColors.neoCoral.copy(alpha = 0.10f), outerShape)
                .border(1.2.dp, AppColors.neoCoral.copy(alpha = 0.35f), outerShape),
            contentAlignment = Alignment.CenterStart,
        ) {
            // trail fill behind the thumb
            Box(
                Modifier
                    .fillMaxHeight()
                    .width(with(density) { (4.dp.toPx() + thumbPx + p * maxDrag).toDp() })
                    .background(AppColors.neoCoral.copy(alpha = 0.22f), RoundedCornerShape(15.dp)),
            )
            Row(
                Modifier
                    .align(Alignment.Center)
                    .graphicsLayer { alpha = (1f - p * 1.5f).coerceIn(0f, 1f) },
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Text(
                    label,
                    style = TextStyle(
                        fontFamily = PlusJakartaSans,
                        color = AppColors.neoCoral,
                        fontSize = 13.sp,
                        fontWeight = FontWeight.W700,
                        letterSpacing = 0.3.sp,
                    ),
                )
                Spacer(Modifier.width(6.dp))
                Icon(
                    Icons.Rounded.KeyboardDoubleArrowRight,
                    contentDescription = null,
                    tint = AppColors.neoCoral,
                    modifier = Modifier.size(16.dp),
                )
            }
            Box(
                Modifier
                    .offset { IntOffset((4.dp.toPx() + progress.value * maxDrag).roundToInt(), 0) }
                    .size(thumbSize)
                    .shadow(
                        elevation = 4.dp,
                        shape = RoundedCornerShape(12.dp),
                        ambientColor = AppColors.neoCoral.copy(alpha = 0.4f),
                        spotColor = AppColors.neoCoral.copy(alpha = 0.4f),
                    )
                    .background(AppColors.neoCoral, RoundedCornerShape(12.dp)),
                contentAlignment = Alignment.Center,
            ) {
                AnimatedContent(
                    targetState = p >= 0.75f,
                    transitionSpec = {
                        (scaleIn(tween(220, easing = EaseOutBack)) + fadeIn(tween(220, easing = EaseOutBack))) togetherWith
                            (scaleOut(tween(220, easing = EaseIn)) + fadeOut(tween(220, easing = EaseIn)))
                    },
                    label = "slideThumbIcon",
                ) { armed ->
                    val shown by transition.animateFloat(
                        transitionSpec = {
                            tween(220, easing = if (targetState == EnterExitState.Visible) EaseOutBack else EaseIn)
                        },
                        label = "slideThumbTurn",
                    ) { if (it == EnterExitState.Visible) 1f else 0f }
                    Icon(
                        if (armed) Icons.Rounded.Delete else Icons.AutoMirrored.Rounded.ArrowForward,
                        contentDescription = null,
                        tint = AppColors.textDarkPrimary,
                        modifier = Modifier
                            .size(20.dp)
                            .graphicsLayer { rotationZ = 0.125f * (1f - shown) * 360f },
                    )
                }
            }
        }
    }
}
