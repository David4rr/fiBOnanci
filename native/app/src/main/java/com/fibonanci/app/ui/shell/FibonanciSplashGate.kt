package com.fibonanci.app.ui.shell

import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.tween
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.MutableState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Rect

/// 3-stage mathematical vault splash gate.
/// - stage 1 (0.00 - 0.48): central monolith rises & dual vault gates slide open
/// - stage 2 (0.28 - 0.48): breathing pulse + wordmark reveal
/// - stage 3 (0.48 - 1.00): shared element logo flight from center to the dashboard header
object FibonanciSplashGate {
    val isSplashActive: MutableState<Boolean> = mutableStateOf(false)

    // window bounds of the dashboard header logo / wordmark, reported by the header
    var dashboardLogoBounds: Rect? by mutableStateOf(null)
    var dashboardTextBounds: Rect? by mutableStateOf(null)
}

@Composable
fun FibonanciSplashGate(
    durationMillis: Int = 1650,
    content: @Composable () -> Unit,
) {
    var isDone by rememberSaveable { mutableStateOf(false) }
    val controller = remember {
        // same as dart initState: flag goes up before the first frame
        if (!isDone) FibonanciSplashGate.isSplashActive.value = true
        Animatable(0f)
    }

    LaunchedEffect(Unit) {
        if (isDone) return@LaunchedEffect
        controller.animateTo(1f, tween(durationMillis, easing = LinearEasing))
        FibonanciSplashGate.isSplashActive.value = false
        isDone = true
    }

    DisposableEffect(Unit) {
        onDispose { FibonanciSplashGate.isSplashActive.value = false }
    }

    if (isDone) {
        content()
        return
    }

    Box(Modifier.fillMaxSize()) {
        content()
        FibonanciSplashOverlay(
            animation = { controller.value },
            targetBounds = { FibonanciSplashGate.dashboardLogoBounds },
            targetTextBounds = { FibonanciSplashGate.dashboardTextBounds },
            modifier = Modifier.fillMaxSize(),
        )
    }
}
