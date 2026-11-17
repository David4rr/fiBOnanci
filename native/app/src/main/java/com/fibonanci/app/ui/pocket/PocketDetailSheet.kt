package com.fibonanci.app.ui.pocket

import androidx.activity.compose.BackHandler
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.rounded.KeyboardArrowLeft
import androidx.compose.material.icons.rounded.KeyboardArrowDown
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.key
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalFocusManager
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.fibonanci.app.core.format.AppCurrency
import com.fibonanci.app.data.db.PocketEntry
import com.fibonanci.app.data.db.TransactionEntry
import com.fibonanci.app.ui.LocalFinance
import com.fibonanci.app.ui.common.ExpandableModalSheet
import com.fibonanci.app.ui.common.ModalGrabHandle
import com.fibonanci.app.ui.common.ModalHeader
import com.fibonanci.app.ui.common.SmoothPageView
import com.fibonanci.app.ui.common.expandableSheetHeaderDrag
import com.fibonanci.app.ui.common.rememberExpandableModalSheetState
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.transaction.TransactionDetailModal
import kotlinx.coroutines.launch

@Composable
fun PocketDetailSheet(
    pocket: PocketEntry,
    initialTab: Int = 0,
    initialIsDeposit: Boolean = true,
    onDismiss: () -> Unit,
) {
    val vm = LocalFinance.current
    val state by vm.state.collectAsStateWithLifecycle()
    val focusManager = LocalFocusManager.current
    val scope = rememberCoroutineScope()
    val sheet = rememberExpandableModalSheetState()
    val pagerState = rememberPagerState(initialPage = if (initialTab == 0) 0 else 1) { 2 }

    var currentTab by remember { mutableIntStateOf(initialTab) }
    var subTab by remember { mutableIntStateOf(if (initialTab != 0) initialTab else 1) }
    var isDeposit by remember { mutableStateOf(initialIsDeposit) }
    var selectedTransaction by remember { mutableStateOf<TransactionEntry?>(null) }

    fun goToTransfer(deposit: Boolean) {
        focusManager.clearFocus()
        isDeposit = deposit
        subTab = 1
        currentTab = 1
        scope.launch { SmoothPageView.animateTo(pagerState, 1) }
    }

    fun goToEditTx(tx: TransactionEntry) {
        focusManager.clearFocus()
        selectedTransaction = tx
        subTab = 2
        currentTab = 2
        scope.launch { SmoothPageView.animateTo(pagerState, 1) }
    }

    fun goToDetails() {
        focusManager.clearFocus()
        currentTab = 0
        scope.launch { SmoothPageView.animateTo(pagerState, 0) }
    }

    val canPop = currentTab == 0 || (initialTab == 1 && currentTab == 1)
    fun handleClose() = if (canPop) onDismiss() else goToDetails()

    val latestPocket = state.pockets.firstOrNull { it.id == pocket.id } ?: pocket
    val pocketIdx = state.pockets.indexOfFirst { it.id == latestPocket.id }
    val themeConfig = PocketCardThemeConfig.resolve(latestPocket, if (pocketIdx >= 0) pocketIdx else 0, allPockets = state.pockets)
    val pocketColor = themeConfig.backgroundColor
    val pocketTxs = state.transactions.filter { tx ->
        val ref = tx.externalRef
        when {
            ref == "pocket_${latestPocket.id}" || ref == "pocket_close_${latestPocket.id}" -> true
            ref != null && ref.startsWith("pocket_") -> false
            else -> (tx.notes ?: "").lowercase().contains(latestPocket.name.lowercase())
        }
    }
    val currency = state.profile.currency
    val fmt: (Double) -> String = { AppCurrency.format(it, currency) }

    val title = when (currentTab) {
        1 -> if (isDeposit) "Isi Dana ke Kantong" else "Tarik Dana ke Rekening"
        2 -> "Edit Transaksi"
        else -> latestPocket.name
    }
    val subtitle = when (currentTab) {
        1 -> if (isDeposit) {
            "Pilih rekening asal untuk memindahkan dana ke ${latestPocket.name}."
        } else {
            "Pilih rekening tujuan penarikan dari ${latestPocket.name}."
        }
        2 -> selectedTransaction?.notes?.trim()?.takeIf { it.isNotEmpty() } ?: "Ubah rincian mutasi transaksi"
        else -> {
            val target = latestPocket.targetAmount
            if (target != null && target > 0) {
                "${getPocketTypeLabel(latestPocket.type)} • Target: ${fmt(target)}"
            } else {
                getPocketTypeLabel(latestPocket.type)
            }
        }
    }

    // dart PopScope: back goes to the details page instead of closing
    BackHandler(enabled = !canPop) { goToDetails() }

    ExpandableModalSheet(
        onDismiss = onDismiss,
        initialChildSize = 1.0,
        minChildSize = 0.25,
        maxChildSize = 1.0,
        snapSizes = listOf(1.0),
        backgroundColor = AppColors.canvasBg,
        state = sheet,
    ) { _ ->
        Column {
            Column(modifier = Modifier.fillMaxWidth().expandableSheetHeaderDrag(sheet)) {
                if (currentTab == 0) {
                    ModalGrabHandle(padding = PaddingValues(top = 10.dp, bottom = 6.dp))
                } else {
                    Spacer(Modifier.height(20.dp))
                }
                ModalHeader(
                    padding = PaddingValues(start = 20.dp, top = 4.dp, end = 20.dp, bottom = 12.dp),
                    title = title,
                    subtitle = subtitle,
                    closeIcon = if (canPop) Icons.Rounded.KeyboardArrowDown else Icons.AutoMirrored.Rounded.KeyboardArrowLeft,
                    onClose = { handleClose() },
                )
            }
            SmoothPageView(
                controller = pagerState,
                modifier = Modifier.weight(1f),
                children = listOf(
                    {
                        PocketDetailTab(
                            pocket = latestPocket,
                            pocketColor = pocketColor,
                            themeConfig = themeConfig,
                            transactions = pocketTxs,
                            wallets = state.wallets,
                            fmt = fmt,
                            onDeposit = { goToTransfer(true) },
                            onWithdraw = { goToTransfer(false) },
                            onEditTransaction = { goToEditTx(it) },
                            onDismiss = onDismiss,
                        )
                    },
                    {
                        val tx = selectedTransaction
                        if (subTab == 2 && tx != null) {
                            key(tx.id) {
                                TransactionDetailModal(
                                    transaction = tx,
                                    isInline = true,
                                    onClose = { goToDetails() },
                                    onSaved = { goToDetails() },
                                    onDeleted = { goToDetails() },
                                )
                            }
                        } else {
                            Column(
                                modifier = Modifier
                                    .verticalScroll(rememberScrollState())
                                    .padding(start = 24.dp, end = 24.dp, bottom = 24.dp),
                            ) {
                                key("transfer_${isDeposit}_${latestPocket.id}") {
                                    PocketTransferForm(
                                        pocket = latestPocket,
                                        isDeposit = isDeposit,
                                        onSuccess = { handleClose() },
                                        onCancel = { handleClose() },
                                    )
                                }
                            }
                        }
                    },
                ),
            )
        }
    }
}
