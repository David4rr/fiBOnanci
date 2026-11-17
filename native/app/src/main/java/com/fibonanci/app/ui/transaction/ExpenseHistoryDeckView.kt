package com.fibonanci.app.ui.transaction

import androidx.compose.foundation.gestures.Orientation
import androidx.compose.foundation.gestures.draggable
import androidx.compose.foundation.gestures.rememberDraggableState
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.outlined.ReceiptLong
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.fibonanci.app.data.db.CategoryEntry
import com.fibonanci.app.data.db.PocketEntry
import com.fibonanci.app.data.db.TransactionEntry
import com.fibonanci.app.data.db.WalletEntry
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.PlusJakartaSans

// dart wraps itself in Expanded; callers pass Modifier.weight(1f)
@Composable
fun ExpenseHistoryDeckView(
    isFiltering: Boolean,
    searchQuery: String,
    filtered: List<TransactionEntry>,
    sortedDays: List<String>,
    currentDayKey: String,
    currentDayTxs: List<TransactionEntry>,
    allTransactions: List<TransactionEntry>,
    wallets: List<WalletEntry>,
    modifier: Modifier = Modifier,
    categories: List<CategoryEntry>? = null,
    pockets: List<PocketEntry>? = null,
    onManageTransaction: ((TransactionEntry) -> Unit)? = null,
    onDownwardDrag: ((Float) -> Unit)? = null,
    onDownwardDragEnd: ((Float) -> Unit)? = null,
) {
    val isToday = currentDayKey.isNotEmpty() && DailyDateHelper.formatDayTabLabel(currentDayKey) == "Hari Ini"
    val listToDisplay = if (isFiltering) filtered else currentDayTxs

    Column(modifier) {
        Row(
            Modifier.fillMaxWidth().padding(start = 20.dp, top = 8.dp, end = 20.dp, bottom = 4.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically,
        ) {
            if (isFiltering) {
                Text(
                    if (searchQuery.isNotEmpty()) "Hasil Pencarian: ${filtered.size} Transaksi" else "Hasil Filter: ${filtered.size} Transaksi",
                    style = TextStyle(fontFamily = PlusJakartaSans, fontSize = 11.sp, fontWeight = FontWeight.Bold, color = AppColors.neoChartreuse),
                )
            } else if (sortedDays.isNotEmpty()) {
                Text(
                    DailyDateHelper.formatDayTabLabel(currentDayKey).uppercase(),
                    style = TextStyle(
                        fontFamily = PlusJakartaSans, fontSize = 11.sp, fontWeight = FontWeight.Bold, letterSpacing = 1.sp,
                        color = if (isToday) AppColors.neoChartreuse else AppColors.textWhite,
                    ),
                )
                Text(
                    "//  ${currentDayTxs.size} TRANSAKSI",
                    style = TextStyle(
                        fontFamily = PlusJakartaSans, fontSize = 10.sp, fontWeight = FontWeight.Bold, letterSpacing = 0.8.sp,
                        color = if (isToday) AppColors.neoChartreuse else AppColors.textMuted, fontFeatureSettings = "tnum",
                    ),
                )
            }
        }
        Spacer(Modifier.height(6.dp))
        Box(Modifier.weight(1f).fillMaxWidth()) {
            if (listToDisplay.isEmpty()) {
                val dragState = rememberDraggableState { onDownwardDrag?.invoke(it) }
                Column(
                    Modifier
                        .fillMaxSize()
                        .draggable(dragState, Orientation.Vertical, onDragStopped = { v -> onDownwardDragEnd?.invoke(v) }),
                    verticalArrangement = Arrangement.Center,
                    horizontalAlignment = Alignment.CenterHorizontally,
                ) {
                    Icon(Icons.AutoMirrored.Outlined.ReceiptLong, null, Modifier.size(48.dp), tint = AppColors.textSubtle)
                    Spacer(Modifier.height(12.dp))
                    Text(
                        "Tidak Ada Transaksi di Tanggal Ini",
                        style = TextStyle(fontFamily = PlusJakartaSans, fontSize = 15.sp, fontWeight = FontWeight.Bold, color = AppColors.textWhite),
                    )
                }
            } else {
                StackedCardDeckScrollList(
                    transactions = listToDisplay,
                    allTransactions = allTransactions,
                    wallets = wallets,
                    categories = categories,
                    pockets = pockets,
                    onManageTransaction = onManageTransaction,
                    onDownwardDrag = onDownwardDrag,
                    onDownwardDragEnd = onDownwardDragEnd,
                )
            }
        }
    }
}
