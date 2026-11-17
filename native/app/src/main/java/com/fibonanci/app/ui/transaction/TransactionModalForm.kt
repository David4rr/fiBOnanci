package com.fibonanci.app.ui.transaction

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.AccountBalanceWallet
import androidx.compose.material.icons.outlined.Category
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.fibonanci.app.data.db.CategoryEntry
import com.fibonanci.app.data.db.ProfileEntry
import com.fibonanci.app.data.db.WalletEntry
import com.fibonanci.app.ui.common.AppTextField
import com.fibonanci.app.ui.common.CurrencyAmountField
import com.fibonanci.app.ui.common.ModalGrabHandle
import com.fibonanci.app.ui.common.ModalHeader
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.AppTypography

@Composable
fun TransactionModalHeaderView(type: String, onClose: () -> Unit) {
    Column {
        ModalGrabHandle(padding = PaddingValues(bottom = 14.dp))
        ModalHeader(
            title = "Catat Transaksi",
            subtitle = when (type) {
                "expense" -> "Pengeluaran kas atau mutasi keluar"
                "income" -> "Pemasukan gaji atau dana masuk"
                else -> "Transfer antar rekening & profil"
            },
            titleStyle = AppTypography.modalTitle,
            subtitleStyle = AppTypography.modalSubtitle,
            onClose = onClose,
        )
    }
}

@Composable
fun TransactionCategoryDropdown(
    selectedCategoryId: String?,
    categories: List<CategoryEntry>,
    onChanged: (String?) -> Unit,
) {
    TransactionDropdownContainer {
        TransactionDropdownButton(
            value = selectedCategoryId,
            items = categories.map { it.id },
            onChanged = { onChanged(it) },
            hint = { Text("Pilih Kategori", style = AppTypography.listSubtitle) },
        ) { id ->
            val c = categories.first { it.id == id }
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(Icons.Outlined.Category, null, Modifier.size(18.dp), tint = AppColors.neoCyan)
                Spacer(Modifier.width(10.dp))
                Text(c.name, modifier = Modifier.weight(1f), style = AppTypography.listTitle, maxLines = 1, overflow = TextOverflow.Ellipsis)
            }
        }
    }
}

@Composable
fun TransactionFormInputs(
    type: String,
    onTypeChanged: (String) -> Unit,
    amount: String,
    onAmountChange: (String) -> Unit,
    selectedWalletId: String?,
    wallets: List<WalletEntry>,
    onWalletChanged: (String?) -> Unit,
    profiles: List<ProfileEntry>,
    currentProfile: ProfileEntry,
    selectedTargetProfileId: String,
    onTargetProfileChanged: (String) -> Unit,
    selectedDestinationWalletId: String?,
    destWallets: List<WalletEntry>,
    onDestinationWalletChanged: (String?) -> Unit,
    selectedCategoryId: String?,
    matchingCats: List<CategoryEntry>,
    onCategoryChanged: (String?) -> Unit,
    notes: String,
    onNotesChange: (String) -> Unit,
    onCancel: () -> Unit,
    onSave: () -> Unit,
) {
    Column {
        TransactionTypeToggle(selectedType = type, onTypeChanged = onTypeChanged)
        Spacer(Modifier.height(16.dp))
        CurrencyAmountField(value = amount, onValueChange = onAmountChange)
        Spacer(Modifier.height(12.dp))
        TransactionDropdownContainer {
            TransactionDropdownButton(
                value = selectedWalletId,
                items = wallets.map { it.id },
                onChanged = { onWalletChanged(it) },
                hint = { Text(if (type == "transfer") "Pilih Rekening Asal" else "Pilih Rekening", style = AppTypography.listSubtitle) },
            ) { id ->
                val w = wallets.first { it.id == id }
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(Icons.Outlined.AccountBalanceWallet, null, Modifier.size(18.dp), tint = AppColors.neoCoral)
                    Spacer(Modifier.width(10.dp))
                    Text(w.name, modifier = Modifier.weight(1f), style = AppTypography.listTitle, maxLines = 1, overflow = TextOverflow.Ellipsis)
                }
            }
        }
        Spacer(Modifier.height(12.dp))
        if (type == "transfer") {
            TransactionTransferDestinationSelector(
                profiles = profiles,
                currentProfile = currentProfile,
                selectedTargetProfileId = selectedTargetProfileId,
                onTargetProfileChanged = onTargetProfileChanged,
                selectedDestinationWalletId = selectedDestinationWalletId,
                destinationWallets = destWallets,
                onDestinationWalletChanged = onDestinationWalletChanged,
            )
        } else {
            TransactionCategoryDropdown(
                selectedCategoryId = selectedCategoryId,
                categories = matchingCats,
                onChanged = onCategoryChanged,
            )
        }
        Spacer(Modifier.height(12.dp))
        AppTextField(value = notes, onValueChange = onNotesChange, hintText = "Catatan (Opsional)")
        Spacer(Modifier.height(24.dp))
        TransactionActionFooter(onCancel = onCancel, onSave = onSave)
    }
}
