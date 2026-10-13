import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../domain/services/financial_health_service.dart';
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
      padding: padding ?? const EdgeInsets.fromLTRB(24, 12, 24, 40),
      children: [
        FinancialHealthScoreCard(report: report),
        const SizedBox(height: 28),
        Text(
          '4 Pilar Rasio Keuangan',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.white.withValues(alpha: 0.38),
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        FinancialHealthPillarCard(metric: report.emergencyRunway),
        FinancialHealthPillarCard(metric: report.fixedCommitment),
        FinancialHealthPillarCard(metric: report.savingsMargin),
        FinancialHealthPillarCard(metric: report.spendPacing),
        const SizedBox(height: 24),
        FinancialHealthRecommendationsSection(
          recommendations: report.recommendations,
        ),
      ],
    );
  }
}
