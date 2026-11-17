package com.fibonanci.app.ui.wallet

import androidx.activity.compose.BackHandler
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
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.rounded.KeyboardArrowLeft
import androidx.compose.material.icons.rounded.KeyboardArrowDown
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Text
import androidx.compose.material3.TextField
import androidx.compose.material3.TextFieldDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.platform.LocalFocusManager
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.TextFieldValue
import androidx.compose.ui.unit.dp
import com.fibonanci.app.core.format.AppCurrency
import com.fibonanci.app.core.format.RupiahInputFormatter
import com.fibonanci.app.core.notification.NotificationBridge
import com.fibonanci.app.ui.LocalFinance
import com.fibonanci.app.ui.common.AppTextField
import com.fibonanci.app.ui.common.ModalGrabHandle
import com.fibonanci.app.ui.common.ModalHeader
import com.fibonanci.app.ui.common.ModalHost
import com.fibonanci.app.ui.common.ModalKind
import com.fibonanci.app.ui.common.SmoothPageView
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.AppTypography
import kotlinx.coroutines.launch

fun showAddWalletModal(host: ModalHost) {
    host.show(ModalKind.Sheet) { dismiss -> AddWalletModal(onDismiss = dismiss) }
}

@Composable
fun AddWalletModal(onDismiss: () -> Unit) {
    val vm = LocalFinance.current
    val context = LocalContext.current
    val focusManager = LocalFocusManager.current
    val scope = rememberCoroutineScope()
    val currency = vm.state.value.profile.currency

    var nameText by remember { mutableStateOf("") }
    var balanceValue by remember { mutableStateOf(TextFieldValue("")) }
    var accountNumberText by remember { mutableStateOf("") }
    var customPackageText by remember { mutableStateOf("") }
    val pagerState = rememberPagerState { 2 }
    var type by remember { mutableStateOf("bank") }
    var selectedPackage by remember { mutableStateOf<String?>(null) }
    var isCustomPackage by remember { mutableStateOf(false) }
    var currentTab by remember { mutableIntStateOf(0) }

    // warm the installed app cache like initState
    LaunchedEffect(Unit) { NotificationBridge.getInstalledBankApps(context) }

    fun switchTab(tab: Int) {
        focusManager.clearFocus()
        currentTab = tab
        scope.launch { SmoothPageView.animateTo(pagerState, tab) }
    }

    fun saveWallet() {
        val name = nameText.trim()
        if (name.isEmpty()) return
        val balance = AppCurrency.parseInputToIdr(balanceValue.text, currency)
        val accNum = accountNumberText.trim()
        val boundPkg = if (isCustomPackage) customPackageText.trim() else selectedPackage

        vm.addWallet(
            name = name,
            type = type,
            accountNumber = accNum.ifEmpty { null },
            initialBalance = balance,
            colorHex = "#10B981",
            iconName = if (type == "cash") "wallet" else "landmark",
            boundPackageName = if (!boundPkg.isNullOrEmpty()) boundPkg else null,
        )
        onDismiss()
    }

    val density = LocalDensity.current
    val bottomInset = with(density) { WindowInsets.ime.getBottom(density).toDp() }
    val screenHeight = LocalConfiguration.current.screenHeightDp.dp
    val sheetHeight = maxOf(360.dp, minOf(screenHeight - bottomInset - 24.dp, 700.dp))
    val symbol = AppCurrency.symbolFor(currency)
    val isForm = currentTab == 0

    // PopScope(canPop: isForm): back on the picker page returns to the form
    BackHandler(enabled = !isForm) { switchTab(0) }

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
                title = if (isForm) "Tambah Rekening Baru" else "Pilih Aplikasi",
                subtitle = if (isForm) "Bank, E-Wallet, atau Kas Tunai" else "Cari bank atau e-wallet di HP Anda",
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
                        AppTextField(
                            value = nameText,
                            onValueChange = { nameText = it },
                            hintText = "Nama Rekening (cth: Kas Tunai, Bank Jago Saving)",
                        )
                        Spacer(Modifier.height(12.dp))
                        TextField(
                            value = balanceValue,
                            onValueChange = { balanceValue = RupiahInputFormatter.formatEditUpdate(balanceValue, it) },
                            modifier = Modifier.fillMaxWidth(),
                            textStyle = AppTypography.listTitle,
                            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                            placeholder = { Text("Saldo Awal (${symbol.trim()})") },
                            prefix = { Text(symbol, style = AppTypography.listTitle) },
                            singleLine = true,
                            shape = RoundedCornerShape(16.dp),
                            colors = TextFieldDefaults.colors(
                                focusedContainerColor = AppColors.canvasInputSearch,
                                unfocusedContainerColor = AppColors.canvasInputSearch,
                                focusedIndicatorColor = Color.Transparent,
                                unfocusedIndicatorColor = Color.Transparent,
                            ),
                        )
                        Spacer(Modifier.height(12.dp))
                        AppTextField(
                            value = accountNumberText,
                            onValueChange = { accountNumberText = it },
                            hintText = "Nomor Rekening (Opsional, cth: 5410982341)",
                        )
                        Spacer(Modifier.height(12.dp))
                        WalletTypeSelector(selectedType = type, onTypeChanged = { type = it })
                        Spacer(Modifier.height(16.dp))
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
                        Spacer(Modifier.height(24.dp))
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
                                onClick = { saveWallet() },
                                colors = ButtonDefaults.buttonColors(containerColor = AppColors.neoChartreuse),
                                shape = RoundedCornerShape(16.dp),
                                elevation = ButtonDefaults.buttonElevation(0.dp, 0.dp, 0.dp, 0.dp, 0.dp),
                                modifier = Modifier.weight(2f).height(52.dp),
                            ) {
                                Text(
                                    "Simpan Rekening",
                                    style = AppTypography.listTitle.copy(color = AppColors.textDarkPrimary, fontWeight = FontWeight.W800),
                                )
                            }
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
