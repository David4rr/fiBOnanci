package com.fibonanci.app.ui.walletdetail

import androidx.compose.foundation.lazy.LazyListState
import androidx.compose.foundation.pager.PagerState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.rememberUpdatedState
import androidx.compose.runtime.snapshotFlow
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalDensity
import com.fibonanci.app.data.db.TransactionEntry
import com.fibonanci.app.data.db.WalletEntry
import com.fibonanci.app.ui.common.SmoothPageView
import com.fibonanci.app.ui.transaction.TransactionDetailModal
import com.fibonanci.app.ui.transaction.TransactionModal

@Composable
fun WalletDetailPageView(
    pageController: PagerState,
    activeSubTab: Int = 1,
    scrollController: LazyListState,
    wallet: WalletEntry,
    cardIndex: Int,
    fmt: (Double) -> String,
    cardColor: Color,
    allWallets: List<WalletEntry>,
    transactions: List<TransactionEntry>,
    filteredTx: List<TransactionEntry>,
    searchText: String,
    searchQuery: String,
    selectedFilter: WalletTxFilter,
    onSearchChanged: (String) -> Unit,
    onClearSearch: () -> Unit,
    onFilterChanged: (WalletTxFilter) -> Unit,
    onScrollOffsetChanged: (Float) -> Unit,
    onEditBalance: () -> Unit,
    onAddTransaction: () -> Unit,
    onEditTransaction: (TransactionEntry) -> Unit,
    selectedTransaction: TransactionEntry?,
    onReturnToDetails: () -> Unit,
    isPickingApp: Boolean = false,
    onPickingAppChanged: ((Boolean) -> Unit)? = null,
    modifier: Modifier = Modifier,
) {
    val density = LocalDensity.current
    val currentOnScroll by rememberUpdatedState(onScrollOffsetChanged)

    // dart ScrollNotification pixels → vertical offset in dp; items past the first count as fully scrolled
    LaunchedEffect(scrollController) {
        snapshotFlow {
            if (scrollController.firstVisibleItemIndex > 0) {
                Float.MAX_VALUE
            } else {
                with(density) { scrollController.firstVisibleItemScrollOffset.toDp().value }
            }
        }.collect { currentOnScroll(it) }
    }

    SmoothPageView(
        controller = pageController,
        allowImplicitScrolling = false,
        modifier = modifier,
        children = listOf(
            {
                WalletDetailScrollView(
                    scrollController = scrollController,
                    wallet = wallet,
                    cardIndex = if (cardIndex >= 0) cardIndex else 0,
                    fmt = fmt,
                    cardColor = cardColor,
                    allWallets = allWallets,
                    transactions = transactions,
                    filteredTx = filteredTx,
                    searchText = searchText,
                    searchQuery = searchQuery,
                    selectedFilter = selectedFilter,
                    onSearchChanged = onSearchChanged,
                    onClearSearch = onClearSearch,
                    onFilterChanged = onFilterChanged,
                    onEditBalance = onEditBalance,
                    onAddTransaction = onAddTransaction,
                    onEditTransaction = onEditTransaction,
                )
            },
            {
                when (activeSubTab) {
                    1 -> WalletDetailEditTab(
                        wallet = wallet,
                        onReturnToDetails = onReturnToDetails,
                        isPickingApp = isPickingApp,
                        onPickingAppChanged = onPickingAppChanged,
                    )
                    2 -> TransactionModal(
                        initialWalletId = wallet.id,
                        isInline = true,
                        onClose = onReturnToDetails,
                        onSaved = onReturnToDetails,
                    )
                    else -> if (selectedTransaction != null) {
                        TransactionDetailModal(
                            transaction = selectedTransaction,
                            isInline = true,
                            onClose = onReturnToDetails,
                            onSaved = onReturnToDetails,
                            onDeleted = onReturnToDetails,
                        )
                    }
                }
            },
        ),
    )
}
