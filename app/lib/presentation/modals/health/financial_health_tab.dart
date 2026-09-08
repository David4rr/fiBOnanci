import 'package:flutter/material.dart';

import '../../../domain/services/financial_health_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import 'financial_health_pillar_card.dart';
import 'financial_health_score_card.dart';

class FinancialHealthTab extends StatelessWidget {
  final FinancialHealthReport report;
  final ScrollController? scrollController;
  final EdgeInsetsGeometry? padding;

  const FinancialHealthTab({
    super.key,
    required this.report,
    this.scrollController,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollController,
      physics: const BouncingScrollPhysics(),
      padding: padding ?? const EdgeInsets.fromLTRB(20, 16, 20, 36),
      children: [
        FinancialHealthScoreCard(report: report),
        const SizedBox(height: 28),
        Text('4 Pilar Rasio Keuangan', style: AppTypography.sectionTitle),
        const SizedBox(height: 14),
        FinancialHealthPillarCard(
          metric: report.emergencyRunway,
          icon: Icons.shield_outlined,
          accentColor: AppColors.neoMint,
        ),
        const SizedBox(height: 12),
        FinancialHealthPillarCard(
          metric: report.fixedCommitment,
          icon: Icons.receipt_long_outlined,
          accentColor: AppColors.neoCoral,
        ),
        const SizedBox(height: 12),
        FinancialHealthPillarCard(
          metric: report.savingsMargin,
          icon: Icons.savings_outlined,
          accentColor: AppColors.neoPurple,
        ),
        const SizedBox(height: 12),
        FinancialHealthPillarCard(
          metric: report.spendPacing,
          icon: Icons.speed_rounded,
          accentColor: AppColors.neoCyan,
        ),
        const SizedBox(height: 28),
        FinancialHealthRecommendationsSection(
          recommendations: report.recommendations,
        ),
      ],
    );
  }
}
