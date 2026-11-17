package com.fibonanci.app.ui.common

import androidx.compose.animation.core.animate
import androidx.compose.animation.core.EaseOutCubic
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.snap
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.gestures.Orientation
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.gestures.draggable
import androidx.compose.foundation.gestures.rememberDraggableState
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.displayCutout
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.systemBars
import androidx.compose.foundation.layout.union
import androidx.compose.foundation.layout.windowInsetsPadding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.runtime.Stable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.rememberUpdatedState
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.composed
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.RectangleShape
import androidx.compose.ui.input.nestedscroll.NestedScrollConnection
import androidx.compose.ui.input.nestedscroll.NestedScrollSource
import androidx.compose.ui.input.nestedscroll.nestedScroll
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.Velocity
import androidx.compose.ui.unit.dp
import com.fibonanci.app.ui.theme.AppColors
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch
import kotlin.math.abs
import kotlin.math.roundToInt

/**
 * replaces the dart GlobalKey<ExpandableModalSheetState>: hoist it with
 * [rememberExpandableModalSheetState], pass it to [ExpandableModalSheet] and drive the
 * header drag through the handle* methods (or [expandableSheetHeaderDrag]).
 * deltas and velocities are in px / px per second, positive = downwards.
 */
@Stable
class ExpandableModalSheetState internal constructor() {
    internal var size by mutableFloatStateOf(1f)
    internal var dragOffset by mutableFloatStateOf(0f) // logical px, like the dart value
    internal var isDragging by mutableStateOf(false)
    private var isDismissing = false
    private var dragStartSize = 1f

    // bound by the sheet on every composition
    internal var initialChildSize = 1f
    internal var minChildSize = 0.25f
    internal var maxChildSize = 1f
    internal var snapSizes: List<Float> = listOf(0.85f, 1f)
    internal var heightPx = 0f
    internal var density = 1f
    internal var onDismiss: () -> Unit = {}
    internal var scope: CoroutineScope? = null
    private var initialized = false
    private var animJob: Job? = null

    val currentSize: Double get() = size.toDouble()

    private val baseSize: Float
        get() = if (initialChildSize < maxChildSize) {
            initialChildSize
        } else {
            snapSizes.firstOrNull() ?: 0.85f
        }

    internal fun initialize() {
        if (initialized) return
        initialized = true
        size = initialChildSize
    }

    internal fun dismiss() {
        if (isDismissing) return
        isDismissing = true
        onDismiss()
    }

    // DraggableScrollableNotification: extent at or below min + 0.05 closes the sheet
    internal fun setExtent(newSize: Float) {
        animJob?.cancel()
        size = newSize.coerceIn(minChildSize, maxChildSize)
        if (size <= minChildSize + 0.05f) dismiss()
    }

    internal fun animateExtent(target: Float) {
        animJob?.cancel()
        animJob = scope?.launch {
            animate(size, target, animationSpec = tween(220, easing = EaseOutCubic)) { value, _ -> size = value }
            if (target <= minChildSize + 0.05f) dismiss()
        }
    }

    // DraggableScrollableSheet snap: fling picks the next snap size in its direction, otherwise the nearest
    internal fun settle(velocityPx: Float) {
        val snaps = (listOf(minChildSize) + effectiveSnapSizes() + listOf(maxChildSize)).distinct().sorted()
        val current = size
        val growVelocity = -velocityPx / density
        val target = when {
            growVelocity > 50f -> snaps.firstOrNull { it > current + 0.001f } ?: maxChildSize
            growVelocity < -50f -> snaps.lastOrNull { it < current - 0.001f } ?: minChildSize
            else -> snaps.minBy { abs(it - current) }
        }
        animateExtent(target)
    }

    internal fun effectiveSnapSizes(): List<Float> {
        val sorted = snapSizes.distinct().sorted().toMutableList()
        if (sorted.size == 1 && sorted.first() == 1f) sorted.add(0, 0.85f)
        return sorted
    }

    fun handleHeaderDragStart() {
        if (isDismissing) return
        isDragging = true
        dragStartSize = size
    }

    fun handleHeaderDragUpdate(delta: Float) {
        if (isDismissing) return
        val d = delta / density
        if (!isDragging) {
            dragStartSize = size
            isDragging = true
        }
        if ((size <= baseSize + 0.02f && d > 0f) || dragOffset > 0f) {
            dragOffset = (dragOffset + d).coerceIn(0f, 1000f)
            return
        }
        if (heightPx <= 0f) return
        setExtent(size - delta / heightPx)
    }

    fun handleHeaderDragEnd(velocity: Float) {
        if (isDismissing) return
        isDragging = false
        val v = velocity / density

        if (dragOffset > 0f) {
            if (v > 160f || dragOffset > 50f) {
                dismiss()
                return
            }
            dragOffset = 0f
            return
        }

        val current = size
        val wasAtMax = dragStartSize >= maxChildSize - 0.04f

        if (v > 160f && (!wasAtMax || v > 350f)) {
            dismiss()
            return
        }
        if (v < -160f) {
            animateExtent(maxChildSize)
            return
        }
        if (!wasAtMax && (current < dragStartSize - 0.04f || current <= minChildSize + 0.08f)) {
            dismiss()
            return
        }
        if (wasAtMax && (current <= minChildSize + 0.08f || current < baseSize - 0.22f)) {
            dismiss()
            return
        }
        if (current >= maxChildSize - 0.05f) {
            animateExtent(maxChildSize)
            return
        }
        animateExtent(baseSize)
    }
}

@Composable
fun rememberExpandableModalSheetState(): ExpandableModalSheetState = remember { ExpandableModalSheetState() }

/** wires a vertical drag on the header to the sheet's header drag handlers. */
fun Modifier.expandableSheetHeaderDrag(state: ExpandableModalSheetState): Modifier = composed {
    this.draggable(
        state = rememberDraggableState { state.handleHeaderDragUpdate(it) },
        orientation = Orientation.Vertical,
        onDragStarted = { state.handleHeaderDragStart() },
        onDragStopped = { velocity -> state.handleHeaderDragEnd(velocity) },
    )
}

/**
 * expandable modal sheet that starts at [initialChildSize] and expands to full screen
 * when dragged or scrolled up. dragging below [minChildSize] or tapping the backdrop dismisses it.
 * inner scrollables couple to the sheet extent through nested scrolling.
 */
@Composable
fun ExpandableModalSheet(
    onDismiss: () -> Unit,
    initialChildSize: Double = 1.0,
    minChildSize: Double = 0.25,
    maxChildSize: Double = 1.0,
    snapSizes: List<Double> = listOf(0.85, 1.0),
    backgroundColor: Color = AppColors.canvasBg,
    borderColor: Color = AppColors.canvasBorder,
    topRadius: Dp = 28.dp,
    state: ExpandableModalSheetState = rememberExpandableModalSheetState(),
    modifier: Modifier = Modifier,
    builder: @Composable (currentSize: Double) -> Unit,
) {
    val scope = rememberCoroutineScope()
    val density = LocalDensity.current.density
    val dismiss by rememberUpdatedState(onDismiss)

    state.initialChildSize = initialChildSize.toFloat()
    state.minChildSize = minChildSize.toFloat()
    state.maxChildSize = maxChildSize.toFloat()
    state.snapSizes = snapSizes.map { it.toFloat() }
    state.density = density
    state.scope = scope
    state.onDismiss = { dismiss() }
    remember(state) { state.initialize() }

    val nestedScroll = remember(state) {
        object : NestedScrollConnection {
            override fun onPreScroll(available: Offset, source: NestedScrollSource): Offset {
                // finger moving up: grow the sheet before the content scrolls
                if (available.y < 0f && source == NestedScrollSource.UserInput &&
                    state.size < state.maxChildSize && state.heightPx > 0f
                ) {
                    val before = state.size
                    val target = (before - available.y / state.heightPx).coerceAtMost(state.maxChildSize)
                    state.setExtent(target)
                    return Offset(0f, -(target - before) * state.heightPx)
                }
                return Offset.Zero
            }

            override fun onPostScroll(consumed: Offset, available: Offset, source: NestedScrollSource): Offset {
                // content already at the top and finger moving down: shrink the sheet
                if (available.y > 0f && source == NestedScrollSource.UserInput && state.heightPx > 0f) {
                    state.setExtent(state.size - available.y / state.heightPx)
                    return Offset(0f, available.y)
                }
                return Offset.Zero
            }

            override suspend fun onPreFling(available: Velocity): Velocity {
                val sizeNow = state.size
                val atSnap = state.effectiveSnapSizes().any { abs(it - sizeNow) < 0.001f } ||
                    abs(state.maxChildSize - sizeNow) < 0.001f
                if (!atSnap) {
                    state.settle(available.y)
                    return available
                }
                return Velocity.Zero
            }
        }
    }

    val offsetDp by animateFloatAsState(
        targetValue = state.dragOffset,
        animationSpec = if (state.isDragging) snap() else tween(200, easing = EaseOutCubic),
        label = "sheetDragOffset",
    )

    BoxWithConstraints(modifier.fillMaxSize()) {
        state.heightPx = constraints.maxHeight.toFloat()

        // backdrop tap closes the sheet
        Box(
            Modifier
                .fillMaxSize()
                .pointerInput(state) { detectTapGestures { state.dismiss() } },
        )

        val currentSize = state.size
        val fullScreen = currentSize >= 0.99f
        val shape = if (fullScreen) RectangleShape else RoundedCornerShape(topStart = topRadius, topEnd = topRadius)

        Box(
            Modifier
                .align(Alignment.BottomCenter)
                .offset { IntOffset(0, (offsetDp * density).roundToInt()) }
                .fillMaxWidth()
                .height(maxHeight * currentSize)
                .nestedScroll(nestedScroll)
                .clip(shape)
                .background(backgroundColor, shape)
                .then(if (fullScreen) Modifier else Modifier.border(1.dp, borderColor, shape))
                // swallow taps inside the sheet so the backdrop does not close it
                .pointerInput(Unit) { detectTapGestures { } }
                .windowInsetsPadding(WindowInsets.systemBars.union(WindowInsets.displayCutout)),
        ) {
            builder(currentSize.toDouble())
        }
    }
}
