package com.fibonanci.app.ui.transaction

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBars
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.windowInsetsPadding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.ui.graphics.RectangleShape
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
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.fibonanci.app.core.format.AppCurrency
import com.fibonanci.app.data.db.TransactionEntry
import com.fibonanci.app.ui.LocalFinance
import com.fibonanci.app.ui.common.AppTextField
import com.fibonanci.app.ui.common.CurrencyAmountField
import com.fibonanci.app.ui.common.LocalModalHost
import com.fibonanci.app.ui.common.ModalGrabHandle
import com.fibonanci.app.ui.common.ModalHeader
import com.fibonanci.app.ui.common.ModalHost
import com.fibonanci.app.ui.common.ModalKind
import com.fibonanci.app.ui.common.SlideToDeleteButton
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.AppTypography

private const val TRANSFER_CATEGORY_ID = "11111111-1111-4111-8111-111111111111"

fun showTransactionDetailModal(host: ModalHost, transaction: TransactionEntry) {
    host.show(ModalKind.Sheet) { dismiss ->
        TransactionDetailModal(transaction = transaction, onClose = dismiss, onSaved = dismiss, onDeleted = dismiss)
    }
}

// onClose / onSaved / onDeleted replace the dart Navigator.pop fallback
@Composable
fun TransactionDetailModal(
    transaction: TransactionEntry,
    onClose: () -> Unit,
    onSaved: () -> Unit,
    onDeleted: () -> Unit,
    isInline: Boolean = false,
) {
    val vm = LocalFinance.current
    val host = LocalModalHost.current
    val state by vm.state.collectAsStateWithLifecycle()
    val currency = state.profile.currency

    var amount by remember { mutableStateOf(AppCurrency.formatIdrForInput(transaction.amount, currency)) }
    var notes by remember { mutableStateOf(transaction.notes ?: "") }
    var type by remember { mutableStateOf(transaction.type) }
    var walletId by remember { mutableStateOf(transaction.walletId) }
    var categoryId by remember { mutableStateOf(transaction.categoryId) }
    var destinationWalletId by remember { mutableStateOf(transaction.destinationWalletId) }

    val isPocketTx = (transaction.externalRef?.startsWith("pocket_") ?: false) ||
        (transaction.notes?.contains("Kantong ") ?: false)

    fun saveChanges() {
        val newAmount = AppCurrency.parseInputToIdr(amount, currency)
        if (newAmount <= 0) return
        if (type == "transfer" && !isPocketTx && (destinationWalletId == null || destinationWalletId == walletId)) {
            host.showSnackBar("Rekening asal dan tujuan tidak boleh sama!")
            return
        }
        vm.updateTransaction(
            transactionId = transaction.id,
            newAmount = newAmount,
            newCategoryId = if (type == "transfer") TRANSFER_CATEGORY_ID else categoryId,
            newNotes = notes.trim().ifEmpty { null },
            newType = type,
            newWalletId = walletId,
            newDestinationWalletId = if (type == "transfer" && !isPocketTx) destinationWalletId else null,
        )
        onSaved()
        host.showSnackBar(
            "Perubahan transaksi & saldo dompet berhasil diperbarui!",
            background = AppColors.neoMint,
            contentColor = AppColors.textDarkPrimary,
        )
    }

    val wallets = state.wallets
    val categories = state.categories
    // per-build reconciliation (dart build)
    walletId = if (wallets.any { it.id == walletId }) walletId else wallets.firstOrNull()?.id ?: ""
    val destWallets = wallets.filter { it.id != walletId }
    if (!isPocketTx && (destinationWalletId == null || destWallets.none { it.id == destinationWalletId })) {
        destinationWalletId = destWallets.firstOrNull()?.id
    }
    val matchingCats = categories.filter { it.type == type }
    if (type != "transfer" && matchingCats.none { it.id == categoryId }) {
        categoryId = matchingCats.firstOrNull()?.id ?: ""
    }

    Column(
        Modifier
            .fillMaxWidth()
            .clip(if (isInline) RectangleShape else RoundedCornerShape(topStart = 28.dp, topEnd = 28.dp))
            .background(if (isInline) Color.Transparent else AppColors.canvasCardSurface)
            .then(if (isInline) Modifier else Modifier.windowInsetsPadding(WindowInsets.navigationBars))
            .verticalScroll(rememberScrollState())
            .padding(
                if (isInline) PaddingValues(start = 20.dp, top = 16.dp, end = 20.dp, bottom = 48.dp)
                else PaddingValues(start = 24.dp, top = 16.dp, end = 24.dp, bottom = 24.dp),
            ),
    ) {
        if (!isInline) {
            ModalGrabHandle(padding = PaddingValues(bottom = 14.dp))
            ModalHeader(
                title = "Edit Transaksi",
                subtitle = "Ubah kategori, rekening, atau nominal",
                onClose = onClose,
            )
        }
        TransactionTypeToggle(
            selectedType = type,
            onTypeChanged = { t ->
                type = t
                val matching = categories.filter { it.type == t }
                if (t != "transfer" && matching.none { it.id == categoryId }) {
                    categoryId = matching.firstOrNull()?.id ?: ""
                }
            },
        )
        Spacer(Modifier.height(16.dp))
        CurrencyAmountField(value = amount, onValueChange = { amount = it })
        Spacer(Modifier.height(14.dp))
        Text("REKENING PENYIMPANAN", style = AppTypography.badgeLabel.copy(color = AppColors.textMuted))
        Spacer(Modifier.height(6.dp))
        TransactionDetailComponents.buildWalletDropdown(wallets = wallets, selectedId = walletId, onChanged = { walletId = it!! })
        if (type == "transfer" && !isPocketTx) {
            Spacer(Modifier.height(12.dp))
            Text("Rekening Tujuan", style = AppTypography.badgeLabel.copy(color = AppColors.textMuted))
            Spacer(Modifier.height(6.dp))
            TransactionDetailComponents.buildWalletDropdown(wallets = destWallets, selectedId = destinationWalletId, onChanged = { destinationWalletId = it })
        } else if (type != "transfer") {
            Spacer(Modifier.height(12.dp))
            Text("Kategori", style = AppTypography.badgeLabel.copy(color = AppColors.textMuted))
            Spacer(Modifier.height(6.dp))
            TransactionDropdownContainer {
                TransactionDropdownButton(
                    value = categoryId.ifEmpty { null },
                    items = matchingCats.map { it.id },
                    onChanged = { categoryId = it },
                ) { id ->
                    Text(matchingCats.first { it.id == id }.name, style = AppTypography.listTitle)
                }
            }
        }
        Spacer(Modifier.height(12.dp))
        AppTextField(value = notes, onValueChange = { notes = it }, hintText = "Catatan (Opsional)")
        Spacer(Modifier.height(24.dp))
        TransactionDetailComponents.buildActionButtons(onSave = { saveChanges() }, onCancel = onClose)
        Spacer(Modifier.height(14.dp))
        SlideToDeleteButton(
            label = "Hapus Transaksi",
            onSlideComplete = { TransactionDetailComponents.executeDelete(vm, host, transaction.id, onDeleted) },
        )
    }
}
