import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/finance/finance_bloc.dart';
import '../../bloc/finance/finance_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'health/financial_health_pillar_card.dart';
import 'health/financial_health_score_card.dart';

export 'health/financial_health_pillar_card.dart';
export 'health/financial_health_score_card.dart';

class FinancialHealthModal {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.canvasBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (ctx) {
        return BlocBuilder<FinanceBloc, FinanceState>(
          builder: (context, state) {
            final report = state.healthReport;

            return DraggableScrollableSheet(
              initialChildSize: 0.9,
              minChildSize: 0.6,
              maxChildSize: 0.96,
              expand: false,
              builder: (sheetContext, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: AppColors.canvasBg,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                    children: [
                      Center(
                        child: Container(
                          width: 44,
                          height: 4,
                          decoration: BoxDecoration(color: AppColors.textSubtle, borderRadius: BorderRadius.circular(2)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Audit Kesehatan Finansial', style: AppTypography.heroGreeting.copyWith(fontSize: 22)),
                              const SizedBox(height: 2),
                              Text('Berdasarkan rasio arus kas, aset, & tagihan riil', style: AppTypography.listSubtitle),
                            ],
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            icon: const Icon(Icons.close, color: AppColors.textMuted, size: 18),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      FinancialHealthScoreCard(report: report),
                      const SizedBox(height: 28),
                      Text('4 Pilar Rasio Keuangan', style: AppTypography.sectionTitle),
                      const SizedBox(height: 14),
                      FinancialHealthPillarCard(metric: report.emergencyRunway, icon: Icons.shield_outlined, accentColor: AppColors.neoMint),
                      const SizedBox(height: 12),
                      FinancialHealthPillarCard(metric: report.fixedCommitment, icon: Icons.receipt_long_outlined, accentColor: AppColors.neoCoral),
                      const SizedBox(height: 12),
                      FinancialHealthPillarCard(metric: report.savingsMargin, icon: Icons.savings_outlined, accentColor: AppColors.neoPurple),
                      const SizedBox(height: 12),
                      FinancialHealthPillarCard(metric: report.spendPacing, icon: Icons.speed_rounded, accentColor: AppColors.neoCyan),
                      const SizedBox(height: 28),
                      FinancialHealthRecommendationsSection(recommendations: report.recommendations),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
