import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/formatters/app_currency.dart';
import '../../../core/l10n/locale_notifier.dart';
import '../../../domain/services/financial_health_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/common_widgets.dart';
import '../../widgets/folder_tab_card.dart';
import '../profile/profile_card_painters.dart';
import 'financial_health_l10n.dart';

class FinancialHealthScoreCard extends StatelessWidget {
  final FinancialHealthReport report;

  const FinancialHealthScoreCard({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final fmt = AppCurrency.of(context);
    final isHealthyTier = report.overallScore >= 70;
    final accent = isHealthyTier ? AppColors.textAccent : (report.overallScore >= 50 ? const Color(0xFFFBBF24) : AppColors.neoCoral);
    const clipper = FolderTabClipper(tabWidthFactor: 0.56, cornerRadius: 24.0, stepDepth: 18.0);

    return CustomPaint(
      foregroundPainter: FolderTabBorderPainter(clipper: clipper, borderColor: AppColors.canvasBorder, borderWidth: 1.1),
      child: ClipPath(
        clipper: clipper,
        child: Container(
          color: AppColors.canvasCardSurface,
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: accent)),
                const SizedBox(width: 7),
                Text('${l10n.healthIndexPrefix} • ${FinancialHealthL10n.tierLabel(l10n, report.tier).toUpperCase()}', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w800, color: accent, letterSpacing: 0.9)),
              ]),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            AnimatedCountingText(
                              value: report.overallScore.toDouble(),
                              formatter: (v) => '${v.round()}',
                              respectPrivacyMask: false,
                              duration: const Duration(milliseconds: 620),
                              style: GoogleFonts.plusJakartaSans(fontSize: 44, fontWeight: FontWeight.w800, color: AppColors.textWhite, letterSpacing: -1.6, height: 1.0),
                            ),
                            const SizedBox(width: 6),
                            Text('/ 100', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMuted, fontFeatures: const [FontFeature.tabularFigures()])),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(FinancialHealthL10n.tierHeadline(l10n, report.tier), style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary, height: 1.35)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 84,
                    height: 36,
                    child: CustomPaint(
                      painter: ProfileWaveChartPainter(
                        scores: [report.emergencyRunway.score, report.fixedCommitment.score, report.savingsMargin.score, report.spendPacing.score, report.overallScore.toDouble()],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(child: _buildAssetStat(l10n.healthLiquidAssets, report.totalLiquidAssets, fmt.format)),
                const SizedBox(width: 16),
                Expanded(child: _buildAssetStat(l10n.healthPocketReserves, report.totalPocketsAmount, fmt.format)),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssetStat(String label, double value, String Function(double) formatter) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 10.5, fontWeight: FontWeight.w500, color: AppColors.textMuted)),
        const SizedBox(height: 3),
        AnimatedCountingText(
          value: value,
          formatter: formatter,
          respectPrivacyMask: false,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textWhite,
          ),
        ),
      ],
    );
  }
}

class FinancialHealthRecommendationsSection extends StatelessWidget {
  final List<String> recommendations;

  const FinancialHealthRecommendationsSection({
    super.key,
    required this.recommendations,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppL10n.of(context).healthNotesActions,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: AppColors.textSubtle,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 12),
        for (int i = 0; i < recommendations.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '0${i + 1}',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    recommendations[i],
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      color: AppColors.textPrimary,
                      height: 1.45,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
