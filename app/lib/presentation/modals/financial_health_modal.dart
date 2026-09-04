import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/finance/finance_bloc.dart';
import '../../bloc/finance/finance_state.dart';
import '../theme/app_colors.dart';
import '../widgets/common/common_widgets.dart';
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
                      const ModalGrabHandle(width: 44, padding: EdgeInsets.only(bottom: 20)),
                      ModalHeader(
                        title: 'Audit Kesehatan Finansial',
                        subtitle: 'Berdasarkan rasio arus kas, aset, & tagihan riil',
                        titleStyle: AppTypography.heroGreeting.copyWith(fontSize: 22),
                        closeIconColor: AppColors.textMuted,
                        padding: const EdgeInsets.only(bottom: 24),
                        onClose: () => Navigator.of(ctx).pop(),
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
