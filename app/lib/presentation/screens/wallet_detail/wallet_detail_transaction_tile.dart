import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../data/database/app_database.dart';
import '../../theme/app_colors.dart';
import '../../widgets/transaction_detail_modal.dart';
import 'tactile_hero_card.dart';

class WalletDetailTransactionTile extends StatelessWidget {
  final TransactionEntry tx;
  final String walletId;
  final NumberFormat currencyFormatter;

  const WalletDetailTransactionTile({
    super.key,
    required this.tx,
    required this.walletId,
    required this.currencyFormatter,
  });

  @override
  Widget build(BuildContext context) {
    final isExpense = tx.type == 'expense' || tx.walletId == walletId && tx.type != 'income';
    final prefix = isExpense ? '- ' : '+ ';
    final typeColor = isExpense ? AppColors.textWhite : AppColors.neoMint;

    final iconData = tx.type == 'income'
        ? Icons.south_west_rounded
        : (tx.type == 'transfer' ? Icons.swap_horiz_rounded : Icons.north_east_rounded);

    final iconBgColor = tx.type == 'income'
        ? AppColors.neoMint.withValues(alpha: 0.15)
        : (tx.type == 'transfer' ? AppColors.neoPurple.withValues(alpha: 0.15) : AppColors.canvasInputSearch);

    final iconColor = tx.type == 'income'
        ? AppColors.neoMint
        : (tx.type == 'transfer' ? AppColors.neoPurple : AppColors.textWhite);

    final dateFormatted = DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(tx.transactionDate);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4.5),
      child: PressableScale(
        onTap: () => TransactionDetailModal.show(context, transaction: tx),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.canvasCardSurface,
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
                  color: iconBgColor,
                  border: Border.all(color: AppColors.canvasBorder, width: 0.8),
                ),
                child: Icon(iconData, color: iconColor, size: 17),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (tx.notes != null && tx.notes!.isNotEmpty)
                          ? tx.notes!
                          : (tx.type == 'income' ? 'Pemasukan' : (tx.type == 'transfer' ? 'Transfer Saldo' : 'Pengeluaran')),
                      style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textWhite),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2.5),
                    Text(dateFormatted, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textMuted)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '$prefix${currencyFormatter.format(tx.amount)}',
                style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.w800, color: typeColor, fontFeatures: const [FontFeature.tabularFigures()]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
