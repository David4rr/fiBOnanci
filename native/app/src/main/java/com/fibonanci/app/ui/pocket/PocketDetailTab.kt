package com.fibonanci.app.ui.pocket

import androidx.compose.foundation.background
import androidx.compose.foundation.border
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
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.outlined.ReceiptLong
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.fibonanci.app.data.db.PocketEntry
import com.fibonanci.app.data.db.TransactionEntry
import com.fibonanci.app.data.db.WalletEntry
import com.fibonanci.app.ui.LocalFinance
import com.fibonanci.app.ui.common.LocalModalHost
import com.fibonanci.app.ui.common.SlideToDeleteButton
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.AppTypography

// onDismiss closes the hosting pocket detail modal (dart Navigator.pop inside the delete flow).
@Composable
fun PocketDetailTab(
    pocket: PocketEntry,
    pocketColor: Color,
    themeConfig: PocketCardThemeConfig? = null,
    transactions: List<TransactionEntry>,
    wallets: List<WalletEntry>,
    fmt: (Double) -> String,
    onDeposit: () -> Unit,
    onWithdraw: () -> Unit,
    onEditTransaction: ((TransactionEntry) -> Unit)? = null,
    onDismiss: () -> Unit,
) {
    val vm = LocalFinance.current
    val host = LocalModalHost.current
    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(start = 20.dp, top = 4.dp, end = 20.dp, bottom = 24.dp),
    ) {
        PocketDetailHeader(
            pocket = pocket,
            pocketColor = pocketColor,
            themeConfig = themeConfig,
            fmt = fmt,
            transactions = transactions,
        )
        Spacer(Modifier.height(20.dp))
        PocketDetailActions(
            pocket = pocket,
            pocketColor = pocketColor,
            onDeposit = onDeposit,
            onWithdraw = onWithdraw,
        )
        Spacer(Modifier.height(22.dp))
        Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
            Text("Riwayat Mutasi", style = AppTypography.sectionTitle.copy(fontSize = 15.5.sp), modifier = Modifier.weight(1f))
            if (transactions.isNotEmpty()) {
                Box(
                    modifier = Modifier
                        .background(AppColors.canvasInputSearch, RoundedCornerShape(8.dp))
                        .padding(horizontal = 8.dp, vertical = 3.dp),
                ) {
                    Text(
                        "${transactions.size} mutasi",
                        style = TextStyle(color = AppColors.textMuted, fontSize = 11.sp, fontWeight = FontWeight.SemiBold),
                    )
                }
            }
        }
        Spacer(Modifier.height(12.dp))
        if (transactions.isEmpty()) {
            Column(
                modifier = Modifier.fillMaxWidth().padding(vertical = 24.dp, horizontal = 16.dp),
                horizontalAlignment = Alignment.CenterHorizontally,
            ) {
                Box(
                    modifier = Modifier
                        .size(44.dp)
                        .background(Color.White.copy(alpha = 0.04f), CircleShape)
                        .border(1.dp, Color.White.copy(alpha = 0.08f), CircleShape),
                    contentAlignment = Alignment.Center,
                ) {
                    Icon(Icons.AutoMirrored.Outlined.ReceiptLong, contentDescription = null, tint = AppColors.textSubtle, modifier = Modifier.size(20.dp))
                }
                Spacer(Modifier.height(10.dp))
                Text("Belum ada riwayat mutasi", style = AppTypography.listSubtitle, textAlign = TextAlign.Center)
            }
        } else {
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                transactions.forEach { tx ->
                    PocketTransactionTile(
                        transaction = tx,
                        wallets = wallets,
                        fmt = fmt,
                        onTap = onEditTransaction?.let { { it(tx) } },
                    )
                }
            }
        }
        Spacer(Modifier.height(24.dp))
        SlideToDeleteButton(
            label = "Hapus Kantong",
            onSlideComplete = { showPocketDeleteDialog(vm, host, pocket, onDismiss) },
        )
    }
}
