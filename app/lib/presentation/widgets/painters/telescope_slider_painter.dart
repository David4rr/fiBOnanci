import 'dart:ui';

import 'package:flutter/material.dart';

/// Minimalist optical ruler painter: matte pill housing where the vertical active indicator
/// tracks the selected day (1..31) while graduation lines glide smoothly in parallax.
class TelescopeSliderPainter extends CustomPainter {
  final double animatedDay;
  final double dragProgress;
  final Color accentColor;
  final Color trackColor;
  final Color majorTickColor;
  final Color minorTickColor;

  static const int _tickCount = 61; // 15 intervals of 4 -> bright major line every 4th tick
  static const double _parallaxSpan = 44.0;

  const TelescopeSliderPainter({
    required this.animatedDay,
    required this.dragProgress,
    required this.accentColor,
    required this.trackColor,
    required this.majorTickColor,
    required this.minorTickColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const horizontalPad = 18.0;
    final usableWidth = (size.width - horizontalPad * 2).clamp(1.0, double.infinity);
    final centerY = size.height / 2;
    final fraction = ((animatedDay - 1.0) / 30.0).clamp(0.0, 1.0);
    final activeX = horizontalPad + fraction * usableWidth;
    final parallaxShift = -(fraction - 0.5) * _parallaxSpan;

    // 1. Matte pill container
    final housingRect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(16),
    );
    canvas.save();
    canvas.clipRRect(housingRect);
    canvas.drawRect(Offset.zero & size, Paint()..color = trackColor);

    // 2. Parallax-moving vertical graduation lines
    const tickHalfH = 7.0;
    const edgeMargin = 8.0;
    const fadeSpan = 22.0;
    final step = usableWidth / (_tickCount - 1);

    for (int i = -8; i < _tickCount + 8; i++) {
      final x = horizontalPad + (i * step) + parallaxShift;
      if (x < edgeMargin || x > size.width - edgeMargin) continue;

      final leftFade = ((x - edgeMargin) / fadeSpan).clamp(0.0, 1.0);
      final rightFade = ((size.width - edgeMargin - x) / fadeSpan).clamp(0.0, 1.0);
      final edgeAlpha = leftFade < rightFade ? leftFade : rightFade;

      final isMajor = i % 4 == 0;
      final baseColor = isMajor ? majorTickColor : minorTickColor;
      final paint = Paint()
        ..color = baseColor.withValues(alpha: baseColor.a * edgeAlpha)
        ..strokeWidth = isMajor ? 1.3 : 1.1
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(x, centerY - tickHalfH),
        Offset(x, centerY + tickHalfH),
        paint,
      );
    }

    canvas.restore();

    // 3. Moving vertical active indicator bar
    final activeHalfH = lerpDouble(9.5, 11.5, dragProgress)!;
    final activeWidth = lerpDouble(2.8, 3.4, dragProgress)!;

    canvas.drawLine(
      Offset(activeX, centerY - activeHalfH),
      Offset(activeX, centerY + activeHalfH),
      Paint()
        ..color = accentColor
        ..strokeWidth = activeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant TelescopeSliderPainter oldDelegate) {
    return oldDelegate.animatedDay != animatedDay ||
        oldDelegate.dragProgress != dragProgress ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.majorTickColor != majorTickColor ||
        oldDelegate.minorTickColor != minorTickColor;
  }
}
