package com.fibonanci.app.ui.transaction

import androidx.compose.runtime.Composable
import com.fibonanci.app.data.db.TransactionEntry
import com.fibonanci.app.data.db.WalletEntry
import com.fibonanci.app.ui.common.ModalHost

// backward-compatible wrapper for ExpenseHistoryScreen
@Composable
fun AllTransactionsModal(
    allTransactions: List<TransactionEntry>,
    wallets: List<WalletEntry>,
    initialChildSize: Double = 1.0,
    onDismiss: () -> Unit,
) {
    ExpenseHistoryScreen(allTransactions, wallets, initialChildSize, onDismiss)
}

fun showAllTransactionsModal(
    host: ModalHost,
    allTransactions: List<TransactionEntry>,
    wallets: List<WalletEntry>,
    initialChildSize: Double = 1.0,
) {
    showExpenseHistoryScreen(
        host,
        allTransactions = allTransactions,
        wallets = wallets,
        initialChildSize = initialChildSize,
        builder = { dismiss -> AllTransactionsModal(allTransactions, wallets, initialChildSize, dismiss) },
    )
}
