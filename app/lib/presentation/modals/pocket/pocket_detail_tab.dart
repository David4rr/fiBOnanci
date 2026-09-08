import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/database/app_database.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/pocket_transaction_tile.dart';
import 'pocket_detail_views.dart';

class PocketDetailTab extends StatelessWidget {
  final PocketEntry pocket;
  final Color pocketColor;
  final List<TransactionEntry> transactions;
  final List<WalletEntry> wallets;
  final NumberFormat currencyFormatter;
  final VoidCallback onDeposit;
  final VoidCallback onWithdraw;

  const PocketDetailTab({
    super.key,
    required this.pocket,
    required this.pocketColor,
    required this.transactions,
    required this.wallets,
    required this.currencyFormatter,
    required this.onDeposit,
    required this.onWithdraw,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PocketDetailHeader(
            pocket: pocket,
            pocketColor: pocketColor,
            currencyFormatter: currencyFormatter,
          ),
          const SizedBox(height: 20),
          PocketDetailActions(
            pocket: pocket,
            pocketColor: pocketColor,
            onDeposit: onDeposit,
            onWithdraw: onWithdraw,
          ),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text('Riwayat Mutasi', style: AppTypography.sectionTitle.copyWith(fontSize: 15.5)),
              ),
              if (transactions.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: AppColors.canvasInputSearch, borderRadius: BorderRadius.circular(8)),
                  child: Text('${transactions.length} mutasi', style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w600)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (transactions.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.canvasInputSearch,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.canvasBorder),
              ),
              child: Column(
                children: [
                  const Icon(Icons.receipt_long_outlined, size: 32, color: AppColors.textSubtle),
                  const SizedBox(height: 8),
                  Text('Belum ada riwayat mutasi', style: AppTypography.listSubtitle),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) => PocketTransactionTile(
                transaction: transactions[index],
                wallets: wallets,
                currencyFormatter: currencyFormatter,
              ),
            ),
          const SizedBox(height: 24),
          Center(
            child: TextButton.icon(
              onPressed: () => showPocketDeleteDialog(context, pocket),
              icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFEF4444)),
              label: const Text('Hapus Kantong', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w700, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }
}
