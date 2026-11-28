import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'category_donut_chart.dart';

class DonutRingPainter extends CustomPainter {
  final List<UnifiedDonutSlice> slices;
  final double totalSliceSum;
  final double progress;
  final int? selectedIndex;

  const DonutRingPainter({
    required this.slices,
    required this.totalSliceSum,
    required this.progress,
    required this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = math.min(size.width, size.height) / 2 - 20;
    const strokeWidth = 22.0;

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = AppColors.surfaceSubtle;
    canvas.drawCircle(center, baseRadius, trackPaint);
    if (slices.isEmpty || totalSliceSum <= 0 || baseRadius <= 0) return;

    final n = slices.length;
    if (n == 1) {
      final item = slices.first;
      final isSelected = selectedIndex == 0;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSelected ? 26.0 : strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = item.color;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: isSelected ? baseRadius + 2.0 : baseRadius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        paint,
      );
      return;
    }

    // Reserve uniform gap per segment: cap protrusion (strokeWidth / radius) + crisp visual gap.
    final capCompensation = strokeWidth / baseRadius;
    final desiredGap = capCompensation + 0.095;
    final maxTotalGap = 2 * math.pi * 0.65;
    final gapAngle = (n * desiredGap > maxTotalGap) ? (maxTotalGap / n) : desiredGap;

    final totalAvailableArc = math.max(0.0, 2 * math.pi - n * gapAngle);
    final minSliceArc = math.min(0.02, (totalAvailableArc / n) * 0.25);
    final proportionalPool = math.max(0.0, totalAvailableArc - n * minSliceArc);

    double startAngle = -math.pi / 2 + gapAngle / 2;
    for (int i = 0; i < n; i++) {
      final item = slices[i];
      final fullSliceArc = minSliceArc + (item.amount / totalSliceSum) * proportionalPool;
      final animatedArc = fullSliceArc * progress;
      final isSelected = selectedIndex == i;
      final isDimmed = selectedIndex != null && !isSelected;

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSelected ? 26.0 : strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = isDimmed ? item.color.withValues(alpha: 0.25) : item.color;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: isSelected ? baseRadius + 2.0 : baseRadius),
        startAngle,
        math.max(0.002, animatedArc),
        false,
        paint,
      );
      startAngle += (fullSliceArc + gapAngle) * progress;
    }
  }

  @override
  bool shouldRepaint(covariant DonutRingPainter old) =>
      old.progress != progress || old.selectedIndex != selectedIndex || old.totalSliceSum != totalSliceSum;
}
