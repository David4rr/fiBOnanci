package com.fibonanci.app.ui.inbox

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.ime
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.windowInsetsPadding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Checkbox
import androidx.compose.material3.CheckboxDefaults
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.fibonanci.app.core.notification.NotificationBridge
import com.fibonanci.app.core.notification.ParsedNotificationResult
import com.fibonanci.app.ui.LocalFinance
import com.fibonanci.app.ui.common.AppTextField
import com.fibonanci.app.ui.common.CurrencyAmountField
import com.fibonanci.app.ui.common.ModalGrabHandle
import com.fibonanci.app.ui.common.ModalHeader
import com.fibonanci.app.ui.common.ModalHost
import com.fibonanci.app.ui.common.ModalKind
import com.fibonanci.app.ui.common.PrimaryActionButton
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.AppTypography
import kotlinx.coroutines.launch

fun showNotificationReviewModal(
    host: ModalHost,
    parsed: ParsedNotificationResult,
    rawPackage: String,
    onResult: (Boolean) -> Unit = {},
) {
    host.show(ModalKind.Sheet) { dismiss ->
        NotificationReviewModal(
            parsed = parsed,
            rawPackage = rawPackage,
            onClose = { result ->
                dismiss()
                onResult(result)
            },
        )
    }
}

@Composable
fun NotificationReviewModal(
    parsed: ParsedNotificationResult,
    rawPackage: String,
    onClose: (Boolean) -> Unit,
    modifier: Modifier = Modifier,
) {
    val vm = LocalFinance.current
    val state by vm.state.collectAsStateWithLifecycle()
    val context = LocalContext.current
    val scope = rememberCoroutineScope()

    var amountText by remember { mutableStateOf("%.0f".format(parsed.amount)) }
    var notesText by remember { mutableStateOf(parsed.counterparty) }
    var type by remember { mutableStateOf(parsed.type) }
    var selectedWalletId by remember { mutableStateOf<String?>(null) }
    var selectedCategoryId by remember { mutableStateOf<String?>(null) }
    var isSaving by remember { mutableStateOf(false) }
    var rememberBinding by remember { mutableStateOf(false) }

    LaunchedEffect(Unit) {
        val rules = vm.repository.getNotificationRules(profileId = vm.state.value.profile.id)
        val match = rules.firstOrNull { it.packageName == rawPackage && it.isEnabled }
        if (match != null) selectedWalletId = match.walletId
    }

    fun confirmAndSave() {
        val amt = amountText.replace(Regex("[^0-9]"), "").toDoubleOrNull()
        if (amt == null || amt <= 0) return
        val walletId = selectedWalletId ?: state.wallets.firstOrNull()?.id
        val categoryId = selectedCategoryId ?: state.categories.firstOrNull()?.id
        if (walletId == null || categoryId == null) return

        isSaving = true
        scope.launch {
            if (rememberBinding) {
                vm.bindWalletToPackage(walletId = walletId, packageName = rawPackage, isEnabled = true)
                NotificationBridge.syncAllowedPackages(context, vm.repository)
            }
            vm.addTransaction(
                walletId = walletId,
                categoryId = categoryId,
                amount = amt,
                type = type,
                notes = notesText.trim(),
                source = "notification_prompt",
                externalRef = parsed.externalRef,
            )
            onClose(true)
        }
    }

    Column(
        modifier = modifier
            .fillMaxWidth()
            .background(AppColors.canvasCardSurface, RoundedCornerShape(topStart = 28.dp, topEnd = 28.dp))
            .windowInsetsPadding(WindowInsets.ime)
            .padding(start = 24.dp, top = 16.dp, end = 24.dp, bottom = 24.dp)
            .verticalScroll(rememberScrollState()),
    ) {
        ModalGrabHandle(padding = PaddingValues(bottom = 14.dp))
        ModalHeader(
            title = "Review Notifikasi Bank",
            subtitle = "Deteksi otomatis dari $rawPackage",
            onClose = { onClose(false) },
        )
        Spacer(Modifier.height(16.dp))
        Row {
            with(NotificationReviewSelectors) {
                buildTypePill(
                    label = "Pemasukan (+)",
                    isSelected = type == "income",
                    activeColor = AppColors.neoMint,
                    onTap = { type = "income" },
                )
                Spacer(Modifier.width(10.dp))
                buildTypePill(
                    label = "Pengeluaran (-)",
                    isSelected = type == "expense",
                    activeColor = AppColors.neoCoral,
                    onTap = { type = "expense" },
                )
            }
        }
        Spacer(Modifier.height(16.dp))
        CurrencyAmountField(
            value = amountText,
            onValueChange = { amountText = it },
            prefixColor = if (type == "income") AppColors.neoMint else AppColors.neoCoral,
        )
        Spacer(Modifier.height(16.dp))
        Text("REKENING TUJUAN / ASAL", style = AppTypography.badgeLabel.copy(color = AppColors.neoChartreuse))
        Spacer(Modifier.height(6.dp))
        NotificationReviewSelectors.buildWalletDropdown(
            wallets = state.wallets,
            selectedWalletId = selectedWalletId,
            onChanged = { selectedWalletId = it },
        )
        Spacer(Modifier.height(16.dp))
        Text("KATEGORI", style = AppTypography.badgeLabel.copy(color = AppColors.textMuted))
        Spacer(Modifier.height(6.dp))
        NotificationReviewSelectors.buildCategoryDropdown(
            categories = state.categories,
            selectedCategoryId = selectedCategoryId,
            onChanged = { selectedCategoryId = it },
        )
        Spacer(Modifier.height(16.dp))
        AppTextField(value = notesText, onValueChange = { notesText = it }, hintText = "Catatan / Merchant")
        Spacer(Modifier.height(14.dp))
        // dense leading CheckboxListTile
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .clickable { rememberBinding = !rememberBinding }
                .padding(vertical = 4.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Checkbox(
                checked = rememberBinding,
                onCheckedChange = { rememberBinding = it },
                colors = CheckboxDefaults.colors(
                    checkedColor = AppColors.neoChartreuse,
                    checkmarkColor = AppColors.textDarkPrimary,
                ),
            )
            Spacer(Modifier.width(16.dp))
            Text(
                "Ingat rekening ini untuk $rawPackage",
                style = AppTypography.listSubtitle.copy(color = AppColors.textWhite),
                modifier = Modifier.weight(1f),
            )
        }
        Spacer(Modifier.height(20.dp))
        Row {
            OutlinedButton(
                onClick = { onClose(false) },
                modifier = Modifier.weight(1f).height(52.dp),
                border = BorderStroke(1.dp, AppColors.canvasBorder),
                shape = RoundedCornerShape(16.dp),
            ) {
                Text("Abaikan", style = TextStyle(color = AppColors.textMuted))
            }
            Spacer(Modifier.width(14.dp))
            PrimaryActionButton(
                text = "Konfirmasi Simpan",
                isLoading = isSaving,
                onPressed = if (isSaving) null else ({ confirmAndSave() }),
                modifier = Modifier.weight(2f),
            )
        }
    }
}
