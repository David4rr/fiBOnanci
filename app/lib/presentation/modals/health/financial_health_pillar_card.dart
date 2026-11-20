import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../domain/services/financial_health_service.dart';
import '../../theme/app_colors.dart';

class FinancialHealthPillarCard extends StatelessWidget {
  final HealthPillarMetric metric;
  final IconData? icon;
  final Color? accentColor;

  const FinancialHealthPillarCard({
    super.key,
    required this.metric,
    this.icon,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = (metric.score / 100.0).clamp(0.0, 1.0);
    final Color barColor = metric.isHealthy ? AppColors.neoChartreuse : AppColors.neoCoral;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(shape: BoxShape.circle, color: barColor),
              ),
              Expanded(
                child: Text(
                  metric.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textWhite,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                metric.displayValue,
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textWhite,
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: SizedBox(
              height: 3,
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white.withValues(alpha: 0.06),
                valueColor: AlwaysStoppedAnimation<Color>(barColor),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  metric.description,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${metric.benchmark} • ${metric.score.toStringAsFixed(0)}/100',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.45),
                  fontWeight: FontWeight.w500,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          if (metric.allocationRecommendation != null &&
              metric.allocationRecommendation!.isNotEmpty) ...[
            const SizedBox(height: 7),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6.5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.035),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: metric.isHealthy
                      ? AppColors.neoChartreuse.withValues(alpha: 0.16)
                      : AppColors.neoCoral.withValues(alpha: 0.16),
                  width: 0.8,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 1.5),
                    child: Icon(
                      metric.isHealthy
                          ? Icons.check_circle_outline_rounded
                          : Icons.lightbulb_outline_rounded,
                      size: 13,
                      color: metric.isHealthy
                          ? AppColors.neoChartreuse
                          : const Color(0xFFFFA439),
                    ),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      metric.allocationRecommendation!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.82),
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
