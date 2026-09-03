import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

class PocketSplinePainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;
  final Color lineColor;
  final int? touchedIndex;
  final double progress;

  PocketSplinePainter({
    required this.values,
    required this.labels,
    required this.lineColor,
    this.touchedIndex,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const bottomLabelHeight = 16.0;
    final chartHeight = size.height - bottomLabelHeight;
    if (chartHeight <= 0 || values.isEmpty) return;

    final n = values.length;
    final double minVal = values.reduce(math.min);
    final double maxVal = values.reduce(math.max);

    const topPad = 8.0;
    const bottomPad = 6.0;
    final plotH = chartHeight - topPad - bottomPad;
    final dx = n > 1 ? size.width / (n - 1) : size.width;

    final points = _calcPoints(values, n, dx, minVal, maxVal, topPad, plotH, size.width);

    if (touchedIndex != null && touchedIndex! < n) {
      final scrubX = points[touchedIndex!].dx;
      canvas.drawLine(
        Offset(scrubX, 0),
        Offset(scrubX, chartHeight),
        Paint()..color = AppColors.canvasBorder..strokeWidth = 1.0..style = PaintingStyle.stroke,
      );
    }

    _drawSplineCurve(canvas, points, chartHeight, lineColor, activeIndex: touchedIndex);
    _drawLabels(canvas, size, points, bottomLabelHeight);
  }

  List<Offset> _calcPoints(List<double> vals, int n, double dx, double minVal, double maxVal, double topPad, double plotH, double totalWidth) {
    final List<Offset> points = [];
    final bool isFlat = (maxVal - minVal) == 0;
    final double range = isFlat ? 1.0 : (maxVal - minVal);

    for (int i = 0; i < n; i++) {
      final v = vals[i];
      final norm = isFlat ? 0.5 : ((v - minVal) / range).clamp(0.0, 1.0);
      final x = n > 1 ? i * dx : totalWidth / 2;
      final baseTargetY = topPad + (1.0 - norm) * plotH;
      final y = plotH + topPad - ((plotH + topPad - baseTargetY) * progress);
      points.add(Offset(x, y));
    }
    return points;
  }

  void _drawSplineCurve(Canvas canvas, List<Offset> points, double chartHeight, Color color, {int? activeIndex}) {
    if (points.isEmpty) return;

    final path = Path();
    final fillPath = Path();

    path.moveTo(points[0].dx, points[0].dy);
    fillPath.moveTo(points[0].dx, chartHeight);
    fillPath.lineTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final controlX = (p0.dx + p1.dx) / 2;
      path.cubicTo(controlX, p0.dy, controlX, p1.dy, p1.dx, p1.dy);
      fillPath.cubicTo(controlX, p0.dy, controlX, p1.dy, p1.dx, p1.dy);
    }

    fillPath.lineTo(points.last.dx, chartHeight);
    fillPath.close();

    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [color.withValues(alpha: 0.24 * progress), color.withValues(alpha: 0.01)],
    );
    final fillPaint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, points.last.dx, chartHeight))
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);

    final strokePaint = Paint()
      ..color = color.withValues(alpha: 0.95)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, strokePaint);

    final targetIndex = activeIndex ?? (points.length - 1);
    if (targetIndex < points.length) {
      final activePoint = points[targetIndex];
      canvas.drawCircle(activePoint, 6.0, Paint()..color = color.withValues(alpha: 0.35));
      canvas.drawCircle(activePoint, 3.2, Paint()..color = color);
      canvas.drawCircle(activePoint, 1.4, Paint()..color = Colors.white);
    }
  }

  void _drawLabels(Canvas canvas, Size size, List<Offset> points, double labelHeight) {
    if (labels.isEmpty) return;

    for (int i = 0; i < labels.length && i < points.length; i++) {
      final label = labels[i];
      if (label.isEmpty) continue;

      final textSpan = TextSpan(
        text: label,
        style: GoogleFonts.plusJakartaSans(color: AppColors.textMuted, fontSize: 9.0, fontWeight: FontWeight.w600),
      );
      final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr)..layout();
      final x = (points[i].dx - tp.width / 2).clamp(0.0, size.width - tp.width);
      final y = size.height - labelHeight + 2;
      tp.paint(canvas, Offset(x, y));
    }
  }

  @override
  bool shouldRepaint(covariant PocketSplinePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.touchedIndex != touchedIndex ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.values != values;
  }
}
