package com.fibonanci.app.ui.walletdetail

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.NorthEast
import androidx.compose.material.icons.rounded.SouthWest
import androidx.compose.material.icons.rounded.SwapHoriz
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.fibonanci.app.core.toLocalDateTime
import com.fibonanci.app.data.db.TransactionEntry
import com.fibonanci.app.ui.common.LocalModalHost
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.PlusJakartaSans
import com.fibonanci.app.ui.transaction.showTransactionDetailModal
import java.time.format.DateTimeFormatter
import java.util.Locale

object WalletDetailTransactionTile {
    val dateFormat: DateTimeFormatter = DateTimeFormatter.ofPattern("dd MMM yyyy, HH:mm", Locale.forLanguageTag("id-ID"))
}

@Composable
fun WalletDetailTransactionTile(
    tx: TransactionEntry,
    walletId: String,
    fmt: (Double) -> String,
    onEditTransaction: ((TransactionEntry) -> Unit)? = null,
    modifier: Modifier = Modifier,
) {
    val host = LocalModalHost.current
    val isIncomingTransfer = tx.type == "transfer" && tx.destinationWalletId == walletId && tx.walletId != walletId
    val isExpense = tx.type == "expense" || (tx.type == "transfer" && !isIncomingTransfer)
    val prefix = if (isExpense) "- " else "+ "
    val typeColor = if (isExpense) AppColors.textWhite else AppColors.neoMint
    val incoming = tx.type == "income" || isIncomingTransfer

    val iconData = if (incoming) Icons.Rounded.SouthWest else if (tx.type == "transfer") Icons.Rounded.SwapHoriz else Icons.Rounded.NorthEast
    val iconBgColor = if (incoming) {
        AppColors.neoMint.copy(alpha = 0.15f)
    } else if (tx.type == "transfer") {
        AppColors.neoPurple.copy(alpha = 0.15f)
    } else {
        AppColors.canvasInputSearch
    }
    val iconColor = if (incoming) AppColors.neoMint else if (tx.type == "transfer") AppColors.neoPurple else AppColors.textWhite
    val dateFormatted = tx.transactionDate.toLocalDateTime().format(WalletDetailTransactionTile.dateFormat)

    val title = if (!tx.notes.isNullOrEmpty()) {
        tx.notes
    } else if (tx.type == "income") {
        "Pemasukan"
    } else if (tx.type == "transfer") {
        if (isIncomingTransfer) "Transfer Masuk" else "Transfer Keluar"
    } else {
        "Pengeluaran"
    }

    PressableScale(
        onTap = { if (onEditTransaction != null) onEditTransaction(tx) else showTransactionDetailModal(host, transaction = tx) },
        modifier = modifier.padding(horizontal = 20.dp, vertical = 4.5.dp),
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .background(AppColors.canvasCardSurface, RoundedCornerShape(16.dp))
                .border(0.8.dp, AppColors.canvasBorder, RoundedCornerShape(16.dp))
                .padding(horizontal = 14.dp, vertical = 12.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Box(
                modifier = Modifier
                    .size(36.dp)
                    .background(iconBgColor, CircleShape)
                    .border(0.8.dp, AppColors.canvasBorder, CircleShape),
                contentAlignment = Alignment.Center,
            ) {
                Icon(iconData, contentDescription = null, tint = iconColor, modifier = Modifier.size(17.dp))
            }
            Spacer(Modifier.width(12.dp))
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    title,
                    style = TextStyle(fontFamily = PlusJakartaSans, fontSize = 13.5.sp, fontWeight = FontWeight.W700, color = AppColors.textWhite),
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                )
                Spacer(Modifier.height(2.5.dp))
                Text(
                    dateFormatted,
                    style = TextStyle(fontFamily = PlusJakartaSans, fontSize = 11.sp, fontWeight = FontWeight.W500, color = AppColors.textMuted),
                )
            }
            Spacer(Modifier.width(10.dp))
            Text(
                "$prefix${fmt(tx.amount)}",
                style = TextStyle(
                    fontFamily = PlusJakartaSans,
                    fontSize = 13.5.sp,
                    fontWeight = FontWeight.W800,
                    color = typeColor,
                    fontFeatureSettings = "tnum",
                ),
            )
        }
    }
}
