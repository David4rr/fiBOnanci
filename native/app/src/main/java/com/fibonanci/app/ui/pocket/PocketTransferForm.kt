package com.fibonanci.app.ui.pocket

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.ErrorOutline
import androidx.compose.material.icons.rounded.KeyboardArrowDown
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.fibonanci.app.core.format.AppCurrency
import com.fibonanci.app.data.db.PocketEntry
import com.fibonanci.app.data.db.WalletEntry
import com.fibonanci.app.ui.LocalFinance
import com.fibonanci.app.ui.common.CurrencyAmountField
import com.fibonanci.app.ui.common.PrimaryActionButton
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.AppTypography
import com.fibonanci.app.ui.theme.PlusJakartaSans

@Composable
fun PocketTransferForm(
    pocket: PocketEntry,
    isDeposit: Boolean,
    onSuccess: () -> Unit,
    onCancel: (() -> Unit)? = null,
) {
    val vm = LocalFinance.current
    val state by vm.state.collectAsStateWithLifecycle()
    val currency = state.profile.currency
    val format: (Double) -> String = { AppCurrency.format(it, currency) }

    // dart resets these in didUpdateWidget when isDeposit or the pocket id changes
    var amountText by remember(isDeposit, pocket.id) { mutableStateOf("") }
    var selectedWalletId by remember(isDeposit, pocket.id) { mutableStateOf<String?>(null) }
    var errorMessage by remember(isDeposit, pocket.id) { mutableStateOf<String?>(null) }

    val latestPocket = state.pockets.firstOrNull { it.id == pocket.id } ?: pocket
    val activeWallets = state.wallets.filter { !it.isDeleted }
    val linked = latestPocket.linkedWalletId
    val defaultId = if (linked != null && activeWallets.any { it.id == linked }) linked else activeWallets.firstOrNull()?.id
    val resolvedWalletId = if (activeWallets.any { it.id == selectedWalletId }) selectedWalletId else defaultId
    val actionColor = if (isDeposit) AppColors.neoMint else AppColors.neoCoral

    Column(modifier = Modifier.fillMaxWidth()) {
        if (activeWallets.isNotEmpty()) {
            Text(if (isDeposit) "Rekening Sumber" else "Rekening Tujuan", style = AppTypography.listSubtitle)
            Spacer(Modifier.height(6.dp))
            WalletDropdown(
                wallets = activeWallets,
                selectedId = resolvedWalletId,
                format = format,
                shape = RoundedCornerShape(14.dp),
                bordered = true,
                verticalPadding = 2,
                itemStyle = AppTypography.listSubtitle.copy(color = AppColors.textWhite, fontWeight = FontWeight.SemiBold),
                onSelected = {
                    selectedWalletId = it
                    errorMessage = null
                },
            )
            Spacer(Modifier.height(16.dp))
        } else {
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .background(AppColors.neoCoral.copy(alpha = 0.12f), RoundedCornerShape(12.dp))
                    .padding(12.dp),
            ) {
                Text(
                    "Belum ada rekening aktif untuk transaksi.",
                    style = TextStyle(fontFamily = PlusJakartaSans, color = AppColors.neoCoral, fontSize = 12.sp),
                )
            }
            Spacer(Modifier.height(16.dp))
        }
        Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
            Text(
                if (isDeposit) "Nominal Setoran" else "Nominal Penarikan",
                style = AppTypography.listSubtitle,
                modifier = Modifier.weight(1f),
            )
            if (!isDeposit) {
                Text(
                    "Tarik Semua (${format(latestPocket.currentAmount)})",
                    style = TextStyle(
                        fontFamily = PlusJakartaSans,
                        color = if (latestPocket.currentAmount > 0) actionColor else AppColors.textMuted,
                        fontSize = 11.5.sp,
                        fontWeight = FontWeight.Bold,
                    ),
                    modifier = Modifier.clickable(
                        enabled = latestPocket.currentAmount > 0,
                        interactionSource = remember { MutableInteractionSource() },
                        indication = null,
                    ) {
                        amountText = AppCurrency.formatIdrForInput(latestPocket.currentAmount, currency)
                        if (errorMessage != null) errorMessage = null
                    },
                )
            } else {
                Text(
                    "Saldo: ${format(latestPocket.currentAmount)}",
                    style = TextStyle(fontFamily = PlusJakartaSans, color = AppColors.textMuted, fontSize = 11.5.sp, fontWeight = FontWeight.SemiBold),
                )
            }
        }
        Spacer(Modifier.height(6.dp))
        CurrencyAmountField(
            value = amountText,
            onValueChange = { amountText = it },
            labelText = "Nominal",
            prefixColor = actionColor,
            hintText = "0",
            onChanged = { if (errorMessage != null) errorMessage = null },
        )
        val error = errorMessage
        if (error != null) {
            Spacer(Modifier.height(10.dp))
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .background(AppColors.neoCoral.copy(alpha = 0.12f), RoundedCornerShape(8.dp))
                    .padding(horizontal = 10.dp, vertical = 6.dp),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Icon(Icons.Rounded.ErrorOutline, contentDescription = null, tint = AppColors.neoCoral, modifier = Modifier.size(14.dp))
                Spacer(Modifier.width(6.dp))
                Text(
                    error,
                    style = TextStyle(fontFamily = PlusJakartaSans, color = AppColors.neoCoral, fontSize = 11.5.sp, fontWeight = FontWeight.SemiBold),
                    modifier = Modifier.weight(1f),
                )
            }
        }
        Spacer(Modifier.height(20.dp))
        PrimaryActionButton(
            text = "Konfirmasi",
            backgroundColor = actionColor,
            foregroundColor = AppColors.canvasBg,
            onPressed = if (activeWallets.isEmpty() || (!isDeposit && latestPocket.currentAmount <= 0)) {
                null
            } else {
                {
                    val amount = AppCurrency.parseInputToIdr(amountText, currency)
                    val walletId = resolvedWalletId
                    val selectedWallet = activeWallets.firstOrNull { it.id == walletId }
                    when {
                        amount <= 0 -> errorMessage = "Masukkan nominal lebih dari ${format(0.0)}"
                        walletId == null -> errorMessage = "Pilih rekening terlebih dahulu"
                        selectedWallet == null -> errorMessage = "Rekening tidak valid"
                        isDeposit && amount > selectedWallet.balance ->
                            errorMessage = "Saldo ${selectedWallet.name} tidak cukup (${format(selectedWallet.balance)})"
                        !isDeposit && amount > latestPocket.currentAmount ->
                            errorMessage = "Saldo kantong tidak cukup (${format(latestPocket.currentAmount)})"
                        else -> {
                            vm.transferPocketFunds(
                                pocketId = latestPocket.id,
                                walletId = walletId,
                                amount = amount,
                                isDepositToPocket = isDeposit,
                            )
                            amountText = ""
                            errorMessage = null
                            onSuccess()
                        }
                    }
                }
            },
        )
    }
}

// shared wallet picker used by the transfer form and the add pocket modal (dart DropdownButton).
@Composable
internal fun WalletDropdown(
    wallets: List<WalletEntry>,
    selectedId: String?,
    format: (Double) -> String,
    shape: RoundedCornerShape,
    bordered: Boolean,
    verticalPadding: Int,
    itemStyle: TextStyle,
    onSelected: (String) -> Unit,
) {
    var expanded by remember { mutableStateOf(false) }
    val selected = wallets.firstOrNull { it.id == selectedId }
    Box(modifier = Modifier.fillMaxWidth()) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .background(AppColors.canvasInputSearch, shape)
                .then(if (bordered) Modifier.border(1.dp, AppColors.canvasBorder, shape) else Modifier)
                .clickable(interactionSource = remember { MutableInteractionSource() }, indication = null) { expanded = true }
                .padding(horizontal = 14.dp, vertical = verticalPadding.dp)
                .heightIn(min = 48.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Text(
                if (selected != null) "${selected.name} (${format(selected.balance)})" else "",
                style = itemStyle,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
                modifier = Modifier.weight(1f),
            )
            Icon(Icons.Rounded.KeyboardArrowDown, contentDescription = null, tint = AppColors.textMuted)
        }
        DropdownMenu(
            expanded = expanded,
            onDismissRequest = { expanded = false },
            containerColor = AppColors.canvasCardSurface,
        ) {
            wallets.forEach { w ->
                DropdownMenuItem(
                    text = { Text("${w.name} (${format(w.balance)})", style = itemStyle, maxLines = 1, overflow = TextOverflow.Ellipsis) },
                    onClick = {
                        expanded = false
                        onSelected(w.id)
                    },
                )
            }
        }
    }
}
