import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class SplineChartPainter extends CustomPainter {
  final List<double>? values;
  final List<double>? incomeValues;
  final List<double>? expenseValues;
  final List<String> labels;
  final Color lineColor;
  final int? touchedIndex;
  final double progress;

  SplineChartPainter({
    this.values,
    this.incomeValues,
    this.expenseValues,
    required this.labels,
    required this.lineColor,
    this.touchedIndex,
    this.progress = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const bottomLabelHeight = 22.0;
    final chartHeight = size.height - bottomLabelHeight;
    if (chartHeight <= 0) return;

    final isDual = incomeValues != null && expenseValues != null;
    if (isDual) {
      _paintDual(canvas, size, chartHeight, bottomLabelHeight);
    } else if (values != null && values!.isNotEmpty) {
      _paintSingle(canvas, size, chartHeight, bottomLabelHeight, values!, lineColor);
    }
  }

  void _paintDual(Canvas canvas, Size size, double chartHeight, double bottomLabelHeight) {
    final inc = incomeValues!;
    final exp = expenseValues!;
    final n = math.max(inc.length, exp.length);
    if (n == 0) return;

    double maxVal = 0.0;
    for (final v in inc) {
      if (v > maxVal) maxVal = v;
    }
    for (final v in exp) {
      if (v > maxVal) maxVal = v;
    }
    if (maxVal == 0.0) maxVal = 1.0;

    const topPad = 10.0;
    const bottomPad = 8.0;
    final plotH = chartHeight - topPad - bottomPad;
    final dx = n > 1 ? size.width / (n - 1) : size.width;

    final incPoints = _calcPoints(inc, n, dx, 0.0, maxVal, topPad, plotH, size.width);
    final expPoints = _calcPoints(exp, n, dx, 0.0, maxVal, topPad, plotH, size.width);

    if (touchedIndex != null && touchedIndex! < n) {
      final scrubX = incPoints[touchedIndex!].dx;
      canvas.drawLine(
        Offset(scrubX, 0),
        Offset(scrubX, chartHeight),
        Paint()..color = AppColors.canvasBorder..strokeWidth = 1.2..style = PaintingStyle.stroke,
      );
    }

    _drawSplineCurve(canvas, incPoints, chartHeight, AppColors.neoMint, withGradient: true, activeIndex: touchedIndex);
    _drawSplineCurve(canvas, expPoints, chartHeight, AppColors.neoCoral, withGradient: false, activeIndex: touchedIndex);
    _drawLabels(canvas, size, incPoints, bottomLabelHeight);
  }

  void _paintSingle(Canvas canvas, Size size, double chartHeight, double bottomLabelHeight, List<double> vals, Color color) {
    final n = vals.length;
    final double minVal = vals.reduce(math.min);
    final double maxVal = vals.reduce(math.max);

    const topPad = 10.0;
    const bottomPad = 8.0;
    final plotH = chartHeight - topPad - bottomPad;
    final dx = n > 1 ? size.width / (n - 1) : size.width;

    final points = _calcPoints(vals, n, dx, minVal, maxVal, topPad, plotH, size.width);

    if (touchedIndex != null && touchedIndex! < n) {
      final scrubX = points[touchedIndex!].dx;
      canvas.drawLine(
        Offset(scrubX, 0),
        Offset(scrubX, chartHeight),
        Paint()..color = AppColors.canvasBorder..strokeWidth = 1.2..style = PaintingStyle.stroke,
      );
    }

    _drawSplineCurve(canvas, points, chartHeight, color, withGradient: true, activeIndex: touchedIndex);
    _drawLabels(canvas, size, points, bottomLabelHeight);
  }

  List<Offset> _calcPoints(List<double> vals, int n, double dx, double minVal, double maxVal, double topPad, double plotH, double totalWidth) {
    final List<Offset> points = [];
    final double range = (maxVal - minVal) == 0 ? 1.0 : (maxVal - minVal);

    for (int i = 0; i < n; i++) {
      final v = i < vals.length ? vals[i] : 0.0;
      final norm = ((v - minVal) / range).clamp(0.0, 1.0);
      final x = n > 1 ? i * dx : totalWidth / 2;
      final baseTargetY = topPad + (1.0 - norm) * plotH;
      final y = plotH + topPad - ((plotH + topPad - baseTargetY) * progress);
      points.add(Offset(x, y));
    }
    return points;
  }

  void _drawSplineCurve(Canvas canvas, List<Offset> points, double chartHeight, Color color, {required bool withGradient, int? activeIndex}) {
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

    if (withGradient) {
      final gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withValues(alpha: 0.22 * progress), color.withValues(alpha: 0.01)],
      );
      final fillPaint = Paint()
        ..shader = gradient.createShader(Rect.fromLTWH(0, 0, points.last.dx, chartHeight))
        ..style = PaintingStyle.fill;
      canvas.drawPath(fillPath, fillPaint);
    }

    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, glowPaint);

    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, linePaint);

    final highlightIdx = activeIndex ?? (points.length - 1);
    if (highlightIdx < points.length) {
      final targetPt = points[highlightIdx];
      canvas.drawCircle(targetPt, 7.0, Paint()..color = color.withValues(alpha: 0.25));
      canvas.drawCircle(targetPt, 4.0, Paint()..color = color);
      canvas.drawCircle(targetPt, 1.8, Paint()..color = AppColors.canvasCardSurface);
    }
  }

  void _drawLabels(Canvas canvas, Size size, List<Offset> points, double bottomLabelHeight) {
    const labelStyle = TextStyle(color: AppColors.textMuted, fontSize: 9.5, fontWeight: FontWeight.w600);
    for (int i = 0; i < labels.length && i < points.length; i++) {
      if (labels[i].isEmpty) continue;
      final textSpan = TextSpan(text: labels[i], style: labelStyle);
      final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr)..layout();
      final x = (points[i].dx - (textPainter.width / 2)).clamp(0.0, size.width - textPainter.width);
      textPainter.paint(canvas, Offset(x, size.height - bottomLabelHeight + 6));
    }
  }

  @override
  bool shouldRepaint(covariant SplineChartPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.incomeValues != incomeValues ||
        oldDelegate.expenseValues != expenseValues ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.labels != labels ||
        oldDelegate.touchedIndex != touchedIndex ||
        oldDelegate.progress != progress;
  }
}
