package com.fibonanci.app.ui

import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.core.CubicBezierEasing
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.scaleIn
import androidx.compose.animation.slideInHorizontally
import androidx.compose.animation.slideOutHorizontally
import androidx.compose.animation.togetherWith
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.CheckCircle
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.compose.LifecycleEventEffect
import com.fibonanci.app.core.notification.NotificationBridge
import com.fibonanci.app.core.reminders.SubscriptionAutoDeductRunner
import com.fibonanci.app.ui.common.AppLockGate
import com.fibonanci.app.ui.common.LocalModalHost
import com.fibonanci.app.ui.common.ModalHostLayer
import com.fibonanci.app.ui.dashboard.DashboardScreen
import com.fibonanci.app.ui.pocket.showAddPocketModal
import com.fibonanci.app.ui.settings.SettingsScreen
import com.fibonanci.app.ui.shell.BottomNavDock
import com.fibonanci.app.ui.subscription.SubscriptionScreen
import com.fibonanci.app.ui.subscription.showAddSubscriptionModal
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.transaction.showQuickTransactionInputSheet
import com.fibonanci.app.ui.wallet.WalletScreen
import com.fibonanci.app.ui.wallet.showAddWalletModal
import kotlinx.coroutines.launch

private val tabInCurve = CubicBezierEasing(0.22f, 1f, 0.36f, 1f)
private val tabOutCurve = CubicBezierEasing(0.32f, 0f, 0.67f, 0f)

// four tabs under a floating dock; modals and routes are drawn by the host layer on top.
@Composable
fun MainShell() {
    val vm = LocalFinance.current
    val host = LocalModalHost.current
    val context = LocalContext.current
    val scope = rememberCoroutineScope()
    var currentIndex by remember { mutableIntStateOf(0) }
    var walletSegment by remember { mutableIntStateOf(0) }

    val onAutoLogged: (String) -> Unit = { msg ->
        host.showSnackBar(
            message = "Notifikasi Otomatis Tercatat!\n$msg",
            background = AppColors.neoMint,
            contentColor = AppColors.textDarkPrimary,
            icon = Icons.Rounded.CheckCircle,
        )
    }

    LaunchedEffect(Unit) {
        NotificationBridge.startListening(context, vm.repository, onAutoLogged)
        SubscriptionAutoDeductRunner.runAutoDeduct(context, vm.repository)
    }
    LifecycleEventEffect(Lifecycle.Event.ON_RESUME) {
        NotificationBridge.onAppResumed(context, vm.repository, onAutoLogged)
        scope.launch { SubscriptionAutoDeductRunner.runAutoDeduct(context, vm.repository) }
    }

    AppLockGate {
        Box(Modifier.fillMaxSize().background(AppColors.canvasBg)) {
            AnimatedContent(
                targetState = currentIndex,
                transitionSpec = {
                    val direction = if (targetState > initialState) 1 else -1
                    (fadeIn(tween(300, easing = tabInCurve)) +
                        slideInHorizontally(tween(300, easing = tabInCurve)) { (it * 0.05f * direction).toInt() } +
                        scaleIn(tween(300, easing = tabInCurve), initialScale = 0.985f)) togetherWith
                        (fadeOut(tween(300, easing = tabOutCurve)) +
                            slideOutHorizontally(tween(300, easing = tabOutCurve)) { (-it * 0.05f * direction).toInt() })
                },
                label = "tab",
            ) { index ->
                when (index) {
                    1 -> SubscriptionScreen(onAddSubscription = { showAddSubscriptionModal(host) })
                    2 -> WalletScreen(initialSegment = walletSegment, onSegmentChanged = { walletSegment = it })
                    3 -> SettingsScreen()
                    else -> DashboardScreen(
                        onNavigateToWallets = { currentIndex = 2 },
                        onNavigateToSubscriptions = { currentIndex = 1 },
                    )
                }
            }

            BottomNavDock(
                currentIndex = currentIndex,
                onTapIndex = { currentIndex = it },
                onAddAction = {
                    when (currentIndex) {
                        1 -> showAddSubscriptionModal(host)
                        2 -> if (walletSegment == 1) showAddPocketModal(host) else showAddWalletModal(host)
                        else -> showQuickTransactionInputSheet(host)
                    }
                },
                onAddLongPress = { showQuickTransactionInputSheet(host) },
                modifier = Modifier.align(Alignment.BottomCenter),
            )

            ModalHostLayer(host)
        }
    }
}
