package com.fibonanci.app.ui.walletdetail

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalFocusManager
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.fibonanci.app.data.db.TransactionEntry
import com.fibonanci.app.data.db.WalletEntry
import com.fibonanci.app.ui.LocalFinance
import com.fibonanci.app.ui.common.ExpandableModalSheet
import com.fibonanci.app.ui.common.ModalHost
import com.fibonanci.app.ui.common.SmoothPageView
import com.fibonanci.app.ui.common.expandableSheetHeaderDrag
import com.fibonanci.app.ui.common.rememberExpandableModalSheetState
import com.fibonanci.app.ui.wallet.getWalletColor
import kotlinx.coroutines.launch
import kotlin.math.abs

fun showWalletDetailScreen(host: ModalHost, wallet: WalletEntry, initialChildSize: Double = 1.0) =
    showWalletDetail(host, wallet = wallet, initialChildSize = initialChildSize)

fun pushWalletDetailScreen(host: ModalHost, wallet: WalletEntry, initialChildSize: Double = 1.0) =
    showWalletDetail(host, wallet = wallet, initialChildSize = initialChildSize)

@Composable
fun WalletDetailScreen(
    walletId: String,
    fmt: (Double) -> String,
    initialChildSize: Double = 1.0,
    onDismiss: () -> Unit,
) {
    val vm = LocalFinance.current
    val state by vm.state.collectAsStateWithLifecycle()
    val focusManager = LocalFocusManager.current
    val scope = rememberCoroutineScope()
    val sheet = rememberExpandableModalSheetState()
    val pagerState = rememberPagerState(initialPage = 0) { 2 }
    val listState = rememberLazyListState()

    var headerOpacity by remember { mutableFloatStateOf(0f) }
    var selectedFilter by remember { mutableStateOf(WalletTxFilter.all) }
    var searchText by remember { mutableStateOf("") }
    var searchQuery by remember { mutableStateOf("") }
    var currentTab by remember { mutableIntStateOf(0) }
    var subTab by remember { mutableIntStateOf(1) }
    var isPickingApp by remember { mutableStateOf(false) }
    var selectedTransaction by remember { mutableStateOf<TransactionEntry?>(null) }

    fun goToSubTab(tab: Int, tx: TransactionEntry? = null) {
        focusManager.clearFocus()
        isPickingApp = false
        if (tx != null) selectedTransaction = tx
        if (tab != 0) subTab = tab
        currentTab = tab
        scope.launch { SmoothPageView.animateTo(pagerState, if (tab == 0) 0 else 1) }
    }

    // the last wallet may disappear while the route is closing after a delete
    if (state.wallets.isEmpty()) return
    val wallet = state.wallets.firstOrNull { it.id == walletId } ?: state.wallets.first()
    val cardIndex = state.wallets.indexOfFirst { it.id == walletId }
    val cardColor = getWalletColor(if (cardIndex >= 0) cardIndex else 0, wallet.colorHex)
    val walletTx = state.transactions.filter { it.walletId == wallet.id || it.destinationWalletId == wallet.id }

    val filteredTx = walletTx.filter { tx ->
        if (selectedFilter == WalletTxFilter.income && tx.type != "income" && (tx.type != "transfer" || tx.destinationWalletId != wallet.id)) return@filter false
        if (selectedFilter == WalletTxFilter.expense && tx.type != "expense" && (tx.type != "transfer" || tx.walletId != wallet.id)) return@filter false
        if (selectedFilter == WalletTxFilter.transfer && tx.type != "transfer") return@filter false
        if (searchQuery.isNotEmpty()) {
            val notes = (tx.notes ?: "").lowercase()
            val amountStr = fmt(tx.amount).lowercase()
            if (!notes.contains(searchQuery) && !amountStr.contains(searchQuery)) return@filter false
        }
        true
    }

    val editingPicker = currentTab == 1 && isPickingApp
    CompositionLocalProvider(LocalWalletDetailDismiss provides onDismiss) {
        ExpandableModalSheet(
            onDismiss = onDismiss,
            initialChildSize = initialChildSize,
            minChildSize = 0.25,
            maxChildSize = 1.0,
            snapSizes = listOf(initialChildSize, 1.0),
            state = sheet,
        ) { _ ->
            Column {
                WalletDetailAppBar(
                    wallet = wallet,
                    headerBalanceOpacity = headerOpacity,
                    headerOpacityListenable = { headerOpacity },
                    fmt = fmt,
                    onDismiss = onDismiss,
                    isEditing = currentTab != 0,
                    onReturnToDetails = if (editingPicker) ({ isPickingApp = false }) else ({ goToSubTab(0) }),
                    customTitle = when {
                        editingPicker -> "Pilih Aplikasi"
                        currentTab == 1 -> "Penyesuaian Saldo: ${wallet.name}"
                        currentTab == 2 -> "Catat Transaksi"
                        currentTab == 3 -> "Edit Transaksi"
                        else -> null
                    },
                    customSubtitle = when {
                        editingPicker -> "Cari bank atau e-wallet di HP Anda"
                        currentTab == 1 -> "Ubah saldo awal & preferensi rekening"
                        currentTab == 2 -> "Rekening: ${wallet.name}"
                        currentTab == 3 -> selectedTransaction?.notes?.takeIf { it.isNotEmpty() } ?: "Ubah rincian mutasi transaksi"
                        else -> null
                    },
                    modifier = Modifier.fillMaxWidth().expandableSheetHeaderDrag(sheet),
                )
                WalletDetailPageView(
                    pageController = pagerState,
                    activeSubTab = subTab,
                    scrollController = listState,
                    wallet = wallet,
                    cardIndex = if (cardIndex >= 0) cardIndex else 0,
                    fmt = fmt,
                    cardColor = cardColor,
                    allWallets = state.wallets,
                    transactions = state.transactions,
                    filteredTx = filteredTx,
                    searchText = searchText,
                    searchQuery = searchQuery,
                    selectedFilter = selectedFilter,
                    onSearchChanged = { q ->
                        searchText = q
                        searchQuery = q.trim().lowercase()
                    },
                    onClearSearch = {
                        searchText = ""
                        searchQuery = ""
                    },
                    onFilterChanged = { selectedFilter = it },
                    onScrollOffsetChanged = { off ->
                        val next = (off / 160f).coerceIn(0f, 1f)
                        if (abs(next - headerOpacity) > 0.01f || next == 0f || next == 1f) {
                            headerOpacity = next
                        }
                    },
                    onEditBalance = { goToSubTab(1) },
                    onAddTransaction = { goToSubTab(2) },
                    onEditTransaction = { tx -> goToSubTab(3, tx) },
                    selectedTransaction = selectedTransaction,
                    onReturnToDetails = { goToSubTab(0) },
                    isPickingApp = isPickingApp,
                    onPickingAppChanged = { isPickingApp = it },
                    modifier = Modifier.weight(1f),
                )
            }
        }
    }
}
