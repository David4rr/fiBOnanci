package com.fibonanci.app.ui.subscription

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.fibonanci.app.core.format.AppCurrency
import com.fibonanci.app.data.db.SubscriptionEntry
import com.fibonanci.app.ui.LocalFinance
import com.fibonanci.app.ui.common.AppTextField
import com.fibonanci.app.ui.common.CurrencyAmountField
import com.fibonanci.app.ui.common.LocalModalHost
import com.fibonanci.app.ui.common.PrimaryActionButton
import com.fibonanci.app.ui.common.SlideToDeleteButton
import com.fibonanci.app.ui.theme.AppColors

// full-height edit view for installments and subscriptions embedded as a sliding tab inside the detail screen.
@Composable
fun SubscriptionDetailEditTab(
    subscription: SubscriptionEntry,
    onSaved: (() -> Unit)? = null,
    onReturnToDetails: (() -> Unit)? = null,
    onDismiss: () -> Unit,
) {
    val vm = LocalFinance.current
    val host = LocalModalHost.current
    val state by vm.state.collectAsStateWithLifecycle()
    val currency = state.profile.currency
    val sub = subscription

    var title by remember { mutableStateOf(sub.title) }
    var costText by remember { mutableStateOf(AppCurrency.formatIdrForInput(sub.cost, currency)) }
    var dueDay by remember { mutableIntStateOf(sub.dueDay) }
    var autoDeduct by remember { mutableStateOf(sub.autoDeduct) }
    var isInstallment by remember { mutableStateOf(sub.isInstallment) }
    var totalCycles by remember { mutableIntStateOf(sub.totalCycles ?: 3) }
    var selectedWalletId by remember { mutableStateOf<String?>(sub.walletId) }
    val selectedCategoryId: String? = remember { sub.categoryId }

    fun saveSubscription() {
        val trimmed = title.trim()
        val cost = AppCurrency.parseInputToIdr(costText, currency)
        val walletId = selectedWalletId
        val categoryId = selectedCategoryId
        if (trimmed.isEmpty() || cost <= 0 || walletId == null || categoryId == null) return

        val deadline = if (isInstallment) SubscriptionInstallmentSelector.calculateDeadlineDate(dueDay = dueDay, totalCycles = totalCycles) else null
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
        if (onSaved != null) onSaved() else onDismiss()
    }

    val wallets = state.wallets
    val safeWalletId = if (wallets.any { it.id == selectedWalletId }) selectedWalletId else wallets.firstOrNull()?.id

    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(start = 20.dp, top = 8.dp, end = 20.dp, bottom = 32.dp),
    ) {
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
        PrimaryActionButton(text = "Simpan Perubahan", onPressed = { saveSubscription() })
        Spacer(Modifier.height(14.dp))
        SlideToDeleteButton(
            label = if (isInstallment) "Hapus Cicilan Ini" else "Hapus Langganan Ini",
            onSlideComplete = { executeDeleteSubscription(vm, host, sub.id, onDismiss) },
        )
    }
}
