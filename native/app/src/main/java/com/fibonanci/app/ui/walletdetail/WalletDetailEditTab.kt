package com.fibonanci.app.ui.walletdetail

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.asPaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.ime
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
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.compositionLocalOf
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalFocusManager
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewModelScope
import com.fibonanci.app.core.format.AppCurrency
import com.fibonanci.app.core.notification.NotificationBridge
import com.fibonanci.app.core.notification.kPopularBankAppPresets
import com.fibonanci.app.data.db.NotificationRuleEntry
import com.fibonanci.app.data.db.WalletEntry
import com.fibonanci.app.ui.LocalFinance
import com.fibonanci.app.ui.common.AppTextField
import com.fibonanci.app.ui.common.CurrencyAmountField
import com.fibonanci.app.ui.common.LocalModalHost
import com.fibonanci.app.ui.common.SlideToDeleteButton
import com.fibonanci.app.ui.common.SmoothPageView
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.AppTypography
import com.fibonanci.app.ui.wallet.InstalledAppPickerModal
import com.fibonanci.app.ui.wallet.WalletBindingSelector
import com.fibonanci.app.ui.wallet.WalletDeleteDialog
import kotlinx.coroutines.launch

// pops the whole wallet detail route (the dart modal context used by the delete dialog)
val LocalWalletDetailDismiss = compositionLocalOf<() -> Unit> { {} }

@Composable
fun WalletDetailEditTab(
    wallet: WalletEntry,
    onReturnToDetails: () -> Unit,
    isPickingApp: Boolean = false,
    onPickingAppChanged: ((Boolean) -> Unit)? = null,
    modifier: Modifier = Modifier,
) {
    val vm = LocalFinance.current
    val host = LocalModalHost.current
    val context = LocalContext.current
    val focusManager = LocalFocusManager.current
    val dismissRoute = LocalWalletDetailDismiss.current
    val scope = rememberCoroutineScope()
    val currency = vm.state.value.profile.currency

    var balanceText by remember { mutableStateOf(AppCurrency.formatIdrForInput(wallet.balance, currency)) }
    var accountNumberText by remember { mutableStateOf(wallet.accountNumber ?: "") }
    var customPackageText by remember { mutableStateOf("") }
    val pagerState = rememberPagerState(initialPage = if (isPickingApp) 1 else 0) { 2 }
    var selectedPackage by remember { mutableStateOf<String?>(null) }
    var isCustomPackage by remember { mutableStateOf(false) }
    var currentRule by remember { mutableStateOf<NotificationRuleEntry?>(null) }

    LaunchedEffect(Unit) {
        // warm the installed app cache like the dart initState
        launch { NotificationBridge.getInstalledBankApps(context) }
        val rules = vm.repository.getNotificationRulesForWallet(wallet.id)
        val match = rules.firstOrNull { it.isEnabled }
        if (match != null) {
            currentRule = match
            selectedPackage = match.packageName
            isCustomPackage = kPopularBankAppPresets.none { it.packageName == selectedPackage }
            if (isCustomPackage) customPackageText = selectedPackage ?: ""
        }
    }

    var lastPicking by remember { mutableStateOf(isPickingApp) }
    LaunchedEffect(isPickingApp) {
        if (isPickingApp != lastPicking) {
            lastPicking = isPickingApp
            SmoothPageView.animateTo(pagerState, if (isPickingApp) 1 else 0)
        }
    }

    fun setPickingApp(picking: Boolean) {
        focusManager.clearFocus()
        if (onPickingAppChanged != null) {
            onPickingAppChanged(picking)
        } else {
            scope.launch { SmoothPageView.animateTo(pagerState, if (picking) 1 else 0) }
        }
    }

    fun saveWallet() {
        val newBal = AppCurrency.parseInputToIdr(balanceText, currency)
        val accNum = accountNumberText.trim()
        val boundPkg = if (isCustomPackage) customPackageText.trim() else selectedPackage

        vm.updateWalletBalance(
            walletId = wallet.id,
            newBalance = if (newBal > 0) newBal else wallet.balance,
            accountNumber = accNum,
        )
        val repo = vm.repository
        val rule = currentRule
        if (!boundPkg.isNullOrEmpty()) {
            vm.viewModelScope.launch {
                repo.bindWalletToPackage(walletId = wallet.id, packageName = boundPkg)
                NotificationBridge.syncAllowedPackages(context, repo)
            }
        } else if (rule != null) {
            vm.viewModelScope.launch {
                repo.unbindPackage(rule.packageName)
                NotificationBridge.syncAllowedPackages(context, repo)
            }
        }

        onReturnToDetails()
    }

    SmoothPageView(
        controller = pagerState,
        modifier = modifier.fillMaxSize().background(AppColors.canvasCardSurface),
        children = listOf(
            {
                val imeBottom = WindowInsets.ime.asPaddingValues().calculateBottomPadding()
                Column(
                    modifier = Modifier
                        .fillMaxSize()
                        .verticalScroll(rememberScrollState())
                        .padding(start = 20.dp, top = 16.dp, end = 20.dp, bottom = 48.dp + imeBottom),
                ) {
                    CurrencyAmountField(value = balanceText, onValueChange = { balanceText = it })
                    Spacer(Modifier.height(12.dp))
                    AppTextField(
                        value = accountNumberText,
                        onValueChange = { accountNumberText = it },
                        hintText = "Nomor Rekening (Opsional, cth: 5410982341)",
                    )
                    Spacer(Modifier.height(14.dp))
                    WalletBindingSelector(
                        selectedPackage = selectedPackage,
                        isCustomPackage = isCustomPackage,
                        customPackageText = customPackageText,
                        onCustomPackageTextChange = { customPackageText = it },
                        onPackageChanged = { pkg, custom ->
                            selectedPackage = pkg
                            isCustomPackage = custom
                        },
                        onOpenAppPicker = { setPickingApp(true) },
                    )
                    Spacer(Modifier.height(20.dp))
                    Row(modifier = Modifier.fillMaxWidth()) {
                        OutlinedButton(
                            onClick = onReturnToDetails,
                            border = BorderStroke(1.dp, AppColors.canvasBorder),
                            shape = RoundedCornerShape(16.dp),
                            modifier = Modifier.weight(1f).height(52.dp),
                        ) {
                            Text("Batal", style = AppTypography.listTitle.copy(color = AppColors.textMuted, fontWeight = FontWeight.W600))
                        }
                        Spacer(Modifier.width(10.dp))
                        Button(
                            onClick = { saveWallet() },
                            colors = ButtonDefaults.buttonColors(containerColor = AppColors.neoChartreuse),
                            shape = RoundedCornerShape(16.dp),
                            elevation = ButtonDefaults.buttonElevation(0.dp, 0.dp, 0.dp, 0.dp, 0.dp),
                            modifier = Modifier.weight(2f).height(52.dp),
                        ) {
                            Text("Perbarui Saldo", style = AppTypography.listTitle.copy(color = AppColors.textDarkPrimary, fontWeight = FontWeight.Bold))
                        }
                    }
                    Spacer(Modifier.height(16.dp))
                    SlideToDeleteButton(
                        label = "Hapus Rekening",
                        onSlideComplete = { WalletDeleteDialog.show(host, vm, dismissRoute, wallet) },
                    )
                }
            },
            {
                InstalledAppPickerModal(
                    isInline = true,
                    onClose = { setPickingApp(false) },
                    onAppSelected = { picked ->
                        customPackageText = picked
                        selectedPackage = picked
                        isCustomPackage = true
                        setPickingApp(false)
                    },
                )
            },
        ),
    )
}
