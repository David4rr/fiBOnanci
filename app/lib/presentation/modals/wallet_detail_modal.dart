import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/database/app_database.dart';
import '../screens/wallet_detail_screen.dart';

export '../screens/wallet_detail_screen.dart';

/// Compatibility wrapper for [WalletDetailScreen].
class WalletDetailModal extends StatelessWidget {
  final String walletId;
  final NumberFormat currencyFormatter;

  const WalletDetailModal({
    super.key,
    required this.walletId,
    required this.currencyFormatter,
  });

  /// Displays the account details screen for a given wallet.
  static Future<void> show(
    BuildContext context, {
    required WalletEntry wallet,
  }) {
    return WalletDetailScreen.push(context, wallet: wallet);
  }

  @override
  Widget build(BuildContext context) {
    return WalletDetailScreen(
      walletId: walletId,
      currencyFormatter: currencyFormatter,
    );
  }
}
