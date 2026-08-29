import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class TrendSplineChart extends StatelessWidget {
  final List<double>? values;
  final List<double>? incomeValues;
  final List<double>? expenseValues;
  final List<String> labels;
  final Color lineColor;
  final String? headline;
  final String? subtitle;
  final double height;

  const TrendSplineChart({
    super.key,
    this.values,
    this.incomeValues,
    this.expenseValues,
    required this.labels,
    this.lineColor = AppColors.neoMint,
    this.headline,
    this.subtitle,
    this.height = 140,
  });

  bool get isDual => incomeValues != null && expenseValues != null;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.canvasCardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.canvasBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header & Legend Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (headline != null)
                Expanded(
                  child: Text(
                    headline!,
                    style: AppTypography.listTitle.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textWhite,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              const SizedBox(width: 8),
              if (isDual)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildLegendDot(AppColors.neoMint, 'Masuk'),
                    const SizedBox(width: 10),
                    _buildLegendDot(AppColors.neoCoral, 'Keluar'),
                  ],
                )
              else if (subtitle != null)
                Text(
                  subtitle!,
                  style: AppTypography.badgeLabel.copyWith(
                    color: lineColor,
                    fontSize: 10,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Chart Canvas
          SizedBox(
            height: height,
            width: double.infinity,
            child: CustomPaint(
              painter: _SplineChartPainter(
                values: values,
                incomeValues: incomeValues,
                expenseValues: expenseValues,
                labels: labels,
                lineColor: lineColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _SplineChartPainter extends CustomPainter {
  final List<double>? values;
  final List<double>? incomeValues;
  final List<double>? expenseValues;
  final List<String> labels;
  final Color lineColor;

  _SplineChartPainter({
    this.values,
    this.incomeValues,
    this.expenseValues,
    required this.labels,
    required this.lineColor,
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

    // 1. Draw Income Series (Green)
    final incPoints = _calcPoints(inc, n, dx, 0.0, maxVal, topPad, plotH, size.width);
    _drawSplineCurve(canvas, incPoints, chartHeight, AppColors.neoMint, withGradient: true);

    // 2. Draw Expense Series (Red / NeoCoral)
    final expPoints = _calcPoints(exp, n, dx, 0.0, maxVal, topPad, plotH, size.width);
    _drawSplineCurve(canvas, expPoints, chartHeight, AppColors.neoCoral, withGradient: false);

    // 3. Draw X-Axis Labels
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
    _drawSplineCurve(canvas, points, chartHeight, color, withGradient: true);
    _drawLabels(canvas, size, points, bottomLabelHeight);
  }

  List<Offset> _calcPoints(
    List<double> vals,
    int n,
    double dx,
    double minVal,
    double maxVal,
    double topPad,
    double plotH,
    double totalWidth,
  ) {
    final List<Offset> points = [];
    final double range = (maxVal - minVal) == 0 ? 1.0 : (maxVal - minVal);

    for (int i = 0; i < n; i++) {
      final v = i < vals.length ? vals[i] : 0.0;
      final norm = ((v - minVal) / range).clamp(0.0, 1.0);
      final x = n > 1 ? i * dx : totalWidth / 2;
      final y = topPad + (1.0 - norm) * plotH;
      points.add(Offset(x, y));
    }
    return points;
  }

  void _drawSplineCurve(Canvas canvas, List<Offset> points, double chartHeight, Color color, {required bool withGradient}) {
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

    // Fill gradient (only for primary series to avoid muddy blending)
    if (withGradient) {
      final gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.22),
          color.withValues(alpha: 0.01),
        ],
      );
      final fillPaint = Paint()
        ..shader = gradient.createShader(Rect.fromLTWH(0, 0, points.last.dx, chartHeight))
        ..style = PaintingStyle.fill;
      canvas.drawPath(fillPath, fillPaint);
    }

    // Glow stroke
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, glowPaint);

    // Sharp stroke
    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, linePaint);

    // End active dot
    final lastPoint = points.last;
    canvas.drawCircle(lastPoint, 6.0, Paint()..color = color.withValues(alpha: 0.25));
    canvas.drawCircle(lastPoint, 3.5, Paint()..color = color);
    canvas.drawCircle(lastPoint, 1.5, Paint()..color = AppColors.canvasCardSurface);
  }

  void _drawLabels(Canvas canvas, Size size, List<Offset> points, double bottomLabelHeight) {
    const labelStyle = TextStyle(
      color: AppColors.textMuted,
      fontSize: 9.5,
      fontWeight: FontWeight.w600,
    );

    for (int i = 0; i < labels.length && i < points.length; i++) {
      if (labels[i].isEmpty) continue;
      final textSpan = TextSpan(text: labels[i], style: labelStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      final x = points[i].dx - (textPainter.width / 2);
      final clampedX = x.clamp(0.0, size.width - textPainter.width);
      textPainter.paint(canvas, Offset(clampedX, size.height - bottomLabelHeight + 6));
    }
  }

  @override
  bool shouldRepaint(covariant _SplineChartPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.incomeValues != incomeValues ||
        oldDelegate.expenseValues != expenseValues ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.labels != labels;
  }
}
