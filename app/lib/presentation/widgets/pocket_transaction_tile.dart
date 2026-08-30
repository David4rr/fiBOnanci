import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../data/database/app_database.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'transaction_detail_modal.dart';

class PocketTransactionTile extends StatelessWidget {
  final TransactionEntry transaction;
  final List<WalletEntry> wallets;
  final NumberFormat currencyFormatter;

  const PocketTransactionTile({
    super.key,
    required this.transaction,
    required this.wallets,
    required this.currencyFormatter,
  });

  @override
  Widget build(BuildContext context) {
    final n = (transaction.notes ?? '').toLowerCase();
    final isDeposit = n.contains('setoran') || transaction.type == 'transfer';
    final themeColor = isDeposit ? AppColors.neoMint : AppColors.neoCoral;
    final sign = isDeposit ? '+' : '-';

    final wallet = wallets.where((w) => w.id == transaction.walletId).firstOrNull;
    final walletName = wallet?.name ?? 'Rekening';
    final dateStr = DateFormat('d MMM, HH:mm', 'id_ID').format(transaction.transactionDate.toLocal());
    final subtitleText = isDeposit ? 'Dari $walletName • $dateStr' : 'Ke $walletName • $dateStr';

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => TransactionDetailModal.show(context, transaction: transaction),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.canvasInputSearch,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.canvasBorder, width: 0.8),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: themeColor.withValues(alpha: 0.14),
              ),
              child: Icon(
                isDeposit ? Icons.south_west_rounded : Icons.north_east_rounded,
                color: themeColor,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.notes ?? (isDeposit ? 'Setoran Kantong' : 'Penarikan Kantong'),
                    style: AppTypography.listTitle.copyWith(fontSize: 13.5),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitleText,
                    style: AppTypography.listSubtitle.copyWith(fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$sign${currencyFormatter.format(transaction.amount)}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: themeColor,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
