package com.fibonanci.app.ui.subscription

import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
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

// swiss-editorial filter modal for subscription screen matching transaction filter modal on dashboard.
@OptIn(ExperimentalLayoutApi::class)
fun showSubscriptionFilterModal(
    host: ModalHost,
    wallets: List<WalletEntry>,
    initialStatus: String,
    initialWalletId: String?,
    onApply: (status: String, walletId: String?) -> Unit,
) {
    host.show(ModalKind.Sheet) { dismiss ->
        var currentStatus by remember { mutableStateOf(initialStatus) }
        var currentWalletId by remember { mutableStateOf(initialWalletId) }

        Column(
            modifier = Modifier
                .fillMaxWidth()
                .background(AppColors.canvasCardSurface, RoundedCornerShape(topStart = 28.dp, topEnd = 28.dp))
                .navigationBarsPadding()
                .padding(24.dp),
        ) {
            ModalGrabHandle(padding = PaddingValues(bottom = 14.dp))
            ModalHeader(
                title = "Filter Tagihan",
                subtitle = "Status pembayaran & frekuensi siklus",
                onClose = dismiss,
            )
            Text("STATUS PEMBAYARAN", style = AppTypography.badgeLabel.copy(color = AppColors.textMuted))
            Spacer(Modifier.height(8.dp))
            FlowRow(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                for ((value, label) in listOf("all" to "Semua Status", "unpaid" to "Belum Bayar", "paid" to "Sudah Lunas")) {
                    AppChoiceChip(label = label, selected = value == currentStatus, onTap = { currentStatus = value })
                }
            }
            Spacer(Modifier.height(16.dp))
            Text("REKENING PEMBAYARAN", style = AppTypography.badgeLabel.copy(color = AppColors.textMuted))
            Spacer(Modifier.height(8.dp))
            FlowRow(
                horizontalArrangement = Arrangement.spacedBy(8.dp),
                verticalArrangement = Arrangement.spacedBy(8.dp),
            ) {
                AppChoiceChip(label = "Semua Rekening", selected = currentWalletId == null, onTap = { currentWalletId = null })
                for (w in wallets) {
                    AppChoiceChip(label = w.name, selected = w.id == currentWalletId, onTap = { currentWalletId = w.id })
                }
            }
            Spacer(Modifier.height(24.dp))
            PrimaryActionButton(
                text = "Terapkan Filter",
                height = 48.dp,
                borderRadius = 16.dp,
                onPressed = {
                    dismiss()
                    onApply(currentStatus, currentWalletId)
                },
            )
        }
    }
}
