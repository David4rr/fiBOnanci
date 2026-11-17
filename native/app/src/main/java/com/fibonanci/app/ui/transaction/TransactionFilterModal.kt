package com.fibonanci.app.ui.transaction

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.navigationBars
import androidx.compose.foundation.layout.windowInsetsPadding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.unit.dp
import com.fibonanci.app.data.db.WalletEntry
import com.fibonanci.app.ui.common.AppChoiceChip
import com.fibonanci.app.ui.common.ModalGrabHandle
import com.fibonanci.app.ui.common.ModalHeader
import com.fibonanci.app.ui.common.ModalHost
import com.fibonanci.app.ui.common.ModalKind
import com.fibonanci.app.ui.common.PrimaryActionButton
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.AppTypography

fun showTransactionFilterModal(
    host: ModalHost,
    wallets: List<WalletEntry>,
    initialType: String,
    initialWalletId: String?,
    onApply: (type: String, walletId: String?) -> Unit,
    showWalletFilter: Boolean = true,
) {
    host.show(ModalKind.Sheet) { dismiss ->
        TransactionFilterSheet(wallets, initialType, initialWalletId, onApply, showWalletFilter, dismiss)
    }
}

@OptIn(ExperimentalLayoutApi::class)
@Composable
private fun TransactionFilterSheet(
    wallets: List<WalletEntry>,
    initialType: String,
    initialWalletId: String?,
    onApply: (String, String?) -> Unit,
    showWalletFilter: Boolean,
    onDismiss: () -> Unit,
) {
    var currentType by remember { mutableStateOf(initialType) }
    var currentWalletId by remember { mutableStateOf(initialWalletId) }

    Column(
        Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(topStart = 28.dp, topEnd = 28.dp))
            .background(AppColors.canvasCardSurface)
            .windowInsetsPadding(WindowInsets.navigationBars)
            .verticalScroll(rememberScrollState())
            .padding(24.dp),
    ) {
        ModalGrabHandle(padding = PaddingValues(bottom = 14.dp))
        ModalHeader(
            title = "Filter Transaksi",
            subtitle = "Pilih jenis transaksi & rekening",
            onClose = onDismiss,
        )
        Text("TIPE TRANSAKSI", style = AppTypography.badgeLabel.copy(color = AppColors.textMuted))
        Spacer(Modifier.height(8.dp))
        FlowRow(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            listOf("all" to "Semua", "expense" to "Pengeluaran", "income" to "Pemasukan", "transfer" to "Transfer").forEach { (value, label) ->
                AppChoiceChip(label = label, selected = value == currentType, onTap = { currentType = value })
            }
        }
        if (showWalletFilter && wallets.isNotEmpty()) {
            Spacer(Modifier.height(16.dp))
            Text("REKENING", style = AppTypography.badgeLabel.copy(color = AppColors.textMuted))
            Spacer(Modifier.height(8.dp))
            FlowRow(horizontalArrangement = Arrangement.spacedBy(8.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                AppChoiceChip(label = "Semua Rekening", selected = currentWalletId == null, onTap = { currentWalletId = null })
                for (w in wallets) {
                    AppChoiceChip(label = w.name, selected = w.id == currentWalletId, onTap = { currentWalletId = w.id })
                }
            }
        }
        Spacer(Modifier.height(24.dp))
        PrimaryActionButton(
            text = "Terapkan Filter",
            height = 48.dp,
            borderRadius = 14.dp,
            onPressed = {
                onApply(currentType, currentWalletId)
                onDismiss()
            },
        )
    }
}
