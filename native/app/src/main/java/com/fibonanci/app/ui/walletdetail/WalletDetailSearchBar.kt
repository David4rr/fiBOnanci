package com.fibonanci.app.ui.walletdetail

import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.fibonanci.app.ui.common.ExpandableSearchFilterBar

// the dart searchController text is carried by searchQuery (raw field text)
@Composable
fun WalletDetailSearchBar(
    searchQuery: String,
    selectedFilter: WalletTxFilter,
    onSearchChanged: (String) -> Unit,
    onClearSearch: () -> Unit,
    onFilterChanged: (WalletTxFilter) -> Unit,
    modifier: Modifier = Modifier,
) {
    ExpandableSearchFilterBar(
        searchQuery = searchQuery,
        typeFilter = if (selectedFilter == WalletTxFilter.all) "all" else selectedFilter.name,
        showWalletFilter = false,
        padding = PaddingValues(0.dp),
        borderRadius = 23.dp,
        showActiveChipsBelow = false,
        onSearchChanged = onSearchChanged,
        onClearSearch = onClearSearch,
        onFilterApplied = { type, _ ->
            when (type) {
                "income" -> onFilterChanged(WalletTxFilter.income)
                "expense" -> onFilterChanged(WalletTxFilter.expense)
                "transfer" -> onFilterChanged(WalletTxFilter.transfer)
                else -> onFilterChanged(WalletTxFilter.all)
            }
        },
        modifier = modifier,
    )
}
