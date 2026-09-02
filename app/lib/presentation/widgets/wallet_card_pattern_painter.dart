import 'package:flutter/material.dart';

/// Available procedural card texture patterns.
enum WalletPatternType {
  topographicContours, // Organic elevation lines, Swiss alpine cartography
  bauhausConcentric,   // Modernist overlapping arc rings & discs (Bauhaus/Swiss)
  isometricCircuit,    // Micro-tech 45° cross-hatch & node pathways
  fluidWaveSplines,    // Layered flowing sine curves & liquidity waves
  angularPrismGeom,    // Bold angled facets, diagonal light shards
  constellationMatrix, // Mathematical dot matrix with orbital constellation nodes
}

class WalletPatternHelper {
  /// Deterministically assigns a pattern based on wallet ID string or index.
  static WalletPatternType getPatternForWallet(String walletId, [int? fallbackIndex]) {
    if (walletId.isNotEmpty) {
      final hash = walletId.codeUnits.fold<int>(
        0,
        (prev, elem) => ((prev << 5) - prev + elem) & 0x7FFFFFFF,
      );
      final index = hash % WalletPatternType.values.length;
      return WalletPatternType.values[index];
    }
    return WalletPatternType.values[(fallbackIndex ?? 0) % WalletPatternType.values.length];
  }
}

/// Custom painter rendering tactile, high-end procedural card textures.
class WalletCardPatternPainter extends CustomPainter {
  final WalletPatternType patternType;
  final Color primaryPatternColor;
  final Color secondaryPatternColor;

  const WalletCardPatternPainter({
    required this.patternType,
    required this.primaryPatternColor,
    required this.secondaryPatternColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    switch (patternType) {
      case WalletPatternType.topographicContours:
        _paintTopographicContours(canvas, size);
        break;
      case WalletPatternType.bauhausConcentric:
        _paintBauhausConcentric(canvas, size);
        break;
      case WalletPatternType.isometricCircuit:
        _paintIsometricCircuit(canvas, size);
        break;
      case WalletPatternType.fluidWaveSplines:
        _paintFluidWaveSplines(canvas, size);
        break;
      case WalletPatternType.angularPrismGeom:
        _paintAngularPrismGeom(canvas, size);
        break;
      case WalletPatternType.constellationMatrix:
        _paintConstellationMatrix(canvas, size);
        break;
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 1. TOPOGRAPHIC CONTOURS
  // ───────────────────────────────────────────────────────────────────────────
  void _paintTopographicContours(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = primaryPatternColor.withValues(alpha: 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..isAntiAlias = true;

    final fillPaint = Paint()
      ..color = secondaryPatternColor.withValues(alpha: 0.07)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final w = size.width;
    final h = size.height;

    // Outer contour band
    final pathOuter = Path()
      ..moveTo(w * 0.35, 0)
      ..cubicTo(w * 0.45, h * 0.35, w * 0.70, h * 0.20, w * 0.85, h * 0.65)
      ..cubicTo(w * 0.95, h * 0.95, w, h * 0.90, w, h)
      ..lineTo(w, 0)
      ..close();
    canvas.drawPath(pathOuter, fillPaint);
    canvas.drawPath(pathOuter, strokePaint);

    // Mid contour curve 1
    final path1 = Path()
      ..moveTo(w * 0.20, 0)
      ..cubicTo(w * 0.35, h * 0.45, w * 0.60, h * 0.30, w * 0.75, h * 0.80)
      ..cubicTo(w * 0.85, h * 1.10, w * 0.95, h, w, h * 0.80);
    canvas.drawPath(path1, strokePaint);

    // Mid contour curve 2
    final path2 = Path()
      ..moveTo(w * 0.10, 0)
      ..cubicTo(w * 0.22, h * 0.55, w * 0.50, h * 0.45, w * 0.65, h * 0.95)
      ..lineTo(w * 0.70, h);
    canvas.drawPath(path2, strokePaint);

    // Inner ridge
    final path3 = Path()
      ..moveTo(0, h * 0.25)
      ..cubicTo(w * 0.15, h * 0.65, w * 0.38, h * 0.60, w * 0.50, h);
    canvas.drawPath(path3, strokePaint);

    // Secondary hill on bottom-left
    final hillPath = Path()
      ..moveTo(0, h * 0.70)
      ..cubicTo(w * 0.12, h * 0.75, w * 0.20, h * 0.90, w * 0.25, h);
    canvas.drawPath(hillPath, strokePaint);
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 2. BAUHAUS CONCENTRIC
  // ───────────────────────────────────────────────────────────────────────────
  void _paintBauhausConcentric(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = primaryPatternColor.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..isAntiAlias = true;

    final discPaint = Paint()
      ..color = secondaryPatternColor.withValues(alpha: 0.09)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final w = size.width;
    final h = size.height;
    final center = Offset(w * 0.85, h * 0.30);

    // Background disc 1
    canvas.drawCircle(center, h * 0.65, discPaint);

    // Concentric rings radiating outward
    for (int i = 1; i <= 4; i++) {
      canvas.drawCircle(center, h * 0.22 * i, strokePaint);
    }

    // Secondary bottom-left subtle counter-ring
    final counterCenter = Offset(w * 0.12, h * 0.95);
    canvas.drawCircle(counterCenter, h * 0.45, strokePaint);
    canvas.drawCircle(counterCenter, h * 0.25, strokePaint);
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 3. ISOMETRIC CIRCUIT
  // ───────────────────────────────────────────────────────────────────────────
  void _paintIsometricCircuit(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = primaryPatternColor.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..isAntiAlias = true;

    final linePaint = Paint()
      ..color = primaryPatternColor.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..isAntiAlias = true;

    final dotPaint = Paint()
      ..color = primaryPatternColor.withValues(alpha: 0.28)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final w = size.width;
    final h = size.height;

    // Diagonal isometric grid lines
    const spacing = 32.0;
    for (double x = -h; x < w + h; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x + h, h), gridPaint);
    }

    // Circuit trace 1
    final trace1 = Path()
      ..moveTo(w * 0.45, 0)
      ..lineTo(w * 0.65, h * 0.35)
      ..lineTo(w * 0.85, h * 0.35)
      ..lineTo(w * 0.95, h * 0.55);
    canvas.drawPath(trace1, linePaint);
    canvas.drawCircle(Offset(w * 0.95, h * 0.55), 3.0, dotPaint);

    // Circuit trace 2
    final trace2 = Path()
      ..moveTo(w * 0.30, h)
      ..lineTo(w * 0.50, h * 0.65)
      ..lineTo(w * 0.72, h * 0.65)
      ..lineTo(w * 0.80, h * 0.80);
    canvas.drawPath(trace2, linePaint);
    canvas.drawCircle(Offset(w * 0.80, h * 0.80), 3.0, dotPaint);

    // Circuit trace 3
    final trace3 = Path()
      ..moveTo(w * 0.75, 0)
      ..lineTo(w * 0.88, h * 0.22)
      ..lineTo(w, h * 0.22);
    canvas.drawPath(trace3, linePaint);
    canvas.drawCircle(Offset(w * 0.75, 0), 2.5, dotPaint);
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 4. FLUID WAVE SPLINES
  // ───────────────────────────────────────────────────────────────────────────
  void _paintFluidWaveSplines(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final waveFill1 = Paint()
      ..color = secondaryPatternColor.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final waveFill2 = Paint()
      ..color = secondaryPatternColor.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final waveStroke = Paint()
      ..color = primaryPatternColor.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..isAntiAlias = true;

    // Layer 1 - Broad deep wave
    final path1 = Path()
      ..moveTo(0, h * 0.50)
      ..cubicTo(w * 0.25, h * 0.25, w * 0.60, h * 0.75, w, h * 0.35)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(path1, waveFill1);

    // Stroke along the crest
    final strokePath1 = Path()
      ..moveTo(0, h * 0.50)
      ..cubicTo(w * 0.25, h * 0.25, w * 0.60, h * 0.75, w, h * 0.35);
    canvas.drawPath(strokePath1, waveStroke);

    // Layer 2 - Sweeping secondary wave
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

    // High subtle harmonic ribbon
    final ribbon = Path()
      ..moveTo(w * 0.20, 0)
      ..cubicTo(w * 0.50, h * 0.35, w * 0.75, h * 0.10, w, h * 0.25);
    canvas.drawPath(ribbon, waveStroke);
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 5. ANGULAR PRISM GEOMETRY
  // ───────────────────────────────────────────────────────────────────────────
  void _paintAngularPrismGeom(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final fill1 = Paint()
      ..color = primaryPatternColor.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final fill2 = Paint()
      ..color = secondaryPatternColor.withValues(alpha: 0.06)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final line = Paint()
      ..color = primaryPatternColor.withValues(alpha: 0.20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..isAntiAlias = true;

    // Large angled facet from top-right
    final facet1 = Path()
      ..moveTo(w * 0.60, 0)
      ..lineTo(w, 0)
      ..lineTo(w, h * 0.70)
      ..lineTo(w * 0.75, h * 0.45)
      ..close();
    canvas.drawPath(facet1, fill1);
    canvas.drawPath(facet1, line);

    // Secondary angled slice
    final facet2 = Path()
      ..moveTo(w * 0.40, 0)
      ..lineTo(w * 0.60, 0)
      ..lineTo(w * 0.75, h * 0.45)
      ..lineTo(w * 0.50, h * 0.35)
      ..close();
    canvas.drawPath(facet2, fill2);
    canvas.drawPath(facet2, line);

    // Bottom diagonal ray
    final facet3 = Path()
      ..moveTo(w * 0.30, h)
      ..lineTo(w * 0.70, h)
      ..lineTo(w * 0.85, h * 0.60)
      ..lineTo(w * 0.55, h * 0.70)
      ..close();
    canvas.drawPath(facet3, fill2);
    canvas.drawPath(facet3, line);
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 6. CONSTELLATION MATRIX
  // ───────────────────────────────────────────────────────────────────────────
  void _paintConstellationMatrix(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final dotPaintLight = Paint()
      ..color = primaryPatternColor.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final dotPaintActive = Paint()
      ..color = primaryPatternColor.withValues(alpha: 0.28)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final linePaint = Paint()
      ..color = primaryPatternColor.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..isAntiAlias = true;

    final ringPaint = Paint()
      ..color = primaryPatternColor.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..isAntiAlias = true;

    // Draw stippled background matrix in right half
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

    // Connect select constellation nodes
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

    // Emphasize nodes
    for (final pt in [p1, p2, p3, p4, p5]) {
      canvas.drawCircle(pt, 3.2, dotPaintActive);
      canvas.drawCircle(pt, 6.0, ringPaint);
    }
  }

  @override
  bool shouldRepaint(covariant WalletCardPatternPainter oldDelegate) {
    return oldDelegate.patternType != patternType ||
        oldDelegate.primaryPatternColor != primaryPatternColor ||
        oldDelegate.secondaryPatternColor != secondaryPatternColor;
  }
}
