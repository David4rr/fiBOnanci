package com.fibonanci.app.ui.transaction

import androidx.compose.runtime.Composable
import com.fibonanci.app.data.db.WalletEntry
import com.fibonanci.app.ui.common.ExpandableSearchFilterBar

// the dart search controller is folded into searchQuery (the raw field text) + onSearchChanged
@Composable
fun ExpenseHistorySearchBar(
    searchQuery: String,
    typeFilter: String,
    walletFilter: String?,
    wallets: List<WalletEntry>,
    onSearchChanged: (String) -> Unit,
    onClearSearch: () -> Unit,
    onFilterApplied: (type: String, walletId: String?) -> Unit,
    onClearTypeFilter: () -> Unit,
    onClearWalletFilter: () -> Unit,
) {
    ExpandableSearchFilterBar(
        searchQuery = searchQuery,
        typeFilter = typeFilter,
        walletFilter = walletFilter,
        wallets = wallets,
        onSearchChanged = onSearchChanged,
        onClearSearch = onClearSearch,
        onFilterApplied = onFilterApplied,
        onClearTypeFilter = onClearTypeFilter,
        onClearWalletFilter = onClearWalletFilter,
    )
}
