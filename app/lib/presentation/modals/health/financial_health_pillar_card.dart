import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../domain/services/financial_health_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class FinancialHealthPillarCard extends StatelessWidget {
  final HealthPillarMetric metric;
  final IconData icon;
  final Color accentColor;

  const FinancialHealthPillarCard({
    super.key,
    required this.metric,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
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
