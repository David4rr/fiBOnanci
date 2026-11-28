import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/l10n/locale_notifier.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/common/common_widgets.dart';
import '../../widgets/trend_spline_chart.dart';
import '../../widgets/wallet_cashflow_summary.dart';

class WalletTotalBalanceCard extends StatelessWidget {
  final double totalRealBalance;
  final double monthlyIncome;
  final double monthlyExpense;
  final List<double> incomeSeries;
  final List<double> expenseSeries;
  final List<String> dateLabels;
  final bool showChart;
  final NumberFormat currencyFormatter;

  const WalletTotalBalanceCard({
    super.key,
    required this.totalRealBalance,
    this.monthlyIncome = 0,
    this.monthlyExpense = 0,
    this.incomeSeries = const [],
    this.expenseSeries = const [],
    this.dateLabels = const [],
    this.showChart = false,
    required this.currencyFormatter,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
        decoration: BoxDecoration(
          color: AppColors.canvasCardSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.canvasBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.walletsTotalRealBalance,
                        style: AppTypography.badgeLabel.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 9.5,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      AnimatedCountingText(
                        value: totalRealBalance,
                        formatter: currencyFormatter.format,
                        animateOnMount: false,
                        duration: const Duration(milliseconds: 400),
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.neoChartreuse,
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                WalletCashflowSummary(
                  monthlyIncome: monthlyIncome,
                  monthlyExpense: monthlyExpense,
                  currencyFormatter: currencyFormatter,
                ),
              ],
            ),
            if (showChart) ...[
              const SizedBox(height: 12),
              Divider(color: AppColors.dividerSubtle, height: 1),
              const SizedBox(height: 10),
              TrendSplineChart(
                incomeValues: incomeSeries,
                expenseValues: expenseSeries,
                labels: dateLabels,
                headline: l10n.walletTrendHeadline,
                subtitle: l10n.walletTrendSubtitle,
                height: 74,
                embedded: true,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
