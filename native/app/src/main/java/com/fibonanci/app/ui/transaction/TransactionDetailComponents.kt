package com.fibonanci.app.ui.transaction

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.fibonanci.app.core.format.AppCurrency
import com.fibonanci.app.data.db.WalletEntry
import com.fibonanci.app.ui.FinanceViewModel
import com.fibonanci.app.ui.common.ModalHost
import com.fibonanci.app.ui.common.showAppConfirmationDialog
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.AppTypography

object TransactionDetailComponents {
    @Composable
    fun buildWalletDropdown(
        wallets: List<WalletEntry>,
        selectedId: String?,
        onChanged: (String?) -> Unit,
    ) {
        Box(
            Modifier
                .fillMaxWidth()
                .background(AppColors.canvasInputSearch, RoundedCornerShape(16.dp))
                .border(1.5.dp, AppColors.neoChartreuse.copy(alpha = 0.6f), RoundedCornerShape(16.dp))
                .padding(horizontal = 16.dp),
        ) {
            TransactionDropdownButton(
                value = selectedId,
                items = wallets.map { it.id },
                onChanged = { onChanged(it) },
            ) { id ->
                val w = wallets.first { it.id == id }
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Box(Modifier.size(12.dp).background(AppColors.fromHex(w.colorHex), CircleShape))
                    Spacer(Modifier.width(10.dp))
                    Text(
                        w.name,
                        modifier = Modifier.weight(1f, fill = false),
                        style = AppTypography.listTitle.copy(fontWeight = FontWeight.Bold),
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis,
                    )
                    Spacer(Modifier.weight(1f))
                    Text(AppCurrency.formatCompact(w.balance, "IDR"), style = AppTypography.listSubtitle)
                }
            }
        }
    }

    @Composable
    fun buildActionButtons(
        onSave: () -> Unit,
        onCancel: () -> Unit,
    ) {
        Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(10.dp)) {
            OutlinedButton(
                onClick = onCancel,
                modifier = Modifier.weight(1f).height(52.dp),
                shape = RoundedCornerShape(16.dp),
                border = BorderStroke(1.dp, AppColors.canvasBorder),
            ) {
                Text("Batal", style = AppTypography.listTitle.copy(color = AppColors.textMuted, fontWeight = FontWeight.SemiBold))
            }
            Button(
                onClick = onSave,
                modifier = Modifier.weight(2f).height(52.dp),
                shape = RoundedCornerShape(16.dp),
                colors = ButtonDefaults.buttonColors(containerColor = AppColors.neoChartreuse),
                elevation = ButtonDefaults.buttonElevation(0.dp, 0.dp, 0.dp, 0.dp, 0.dp),
            ) {
                Text("Simpan Perubahan", style = AppTypography.listTitle.copy(color = AppColors.textDarkPrimary, fontWeight = FontWeight.ExtraBold))
            }
        }
    }

    fun executeDelete(vm: FinanceViewModel, host: ModalHost, transactionId: String, onDeleted: () -> Unit) {
        vm.deleteTransaction(transactionId)
        onDeleted()
        host.showSnackBar(
            "Transaksi dihapus & saldo dompet dikembalikan semula!",
            background = AppColors.neoCoral,
            contentColor = AppColors.textWhite,
        )
    }

    fun showDeleteDialog(vm: FinanceViewModel, host: ModalHost, transactionId: String, onDeleted: () -> Unit) {
        showAppConfirmationDialog(
            host,
            title = "Hapus Transaksi?",
            content = "Transaksi ini akan dihapus permanen dan saldo dompet akan dikembalikan.",
            confirmText = "Hapus",
            confirmColor = AppColors.neoCoral,
            onConfirm = { executeDelete(vm, host, transactionId, onDeleted) },
        )
    }
}
