import 'package:flutter/material.dart';

import '../../data/database/app_database.dart';
import '../screens/expense_history_screen.dart';
export '../screens/expense_history_screen.dart';

/// Backward-compatible wrapper for [ExpenseHistoryScreen].
///
/// Uses dedicated full-screen navigation with interactive spring animation
/// and tactile pull-to-dismiss gesture physics.
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
    );
  }
}
