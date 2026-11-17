package com.fibonanci.app.ui.common

import androidx.compose.animation.ContentTransform
import androidx.compose.animation.SizeTransform
import androidx.compose.animation.core.CubicBezierEasing
import androidx.compose.animation.core.EaseInCubic
import androidx.compose.animation.core.Easing
import androidx.compose.animation.core.snap
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.slideInHorizontally
import androidx.compose.animation.slideOutHorizontally
import androidx.compose.animation.togetherWith
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.pager.HorizontalPager
import androidx.compose.foundation.pager.PagerState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.rememberUpdatedState
import androidx.compose.runtime.snapshotFlow
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.graphicsLayer
import kotlinx.coroutines.flow.drop
import kotlin.math.abs

/**
 * shared page-to-page transition container: a pager whose pages cross-fade
 * (opacity 1 -> 0.5) and scale (1.0 -> 0.96) with their distance from the current page.
 */
object SmoothPageView {
    const val defaultDuration = 340
    val defaultCurve: Easing = CubicBezierEasing(0.22f, 1.0f, 0.36f, 1.0f)

    suspend fun animateTo(controller: PagerState, page: Int) {
        controller.animateScrollToPage(
            page,
            animationSpec = tween(defaultDuration, easing = defaultCurve),
        )
    }

    /**
     * AnimatedSwitcher header transition: the incoming child fades in while sliding from
     * 3.5% to the right, the outgoing child plays the same in reverse.
     */
    fun headerTitleTransition(
        durationMillis: Int,
        switchInCurve: Easing = defaultCurve,
        switchOutCurve: Easing = EaseInCubic,
    ): ContentTransform {
        val enter = fadeIn(tween(durationMillis, easing = switchInCurve)) +
            slideInHorizontally(tween(durationMillis, easing = switchInCurve)) { (it * 0.035f).toInt() }
        val exit = fadeOut(tween(durationMillis, easing = switchOutCurve)) +
            slideOutHorizontally(tween(durationMillis, easing = switchOutCurve)) { (it * 0.035f).toInt() }
        // stack layout: size follows the new child immediately
        return ContentTransform(enter, exit, sizeTransform = SizeTransform(clip = false) { _, _ -> snap() })
    }
}

@Composable
fun SmoothPageView(
    controller: PagerState,
    children: List<@Composable () -> Unit>,
    allowImplicitScrolling: Boolean = true,
    userScrollEnabled: Boolean = false,
    onPageChanged: ((Int) -> Unit)? = null,
    modifier: Modifier = Modifier,
) {
    val pageChanged by rememberUpdatedState(onPageChanged)
    LaunchedEffect(controller) {
        // PageView.onPageChanged fires when the rounded page changes, not for the initial page
        snapshotFlow { controller.currentPage }.drop(1).collect { pageChanged?.invoke(it) }
    }

    HorizontalPager(
        state = controller,
        modifier = modifier,
        userScrollEnabled = userScrollEnabled,
        beyondViewportPageCount = if (allowImplicitScrolling) 1 else 0,
    ) { index ->
        Box(
            Modifier.graphicsLayer {
                val page = controller.currentPage + controller.currentPageOffsetFraction
                val delta = abs(page - index).coerceIn(0f, 1f)
                if (delta > 0.001f) {
                    alpha = (1f - delta * 0.5f).coerceIn(0f, 1f)
                    val scale = 1f - delta * 0.04f
                    scaleX = scale
                    scaleY = scale
                }
            },
        ) {
            children[index]()
        }
    }
}
