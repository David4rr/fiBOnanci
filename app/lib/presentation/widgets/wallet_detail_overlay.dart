import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/database/app_database.dart';
import '../modals/wallet_detail_modal.dart';

export '../modals/wallet_detail_modal.dart';

/// Backward-compatibility wrapper for [WalletDetailModal].
class WalletDetailOverlay extends StatelessWidget {
  final WalletEntry wallet;
  final List<WalletEntry> allWallets;
  final List<TransactionEntry> transactions;
  final NumberFormat currencyFormatter;
  final List<double> Function(List<TransactionEntry>, {String? walletId, required String type}) computeSeries;
  final List<String> Function() computeDayLabels;
  final VoidCallback onClose;
  final VoidCallback onEditBalance;
  final VoidCallback onAddTransaction;

  const WalletDetailOverlay({
    super.key,
    required this.wallet,
    required this.allWallets,
    required this.transactions,
    required this.currencyFormatter,
    required this.computeSeries,
    required this.computeDayLabels,
    required this.onClose,
    required this.onEditBalance,
    required this.onAddTransaction,
  });

  @override
  Widget build(BuildContext context) {
    return WalletDetailModal(
      walletId: wallet.id,
      currencyFormatter: currencyFormatter,
    );
  }
}
