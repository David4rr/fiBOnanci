@file:OptIn(ExperimentalMaterial3Api::class, ExperimentalMaterial3ExpressiveApi::class)

package com.fibonanci.app.ui.simple

import androidx.activity.compose.BackHandler
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.rounded.ReceiptLong
import androidx.compose.material.icons.rounded.AccountBalanceWallet
import androidx.compose.material.icons.rounded.Add
import androidx.compose.material.icons.rounded.ArrowDownward
import androidx.compose.material.icons.rounded.ArrowUpward
import androidx.compose.material.icons.rounded.Close
import androidx.compose.material.icons.rounded.Settings
import androidx.compose.material.icons.rounded.SwapHoriz
import androidx.compose.material.icons.rounded.Visibility
import androidx.compose.material.icons.rounded.VisibilityOff
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.ExperimentalMaterial3ExpressiveApi
import androidx.compose.material3.FloatingActionButtonMenu
import androidx.compose.material3.FloatingActionButtonMenuItem
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.IconButtonDefaults
import androidx.compose.material3.IconToggleButton
import androidx.compose.material3.LargeFlexibleTopAppBar
import androidx.compose.material3.LoadingIndicator
import androidx.compose.material3.Scaffold
import androidx.compose.material3.SnackbarHost
import androidx.compose.material3.SnackbarHostState
import androidx.compose.material3.Text
import androidx.compose.material3.ToggleFloatingActionButton
import androidx.compose.material3.ToggleFloatingActionButtonDefaults
import androidx.compose.material3.ToggleFloatingActionButtonDefaults.animateIcon
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.derivedStateOf
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.input.nestedscroll.nestedScroll
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.semantics.stateDescription
import androidx.compose.ui.semantics.traversalIndex
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.fibonanci.app.ui.FinanceStatus
import com.fibonanci.app.ui.LocalFinance
import java.time.LocalDate
import java.time.format.DateTimeFormatter
import kotlinx.coroutines.launch

// which bottom sheet is open over the home list
sealed interface SheetRoute {
    data class Entry(val type: EntryType) : SheetRoute
    data object NewBill : SheetRoute
    data object NewWallet : SheetRoute
    data object Settings : SheetRoute
    data class Wallet(val id: String) : SheetRoute
    data class Bill(val id: String) : SheetRoute
    data class Transaction(val id: String) : SheetRoute
}

enum class EntryType(val label: String, val apiType: String) {
    Expense("Pengeluaran", "expense"),
    Income("Pemasukan", "income"),
    Transfer("Pindah", "transfer"),
}

// the iblameraihan look: the whole everyday flow on one screen
@Composable
fun SimpleShell() {
    val vm = LocalFinance.current
    val state by vm.state.collectAsStateWithLifecycle()
    val snackbar = remember { SnackbarHostState() }
    val scope = rememberCoroutineScope()
    val haptic = LocalHapticFeedback.current
    val scrollBehavior = TopAppBarDefaults.exitUntilCollapsedScrollBehavior()
    var route by remember { mutableStateOf<SheetRoute?>(null) }
    var fabExpanded by rememberSaveable { mutableStateOf(false) }
    var payId by rememberSaveable { mutableStateOf<String?>(null) }
    val notify: (String) -> Unit = { message -> scope.launch { snackbar.showSnackbar(message) } }

    LaunchedEffect(state.errorMessage) {
        val message = state.errorMessage ?: return@LaunchedEffect
        // shown from the screen scope: clearing the error restarts this effect and would cancel it
        scope.launch { snackbar.showSnackbar(message, withDismissAction = true) }
        vm.clearError()
    }
    BackHandler(enabled = fabExpanded) { fabExpanded = false }

    val firstName = state.profile.fullName.trim().substringBefore(' ').ifBlank { state.profile.username }
    val today = remember { LocalDate.now().format(DateTimeFormatter.ofPattern("EEEE, d MMMM", indonesian)) }

    Scaffold(
        modifier = Modifier.fillMaxSize().nestedScroll(scrollBehavior.nestedScrollConnection),
        topBar = {
            LargeFlexibleTopAppBar(
                title = {
                    Text(if (firstName.isBlank()) "Halo" else "Halo, $firstName", maxLines = 1, overflow = TextOverflow.Ellipsis)
                },
                subtitle = { Text(today) },
                actions = {
                    IconToggleButton(
                        checked = state.isBalanceHidden,
                        onCheckedChange = { hidden ->
                            haptic.performHapticFeedback(if (hidden) HapticFeedbackType.ToggleOn else HapticFeedbackType.ToggleOff)
                            vm.toggleBalanceVisibility(hidden)
                        },
                        shapes = IconButtonDefaults.toggleableShapes(),
                        colors = IconButtonDefaults.iconToggleButtonColors(),
                    ) {
                        Icon(
                            if (state.isBalanceHidden) Icons.Rounded.VisibilityOff else Icons.Rounded.Visibility,
                            contentDescription = if (state.isBalanceHidden) "Tampilkan saldo" else "Sembunyikan saldo",
                        )
                    }
                    IconButton(onClick = { route = SheetRoute.Settings }, shapes = IconButtonDefaults.shapes()) {
                        Icon(Icons.Rounded.Settings, contentDescription = "Pengaturan")
                    }
                },
                scrollBehavior = scrollBehavior,
            )
        },
        snackbarHost = { SnackbarHost(snackbar) },
        floatingActionButton = {
            EntryFabMenu(
                expanded = fabExpanded,
                onExpandedChange = { fabExpanded = it },
                onPick = { route = it },
                // the menu pads itself 16dp at the side and bottom; the scaffold already adds that margin
                modifier = Modifier.offset(x = 16.dp, y = 16.dp),
            )
        },
    ) { padding ->
        val loading = state.status == FinanceStatus.Initial || state.status == FinanceStatus.Loading
        if (loading && state.wallets.isEmpty()) {
            Box(Modifier.fillMaxSize().padding(padding), contentAlignment = Alignment.Center) { LoadingIndicator() }
        } else {
            HomeList(state = state, padding = padding, onOpen = { route = it }, onPay = { payId = it.id })
        }
    }

    val close = { route = null }
    when (val open = route) {
        null -> Unit
        is SheetRoute.Entry -> EntrySheet(open.type, state, close, notify)
        SheetRoute.NewBill -> NewBillSheet(state, close, notify)
        SheetRoute.NewWallet -> NewWalletSheet(state, close, notify)
        SheetRoute.Settings -> SettingsSheet(state, close, notify)
        is SheetRoute.Wallet -> {
            val wallet = state.wallets.firstOrNull { it.id == open.id }
            if (wallet == null) LaunchedEffect(open) { route = null } else WalletSheet(wallet, state, close, notify)
        }
        is SheetRoute.Bill -> {
            val sub = state.subscriptions.firstOrNull { it.id == open.id }
            if (sub == null) LaunchedEffect(open) { route = null } else BillSheet(sub, state, close, notify)
        }
        is SheetRoute.Transaction -> {
            val tx = state.transactions.firstOrNull { it.id == open.id }
            if (tx == null) LaunchedEffect(open) { route = null } else TransactionSheet(tx, state, close, notify)
        }
    }

    val paying = state.subscriptions.firstOrNull { it.id == payId }
    if (paying != null) {
        PayDialog(
            sub = paying,
            state = state,
            onConfirm = {
                haptic.performHapticFeedback(HapticFeedbackType.Confirm)
                vm.markSubscriptionPaid(paying.id)
                payId = null
                notify("${paying.title} dibayar")
            },
            onDismiss = { payId = null },
        )
    }
}

@Composable
private fun EntryFabMenu(
    expanded: Boolean,
    onExpandedChange: (Boolean) -> Unit,
    onPick: (SheetRoute) -> Unit,
    modifier: Modifier = Modifier,
) {
    val haptic = LocalHapticFeedback.current
    val items = listOf(
        Triple(Icons.Rounded.ArrowUpward, "Pengeluaran", SheetRoute.Entry(EntryType.Expense)),
        Triple(Icons.Rounded.ArrowDownward, "Pemasukan", SheetRoute.Entry(EntryType.Income)),
        Triple(Icons.Rounded.SwapHoriz, "Pindah saldo", SheetRoute.Entry(EntryType.Transfer)),
        Triple(Icons.AutoMirrored.Rounded.ReceiptLong, "Tagihan baru", SheetRoute.NewBill),
        Triple(Icons.Rounded.AccountBalanceWallet, "Rekening baru", SheetRoute.NewWallet),
    )
    FloatingActionButtonMenu(
        expanded = expanded,
        modifier = modifier,
        button = {
            ToggleFloatingActionButton(
                checked = expanded,
                onCheckedChange = {
                    haptic.performHapticFeedback(HapticFeedbackType.ContextClick)
                    onExpandedChange(it)
                },
                containerSize = ToggleFloatingActionButtonDefaults.containerSizeMedium(),
                containerCornerRadius = ToggleFloatingActionButtonDefaults.containerCornerRadiusMedium(),
                modifier = Modifier.semantics {
                    traversalIndex = -1f
                    stateDescription = if (expanded) "Terbuka" else "Tertutup"
                    contentDescription = "Catat baru"
                },
            ) {
                val icon by remember { derivedStateOf { if (checkedProgress > 0.5f) Icons.Rounded.Close else Icons.Rounded.Add } }
                Icon(
                    icon,
                    contentDescription = null,
                    modifier = Modifier.animateIcon(
                        checkedProgress = { checkedProgress },
                        size = ToggleFloatingActionButtonDefaults.iconSizeMedium(),
                    ),
                )
            }
        },
    ) {
        items.forEach { (icon, label, target) ->
            FloatingActionButtonMenuItem(
                onClick = {
                    onExpandedChange(false)
                    onPick(target)
                },
                icon = { Icon(icon, contentDescription = null) },
                text = { Text(label) },
            )
        }
    }
}
