import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/database/app_database.dart';
import '../../../domain/services/cashflow_analytics_service.dart';
import '../../modals/edit_balance_modal.dart';
import '../../theme/app_colors.dart';
import '../../widgets/transaction_modal.dart';
import '../../widgets/trend_spline_chart.dart';
import 'tactile_hero_card.dart';

class WalletDetailActionsAndChart extends StatelessWidget {
  final WalletEntry wallet;
  final Color cardColor;
  final List<TransactionEntry> transactions;

  const WalletDetailActionsAndChart({
    super.key,
    required this.wallet,
    required this.cardColor,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: PressableScale(
                  onTap: () => EditBalanceModal.show(context, wallet),
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.canvasCardSurface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.canvasBorder, width: 0.8),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.tune_rounded, size: 15, color: AppColors.textWhite),
                          const SizedBox(width: 8),
                          Text('Ubah Saldo', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textWhite)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PressableScale(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => TransactionModal(initialWalletId: wallet.id),
                    );
                  },
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.neoMint,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(color: AppColors.neoMint.withValues(alpha: 0.28), blurRadius: 16, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Catat Transaksi', style: GoogleFonts.plusJakartaSans(color: AppColors.textDarkPrimary, fontWeight: FontWeight.w800, fontSize: 13)),
                              const SizedBox(width: 8),
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.textDarkPrimary.withValues(alpha: 0.15)),
                                child: const Icon(Icons.add_rounded, size: 14, color: AppColors.textDarkPrimary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TrendSplineChart(
            incomeValues: CashflowAnalyticsService.compute30DaySeries(transactions, type: 'income', walletId: wallet.id),
            expenseValues: CashflowAnalyticsService.compute30DaySeries(transactions, type: 'expense', walletId: wallet.id),
            labels: CashflowAnalyticsService.compute30DayLabels(),
            lineColor: cardColor,
            headline: 'Tren Mutasi ${wallet.name}',
            subtitle: '30 Hari Terakhir',
            height: 100,
          ),
        ),
      ],
    );
  }
}
