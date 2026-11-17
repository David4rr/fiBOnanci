@file:OptIn(ExperimentalMaterial3ExpressiveApi::class)

package com.fibonanci.app.ui.simple

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.text.TextAutoSize
import androidx.compose.material3.ExperimentalMaterial3ExpressiveApi
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.text.input.TextFieldValue
import com.fibonanci.app.core.format.AppCurrency
import com.fibonanci.app.core.toLocalDateTime
import com.fibonanci.app.data.db.SubscriptionEntry
import com.fibonanci.app.data.db.TransactionEntry
import com.fibonanci.app.data.db.WalletEntry
import com.fibonanci.app.ui.FinanceState
import com.fibonanci.app.ui.LocalFinance
import java.time.format.DateTimeFormatter
import kotlin.math.abs

// big figure under a small caption, the hero of every detail sheet
@Composable
private fun SheetHero(caption: String, amount: String) {
    Column {
        Text(caption, style = MaterialTheme.typography.titleMedium, color = MaterialTheme.colorScheme.onSurfaceVariant)
        Text(
            amount,
            style = MaterialTheme.typography.displaySmallEmphasized.money(),
            maxLines = 1,
            autoSize = TextAutoSize.StepBased(
                minFontSize = MaterialTheme.typography.headlineSmall.fontSize,
                maxFontSize = MaterialTheme.typography.displaySmallEmphasized.fontSize,
            ),
        )
    }
}

@Composable
fun WalletSheet(wallet: WalletEntry, state: FinanceState, onDismiss: () -> Unit, onSaved: (String) -> Unit) {
    val vm = LocalFinance.current
    val haptic = LocalHapticFeedback.current
    val currency = state.profile.currency
    var correction by remember { mutableStateOf(TextFieldValue(AppCurrency.formatIdrForInput(wallet.balance, currency))) }
    var confirmDelete by remember { mutableStateOf(false) }
    val newBalance = AppCurrency.parseInputToIdr(correction.text, currency)
    val changed = abs(newBalance - wallet.balance) >= 0.5

    SimpleSheet(title = wallet.name, onDismiss = onDismiss) { close ->
        SheetHero(walletTypeLabel(wallet.type), money(state, wallet.balance))
        AmountField(
            value = correction,
            onValueChange = { correction = it },
            label = "Koreksi saldo",
            currency = currency,
            supporting = "Samakan dengan saldo asli. Ini tidak membuat transaksi baru.",
        )
        PrimaryAction(text = "Simpan saldo", enabled = changed) {
            haptic.performHapticFeedback(HapticFeedbackType.Confirm)
            close {
                vm.updateWalletBalance(wallet.id, newBalance)
                onSaved("Saldo diperbarui")
            }
        }
        DestructiveAction("Hapus rekening") { confirmDelete = true }

        if (confirmDelete) {
            ConfirmDialog(
                title = "Hapus ${wallet.name}?",
                text = "Rekening ini hilang dari daftar dan tidak dihitung lagi di saldo.",
                confirmLabel = "Hapus",
                destructive = true,
                onConfirm = {
                    confirmDelete = false
                    haptic.performHapticFeedback(HapticFeedbackType.Reject)
                    close {
                        vm.deleteWallet(wallet.id)
                        onSaved("Rekening dihapus")
                    }
                },
                onDismiss = { confirmDelete = false },
            )
        }
    }
}

@Composable
fun BillSheet(sub: SubscriptionEntry, state: FinanceState, onDismiss: () -> Unit, onSaved: (String) -> Unit) {
    val vm = LocalFinance.current
    val haptic = LocalHapticFeedback.current
    var confirmPay by remember { mutableStateOf(false) }
    var confirmDelete by remember { mutableStateOf(false) }
    val total = sub.totalCycles
    val status = when {
        sub.status == "completed" -> "Lunas"
        isPaidThisMonth(sub) -> "Sudah dibayar bulan ini"
        else -> "Belum dibayar bulan ini"
    }
    val rows = buildList {
        add("Nominal" to money(state, sub.cost))
        add("Dibayar dari" to walletName(state, sub.walletId))
        add("Jatuh tempo" to "Tiap tanggal ${sub.dueDay}")
        if (sub.isInstallment && total != null) {
            add("Sisa cicilan" to "${(total - sub.paidCycles).coerceAtLeast(0)} dari $total kali")
        }
        add("Status" to status)
    }

    SimpleSheet(title = sub.title, onDismiss = onDismiss) { close ->
        DetailGroup(rows)
        if (isPayable(sub)) {
            PrimaryAction(text = "Bayar ${money(state, sub.cost)}", enabled = true) { confirmPay = true }
        }
        DestructiveAction("Hapus tagihan") { confirmDelete = true }

        if (confirmPay) {
            PayDialog(
                sub = sub,
                state = state,
                onConfirm = {
                    confirmPay = false
                    haptic.performHapticFeedback(HapticFeedbackType.Confirm)
                    close {
                        vm.markSubscriptionPaid(sub.id)
                        onSaved("${sub.title} dibayar")
                    }
                },
                onDismiss = { confirmPay = false },
            )
        }
        if (confirmDelete) {
            ConfirmDialog(
                title = "Hapus ${sub.title}?",
                text = "Pembayaran yang sudah tercatat untuk tagihan ini ikut dibatalkan dan saldonya dikembalikan.",
                confirmLabel = "Hapus",
                destructive = true,
                onConfirm = {
                    confirmDelete = false
                    haptic.performHapticFeedback(HapticFeedbackType.Reject)
                    close {
                        vm.deleteSubscription(sub.id)
                        onSaved("Tagihan dihapus")
                    }
                },
                onDismiss = { confirmDelete = false },
            )
        }
    }
}

@Composable
fun TransactionSheet(tx: TransactionEntry, state: FinanceState, onDismiss: () -> Unit, onSaved: (String) -> Unit) {
    val vm = LocalFinance.current
    val haptic = LocalHapticFeedback.current
    var confirmDelete by remember { mutableStateOf(false) }
    val (kind, sign) = when (tx.type) {
        "income" -> "Pemasukan" to "+"
        "transfer" -> "Pindah saldo" to ""
        else -> "Pengeluaran" to "−"
    }
    val category = state.categories.firstOrNull { it.id == tx.categoryId }?.name ?: "Tanpa kategori"
    val time = tx.transactionDate.toLocalDateTime()
        .format(DateTimeFormatter.ofPattern("EEEE, d MMMM yyyy · HH.mm", indonesian))
    val rows = buildList {
        add("Jenis" to kind)
        if (tx.type == "transfer") {
            add("Rekening" to "${walletName(state, tx.walletId)} → ${walletName(state, tx.destinationWalletId)}")
        } else {
            add("Rekening" to walletName(state, tx.walletId))
            add("Kategori" to category)
        }
        add("Waktu" to time)
        tx.notes?.takeIf { it.isNotBlank() }?.let { add("Catatan" to it) }
    }

    SimpleSheet(title = "Transaksi", onDismiss = onDismiss) { close ->
        SheetHero(kind, money(state, tx.amount, sign))
        DetailGroup(rows)
        DestructiveAction("Hapus transaksi") { confirmDelete = true }

        if (confirmDelete) {
            ConfirmDialog(
                title = "Hapus transaksi ini?",
                text = "Saldo rekening dikembalikan seperti sebelum transaksi ini dicatat.",
                confirmLabel = "Hapus",
                destructive = true,
                onConfirm = {
                    confirmDelete = false
                    haptic.performHapticFeedback(HapticFeedbackType.Reject)
                    close {
                        vm.deleteTransaction(tx.id)
                        onSaved("Transaksi dihapus")
                    }
                },
                onDismiss = { confirmDelete = false },
            )
        }
    }
}
