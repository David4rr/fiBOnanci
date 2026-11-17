package com.fibonanci.app.ui.pocket

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.fibonanci.app.core.format.AppCurrency
import com.fibonanci.app.ui.LocalFinance
import com.fibonanci.app.ui.common.CurrencyAmountField
import com.fibonanci.app.ui.common.ModalGrabHandle
import com.fibonanci.app.ui.common.ModalHeader
import com.fibonanci.app.ui.common.ModalHost
import com.fibonanci.app.ui.common.ModalKind
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.AppTypography
import com.fibonanci.app.ui.theme.PlusJakartaSans

fun showAddPocketModal(host: ModalHost) {
    host.show(ModalKind.Sheet) { dismiss -> AddPocketSheet(onDismiss = dismiss) }
}

@Composable
private fun AddPocketSheet(onDismiss: () -> Unit) {
    val vm = LocalFinance.current
    val state by vm.state.collectAsStateWithLifecycle()
    val currency = state.profile.currency
    val format: (Double) -> String = { AppCurrency.format(it, currency) }

    var name by remember { mutableStateOf("") }
    var targetText by remember { mutableStateOf("") }
    var initialText by remember { mutableStateOf("") }
    var selectedType by remember { mutableStateOf("savings") }
    var selectedWalletId by remember { mutableStateOf<String?>(null) }
    var nameError by remember { mutableStateOf<String?>(null) }
    var initialError by remember { mutableStateOf<String?>(null) }

    val activeWallets = state.wallets.filter { !it.isDeleted }
    val resolvedWalletId = if (activeWallets.any { it.id == selectedWalletId }) selectedWalletId else activeWallets.firstOrNull()?.id
    val currentType = kPocketTypes.firstOrNull { it.id == selectedType } ?: kPocketTypes.first()
    val activeColor = AppColors.fromHex(currentType.color)

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(topStart = 28.dp, topEnd = 28.dp))
            .background(AppColors.canvasCardSurface)
            .verticalScroll(rememberScrollState())
            .padding(start = 24.dp, top = 16.dp, end = 24.dp, bottom = 24.dp),
    ) {
        ModalGrabHandle(padding = PaddingValues(bottom = 14.dp))
        ModalHeader(
            title = "Buat Kantong Alokasi Baru",
            subtitle = "Pisahkan dana tabungan agar tidak terpakai saat belanja harian.",
            onClose = onDismiss,
        )
        Spacer(Modifier.height(16.dp))
        Text("TIPE KANTONG", style = AppTypography.listSubtitle)
        Spacer(Modifier.height(8.dp))
        PocketTypeSelector(selectedType = selectedType, onSelectType = { selectedType = it })
        Spacer(Modifier.height(16.dp))
        PocketTypeSelector.buildTextField(
            value = name,
            onValueChange = { name = it },
            label = "Nama Kantong",
            hintText = "Nama Kantong (cth: Tabungan Pensiun, Liburan)",
            errorText = nameError,
            onChanged = { if (nameError != null) nameError = null },
        )
        Spacer(Modifier.height(12.dp))
        CurrencyAmountField(
            value = targetText,
            onValueChange = { targetText = it },
            labelText = "Target Tabungan (Opsional)",
            hintText = "0",
            prefixColor = AppColors.neoChartreuse,
        )
        Spacer(Modifier.height(12.dp))
        CurrencyAmountField(
            value = initialText,
            onValueChange = { initialText = it },
            labelText = "Setoran Awal (Opsional)",
            hintText = "0",
            errorText = initialError,
            prefixColor = AppColors.neoMint,
            onChanged = { if (initialError != null) initialError = null },
        )
        if (activeWallets.isNotEmpty()) {
            Spacer(Modifier.height(12.dp))
            Text("Ambil Dari Rekening (Jika ada setoran awal)", style = AppTypography.listSubtitle)
            Spacer(Modifier.height(6.dp))
            WalletDropdown(
                wallets = activeWallets,
                selectedId = resolvedWalletId,
                format = format,
                shape = RoundedCornerShape(16.dp),
                bordered = false,
                verticalPadding = 0,
                itemStyle = AppTypography.listSubtitle.copy(color = AppColors.textWhite),
                onSelected = { selectedWalletId = it },
            )
        }
        Spacer(Modifier.height(24.dp))
        Row(modifier = Modifier.fillMaxWidth()) {
            OutlinedButton(
                onClick = onDismiss,
                modifier = Modifier.weight(1f).height(52.dp),
                shape = RoundedCornerShape(16.dp),
                border = BorderStroke(1.dp, AppColors.canvasBorder),
            ) {
                Text("Batal", style = AppTypography.listTitle.copy(color = AppColors.textMuted, fontWeight = FontWeight.SemiBold))
            }
            Spacer(Modifier.width(10.dp))
            Button(
                onClick = {
                    val trimmed = name.trim()
                    if (trimmed.isEmpty()) {
                        nameError = "Nama kantong wajib diisi"
                        return@Button
                    }
                    val target = AppCurrency.parseInputToIdr(targetText, currency)
                    val initial = AppCurrency.parseInputToIdr(initialText, currency)
                    if (initial > 0 && resolvedWalletId != null && activeWallets.isNotEmpty()) {
                        val wallet = activeWallets.firstOrNull { it.id == resolvedWalletId } ?: activeWallets.first()
                        if (initial > wallet.balance) {
                            initialError = "Saldo tidak cukup (Maks ${format(wallet.balance)})"
                            return@Button
                        }
                    }
                    vm.addPocket(
                        name = trimmed,
                        type = selectedType,
                        targetAmount = if (target > 0) target else null,
                        initialAmount = initial,
                        colorHex = currentType.color,
                        iconName = "flag",
                        linkedWalletId = resolvedWalletId,
                    )
                    onDismiss()
                },
                modifier = Modifier.weight(2f).height(52.dp),
                shape = RoundedCornerShape(16.dp),
                colors = ButtonDefaults.buttonColors(containerColor = activeColor),
                elevation = ButtonDefaults.buttonElevation(0.dp, 0.dp, 0.dp, 0.dp, 0.dp),
            ) {
                Text(
                    "Buat Kantong Sekarang",
                    style = TextStyle(fontFamily = PlusJakartaSans, color = AppColors.canvasBg, fontWeight = FontWeight.ExtraBold, fontSize = 15.sp),
                )
            }
        }
    }
}
