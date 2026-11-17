package com.fibonanci.app.ui.wallet

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.ime
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.rounded.KeyboardArrowLeft
import androidx.compose.material.icons.rounded.DeleteOutline
import androidx.compose.material.icons.rounded.KeyboardArrowDown
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.platform.LocalFocusManager
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
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
import com.fibonanci.app.ui.common.ModalGrabHandle
import com.fibonanci.app.ui.common.ModalHeader
import com.fibonanci.app.ui.common.ModalHost
import com.fibonanci.app.ui.common.ModalKind
import com.fibonanci.app.ui.common.SmoothPageView
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.AppTypography
import kotlinx.coroutines.launch

fun showEditBalanceModal(host: ModalHost, wallet: WalletEntry) {
    host.show(ModalKind.Sheet) { dismiss -> EditBalanceModal(wallet = wallet, onDismiss = dismiss) }
}

@Composable
fun EditBalanceModal(wallet: WalletEntry, onDismiss: () -> Unit) {
    val vm = LocalFinance.current
    val host = LocalModalHost.current
    val context = LocalContext.current
    val focusManager = LocalFocusManager.current
    val scope = rememberCoroutineScope()
    val currency = vm.state.value.profile.currency

    var balanceText by remember { mutableStateOf(AppCurrency.formatIdrForInput(wallet.balance, currency)) }
    var accountNumberText by remember { mutableStateOf(wallet.accountNumber ?: "") }
    var customPackageText by remember { mutableStateOf("") }
    val pagerState = rememberPagerState { 2 }
    var selectedPackage by remember { mutableStateOf<String?>(null) }
    var isCustomPackage by remember { mutableStateOf(false) }
    var currentTab by remember { mutableIntStateOf(0) }
    var currentRule by remember { mutableStateOf<NotificationRuleEntry?>(null) }

    LaunchedEffect(Unit) {
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

    fun switchTab(tab: Int) {
        focusManager.clearFocus()
        currentTab = tab
        scope.launch { SmoothPageView.animateTo(pagerState, tab) }
    }

    fun save() {
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
        onDismiss()
    }

    val density = LocalDensity.current
    val bottomInset = with(density) { WindowInsets.ime.getBottom(density).toDp() }
    val screenHeight = LocalConfiguration.current.screenHeightDp.dp
    val sheetHeight = maxOf(360.dp, minOf(screenHeight - bottomInset - 32.dp, 560.dp))
    val isForm = currentTab == 0

    Column(
        Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(topStart = 28.dp, topEnd = 28.dp))
            .background(AppColors.canvasCardSurface)
            .padding(bottom = bottomInset)
            .height(sheetHeight),
    ) {
        Column(Modifier.padding(start = 24.dp, top = 16.dp, end = 24.dp)) {
            if (isForm) ModalGrabHandle(padding = PaddingValues(bottom = 14.dp)) else Spacer(Modifier.height(18.dp))
            ModalHeader(
                title = if (isForm) "Penyesuaian Saldo: ${wallet.name}" else "Pilih Aplikasi",
                subtitle = if (isForm) {
                    "Ubah saldo awal rekening sesuai saldo riil saat ini di m-banking."
                } else {
                    "Cari bank atau e-wallet di HP Anda"
                },
                closeIcon = if (isForm) Icons.Rounded.KeyboardArrowDown else Icons.AutoMirrored.Rounded.KeyboardArrowLeft,
                onClose = if (isForm) onDismiss else ({ switchTab(0) }),
            )
        }
        SmoothPageView(
            controller = pagerState,
            modifier = Modifier.weight(1f),
            children = listOf(
                {
                    Column(
                        Modifier
                            .fillMaxSize()
                            .verticalScroll(rememberScrollState())
                            .padding(start = 24.dp, end = 24.dp, bottom = 24.dp),
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
                            onOpenAppPicker = { switchTab(1) },
                        )
                        Spacer(Modifier.height(20.dp))
                        Row(Modifier.fillMaxWidth()) {
                            OutlinedButton(
                                onClick = onDismiss,
                                border = BorderStroke(1.dp, AppColors.canvasBorder),
                                shape = RoundedCornerShape(16.dp),
                                modifier = Modifier.weight(1f).height(52.dp),
                            ) {
                                Text("Batal", style = AppTypography.listTitle.copy(color = AppColors.textMuted, fontWeight = FontWeight.W600))
                            }
                            Spacer(Modifier.width(10.dp))
                            Button(
                                onClick = { save() },
                                colors = ButtonDefaults.buttonColors(containerColor = AppColors.neoChartreuse),
                                shape = RoundedCornerShape(16.dp),
                                elevation = ButtonDefaults.buttonElevation(0.dp, 0.dp, 0.dp, 0.dp, 0.dp),
                                modifier = Modifier.weight(2f).height(52.dp),
                            ) {
                                Text(
                                    "Perbarui Saldo",
                                    style = AppTypography.listTitle.copy(color = AppColors.textDarkPrimary, fontWeight = FontWeight.Bold),
                                )
                            }
                        }
                        Spacer(Modifier.height(14.dp))
                        TextButton(
                            onClick = { WalletDeleteDialog.show(host, vm, onDismiss, wallet) },
                            modifier = Modifier.align(Alignment.CenterHorizontally),
                        ) {
                            Icon(Icons.Rounded.DeleteOutline, contentDescription = null, tint = AppColors.neoCoral, modifier = Modifier.size(18.dp))
                            Spacer(Modifier.width(8.dp))
                            Text(
                                "Hapus Rekening",
                                style = AppTypography.listTitle.copy(color = AppColors.neoCoral, fontSize = 13.5.sp, fontWeight = FontWeight.W600),
                            )
                        }
                    }
                },
                {
                    InstalledAppPickerModal(
                        isInline = true,
                        onClose = { switchTab(0) },
                        onAppSelected = { picked ->
                            customPackageText = picked
                            selectedPackage = picked
                            isCustomPackage = true
                            switchTab(0)
                        },
                    )
                },
            ),
        )
    }
}
