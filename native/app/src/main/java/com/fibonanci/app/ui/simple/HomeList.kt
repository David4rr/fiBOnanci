@file:OptIn(ExperimentalMaterial3ExpressiveApi::class)

package com.fibonanci.app.ui.simple

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.calculateEndPadding
import androidx.compose.foundation.layout.calculateStartPadding
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.rounded.ReceiptLong
import androidx.compose.material.icons.rounded.AccountBalanceWallet
import androidx.compose.material.icons.rounded.Inbox
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.ExperimentalMaterial3ExpressiveApi
import androidx.compose.material3.ListItemDefaults
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalLayoutDirection
import androidx.compose.ui.unit.dp
import com.fibonanci.app.core.toLocalDate
import com.fibonanci.app.data.db.SubscriptionEntry
import com.fibonanci.app.data.db.TransactionEntry
import com.fibonanci.app.ui.FinanceState

private const val TRANSACTION_PREVIEW = 30

// the single scrolling body: hero, wallets, bills, then transactions grouped by day
@Composable
fun HomeList(
    state: FinanceState,
    padding: PaddingValues,
    onOpen: (SheetRoute) -> Unit,
    onPay: (SubscriptionEntry) -> Unit,
    hiddenTransactionIds: Set<String>,
    onDeleteTransaction: (TransactionEntry) -> Unit,
) {
    var showAll by rememberSaveable { mutableStateOf(false) }
    // rows swiped away wait here for the undo window before the delete is committed
    val transactions = remember(state.transactions, hiddenTransactionIds) {
        state.transactions.filter { it.id !in hiddenTransactionIds }
    }
    val days = remember(transactions, showAll) {
        val shown = if (showAll) transactions else transactions.take(TRANSACTION_PREVIEW)
        shown.groupBy { it.transactionDate.toLocalDate() }.toList()
    }
    val direction = LocalLayoutDirection.current

    LazyColumn(
        modifier = Modifier.fillMaxSize(),
        contentPadding = PaddingValues(
            start = padding.calculateStartPadding(direction) + 16.dp,
            end = padding.calculateEndPadding(direction) + 16.dp,
            top = padding.calculateTopPadding() + 8.dp,
            // leaves room for the large fab so the last row is never covered
            bottom = padding.calculateBottomPadding() + 128.dp,
        ),
        // rows of one group sit 2dp apart; headers carry their own top spacing
        verticalArrangement = Arrangement.spacedBy(ListItemDefaults.SegmentedGap),
    ) {
        item(key = "hero") { HeroStack(state, Modifier.animateItem()) }

        item(key = "wallets-header") {
            SectionHeader("Rekening", Modifier.animateItem(), action = "Tambah") { onOpen(SheetRoute.NewWallet) }
        }
        if (state.wallets.isEmpty()) {
            item(key = "wallets-empty") {
                EmptyGroup(
                    Icons.Rounded.AccountBalanceWallet,
                    "Belum ada rekening",
                    "Tambah rekening untuk mulai mencatat",
                    Modifier.animateItem(),
                )
            }
        } else {
            itemsIndexed(state.wallets, key = { _, w -> "w-${w.id}" }) { index, wallet ->
                WalletRow(wallet, state, index, state.wallets.size, { onOpen(SheetRoute.Wallet(wallet.id)) }, Modifier.animateItem())
            }
        }

        item(key = "bills-header") {
            SectionHeader("Tagihan", Modifier.animateItem(), action = "Tambah") { onOpen(SheetRoute.NewBill) }
        }
        if (state.subscriptions.isEmpty()) {
            item(key = "bills-empty") {
                EmptyGroup(
                    Icons.AutoMirrored.Rounded.ReceiptLong,
                    "Belum ada tagihan",
                    "Catat tagihan rutin biar nggak lupa bayar",
                    Modifier.animateItem(),
                )
            }
        } else {
            itemsIndexed(state.subscriptions, key = { _, s -> "b-${s.id}" }) { index, sub ->
                BillRow(
                    sub = sub,
                    state = state,
                    index = index,
                    count = state.subscriptions.size,
                    onClick = { onOpen(SheetRoute.Bill(sub.id)) },
                    onPay = { onPay(sub) },
                    modifier = Modifier.animateItem(),
                )
            }
        }

        item(key = "tx-header") { SectionHeader("Transaksi", Modifier.animateItem()) }
        if (transactions.isEmpty()) {
            item(key = "tx-empty") {
                EmptyGroup(Icons.Rounded.Inbox, "Belum ada transaksi", "Tekan tombol + untuk mulai", Modifier.animateItem())
            }
        } else {
            days.forEach { (date, list) ->
                stickyHeader(key = "d-$date") { _ -> DayHeader(dayLabel(list.first().transactionDate)) }
                itemsIndexed(list, key = { _, t -> "t-${t.id}" }) { index, tx ->
                    SwipeToDeleteRow(
                        shape = groupShapes(index, list.size).shape,
                        deleteLabel = "Hapus transaksi",
                        onDelete = { onDeleteTransaction(tx) },
                        modifier = Modifier.animateItem(),
                    ) {
                        TransactionRow(tx, state, index, list.size, { onOpen(SheetRoute.Transaction(tx.id)) })
                    }
                }
            }
            if (!showAll && transactions.size > TRANSACTION_PREVIEW) {
                item(key = "tx-more") {
                    OutlinedButton(
                        onClick = { showAll = true },
                        shapes = ButtonDefaults.shapes(),
                        modifier = Modifier.fillMaxWidth().padding(top = 12.dp).animateItem(),
                    ) {
                        Text("Lihat semua (${transactions.size})")
                    }
                }
            }
        }
    }
}
