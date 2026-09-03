import 'package:flutter/material.dart';

import '../../data/database/app_database.dart';
import '../screens/expense_history_screen.dart';
export '../screens/expense_history_screen.dart';

/// Backward-compatible wrapper for [ExpenseHistoryScreen].
class AllTransactionsModal extends ExpenseHistoryScreen {
  const AllTransactionsModal({
    super.key,
    required super.allTransactions,
    required super.wallets,
  });

  static Future<void> show(
    BuildContext context, {
    required List<TransactionEntry> allTransactions,
    required List<WalletEntry> wallets,
  }) {
    return ExpenseHistoryScreen.show(
      context,
      allTransactions: allTransactions,
      wallets: wallets,
      builder: (_) => AllTransactionsModal(allTransactions: allTransactions, wallets: wallets),
    );
  }
}
