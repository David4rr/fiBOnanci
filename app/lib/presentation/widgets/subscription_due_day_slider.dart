import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Bespoke tactile obsidian & neon glowing track slider for due day selection (1..31).
class SubscriptionDueDaySlider extends StatelessWidget {
  final int dueDay;
  final ValueChanged<int> onDayChanged;

  const SubscriptionDueDaySlider({
    super.key,
    required this.dueDay,
    required this.onDayChanged,
  });

  static const _milestones = [1, 5, 10, 15, 20, 25, 31];

  void _handleInteraction(Offset localPosition, double trackWidth) {
    const thumbRadius = 14.0;
    final usableWidth = trackWidth - (thumbRadius * 2);
    if (usableWidth <= 0) return;

    final dx = (localPosition.dx - thumbRadius).clamp(0.0, usableWidth);
    final fraction = dx / usableWidth;
    final day = (1 + fraction * 30).round().clamp(1, 31);
    if (day != dueDay) {
      HapticFeedback.selectionClick();
      onDayChanged(day);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('TANGGAL JATUH TEMPO', style: AppTypography.badgeLabel.copyWith(color: AppColors.textMuted, letterSpacing: 0.8)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.neoChartreuse.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.neoChartreuse.withValues(alpha: 0.35)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.event_repeat_rounded, size: 12, color: AppColors.neoChartreuse),
                  const SizedBox(width: 5),
                  Text(
                    'Tgl $dueDay setiap bulan',
                    style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.neoChartreuse, fontFeatures: const [FontFeature.tabularFigures()]),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final trackWidth = constraints.maxWidth;
            const thumbRadius = 14.0;
            final usableWidth = trackWidth - (thumbRadius * 2);
            final fraction = ((dueDay - 1) / 30.0).clamp(0.0, 1.0);
            final thumbX = thumbRadius + (fraction * usableWidth);

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragStart: (d) => _handleInteraction(d.localPosition, trackWidth),
              onHorizontalDragUpdate: (d) => _handleInteraction(d.localPosition, trackWidth),
              onTapDown: (d) => _handleInteraction(d.localPosition, trackWidth),
              child: SizedBox(
                height: 40,
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    Container(
                      height: 12,
                      width: trackWidth,
                      decoration: BoxDecoration(
                        color: AppColors.canvasInputSearch,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.canvasBorder),
                      ),
                    ),
                    Container(
                      height: 12,
                      width: thumbX,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0x33D4F442), AppColors.neoChartreuse]),
                        borderRadius: BorderRadius.horizontal(left: const Radius.circular(6), right: Radius.circular(thumbX >= trackWidth - 2 ? 6 : 2)),
                      ),
                    ),
                    for (final m in _milestones)
                      Positioned(
                        left: thumbRadius + (((m - 1) / 30.0) * usableWidth) - 1.5,
                        child: Container(
                          width: 3,
                          height: 8,
                          decoration: BoxDecoration(
                            color: m <= dueDay ? AppColors.textDarkPrimary.withValues(alpha: 0.6) : AppColors.textMuted.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(1.5),
                          ),
                        ),
                      ),
                    Positioned(
                      left: thumbX - thumbRadius,
                      child: Container(
                        width: thumbRadius * 2,
                        height: thumbRadius * 2,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.neoChartreuse,
                          boxShadow: [BoxShadow(color: AppColors.neoChartreuse.withValues(alpha: 0.45), blurRadius: 10, spreadRadius: 1)],
                          border: Border.all(color: AppColors.textDarkPrimary, width: 2),
                        ),
                        child: Center(
                          child: Container(width: 6, height: 6, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.textDarkPrimary)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final m in _milestones)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onDayChanged(m);
                  },
                  child: Text(
                    '$m',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: m == dueDay ? FontWeight.w800 : FontWeight.w600,
                      color: m == dueDay ? AppColors.neoChartreuse : AppColors.textMuted.withValues(alpha: 0.6),
                      fontFeatures: const [FontFeature.tabularFigures()],
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
