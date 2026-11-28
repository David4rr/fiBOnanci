import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/l10n/locale_notifier.dart';
import '../../../domain/services/financial_health_service.dart';
import '../../theme/app_colors.dart';
import 'financial_health_l10n.dart';
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
    final l10n = AppL10n.of(context);
    final r = FinancialHealthL10n.localize(context, report);
    return ListView(
      controller: scrollController,
      physics: const BouncingScrollPhysics(),
      padding: padding ?? const EdgeInsets.fromLTRB(24, 12, 24, 40),
      children: [
        FinancialHealthScoreCard(report: r),
        const SizedBox(height: 28),
        Text(
          l10n.healthFourPillars,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textSubtle,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        FinancialHealthPillarCard(metric: r.emergencyRunway),
        FinancialHealthPillarCard(metric: r.fixedCommitment),
        FinancialHealthPillarCard(metric: r.savingsMargin),
        FinancialHealthPillarCard(metric: r.spendPacing),
        const SizedBox(height: 24),
        FinancialHealthRecommendationsSection(
          recommendations: r.recommendations,
        ),
      ],
    );
  }
}
