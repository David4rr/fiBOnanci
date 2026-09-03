import 'package:flutter/material.dart';

class WalletPatternsGeometric {
  static void paintIsometricCircuit(
    Canvas canvas,
    Size size,
    Color primaryColor,
    Color secondaryColor,
  ) {
    final gridPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..isAntiAlias = true;

    final linePaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..isAntiAlias = true;

    final dotPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.28)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final w = size.width;
    final h = size.height;

    const spacing = 32.0;
    for (double x = -h; x < w + h; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x + h, h), gridPaint);
    }

    final trace1 = Path()
      ..moveTo(w * 0.45, 0)
      ..lineTo(w * 0.65, h * 0.35)
      ..lineTo(w * 0.85, h * 0.35)
      ..lineTo(w * 0.95, h * 0.55);
    canvas.drawPath(trace1, linePaint);
    canvas.drawCircle(Offset(w * 0.95, h * 0.55), 3.0, dotPaint);

    final trace2 = Path()
      ..moveTo(w * 0.30, h)
      ..lineTo(w * 0.50, h * 0.65)
      ..lineTo(w * 0.72, h * 0.65)
      ..lineTo(w * 0.80, h * 0.80);
    canvas.drawPath(trace2, linePaint);
    canvas.drawCircle(Offset(w * 0.80, h * 0.80), 3.0, dotPaint);

    final trace3 = Path()
      ..moveTo(w * 0.75, 0)
      ..lineTo(w * 0.88, h * 0.22)
      ..lineTo(w, h * 0.22);
    canvas.drawPath(trace3, linePaint);
    canvas.drawCircle(Offset(w * 0.75, 0), 2.5, dotPaint);
  }

  static void paintAngularPrismGeom(
    Canvas canvas,
    Size size,
    Color primaryColor,
    Color secondaryColor,
  ) {
    final w = size.width;
    final h = size.height;

    final fill1 = Paint()
      ..color = primaryColor.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final fill2 = Paint()
      ..color = secondaryColor.withValues(alpha: 0.06)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final line = Paint()
      ..color = primaryColor.withValues(alpha: 0.20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..isAntiAlias = true;

    final facet1 = Path()
      ..moveTo(w * 0.60, 0)
      ..lineTo(w, 0)
      ..lineTo(w, h * 0.70)
      ..lineTo(w * 0.75, h * 0.45)
      ..close();
    canvas.drawPath(facet1, fill1);
    canvas.drawPath(facet1, line);

    final facet2 = Path()
      ..moveTo(w * 0.40, 0)
      ..lineTo(w * 0.60, 0)
      ..lineTo(w * 0.75, h * 0.45)
      ..lineTo(w * 0.50, h * 0.35)
      ..close();
    canvas.drawPath(facet2, fill2);
    canvas.drawPath(facet2, line);

    final facet3 = Path()
      ..moveTo(w * 0.30, h)
      ..lineTo(w * 0.70, h)
      ..lineTo(w * 0.85, h * 0.60)
      ..lineTo(w * 0.55, h * 0.70)
      ..close();
    canvas.drawPath(facet3, fill2);
    canvas.drawPath(facet3, line);
  }

  static void paintConstellationMatrix(
    Canvas canvas,
    Size size,
    Color primaryColor,
    Color secondaryColor,
  ) {
    final w = size.width;
    final h = size.height;

    final dotPaintLight = Paint()
      ..color = primaryColor.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final dotPaintActive = Paint()
      ..color = primaryColor.withValues(alpha: 0.28)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final linePaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..isAntiAlias = true;

    final ringPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..isAntiAlias = true;

    const cols = 7;
    const rows = 4;
    final startX = w * 0.40;
    final cellW = (w * 0.55) / (cols - 1);
    final cellH = (h * 0.75) / (rows - 1);

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final x = startX + c * cellW;
        final y = h * 0.15 + r * cellH;
        canvas.drawCircle(Offset(x, y), 1.2, dotPaintLight);
      }
    }

    final p1 = Offset(startX + 1 * cellW, h * 0.15 + 0 * cellH);
    final p2 = Offset(startX + 3 * cellW, h * 0.15 + 1 * cellH);
    final p3 = Offset(startX + 5 * cellW, h * 0.15 + 1 * cellH);
    final p4 = Offset(startX + 4 * cellW, h * 0.15 + 2 * cellH);
    final p5 = Offset(startX + 2 * cellW, h * 0.15 + 3 * cellH);

    final constellationPath = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(p3.dx, p3.dy)
      ..lineTo(p4.dx, p4.dy)
      ..lineTo(p5.dx, p5.dy);
    canvas.drawPath(constellationPath, linePaint);

    for (final pt in [p1, p2, p3, p4, p5]) {
      canvas.drawCircle(pt, 3.2, dotPaintActive);
      canvas.drawCircle(pt, 6.0, ringPaint);
    }
  }
}
