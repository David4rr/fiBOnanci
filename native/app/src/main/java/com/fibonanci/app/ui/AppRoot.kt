package com.fibonanci.app.ui

import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.togetherWith
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.compose.LifecycleEventEffect
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.fibonanci.app.core.notification.NotificationBridge
import com.fibonanci.app.core.reminders.SubscriptionAutoDeductRunner
import com.fibonanci.app.ui.common.AppLockGate
import com.fibonanci.app.ui.onboarding.OnboardingScreen
import com.fibonanci.app.ui.shell.FibonanciSplashGate
import com.fibonanci.app.ui.simple.AtelierTheme
import com.fibonanci.app.ui.simple.SimpleShell
import com.fibonanci.app.ui.theme.AppColors
import kotlinx.coroutines.launch

private enum class RootScreen { Loading, Onboarding, Rich, Simple }

// picks what the user sees: first-run onboarding, or the app in the look they chose.
@Composable
fun AppRoot() {
    val vm = LocalFinance.current
    val state by vm.state.collectAsStateWithLifecycle()
    val screen = when {
        state.needsOnboarding -> RootScreen.Onboarding
        state.status != FinanceStatus.Success -> RootScreen.Loading
        state.uiStyle == UiStyle.iblameraihan -> RootScreen.Simple
        else -> RootScreen.Rich
    }

    AnimatedContent(
        targetState = screen,
        transitionSpec = { fadeIn(tween(350)) togetherWith fadeOut(tween(250)) },
        label = "root",
    ) { target ->
        when (target) {
            RootScreen.Loading -> Box(Modifier.fillMaxSize().background(AppColors.canvasBg))
            RootScreen.Onboarding -> AtelierTheme { OnboardingScreen() }
            RootScreen.Rich -> FibonanciSplashGate { MainShell() }
            RootScreen.Simple -> AppLockGate {
                SimpleBackgroundWork()
                AtelierTheme { SimpleShell() }
            }
        }
    }
}

// the simple look keeps bank-notification capture and auto-deduct running, like the rich shell does.
@Composable
private fun SimpleBackgroundWork() {
    val vm = LocalFinance.current
    val context = LocalContext.current
    val scope = rememberCoroutineScope()
    LaunchedEffect(Unit) {
        NotificationBridge.startListening(context, vm.repository)
        SubscriptionAutoDeductRunner.runAutoDeduct(context, vm.repository)
    }
    LifecycleEventEffect(Lifecycle.Event.ON_RESUME) {
        NotificationBridge.onAppResumed(context, vm.repository)
        scope.launch { SubscriptionAutoDeductRunner.runAutoDeduct(context, vm.repository) }
    }
}
