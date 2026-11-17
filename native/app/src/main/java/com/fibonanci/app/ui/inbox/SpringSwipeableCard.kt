package com.fibonanci.app.ui.inbox

import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.EaseOutCubic
import androidx.compose.animation.core.spring
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.gestures.Orientation
import androidx.compose.foundation.gestures.draggable
import androidx.compose.foundation.gestures.rememberDraggableState
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxScope
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.Check
import androidx.compose.material.icons.rounded.DeleteOutline
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.rememberUpdatedState
import androidx.compose.runtime.snapshotFlow
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.foundation.layout.offset
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.PlusJakartaSans
import kotlinx.coroutines.launch
import kotlin.math.roundToInt
import kotlin.math.sqrt

// flutter SpringDescription(mass: 1, stiffness: 420, damping: 24) expressed as a damping ratio
private const val SPRING_STIFFNESS = 420f
private val SPRING_DAMPING_RATIO = 24f / (2f * sqrt(SPRING_STIFFNESS * 1f))

@Composable
fun SpringSwipeableCard(
    accentColor: Color,
    onConfirmed: () -> Unit,
    onRejected: () -> Unit,
    onDragOffsetChanged: ((Double) -> Unit)? = null,
    modifier: Modifier = Modifier,
    child: @Composable () -> Unit,
) {
    val scope = rememberCoroutineScope()
    val offset = remember { Animatable(0f) }
    val screenWidth = with(LocalDensity.current) { LocalConfiguration.current.screenWidthDp.dp.toPx() }
    val currentOnDrag by rememberUpdatedState(onDragOffsetChanged)
    val currentOnConfirmed by rememberUpdatedState(onConfirmed)
    val currentOnRejected by rememberUpdatedState(onRejected)

    // report every offset change, both while dragging and while animating
    LaunchedEffect(offset) {
        snapshotFlow { offset.value }.collect { currentOnDrag?.invoke(it.toDouble()) }
    }

    val dragState = rememberDraggableState { delta ->
        scope.launch { offset.snapTo(offset.value + delta) }
    }

    val dragOffset = offset.value
    val isRight = dragOffset > 1f
    val isLeft = dragOffset < -1f

    Box(
        modifier = modifier.draggable(
            state = dragState,
            orientation = Orientation.Horizontal,
            onDragStarted = { offset.stop() },
            onDragStopped = { velocity ->
                val threshold = screenWidth * 0.50f
                when {
                    offset.value >= threshold -> {
                        offset.animateTo(screenWidth, tween(200, easing = EaseOutCubic))
                        currentOnConfirmed()
                    }
                    offset.value <= -threshold -> {
                        offset.animateTo(-screenWidth, tween(200, easing = EaseOutCubic))
                        currentOnRejected()
                    }
                    else -> offset.animateTo(
                        0f,
                        spring(dampingRatio = SPRING_DAMPING_RATIO, stiffness = SPRING_STIFFNESS),
                        initialVelocity = velocity,
                    )
                }
            },
        ),
    ) {
        if (isRight || isLeft) ActionSlot(isRight)
        Box(Modifier.offset { IntOffset(dragOffset.roundToInt(), 0) }) {
            child()
        }
    }
}

@Composable
private fun BoxScope.ActionSlot(isRight: Boolean) {
    val color = if (isRight) AppColors.neoMint else AppColors.neoCoral
    val bg = if (isRight) Color(0xFF10231C) else Color(0xFF261317)
    val icon = if (isRight) Icons.Rounded.Check else Icons.Rounded.DeleteOutline
    val text = if (isRight) "Benar" else "Salah"
    val shape = RoundedCornerShape(18.dp)

    val badge: @Composable () -> Unit = {
        Box(
            modifier = Modifier
                .size(36.dp)
                .background(color.copy(alpha = 0.20f), CircleShape)
                .border(1.5.dp, color.copy(alpha = 0.50f), CircleShape),
            contentAlignment = Alignment.Center,
        ) {
            Icon(icon, contentDescription = null, tint = color, modifier = Modifier.size(20.dp))
        }
    }
    val label: @Composable () -> Unit = {
        Text(
            text,
            style = TextStyle(
                fontFamily = PlusJakartaSans,
                color = color,
                fontWeight = FontWeight.ExtraBold,
                fontSize = 16.sp,
                letterSpacing = (-0.3).sp,
            ),
        )
    }

    Box(
        modifier = Modifier
            .matchParentSize()
            .clip(shape)
            .background(bg, shape)
            .border(1.5.dp, color.copy(alpha = 0.45f), shape)
            .padding(horizontal = 22.dp),
        contentAlignment = if (isRight) Alignment.CenterStart else Alignment.CenterEnd,
    ) {
        Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.Start) {
            if (isRight) {
                badge()
                Spacer(Modifier.width(12.dp))
                label()
            } else {
                label()
                Spacer(Modifier.width(12.dp))
                badge()
            }
        }
    }
}
