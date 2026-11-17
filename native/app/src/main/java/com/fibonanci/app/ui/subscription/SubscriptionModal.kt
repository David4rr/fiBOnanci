package com.fibonanci.app.ui.subscription

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.imePadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.DeleteOutline
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.fibonanci.app.core.format.AppCurrency
import com.fibonanci.app.data.db.SubscriptionEntry
import com.fibonanci.app.ui.LocalFinance
import com.fibonanci.app.ui.common.AppTextField
import com.fibonanci.app.ui.common.CurrencyAmountField
import com.fibonanci.app.ui.common.LocalModalHost
import com.fibonanci.app.ui.common.ModalGrabHandle
import com.fibonanci.app.ui.common.ModalHeader
import com.fibonanci.app.ui.common.ModalHost
import com.fibonanci.app.ui.common.ModalKind
import com.fibonanci.app.ui.common.PrimaryActionButton
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.AppTypography

fun showAddSubscriptionModal(host: ModalHost, subscription: SubscriptionEntry? = null) {
    host.show(ModalKind.Sheet) { dismiss ->
        AddSubscriptionModal(subscription = subscription, onDismiss = dismiss)
    }
}

@Composable
fun AddSubscriptionModal(
    subscription: SubscriptionEntry? = null,
    onDismiss: () -> Unit,
) {
    val vm = LocalFinance.current
    val host = LocalModalHost.current
    val state by vm.state.collectAsStateWithLifecycle()
    val currency = state.profile.currency
    val sub = subscription

    var title by remember { mutableStateOf(sub?.title ?: "") }
    var costText by remember { mutableStateOf(if (sub != null) AppCurrency.formatIdrForInput(sub.cost, currency) else "") }
    var dueDay by remember { mutableIntStateOf(sub?.dueDay ?: 15) }
    var autoDeduct by remember { mutableStateOf(sub?.autoDeduct ?: false) }
    var isInstallment by remember { mutableStateOf(sub?.isInstallment ?: false) }
    var totalCycles by remember { mutableIntStateOf(sub?.totalCycles ?: 3) }
    var selectedWalletId by remember { mutableStateOf(sub?.walletId ?: state.wallets.firstOrNull()?.id) }
    val selectedCategoryId by remember {
        mutableStateOf(
            sub?.categoryId ?: if (state.categories.isNotEmpty()) {
                (state.categories.firstOrNull { it.name.contains("Tagihan") || it.name.contains("Hiburan") } ?: state.categories.first()).id
            } else null,
        )
    }

    fun saveSubscription() {
        val trimmed = title.trim()
        val cost = AppCurrency.parseInputToIdr(costText, currency)
        val walletId = selectedWalletId
        val categoryId = selectedCategoryId
        if (trimmed.isEmpty() || cost <= 0 || walletId == null || categoryId == null) return

        val deadline = if (isInstallment) SubscriptionInstallmentSelector.calculateDeadlineDate(dueDay = dueDay, totalCycles = totalCycles) else null
        if (sub != null) {
            vm.updateSubscription(
                subscriptionId = sub.id,
                title = trimmed,
                cost = cost,
                dueDay = dueDay,
                walletId = walletId,
                categoryId = categoryId,
                autoDeduct = autoDeduct,
                isInstallment = isInstallment,
                totalCycles = if (isInstallment) totalCycles else null,
                paidCycles = sub.paidCycles,
                deadlineDate = deadline,
            )
        } else {
            vm.addSubscription(
                title = trimmed,
                cost = cost,
                dueDay = dueDay,
                walletId = walletId,
                categoryId = categoryId,
                autoDeduct = autoDeduct,
                isInstallment = isInstallment,
                totalCycles = if (isInstallment) totalCycles else null,
                deadlineDate = deadline,
            )
        }
        onDismiss()
    }

    val isEditing = sub != null
    val wallets = state.wallets
    val safeWalletId = if (wallets.any { it.id == selectedWalletId }) selectedWalletId else wallets.firstOrNull()?.id

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .background(AppColors.canvasCardSurface, RoundedCornerShape(topStart = 28.dp, topEnd = 28.dp))
            .imePadding()
            .padding(start = 24.dp, top = 16.dp, end = 24.dp, bottom = 24.dp)
            .verticalScroll(rememberScrollState()),
    ) {
        ModalGrabHandle(padding = PaddingValues(bottom = 14.dp))
        ModalHeader(
            title = if (isEditing) {
                if (isInstallment) "Edit Cicilan" else "Edit Tagihan Rutin"
            } else {
                if (isInstallment) "Tambah Cicilan Baru" else "Tambah Tagihan Baru"
            },
            subtitle = if (isInstallment) "Rencana cicilan tenor & jatuh tempo" else "Langganan, tagihan rutin, atau tagihan berkala",
            titleStyle = AppTypography.modalTitle,
            subtitleStyle = AppTypography.modalSubtitle,
            onClose = onDismiss,
        )
        Spacer(Modifier.height(16.dp))
        AppTextField(
            value = title,
            onValueChange = { title = it },
            hintText = "cth: Netflix, Spotify, Listrik PLN, Kosan",
        )
        Spacer(Modifier.height(12.dp))
        CurrencyAmountField(
            value = costText,
            onValueChange = { costText = it },
            prefixColor = AppColors.neoCoral,
        )
        Spacer(Modifier.height(12.dp))
        SubscriptionInstallmentSelector(
            isInstallment = isInstallment,
            totalCycles = totalCycles,
            dueDay = dueDay,
            onToggleInstallment = { isInstallment = it },
            onCyclesChanged = { totalCycles = it },
        )
        Spacer(Modifier.height(12.dp))
        SubscriptionDueDaySlider(dueDay = dueDay, onDayChanged = { dueDay = it })
        Spacer(Modifier.height(8.dp))
        SubscriptionWalletDropdown(wallets = wallets, selectedWalletId = safeWalletId, onWalletChanged = { selectedWalletId = it })
        Spacer(Modifier.height(12.dp))
        SubscriptionAutoDeductSwitch(autoDeduct = autoDeduct, onToggle = { autoDeduct = it })
        Spacer(Modifier.height(20.dp))
        PrimaryActionButton(
            text = if (isEditing) "Simpan Perubahan" else "Simpan Tagihan",
            onPressed = { saveSubscription() },
        )
        if (sub != null) {
            Spacer(Modifier.height(12.dp))
            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.Center) {
                TextButton(
                    onClick = { showSubscriptionDeleteDialog(vm, host, sub.id, onDismiss) },
                    colors = ButtonDefaults.textButtonColors(contentColor = AppColors.neoCoral),
                ) {
                    Icon(Icons.Rounded.DeleteOutline, contentDescription = null, modifier = Modifier.size(18.dp))
                    Spacer(Modifier.width(8.dp))
                    Text(
                        "Hapus Langganan Ini",
                        style = AppTypography.listTitle.copy(color = AppColors.neoCoral, fontSize = 13.sp, fontWeight = FontWeight.W700),
                    )
                }
            }
        }
    }
}
