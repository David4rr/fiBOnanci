package com.fibonanci.app.ui.dashboard

import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.outlined.ReceiptLong
import androidx.compose.material.icons.rounded.SearchOff
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.fibonanci.app.data.db.CategoryEntry
import com.fibonanci.app.data.db.PocketEntry
import com.fibonanci.app.data.db.TransactionEntry
import com.fibonanci.app.data.db.WalletEntry
import com.fibonanci.app.ui.common.LocalModalHost
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.AppTypography
import com.fibonanci.app.ui.transaction.StackedCardDeckScrollList
import com.fibonanci.app.ui.transaction.showAllTransactionsModal

@Composable
fun ColumnScope.DashboardHistorySection(
    searchQuery: String,
    isFiltering: Boolean,
    filteredTransactions: List<TransactionEntry>,
    allTransactions: List<TransactionEntry>,
    wallets: List<WalletEntry>,
    categories: List<CategoryEntry>? = null,
    pockets: List<PocketEntry>? = null,
) {
    val host = LocalModalHost.current
    Column(Modifier.weight(1f).fillMaxWidth()) {
        Row(
            Modifier.fillMaxWidth().padding(start = 20.dp, top = 8.dp, end = 20.dp, bottom = 8.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Text(
                if (searchQuery.isNotEmpty()) "Hasil Pencarian (${filteredTransactions.size})" else "Riwayat Transaksi",
                style = AppTypography.sectionTitle,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
                modifier = Modifier.weight(1f),
            )
            Spacer(Modifier.width(8.dp))
            Box(
                Modifier
                    .pointerInput(allTransactions, wallets) {
                        detectTapGestures { showAllTransactionsModal(host, allTransactions = allTransactions, wallets = wallets) }
                    }
                    .padding(horizontal = 4.dp, vertical = 2.dp),
            ) {
                Text(
                    "Lihat Semua",
                    style = AppTypography.cardMetricLabel.copy(color = AppColors.neoChartreuse, fontSize = 12.sp),
                )
            }
        }
        Box(Modifier.weight(1f).fillMaxWidth()) {
            if (filteredTransactions.isEmpty()) {
                Column(
                    Modifier.fillMaxSize(),
                    verticalArrangement = Arrangement.Center,
                    horizontalAlignment = Alignment.CenterHorizontally,
                ) {
                    Icon(
                        if (isFiltering) Icons.Rounded.SearchOff else Icons.AutoMirrored.Outlined.ReceiptLong,
                        null,
                        tint = AppColors.textSubtle,
                        modifier = Modifier.size(42.dp),
                    )
                    Spacer(Modifier.height(10.dp))
                    Text(
                        if (isFiltering) "Tidak ada transaksi yang cocok" else "Belum ada transaksi hari ini",
                        style = AppTypography.listSubtitle,
                    )
                }
            } else {
                StackedCardDeckScrollList(
                    transactions = filteredTransactions,
                    allTransactions = allTransactions,
                    wallets = wallets,
                    categories = categories,
                    pockets = pockets,
                )
            }
        }
    }
}
