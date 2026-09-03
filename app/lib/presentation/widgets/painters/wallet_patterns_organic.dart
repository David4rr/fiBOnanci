import 'package:flutter/material.dart';

class WalletPatternsOrganic {
  static void paintTopographicContours(
    Canvas canvas,
    Size size,
    Color primaryColor,
    Color secondaryColor,
  ) {
    final strokePaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..isAntiAlias = true;

    final fillPaint = Paint()
      ..color = secondaryColor.withValues(alpha: 0.07)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final w = size.width;
    final h = size.height;

    final pathOuter = Path()
      ..moveTo(w * 0.35, 0)
      ..cubicTo(w * 0.45, h * 0.35, w * 0.70, h * 0.20, w * 0.85, h * 0.65)
      ..cubicTo(w * 0.95, h * 0.95, w, h * 0.90, w, h)
      ..lineTo(w, 0)
      ..close();
    canvas.drawPath(pathOuter, fillPaint);
    canvas.drawPath(pathOuter, strokePaint);

    final path1 = Path()
      ..moveTo(w * 0.20, 0)
      ..cubicTo(w * 0.35, h * 0.45, w * 0.60, h * 0.30, w * 0.75, h * 0.80)
      ..cubicTo(w * 0.85, h * 1.10, w * 0.95, h, w, h * 0.80);
    canvas.drawPath(path1, strokePaint);

    final path2 = Path()
      ..moveTo(w * 0.10, 0)
      ..cubicTo(w * 0.22, h * 0.55, w * 0.50, h * 0.45, w * 0.65, h * 0.95)
      ..lineTo(w * 0.70, h);
    canvas.drawPath(path2, strokePaint);

    final path3 = Path()
      ..moveTo(0, h * 0.25)
      ..cubicTo(w * 0.15, h * 0.65, w * 0.38, h * 0.60, w * 0.50, h);
    canvas.drawPath(path3, strokePaint);

    final hillPath = Path()
      ..moveTo(0, h * 0.70)
      ..cubicTo(w * 0.12, h * 0.75, w * 0.20, h * 0.90, w * 0.25, h);
    canvas.drawPath(hillPath, strokePaint);
  }

  static void paintBauhausConcentric(
    Canvas canvas,
    Size size,
    Color primaryColor,
    Color secondaryColor,
  ) {
    final strokePaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..isAntiAlias = true;

    final discPaint = Paint()
      ..color = secondaryColor.withValues(alpha: 0.09)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final w = size.width;
    final h = size.height;
    final center = Offset(w * 0.85, h * 0.30);

    canvas.drawCircle(center, h * 0.65, discPaint);

    for (int i = 1; i <= 4; i++) {
      canvas.drawCircle(center, h * 0.22 * i, strokePaint);
    }

    final counterCenter = Offset(w * 0.12, h * 0.95);
    canvas.drawCircle(counterCenter, h * 0.45, strokePaint);
    canvas.drawCircle(counterCenter, h * 0.25, strokePaint);
  }

  static void paintFluidWaveSplines(
    Canvas canvas,
    Size size,
    Color primaryColor,
    Color secondaryColor,
  ) {
    final w = size.width;
    final h = size.height;

    final waveFill1 = Paint()
      ..color = secondaryColor.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final waveFill2 = Paint()
      ..color = secondaryColor.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final waveStroke = Paint()
      ..color = primaryColor.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..isAntiAlias = true;

    final path1 = Path()
      ..moveTo(0, h * 0.50)
      ..cubicTo(w * 0.25, h * 0.25, w * 0.60, h * 0.75, w, h * 0.35)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(path1, waveFill1);

    final strokePath1 = Path()
      ..moveTo(0, h * 0.50)
      ..cubicTo(w * 0.25, h * 0.25, w * 0.60, h * 0.75, w, h * 0.35);
    canvas.drawPath(strokePath1, waveStroke);

    final path2 = Path()
      ..moveTo(0, h * 0.75)
      ..cubicTo(w * 0.35, h * 0.40, w * 0.70, h * 0.85, w, h * 0.55)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(path2, waveFill2);

    final strokePath2 = Path()
      ..moveTo(0, h * 0.75)
      ..cubicTo(w * 0.35, h * 0.40, w * 0.70, h * 0.85, w, h * 0.55);
    canvas.drawPath(strokePath2, waveStroke);

    final ribbon = Path()
      ..moveTo(w * 0.20, 0)
      ..cubicTo(w * 0.50, h * 0.35, w * 0.75, h * 0.10, w, h * 0.25);
    canvas.drawPath(ribbon, waveStroke);
  }
}
