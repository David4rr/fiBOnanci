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
      SplineCanvasHelper.drawScrubLine(canvas, incPoints[touchedIndex!].dx, chartHeight);
    }
    SplineCanvasHelper.drawSplineCurve(canvas, incPoints, chartHeight, AppColors.neoMint, progress: progress, withGradient: true, withGlow: true, activeIndex: touchedIndex, centerDotColor: AppColors.canvasCardSurface);
    SplineCanvasHelper.drawSplineCurve(canvas, expPoints, chartHeight, AppColors.neoCoral, progress: progress, withGradient: false, withGlow: true, activeIndex: touchedIndex, centerDotColor: AppColors.canvasCardSurface);
    SplineCanvasHelper.drawBottomLabels(canvas, size, incPoints, labels, bottomLabelHeight, topOffset: 6);
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
      SplineCanvasHelper.drawScrubLine(canvas, points[touchedIndex!].dx, chartHeight);
    }
    SplineCanvasHelper.drawSplineCurve(canvas, points, chartHeight, color, progress: progress, withGradient: true, withGlow: true, activeIndex: touchedIndex, centerDotColor: AppColors.canvasCardSurface);
    SplineCanvasHelper.drawBottomLabels(canvas, size, points, labels, bottomLabelHeight, topOffset: 6);
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

  @override
  bool shouldRepaint(covariant SplineChartPainter oldDelegate) =>
      oldDelegate.values != values ||
      oldDelegate.incomeValues != incomeValues ||
      oldDelegate.expenseValues != expenseValues ||
      oldDelegate.lineColor != lineColor ||
      oldDelegate.labels != labels ||
      oldDelegate.touchedIndex != touchedIndex ||
      oldDelegate.progress != progress;
}

class SplineCanvasHelper {
  SplineCanvasHelper._();

  static const _labelStyle = TextStyle(color: AppColors.textMuted, fontSize: 9.2, fontWeight: FontWeight.w600);
  static final _scrubPaint = Paint()..color = AppColors.canvasBorder..strokeWidth = 1.1..style = PaintingStyle.stroke;

  static void drawScrubLine(Canvas canvas, double x, double chartHeight) {
    canvas.drawLine(Offset(x, 0), Offset(x, chartHeight), _scrubPaint);
  }

  static void drawSplineCurve(
    Canvas canvas, List<Offset> points, double chartHeight, Color color, {
    required double progress, bool withGradient = true, bool withGlow = false,
    int? activeIndex, Color centerDotColor = Colors.white,
  }) {
    if (points.isEmpty) return;
    final path = Path()..moveTo(points[0].dx, points[0].dy);
    final fillPath = Path()..moveTo(points[0].dx, chartHeight)..lineTo(points[0].dx, points[0].dy);
    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i], p1 = points[i + 1];
      final cx = (p0.dx + p1.dx) / 2;
      path.cubicTo(cx, p0.dy, cx, p1.dy, p1.dx, p1.dy);
      fillPath.cubicTo(cx, p0.dy, cx, p1.dy, p1.dx, p1.dy);
    }
    fillPath..lineTo(points.last.dx, chartHeight)..close();
    if (withGradient) {
      final grad = LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [color.withValues(alpha: 0.23 * progress), color.withValues(alpha: 0.01)],
      );
      canvas.drawPath(fillPath, Paint()..shader = grad.createShader(Rect.fromLTWH(0, 0, points.last.dx, chartHeight)));
    }
    if (withGlow) {
      canvas.drawPath(path, Paint()..color = color.withValues(alpha: 0.25)..style = PaintingStyle.stroke..strokeWidth = 3.5..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round);
    }
    canvas.drawPath(path, Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2.1..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round);
    final idx = activeIndex ?? (points.length - 1);
    if (idx < points.length) {
      final pt = points[idx];
      canvas.drawCircle(pt, 6.5, Paint()..color = color.withValues(alpha: 0.30));
      canvas.drawCircle(pt, 3.6, Paint()..color = color);
      canvas.drawCircle(pt, 1.6, Paint()..color = centerDotColor);
    }
  }

  static void drawBottomLabels(Canvas canvas, Size size, List<Offset> points, List<String> labels, double labelHeight, {double topOffset = 2}) {
    if (labels.isEmpty) return;
    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < labels.length && i < points.length; i++) {
      if (labels[i].isEmpty) continue;
      tp.text = TextSpan(text: labels[i], style: _labelStyle);
      tp.layout();
      final x = (points[i].dx - tp.width / 2).clamp(0.0, size.width - tp.width);
      tp.paint(canvas, Offset(x, size.height - labelHeight + topOffset));
    }
  }
}
