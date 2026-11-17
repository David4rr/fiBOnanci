package com.fibonanci.app.ui.subscription

import androidx.activity.compose.BackHandler
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalFocusManager
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.fibonanci.app.core.format.AppCurrency
import com.fibonanci.app.data.db.SubscriptionEntry
import com.fibonanci.app.data.db.WalletEntry
import com.fibonanci.app.ui.LocalFinance
import com.fibonanci.app.ui.common.ExpandableModalSheet
import com.fibonanci.app.ui.common.ModalHost
import com.fibonanci.app.ui.common.SmoothPageView
import com.fibonanci.app.ui.common.expandableSheetHeaderDrag
import com.fibonanci.app.ui.common.rememberExpandableModalSheetState
import kotlinx.coroutines.launch

fun showSubscriptionDetailScreen(
    host: ModalHost,
    subscription: SubscriptionEntry,
    wallet: WalletEntry,
    indexOverride: Int? = null,
    initialChildSize: Double = 1.0,
) {
    showSubscriptionDetail(
        host,
        subscription = subscription,
        wallet = wallet,
        indexOverride = indexOverride,
        initialChildSize = initialChildSize,
    )
}

// full-screen modal screen for subscription and installment details with reactive state and drag dismiss.
@Composable
fun SubscriptionDetailScreen(
    subscriptionId: String,
    initialWallet: WalletEntry,
    indexOverride: Int? = null,
    initialChildSize: Double = 1.0,
    onDismiss: () -> Unit,
) {
    val vm = LocalFinance.current
    val state by vm.state.collectAsStateWithLifecycle()
    val focusManager = LocalFocusManager.current
    val scope = rememberCoroutineScope()
    val pagerState = rememberPagerState(initialPage = 0) { 2 }
    val sheet = rememberExpandableModalSheetState()
    var currentTab by remember { mutableIntStateOf(0) }

    fun goToEditTab() {
        focusManager.clearFocus()
        currentTab = 1
        scope.launch { SmoothPageView.animateTo(pagerState, 1) }
    }

    fun goToDetailsTab() {
        focusManager.clearFocus()
        currentTab = 0
        scope.launch { SmoothPageView.animateTo(pagerState, 0) }
    }

    val currency = state.profile.currency
    val currencyFormatter: (Double) -> String = { AppCurrency.format(it, currency) }
    val sub = state.subscriptions.firstOrNull { it.id == subscriptionId }
    if (sub == null) {
        LaunchedEffect(Unit) { onDismiss() }
        return
    }

    val wallet = state.wallets.firstOrNull { it.id == sub.walletId } ?: initialWallet
    val subIdx = state.subscriptions.indexOfFirst { it.id == sub.id }
    val effectiveIndex = indexOverride ?: if (subIdx >= 0) subIdx else null

    // pop scope: back on the edit tab returns to details instead of closing
    BackHandler(enabled = currentTab == 1) { goToDetailsTab() }

    ExpandableModalSheet(
        onDismiss = onDismiss,
        initialChildSize = initialChildSize,
        minChildSize = 0.25,
        maxChildSize = 1.0,
        snapSizes = listOf(initialChildSize, 1.0),
        state = sheet,
    ) { _ ->
        Column(Modifier.fillMaxSize()) {
            SubscriptionDetailAppBar(
                subscription = sub,
                currencyFormatter = currencyFormatter,
                onDismiss = onDismiss,
                isEditing = currentTab == 1,
                onReturnToDetails = { goToDetailsTab() },
                modifier = Modifier.expandableSheetHeaderDrag(sheet),
            )
            Box(Modifier.weight(1f).fillMaxWidth()) {
                SmoothPageView(
                    controller = pagerState,
                    allowImplicitScrolling = false,
                    children = listOf<@Composable () -> Unit>(
                        {
                            SubscriptionDetailContent(
                                subscription = sub,
                                wallet = wallet,
                                indexOverride = effectiveIndex,
                                currencyFormatter = currencyFormatter,
                                onEdit = { goToEditTab() },
                                onDismiss = onDismiss,
                            )
                        },
                        {
                            SubscriptionDetailEditTab(
                                subscription = sub,
                                onSaved = onDismiss,
                                onReturnToDetails = { goToDetailsTab() },
                                onDismiss = onDismiss,
                            )
                        },
                    ),
                )
            }
        }
    }
}
