import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/database/app_database.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../expense_category_helpers.dart';

class ActivityCalendarTxTile extends StatelessWidget {
  final TransactionEntry tx;
  final NumberFormat currencyFormatter;
  final List<WalletEntry> wallets;
  final List<CategoryEntry>? categories;
  final List<PocketEntry>? pockets;
  final ValueChanged<TransactionEntry>? onTap;

  const ActivityCalendarTxTile({
    super.key,
    required this.tx,
    required this.currencyFormatter,
    required this.wallets,
    this.categories,
    this.pockets,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final visuals = TransactionVisualResolver.resolve(
      tx: tx,
      categories: categories,
      pockets: pockets,
    );
    final isIncome = tx.type == 'income';
    final wallet = wallets.where((w) => w.id == tx.walletId).firstOrNull;

    return InkWell(
      onTap: () => onTap?.call(tx),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.canvasCardSurface.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: visuals.cardColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(visuals.iconData, size: 15, color: visuals.cardColor),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.notes?.isNotEmpty == true ? tx.notes! : visuals.title,
                    style: TextStyle(color: AppColors.textWhite, fontSize: 12, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${visuals.categoryLabel} • ${wallet?.name ?? "Rekening"}',
                    style: TextStyle(color: AppColors.textSubtle, fontSize: 10.5, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Text(
              '${isIncome ? '+' : '-'}${currencyFormatter.format(tx.amount)}',
              style: AppTypography.tabularFigures.copyWith(
                color: isIncome ? AppColors.textIncome : AppColors.textWhite,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
