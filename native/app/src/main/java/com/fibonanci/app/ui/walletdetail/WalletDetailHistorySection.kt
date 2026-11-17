package com.fibonanci.app.ui.walletdetail

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyListScope
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.outlined.ReceiptLong
import androidx.compose.material.icons.rounded.SearchOff
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.fibonanci.app.data.db.TransactionEntry
import com.fibonanci.app.data.db.WalletEntry
import com.fibonanci.app.ui.common.SearchFilterChip
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.AppTypography
import com.fibonanci.app.ui.theme.PlusJakartaSans

enum class WalletTxFilter { all, income, expense, transfer }

private fun getFilterTypeLabel(filter: WalletTxFilter): String = when (filter) {
    WalletTxFilter.income -> "Masuk"
    WalletTxFilter.expense -> "Keluar"
    WalletTxFilter.transfer -> "Transfer"
    WalletTxFilter.all -> "Semua"
}

// dart SliverMainAxisGroup → items emitted into the parent lazy list.
// searchText is the raw field text (dart searchController), searchQuery the normalized query.
fun LazyListScope.WalletDetailHistorySection(
    wallet: WalletEntry,
    filteredTx: List<TransactionEntry>,
    searchText: String,
    searchQuery: String,
    selectedFilter: WalletTxFilter,
    fmt: (Double) -> String,
    onSearchChanged: (String) -> Unit,
    onClearSearch: () -> Unit,
    onFilterChanged: (WalletTxFilter) -> Unit,
    onEditTransaction: ((TransactionEntry) -> Unit)? = null,
) {
    item(key = "wallet_detail_search") {
        WalletDetailSearchBar(
            searchQuery = searchText,
            selectedFilter = selectedFilter,
            onSearchChanged = onSearchChanged,
            onClearSearch = onClearSearch,
            onFilterChanged = onFilterChanged,
            modifier = Modifier.padding(horizontal = 20.dp, vertical = 4.dp),
        )
    }
    if (selectedFilter != WalletTxFilter.all) {
        item(key = "wallet_detail_filter_chip") {
            Row(modifier = Modifier.fillMaxWidth().padding(horizontal = 20.dp, vertical = 2.dp)) {
                SearchFilterChip(
                    label = "Tipe: ${getFilterTypeLabel(selectedFilter).uppercase()}",
                    onClear = { onFilterChanged(WalletTxFilter.all) },
                )
            }
        }
    }
    item(key = "wallet_detail_history_header") {
        Row(
            modifier = Modifier.fillMaxWidth().padding(start = 20.dp, top = 14.dp, end = 20.dp, bottom = 6.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Text(
                if (searchQuery.isNotEmpty()) "Hasil Pencarian (${filteredTx.size})" else "Riwayat Transaksi",
                style = AppTypography.sectionTitle,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
                modifier = Modifier.weight(1f),
            )
            Text("${filteredTx.size} transaksi", style = AppTypography.listSubtitle.copy(fontSize = 12.sp))
        }
    }
    if (filteredTx.isEmpty()) {
        item(key = "wallet_detail_empty") {
            Column(
                modifier = Modifier.fillMaxWidth().padding(horizontal = 20.dp, vertical = 36.dp),
                horizontalAlignment = Alignment.CenterHorizontally,
            ) {
                Box(
                    modifier = Modifier
                        .size(44.dp)
                        .background(Color.White.copy(alpha = 0.04f), CircleShape)
                        .border(1.dp, Color.White.copy(alpha = 0.08f), CircleShape),
                    contentAlignment = Alignment.Center,
                ) {
                    Icon(
                        if (searchQuery.isNotEmpty()) Icons.Rounded.SearchOff else Icons.AutoMirrored.Outlined.ReceiptLong,
                        contentDescription = null,
                        tint = AppColors.textSubtle,
                        modifier = Modifier.size(20.dp),
                    )
                }
                Spacer(Modifier.height(12.dp))
                Text(
                    if (searchQuery.isNotEmpty()) "Tidak ada transaksi yang cocok" else "Belum ada mutasi transaksi",
                    style = TextStyle(fontFamily = PlusJakartaSans, fontSize = 13.sp, fontWeight = FontWeight.W600, color = AppColors.textMuted),
                    textAlign = TextAlign.Center,
                )
            }
        }
    } else {
        items(filteredTx, key = { it.id }) { tx ->
            WalletDetailTransactionTile(
                tx = tx,
                walletId = wallet.id,
                fmt = fmt,
                onEditTransaction = onEditTransaction,
            )
        }
    }
    item(key = "wallet_detail_footer") {
        Box(
            modifier = Modifier.fillMaxWidth().padding(start = 20.dp, top = 24.dp, end = 20.dp, bottom = 48.dp),
            contentAlignment = Alignment.Center,
        ) {
            Row(
                modifier = Modifier
                    .background(AppColors.canvasCardSurface, RoundedCornerShape(20.dp))
                    .border(0.8.dp, AppColors.canvasBorder, RoundedCornerShape(20.dp))
                    .padding(horizontal = 14.dp, vertical = 7.dp),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Spacer(Modifier.size(6.dp).background(AppColors.neoMint, CircleShape))
                Spacer(Modifier.width(8.dp))
                Text(
                    "Offline & Terenkripsi",
                    style = TextStyle(fontFamily = PlusJakartaSans, fontSize = 11.sp, fontWeight = FontWeight.W600, color = AppColors.textMuted),
                )
            }
        }
    }
}
