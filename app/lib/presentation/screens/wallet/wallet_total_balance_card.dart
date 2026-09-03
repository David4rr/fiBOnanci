import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class WalletTotalBalanceCard extends StatelessWidget {
  final double totalRealBalance;
  final NumberFormat currencyFormatter;

  const WalletTotalBalanceCard({
    super.key,
    required this.totalRealBalance,
    required this.currencyFormatter,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.canvasCardSurface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.canvasBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TOTAL SALDO RIIL', style: AppTypography.badgeLabel.copyWith(color: AppColors.textMuted)),
                  const SizedBox(height: 6),
                  Text(
                    currencyFormatter.format(totalRealBalance),
                    style: AppTypography.heroGreeting.copyWith(color: AppColors.neoChartreuse, fontSize: 24),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.neoChartreuse.withValues(alpha: 0.15),
              ),
              child: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.neoChartreuse, size: 26),
            ),
          ],
        ),
      ),
    );
  }
}
