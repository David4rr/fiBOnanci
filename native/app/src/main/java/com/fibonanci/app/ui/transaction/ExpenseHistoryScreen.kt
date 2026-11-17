package com.fibonanci.app.ui.transaction

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.key
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalFocusManager
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.fibonanci.app.core.format.AppCurrency
import com.fibonanci.app.data.db.TransactionEntry
import com.fibonanci.app.data.db.WalletEntry
import com.fibonanci.app.domain.CashflowAnalyticsService
import com.fibonanci.app.ui.LocalFinance
import com.fibonanci.app.ui.common.ExpandableModalSheet
import com.fibonanci.app.ui.common.ModalHost
import com.fibonanci.app.ui.common.ModalKind
import com.fibonanci.app.ui.common.SmoothPageView
import com.fibonanci.app.ui.common.rememberExpandableModalSheetState
import kotlinx.coroutines.launch

// dart pushes a transparent page route; here it is a full-window expandable sheet on the modal host
fun showExpenseHistoryScreen(
    host: ModalHost,
    allTransactions: List<TransactionEntry>,
    wallets: List<WalletEntry>,
    initialChildSize: Double = 1.0,
    builder: (@Composable (onDismiss: () -> Unit) -> Unit)? = null,
) {
    host.show(ModalKind.Sheet) { dismiss ->
        if (builder != null) builder(dismiss)
        else ExpenseHistoryScreen(allTransactions, wallets, initialChildSize, onDismiss = dismiss)
    }
}

@Composable
fun ExpenseHistoryScreen(
    allTransactions: List<TransactionEntry>,
    wallets: List<WalletEntry>,
    initialChildSize: Double = 1.0,
    onDismiss: () -> Unit,
) {
    val vm = LocalFinance.current
    val blocState by vm.state.collectAsStateWithLifecycle()
    val focusManager = LocalFocusManager.current
    val scope = rememberCoroutineScope()
    val sheet = rememberExpandableModalSheetState()
    val dayScrollController = rememberLazyListState()
    val pageController = rememberPagerState(initialPage = 0) { 2 }

    var searchText by remember { mutableStateOf("") }
    var searchQuery by remember { mutableStateOf("") }
    var typeFilter by remember { mutableStateOf("all") }
    var walletFilter by remember { mutableStateOf<String?>(null) }
    var selectedDayIndex by remember { mutableStateOf<Int?>(null) }
    var currentTab by remember { mutableIntStateOf(0) }
    var selectedTransaction by remember { mutableStateOf<TransactionEntry?>(null) }

    fun goToEditTx(tx: TransactionEntry) {
        focusManager.clearFocus()
        selectedTransaction = tx
        currentTab = 1
        scope.launch { SmoothPageView.animateTo(pageController, 1) }
    }

    fun goToHistory() {
        focusManager.clearFocus()
        currentTab = 0
        scope.launch { SmoothPageView.animateTo(pageController, 0) }
    }

    val currency = blocState.profile.currency
    val liveTxs = blocState.transactions.ifEmpty { allTransactions }
    val liveWallets = blocState.wallets.ifEmpty { wallets }
    val filtered = CashflowAnalyticsService.filterTransactions(
        transactions = liveTxs, wallets = liveWallets, query = searchQuery, typeFilter = typeFilter, walletFilter = walletFilter,
    )
    val dayGroups = DailyDateHelper.groupByDay(filtered)
    val sortedDays = DailyDateHelper.getAllDateKeys(dayGroups)
    val sel = selectedDayIndex
    val safeIndex = if (sel != null && sel >= 0 && sel < sortedDays.size) sel else if (sortedDays.isNotEmpty()) sortedDays.size - 1 else 0
    val currentDayKey = if (sortedDays.isNotEmpty()) sortedDays[safeIndex] else ""
    val currentDayTxs = if (sortedDays.isNotEmpty()) dayGroups[currentDayKey] ?: emptyList() else emptyList()
    val isIncome = typeFilter == "income"
    val totalFiltered = filtered
        .filter { if (isIncome) it.type == "income" else it.type == "expense" || it.type == "transfer" }
        .sumOf { it.amount }

    LaunchedEffect(Unit) {
        if (sortedDays.isNotEmpty()) dayScrollController.scrollToItem(sortedDays.size - 1)
    }

    ExpandableModalSheet(
        onDismiss = onDismiss,
        initialChildSize = initialChildSize,
        minChildSize = 0.25,
        maxChildSize = 1.0,
        snapSizes = listOf(initialChildSize, 1.0),
        state = sheet,
    ) { _ ->
        Column(Modifier.fillMaxSize()) {
            val editTx = selectedTransaction
            ExpenseHistoryAppBar(
                totalFiltered = totalFiltered,
                currencyFormatter = { AppCurrency.format(it, currency) },
                isEditing = currentTab != 0,
                onReturnToHistory = { goToHistory() },
                onDismiss = onDismiss,
                customTitle = if (currentTab != 0) "Edit Transaksi" else null,
                customSubtitle = if (currentTab != 0) {
                    if (!editTx?.notes.isNullOrEmpty()) editTx!!.notes!! else "Ubah rincian mutasi transaksi"
                } else null,
                onDragStart = { sheet.handleHeaderDragStart() },
                onDragUpdate = { sheet.handleHeaderDragUpdate(it) },
                onDragEnd = { sheet.handleHeaderDragEnd(it) },
            )
            Box(Modifier.weight(1f)) {
                SmoothPageView(
                    controller = pageController,
                    children = listOf(
                        {
                            Column(Modifier.fillMaxSize()) {
                                ExpenseHistorySearchBar(
                                    searchQuery = searchText,
                                    typeFilter = typeFilter,
                                    walletFilter = walletFilter,
                                    wallets = liveWallets,
                                    onSearchChanged = { q ->
                                        searchText = q
                                        searchQuery = q.trim().lowercase()
                                    },
                                    onClearSearch = {
                                        searchText = ""
                                        searchQuery = ""
                                    },
                                    onFilterApplied = { t, w ->
                                        typeFilter = t
                                        walletFilter = w
                                        selectedDayIndex = null
                                    },
                                    onClearTypeFilter = { typeFilter = "all" },
                                    onClearWalletFilter = { walletFilter = null },
                                )
                                Spacer(Modifier.height(6.dp))
                                DailyCalendarBar(
                                    scrollController = dayScrollController,
                                    sortedDays = sortedDays,
                                    selectedIndex = safeIndex,
                                    dayGroups = dayGroups,
                                    onDaySelected = { idx -> selectedDayIndex = idx },
                                )
                                Spacer(Modifier.height(10.dp))
                                ExpenseHistoryDeckView(
                                    isFiltering = searchQuery.isNotEmpty() || typeFilter != "all" || walletFilter != null,
                                    searchQuery = searchQuery,
                                    filtered = filtered,
                                    sortedDays = sortedDays,
                                    currentDayKey = currentDayKey,
                                    currentDayTxs = currentDayTxs,
                                    allTransactions = liveTxs,
                                    wallets = liveWallets,
                                    modifier = Modifier.weight(1f),
                                    categories = blocState.categories,
                                    pockets = blocState.pockets,
                                    onManageTransaction = { goToEditTx(it) },
                                    onDownwardDrag = { sheet.handleHeaderDragUpdate(it) },
                                    onDownwardDragEnd = { sheet.handleHeaderDragEnd(it) },
                                )
                            }
                        },
                        {
                            val tx = selectedTransaction
                            if (tx != null) {
                                key(tx.id) {
                                    TransactionDetailModal(
                                        transaction = tx,
                                        isInline = true,
                                        onClose = { goToHistory() },
                                        onSaved = { goToHistory() },
                                        onDeleted = { goToHistory() },
                                    )
                                }
                            }
                        },
                    ),
                )
            }
        }
    }
}
