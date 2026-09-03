import 'dart:math' as math;
import 'package:flutter/material.dart';

class ModernistPaintersAmbient {
  static void paintTokyoMidnight(Canvas canvas, Size size, Color primaryColor, Color secondaryColor) {
    final linePaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.35)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = secondaryColor.withValues(alpha: 0.60)
      ..style = PaintingStyle.fill;

    final focal = Offset(size.width * 0.85, -size.height * 0.2);
    for (int i = 0; i < 6; i++) {
      final target = Offset(size.width * (0.3 + i * 0.15), size.height);
      canvas.drawLine(focal, target, linePaint);
    }

    final dots = [
      Offset(size.width * 0.65, size.height * 0.25),
      Offset(size.width * 0.80, size.height * 0.35),
      Offset(size.width * 0.72, size.height * 0.55),
      Offset(size.width * 0.88, size.height * 0.65),
    ];
    for (final d in dots) {
      canvas.drawCircle(d, 2.2, dotPaint);
    }
  }

  static void paintSolarAmber(Canvas canvas, Size size, Color primaryColor, Color secondaryColor) {
    final ringPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.40)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final sunPaint = Paint()
      ..color = secondaryColor.withValues(alpha: 0.45)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width * 0.82, size.height * 0.38);
    canvas.drawCircle(center, 24, sunPaint);
    canvas.drawCircle(center, 44, ringPaint);
    canvas.drawCircle(center, 68, ringPaint..strokeWidth = 1.4);
  }

  static void paintArcticGlacier(Canvas canvas, Size size, Color primaryColor, Color secondaryColor) {
    final strokePaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.45)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = secondaryColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;

    final path1 = Path()
      ..moveTo(size.width * 0.55, 0)
      ..lineTo(size.width * 0.85, 0)
      ..lineTo(size.width * 0.65, size.height * 0.60)
      ..close();
    canvas.drawPath(path1, fillPaint);
    canvas.drawPath(path1, strokePaint);

    final path2 = Path()
      ..moveTo(size.width * 0.70, 0)
      ..lineTo(size.width, size.height * 0.45)
      ..lineTo(size.width * 0.78, size.height * 0.85)
      ..close();
    canvas.drawPath(path2, strokePaint);
  }

  static void paintCyberNeon(Canvas canvas, Size size, Color primaryColor, Color secondaryColor) {
    final magentaPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.55)
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final cyanPaint = Paint()
      ..color = secondaryColor.withValues(alpha: 0.55)
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path1 = Path()
      ..moveTo(size.width * 0.45, 0)
      ..quadraticBezierTo(size.width * 0.60, size.height * 0.65, size.width, size.height * 0.50);
    canvas.drawPath(path1, magentaPaint);

    final path2 = Path()
      ..moveTo(size.width * 0.60, 0)
      ..quadraticBezierTo(size.width * 0.75, size.height * 0.45, size.width, size.height * 0.85);
    canvas.drawPath(path2, cyanPaint);
  }

  static void paintMatchaZen(Canvas canvas, Size size, Color primaryColor, Color secondaryColor) {
    final pebblePaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;

    final ringPaint = Paint()
      ..color = secondaryColor.withValues(alpha: 0.40)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;

    final center1 = Offset(size.width * 0.78, size.height * 0.32);
    canvas.drawOval(Rect.fromCenter(center: center1, width: 56, height: 38), pebblePaint);
    canvas.drawOval(Rect.fromCenter(center: center1, width: 80, height: 60), ringPaint);

    final center2 = Offset(size.width * 0.62, size.height * 0.62);
    canvas.drawOval(Rect.fromCenter(center: center2, width: 42, height: 28), pebblePaint);
  }

  static void paintTerracottaSunset(Canvas canvas, Size size, Color primaryColor, Color secondaryColor) {
    final arcPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.50)
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = secondaryColor.withValues(alpha: 0.60)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width * 0.76, size.height * 0.55);
    final path = Path()
      ..arcTo(Rect.fromCircle(center: center, radius: 46), math.pi, math.pi, false)
      ..close();
    canvas.drawPath(path, arcPaint);

    canvas.drawLine(
      Offset(size.width * 0.45, size.height * 0.55),
      Offset(size.width, size.height * 0.55),
      linePaint,
    );
  }
}
