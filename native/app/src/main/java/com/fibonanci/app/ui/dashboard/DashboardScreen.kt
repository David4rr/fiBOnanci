package com.fibonanci.app.ui.dashboard

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.WindowInsetsSides
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.only
import androidx.compose.foundation.layout.safeDrawing
import androidx.compose.foundation.layout.windowInsetsPadding
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.fibonanci.app.core.format.AppCurrency
import com.fibonanci.app.core.nowMillis
import com.fibonanci.app.core.toLocalDate
import com.fibonanci.app.domain.CashflowAnalyticsService
import com.fibonanci.app.ui.LocalFinance
import com.fibonanci.app.ui.common.LocalModalHost
import com.fibonanci.app.ui.common.ModalKind
import com.fibonanci.app.ui.subscription.SubscriptionScreen
import com.fibonanci.app.ui.subscription.showAddSubscriptionModal
import com.fibonanci.app.ui.theme.AppColors

@Composable
fun DashboardScreen(
    onNavigateToWallets: (() -> Unit)? = null,
    onNavigateToSubscriptions: (() -> Unit)? = null,
) {
    val vm = LocalFinance.current
    val host = LocalModalHost.current
    val state by vm.state.collectAsStateWithLifecycle()
    var searchText by rememberSaveable { mutableStateOf("") }
    var searchQuery by rememberSaveable { mutableStateOf("") }
    var typeFilter by rememberSaveable { mutableStateOf("all") }
    var walletFilter by rememberSaveable { mutableStateOf<String?>(null) }

    val wallets = state.wallets
    val allTransactions = state.transactions
    val today = nowMillis().toLocalDate()
    val todayTransactions = allTransactions.filter { it.transactionDate.toLocalDate() == today }

    val isFiltering = searchQuery.isNotEmpty() || typeFilter != "all" || walletFilter != null
    val baseTransactions = if (isFiltering) allTransactions else todayTransactions
    val filteredTransactions = CashflowAnalyticsService.filterTransactions(
        transactions = baseTransactions,
        wallets = wallets,
        query = searchQuery,
        typeFilter = typeFilter,
        walletFilter = walletFilter,
    )
    val currency = state.profile.currency

    Column(
        Modifier
            .fillMaxSize()
            .background(AppColors.canvasBg)
            .windowInsetsPadding(WindowInsets.safeDrawing.only(WindowInsetsSides.Top + WindowInsetsSides.Horizontal)),
    ) {
        DashboardHeader(
            profileId = state.profile.id,
            username = state.profile.username,
            avatarPath = state.profile.avatarPath,
            walletCount = wallets.size,
            txCount = allTransactions.size,
        )
        if (wallets.isEmpty()) {
            DashboardEmptyWalletView()
        } else {
            DashboardSearchBar(
                searchQuery = searchText,
                typeFilter = typeFilter,
                walletFilter = walletFilter,
                wallets = wallets,
                onSearchChanged = { value ->
                    searchText = value
                    searchQuery = value.trim().lowercase()
                },
                onClearSearch = {
                    searchText = ""
                    searchQuery = ""
                },
                onFilterApplied = { type, walletId ->
                    typeFilter = type
                    walletFilter = walletId
                },
                onClearTypeFilter = { typeFilter = "all" },
                onClearWalletFilter = { walletFilter = null },
            )
            DashboardBentoGrid(
                metrics = state.metrics,
                wallets = wallets,
                subscriptions = state.subscriptions,
                currencyFormatter = { AppCurrency.format(it, currency) },
                isBalanceHidden = state.isBalanceHidden,
                onNavigateToWallets = { onNavigateToWallets?.invoke() },
                onNavigateToSubscriptions = {
                    if (onNavigateToSubscriptions != null) {
                        onNavigateToSubscriptions()
                    } else {
                        host.show(ModalKind.FullScreen) {
                            SubscriptionScreen(onAddSubscription = { showAddSubscriptionModal(host) })
                        }
                    }
                },
            )
            DashboardHistorySection(
                searchQuery = searchQuery,
                isFiltering = isFiltering,
                filteredTransactions = filteredTransactions,
                allTransactions = allTransactions,
                wallets = wallets,
                categories = state.categories,
                pockets = state.pockets,
            )
        }
    }
}
