import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Two-column monthly income & expense summary cards.
class WalletCashflowSummary extends StatelessWidget {
  final double monthlyIncome;
  final double monthlyExpense;
  final NumberFormat currencyFormatter;

  const WalletCashflowSummary({
    super.key,
    required this.monthlyIncome,
    required this.monthlyExpense,
    required this.currencyFormatter,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Monthly Income Card (Mint)
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.canvasCardSurface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.canvasBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.neoMint.withValues(alpha: 0.15),
                      ),
                      child: const Icon(Icons.arrow_downward, color: AppColors.neoMint, size: 13),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'MASUK (BLN INI)',
                        style: AppTypography.badgeLabel.copyWith(color: AppColors.textMuted, fontSize: 9),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  currencyFormatter.format(monthlyIncome),
                  style: AppTypography.listAmount.copyWith(color: AppColors.neoMint, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Monthly Expense Card (Coral)
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.canvasCardSurface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.canvasBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.neoCoral.withValues(alpha: 0.15),
                      ),
                      child: const Icon(Icons.arrow_upward, color: AppColors.neoCoral, size: 13),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'KELUAR (BLN INI)',
                        style: AppTypography.badgeLabel.copyWith(color: AppColors.textMuted, fontSize: 9),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  currencyFormatter.format(monthlyExpense),
                  style: AppTypography.listAmount.copyWith(color: AppColors.neoCoral, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
