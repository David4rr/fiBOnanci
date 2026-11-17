package com.fibonanci.app.ui.pocket

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
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
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.NorthEast
import androidx.compose.material.icons.rounded.SouthWest
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.fibonanci.app.core.toLocalDateTime
import com.fibonanci.app.data.db.TransactionEntry
import com.fibonanci.app.data.db.WalletEntry
import com.fibonanci.app.ui.common.LocalModalHost
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.AppTypography
import com.fibonanci.app.ui.theme.PlusJakartaSans
import com.fibonanci.app.ui.transaction.showTransactionDetailModal
import java.time.format.DateTimeFormatter
import java.util.Locale

private val tileDateFormat = DateTimeFormatter.ofPattern("d MMM, HH:mm", Locale.forLanguageTag("id-ID"))

// dart `fmt` (NumberFormat) is passed as a formatting lambda.
@Composable
fun PocketTransactionTile(
    transaction: TransactionEntry,
    wallets: List<WalletEntry>,
    fmt: (Double) -> String,
    onTap: (() -> Unit)? = null,
) {
    val host = LocalModalHost.current
    val n = (transaction.notes ?: "").lowercase()
    val isDeposit = n.contains("setoran") || transaction.type == "transfer"
    val themeColor = if (isDeposit) AppColors.neoMint else AppColors.neoCoral
    val sign = if (isDeposit) "+" else "-"

    val wallet = wallets.firstOrNull { it.id == transaction.walletId }
    val walletName = wallet?.name ?: "Rekening"
    val dateStr = transaction.transactionDate.toLocalDateTime().format(tileDateFormat)
    val subtitleText = if (isDeposit) "Dari $walletName • $dateStr" else "Ke $walletName • $dateStr"

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(interactionSource = remember { MutableInteractionSource() }, indication = null) {
                if (onTap != null) onTap() else showTransactionDetailModal(host, transaction = transaction)
            }
            .background(AppColors.canvasInputSearch, RoundedCornerShape(16.dp))
            .border(0.8.dp, AppColors.canvasBorder, RoundedCornerShape(16.dp))
            .padding(horizontal = 14.dp, vertical = 12.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Box(
            modifier = Modifier.size(36.dp).background(themeColor.copy(alpha = 0.14f), CircleShape),
            contentAlignment = Alignment.Center,
        ) {
            Icon(
                if (isDeposit) Icons.Rounded.SouthWest else Icons.Rounded.NorthEast,
                contentDescription = null,
                tint = themeColor,
                modifier = Modifier.size(18.dp),
            )
        }
        Spacer(Modifier.width(12.dp))
        Column(modifier = Modifier.weight(1f), verticalArrangement = Arrangement.Top) {
            Text(
                transaction.notes ?: (if (isDeposit) "Setoran Kantong" else "Penarikan Kantong"),
                style = AppTypography.listTitle.copy(fontSize = 13.5.sp),
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
            )
            Spacer(Modifier.height(2.dp))
            Text(
                subtitleText,
                style = AppTypography.listSubtitle.copy(fontSize = 11.sp),
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
            )
        }
        Spacer(Modifier.width(8.dp))
        Text(
            "$sign${fmt(transaction.amount)}",
            style = TextStyle(
                fontFamily = PlusJakartaSans,
                fontSize = 13.5.sp,
                fontWeight = FontWeight.ExtraBold,
                color = themeColor,
                fontFeatureSettings = "tnum",
            ),
        )
    }
}
