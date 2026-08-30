import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../bloc/finance/finance_bloc.dart';
import '../../bloc/finance/finance_state.dart';
import '../../domain/services/financial_health_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class FinancialHealthModal {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.canvasBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (ctx) {
        return BlocBuilder<FinanceBloc, FinanceState>(
          builder: (context, state) {
            final report = state.healthReport;
            final Color tierColor = report.tierColor;

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
                      // Drag Handle
                      Center(
                        child: Container(
                          width: 44,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.textSubtle,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Title
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
                          GestureDetector(
                            onTap: () => Navigator.of(ctx).pop(),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.canvasCardSurface,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.canvasBorder),
                              ),
                              child: const Icon(Icons.close, color: AppColors.textMuted, size: 18),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Hero Score Badge Card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.canvasCardSurface,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: tierColor.withValues(alpha: 0.35), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: tierColor.withValues(alpha: 0.08),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                // Circular Score Dial
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: tierColor.withValues(alpha: 0.12),
                                    border: Border.all(color: tierColor, width: 3),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '${report.overallScore}',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 26,
                                            fontWeight: FontWeight.w900,
                                            color: AppColors.textWhite,
                                            fontFeatures: const [FontFeature.tabularFigures()],
                                          ),
                                        ),
                                        Text(
                                          '/ 100',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: tierColor.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          'STATUS: ${report.tierLabel.toUpperCase()}',
                                          style: GoogleFonts.plusJakartaSans(
                                            color: tierColor,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        report.tierHeadline,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.textWhite,
                                          height: 1.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // 4 Pillars Breakdown Section Title
                      Text('4 Pilar Rasio Keuangan', style: AppTypography.sectionTitle),
                      const SizedBox(height: 14),

                      // Pillar 1: Emergency Runway
                      _buildPillarCard(
                        metric: report.emergencyRunway,
                        icon: Icons.shield_outlined,
                        accentColor: AppColors.neoMint,
                      ),
                      const SizedBox(height: 12),

                      // Pillar 2: Fixed Commitment
                      _buildPillarCard(
                        metric: report.fixedCommitment,
                        icon: Icons.receipt_long_outlined,
                        accentColor: AppColors.neoCoral,
                      ),
                      const SizedBox(height: 12),

                      // Pillar 3: Net Savings Margin
                      _buildPillarCard(
                        metric: report.savingsMargin,
                        icon: Icons.savings_outlined,
                        accentColor: AppColors.neoPurple,
                      ),
                      const SizedBox(height: 12),

                      // Pillar 4: Spend Pacing
                      _buildPillarCard(
                        metric: report.spendPacing,
                        icon: Icons.speed_outlined,
                        accentColor: AppColors.neoChartreuse,
                      ),
                      const SizedBox(height: 28),

                      // Recommendations Section
                      Text('Rekomendasi Aksi Cerdas', style: AppTypography.sectionTitle),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.canvasCardSurface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.canvasBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: report.recommendations.map((rec) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(top: 3),
                                    width: 18,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      color: AppColors.neoChartreuse.withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.lightbulb_outline_rounded,
                                      color: AppColors.neoChartreuse,
                                      size: 11,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      rec,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        height: 1.5,
                                        color: AppColors.textWhite,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
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

  static Widget _buildPillarCard({
    required HealthPillarMetric metric,
    required IconData icon,
    required Color accentColor,
  }) {
    final double progress = (metric.score / 100.0).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.canvasCardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.canvasBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accentColor, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(metric.title, style: AppTypography.listTitle),
                    const SizedBox(height: 2),
                    Text(metric.description, style: AppTypography.listSubtitle),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: metric.isHealthy ? AppColors.neoMint.withValues(alpha: 0.15) : AppColors.statusDeficit.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  metric.displayValue,
                  style: GoogleFonts.plusJakartaSans(
                    color: metric.isHealthy ? AppColors.neoMint : AppColors.statusDeficit,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                metric.benchmark,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Skor: ${metric.score.toStringAsFixed(0)}/100',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: AppColors.textWhite,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation<Color>(metric.isHealthy ? AppColors.neoMint : accentColor),
            ),
          ),
        ],
      ),
    );
  }
}
