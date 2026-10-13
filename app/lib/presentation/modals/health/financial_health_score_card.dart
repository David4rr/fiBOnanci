import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/formatters/app_currency.dart';
import '../../../domain/services/financial_health_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/folder_tab_card.dart';
import '../profile/profile_card_painters.dart';

class FinancialHealthScoreCard extends StatelessWidget {
  final FinancialHealthReport report;

  const FinancialHealthScoreCard({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final fmt = AppCurrency.of(context);
    final isHealthyTier = report.overallScore >= 70;
    final accent = isHealthyTier ? AppColors.neoChartreuse : (report.overallScore >= 50 ? const Color(0xFFFBBF24) : AppColors.neoCoral);
    const clipper = FolderTabClipper(tabWidthFactor: 0.56, cornerRadius: 24.0, stepDepth: 18.0);

    return CustomPaint(
      foregroundPainter: const FolderTabBorderPainter(clipper: clipper, borderColor: Color(0xFF262936), borderWidth: 1.1),
      child: ClipPath(
        clipper: clipper,
        child: Container(
          color: AppColors.carbonBlack,
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: accent)),
                const SizedBox(width: 7),
                Text('INDEKS • ${report.tierLabel.toUpperCase()}', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w800, color: accent, letterSpacing: 0.9)),
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
                            Text(
                              '${report.overallScore}',
                              style: GoogleFonts.plusJakartaSans(fontSize: 44, fontWeight: FontWeight.w800, color: AppColors.textWhite, letterSpacing: -1.6, height: 1.0, fontFeatures: const [FontFeature.tabularFigures()]),
                            ),
                            const SizedBox(width: 6),
                            Text('/ 100', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMuted, fontFeatures: const [FontFeature.tabularFigures()])),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(report.tierHeadline, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.78), height: 1.35)),
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
                Expanded(child: _buildAssetStat('Likuiditas Rekening', fmt.format(report.totalLiquidAssets))),
                const SizedBox(width: 16),
                Expanded(child: _buildAssetStat('Cadangan Kantong', fmt.format(report.totalPocketsAmount))),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssetStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 10.5, fontWeight: FontWeight.w500, color: AppColors.textMuted)),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textWhite,
            fontFeatures: const [FontFeature.tabularFigures()],
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
          'CATATAN & TINDAKAN',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: Colors.white.withValues(alpha: 0.38),
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
                    color: AppColors.neoChartreuse,
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
                      color: Colors.white.withValues(alpha: 0.82),
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
