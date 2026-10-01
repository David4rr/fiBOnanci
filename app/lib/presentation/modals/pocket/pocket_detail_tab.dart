import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/database/app_database.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/common/common_widgets.dart';
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
  final ValueChanged<TransactionEntry>? onEditTransaction;

  const PocketDetailTab({
    super.key,
    required this.pocket,
    required this.pocketColor,
    required this.transactions,
    required this.wallets,
    required this.currencyFormatter,
    required this.onDeposit,
    required this.onWithdraw,
    this.onEditTransaction,
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
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.04),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                      ),
                      child: const Center(
                        child: Icon(Icons.receipt_long_outlined, size: 20, color: AppColors.textSubtle),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text('Belum ada riwayat mutasi', style: AppTypography.listSubtitle, textAlign: TextAlign.center),
                  ],
                ),
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
                onTap: onEditTransaction != null
                    ? () => onEditTransaction!(transactions[index])
                    : null,
              ),
            ),
          const SizedBox(height: 24),
          SlideToDeleteButton(
            label: 'Hapus Kantong',
            onSlideComplete: () => showPocketDeleteDialog(context, pocket),
          ),
        ],
      ),
    );
  }
}
