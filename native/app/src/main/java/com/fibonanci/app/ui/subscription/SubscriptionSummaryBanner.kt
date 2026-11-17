package com.fibonanci.app.ui.subscription

import androidx.compose.runtime.Composable
import androidx.compose.ui.unit.dp
import com.fibonanci.app.data.db.WalletEntry
import com.fibonanci.app.ui.common.ExpandableSearchFilterBar
import com.fibonanci.app.ui.common.kDefaultSubscriptionStatusChoices

// minimalist expandable search bar with morphing dropdown filters for subscription screen.
@Composable
fun SubscriptionSearchBar(
    searchQuery: String,
    filter: String,
    walletFilter: String?,
    wallets: List<WalletEntry>,
    onSearchChanged: (String) -> Unit,
    onClearSearch: () -> Unit,
    onFilterApplied: (status: String, walletId: String?) -> Unit,
    onClearStatusFilter: () -> Unit,
    onClearWalletFilter: () -> Unit,
) {
    ExpandableSearchFilterBar(
        searchQuery = searchQuery,
        typeFilter = filter,
        walletFilter = walletFilter,
        wallets = wallets,
        hintText = "Cari tagihan, langganan, rekening...",
        headerTitle = "Filter Tagihan",
        primaryFilterTitle = "STATUS PEMBAYARAN",
        primaryFilterChoices = kDefaultSubscriptionStatusChoices,
        borderRadius = 10.dp,
        onSearchChanged = onSearchChanged,
        onClearSearch = onClearSearch,
        onFilterApplied = onFilterApplied,
        onClearTypeFilter = onClearStatusFilter,
        onClearWalletFilter = onClearWalletFilter,
    )
}
