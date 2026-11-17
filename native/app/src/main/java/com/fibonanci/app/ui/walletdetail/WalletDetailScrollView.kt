package com.fibonanci.app.ui.walletdetail

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyListState
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import com.fibonanci.app.data.db.TransactionEntry
import com.fibonanci.app.data.db.WalletEntry

// dart ScrollController → LazyListState; searchController → searchText (raw field text)
@Composable
fun WalletDetailScrollView(
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
    onEditBalance: (() -> Unit)? = null,
    onAddTransaction: (() -> Unit)? = null,
    onEditTransaction: ((TransactionEntry) -> Unit)? = null,
    modifier: Modifier = Modifier,
) {
    LazyColumn(state = scrollController, modifier = modifier.fillMaxSize()) {
        item(key = "wallet_detail_card") {
            Box(
                modifier = Modifier.fillMaxWidth().padding(start = 20.dp, top = 4.dp, end = 20.dp),
                contentAlignment = Alignment.Center,
            ) {
                TactileHeroCard(
                    wallet = wallet,
                    cardIndex = if (cardIndex >= 0) cardIndex else 0,
                    fmt = fmt,
                    cardColor = cardColor,
                    allWallets = allWallets,
                )
            }
        }
        item(key = "wallet_detail_gap_1") { Spacer(Modifier.height(16.dp)) }
        item(key = "wallet_detail_actions") {
            WalletDetailActionsAndChart(
                wallet = wallet,
                cardColor = cardColor,
                transactions = transactions,
                onEditBalance = onEditBalance,
                onAddTransaction = onAddTransaction,
            )
        }
        item(key = "wallet_detail_gap_2") { Spacer(Modifier.height(14.dp)) }
        WalletDetailHistorySection(
            wallet = wallet,
            filteredTx = filteredTx,
            searchText = searchText,
            searchQuery = searchQuery,
            selectedFilter = selectedFilter,
            fmt = fmt,
            onSearchChanged = onSearchChanged,
            onClearSearch = onClearSearch,
            onFilterChanged = onFilterChanged,
            onEditTransaction = onEditTransaction,
        )
        item(key = "wallet_detail_gap_3") { Spacer(Modifier.height(32.dp)) }
    }
}
