import 'package:flutter/material.dart';

class ModernistPaintersGeometric {
  static void paintMonochromeStark(Canvas canvas, Size size, Color primaryColor, Color secondaryColor) {
    final slashPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.20)
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = secondaryColor.withValues(alpha: 0.30)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(size.width * 0.65, 0)
      ..lineTo(size.width * 0.90, 0)
      ..lineTo(size.width * 0.50, size.height)
      ..lineTo(size.width * 0.25, size.height)
      ..close();
    canvas.drawPath(path, slashPaint);

    for (int i = 0; i < 4; i++) {
      final y = size.height * (0.25 + i * 0.18);
      canvas.drawLine(Offset(size.width * 0.55, y), Offset(size.width * 0.92, y), gridPaint);
    }
  }

  static void paintLavenderDusk(Canvas canvas, Size size, Color primaryColor, Color secondaryColor) {
    final spherePaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.40)
      ..style = PaintingStyle.fill;

    final orbitPaint = Paint()
      ..color = secondaryColor.withValues(alpha: 0.50)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width * 0.78, size.height * 0.36);
    canvas.drawCircle(center, 22, spherePaint);
    canvas.drawOval(Rect.fromCenter(center: center, width: 90, height: 42), orbitPaint);

    final satellite = Offset(size.width * 0.58, size.height * 0.50);
    canvas.drawCircle(satellite, 12, spherePaint..color = primaryColor.withValues(alpha: 0.25));
  }

  static void paintCobaltVault(Canvas canvas, Size size, Color primaryColor, Color secondaryColor) {
    final radarPaint = Paint()
      ..color = secondaryColor.withValues(alpha: 0.45)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width * 0.80, size.height * 0.40);
    canvas.drawCircle(center, 14, fillPaint);
    canvas.drawCircle(center, 32, radarPaint);
    canvas.drawCircle(center, 54, radarPaint);

    canvas.drawLine(Offset(center.dx - 64, center.dy), Offset(center.dx + 64, center.dy), radarPaint);
    canvas.drawLine(Offset(center.dx, center.dy - 64), Offset(center.dx, center.dy + 64), radarPaint);
  }

  static void paintBlushPop(Canvas canvas, Size size, Color primaryColor, Color secondaryColor) {
    final pillPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;

    final ringPaint = Paint()
      ..color = secondaryColor.withValues(alpha: 0.60)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(size.width * 0.76, size.height * 0.38), width: 72, height: 34),
      const Radius.circular(17),
    );
    canvas.drawRRect(rect, pillPaint);
    canvas.drawRRect(rect, ringPaint);

    canvas.drawCircle(Offset(size.width * 0.58, size.height * 0.60), 10, pillPaint);
  }

  static void paintNordicPine(Canvas canvas, Size size, Color primaryColor) {
    final strokePaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.45)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;

    final path1 = Path()
      ..moveTo(w * 0.40, 0)
      ..cubicTo(w * 0.55, h * 0.40, w * 0.75, h * 0.25, w, h * 0.60);
    canvas.drawPath(path1, strokePaint);

    final path2 = Path()
      ..moveTo(w * 0.50, 0)
      ..cubicTo(w * 0.65, h * 0.50, w * 0.85, h * 0.35, w, h * 0.80);
    canvas.drawPath(path2, strokePaint);

    final path3 = Path()
      ..moveTo(w * 0.60, 0)
      ..cubicTo(w * 0.75, h * 0.60, w * 0.92, h * 0.45, w, h);
    canvas.drawPath(path3, strokePaint);
  }

  static void paintCopperPatina(Canvas canvas, Size size, Color primaryColor, Color secondaryColor) {
    final slashPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.45)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final accentPaint = Paint()
      ..color = secondaryColor.withValues(alpha: 0.40)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 5; i++) {
      final startX = size.width * (0.60 + i * 0.08);
      final startY = size.height * 0.15;
      canvas.drawLine(
        Offset(startX, startY),
        Offset(startX - 28, startY + 46),
        slashPaint,
      );
    }

    canvas.drawCircle(Offset(size.width * 0.82, size.height * 0.65), 14, accentPaint);
  }
}
