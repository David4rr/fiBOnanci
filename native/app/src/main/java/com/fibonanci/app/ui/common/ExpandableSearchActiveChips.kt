package com.fibonanci.app.ui.common

import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.fibonanci.app.data.db.WalletEntry

/** active filter chips row rendered below the search bar when collapsed. */
@Composable
fun ExpandableSearchActiveChips(
    typeChipLabel: String,
    hasTypeFilter: Boolean,
    walletFilter: String?,
    wallets: List<WalletEntry>,
    onClearType: () -> Unit,
    onClearWallet: () -> Unit,
    modifier: Modifier = Modifier,
) {
    Row(
        modifier
            .padding(horizontal = 20.dp, vertical = 2.dp)
            .horizontalScroll(rememberScrollState()),
    ) {
        if (hasTypeFilter) {
            SearchFilterChip(
                label = typeChipLabel,
                onClear = onClearType,
                modifier = Modifier.padding(end = 8.dp),
            )
        }
        if (walletFilter != null) {
            val wallet = wallets.firstOrNull { it.id == walletFilter } ?: wallets.first()
            SearchFilterChip(label = "Rek: ${wallet.name}", onClear = onClearWallet)
        }
    }
}
