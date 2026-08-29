import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Lightweight, interactive 30-day spline chart with animated entry & touch scrubbing.
class TrendSplineChart extends StatefulWidget {
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
    this.height = 130,
  });

  bool get isDual => incomeValues != null && expenseValues != null;

  @override
  State<TrendSplineChart> createState() => _TrendSplineChartState();
}

class _TrendSplineChartState extends State<TrendSplineChart> {
  int? _touchedIndex;
  static final _currencyFmt = NumberFormat.compactSimpleCurrency(locale: 'id_ID');

  void _handleTouch(Offset localPosition, double width, int count) {
    if (count <= 1 || width <= 0) return;
    final double fraction = (localPosition.dx / width).clamp(0.0, 1.0);
    final int index = (fraction * (count - 1)).round().clamp(0, count - 1);
    if (_touchedIndex != index) {
      setState(() => _touchedIndex = index);
    }
  }

  void _clearTouch() {
    if (_touchedIndex != null) {
      setState(() => _touchedIndex = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final int count = widget.isDual
        ? math.max(widget.incomeValues!.length, widget.expenseValues!.length)
        : (widget.values?.length ?? 0);

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
          // ── Header & Interactive Tooltip Row ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (widget.headline != null)
                Expanded(
                  child: Text(
                    widget.headline!,
                    style: AppTypography.listTitle.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textWhite,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              const SizedBox(width: 8),

              // Interactive Scrubbing Info or Static Legend
              if (_touchedIndex != null && _touchedIndex! < count)
                _buildScrubbingBadge(_touchedIndex!)
              else if (widget.isDual)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildLegendDot(AppColors.neoMint, 'Masuk'),
                    const SizedBox(width: 10),
                    _buildLegendDot(AppColors.neoCoral, 'Keluar'),
                  ],
                )
              else if (widget.subtitle != null)
                Text(
                  widget.subtitle!,
                  style: AppTypography.badgeLabel.copyWith(
                    color: widget.lineColor,
                    fontSize: 10,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Chart Area with Touch Scrubbing & Entry Animation ──
          LayoutBuilder(
            builder: (context, constraints) {
              final chartWidth = constraints.maxWidth;

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragDown: (d) => _handleTouch(d.localPosition, chartWidth, count),
                onHorizontalDragUpdate: (d) => _handleTouch(d.localPosition, chartWidth, count),
                onHorizontalDragEnd: (_) => _clearTouch(),
                onHorizontalDragCancel: _clearTouch,
                onTapDown: (d) => _handleTouch(d.localPosition, chartWidth, count),
                onTapUp: (_) => _clearTouch(),
                onTapCancel: _clearTouch,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutCubic,
                  builder: (context, animProgress, child) {
                    return SizedBox(
                      height: widget.height,
                      width: double.infinity,
                      child: CustomPaint(
                        painter: _SplineChartPainter(
                          values: widget.values,
                          incomeValues: widget.incomeValues,
                          expenseValues: widget.expenseValues,
                          labels: widget.labels,
                          lineColor: widget.lineColor,
                          touchedIndex: _touchedIndex,
                          progress: animProgress,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildScrubbingBadge(int index) {
    final dateStr = index < widget.labels.length && widget.labels[index].isNotEmpty
        ? widget.labels[index]
        : 'H-${30 - index}';

    if (widget.isDual) {
      final inAmt = index < widget.incomeValues!.length ? widget.incomeValues![index] : 0.0;
      final exAmt = index < widget.expenseValues!.length ? widget.expenseValues![index] : 0.0;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.canvasInputSearch,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.canvasBorder, width: 0.8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$dateStr • ',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w600),
            ),
            Text(
              '+${_currencyFmt.format(inAmt)} ',
              style: const TextStyle(color: AppColors.neoMint, fontSize: 10, fontWeight: FontWeight.bold),
            ),
            Text(
              '-${_currencyFmt.format(exAmt)}',
              style: const TextStyle(color: AppColors.neoCoral, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    } else {
      final amt = index < widget.values!.length ? widget.values![index] : 0.0;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.canvasInputSearch,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.canvasBorder, width: 0.8),
        ),
        child: Text(
          '$dateStr: ${_currencyFmt.format(amt)}',
          style: TextStyle(color: widget.lineColor, fontSize: 10, fontWeight: FontWeight.bold),
        ),
      );
    }
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
  final int? touchedIndex;
  final double progress;

  _SplineChartPainter({
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

    // Calculate Points
    final incPoints = _calcPoints(inc, n, dx, 0.0, maxVal, topPad, plotH, size.width);
    final expPoints = _calcPoints(exp, n, dx, 0.0, maxVal, topPad, plotH, size.width);

    // Draw Vertical Scrubbing Guide Line
    if (touchedIndex != null && touchedIndex! < n) {
      final scrubX = incPoints[touchedIndex!].dx;
      final guidePaint = Paint()
        ..color = AppColors.canvasBorder
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(scrubX, 0), Offset(scrubX, chartHeight), guidePaint);
    }

    // 1. Draw Income Series (Green)
    _drawSplineCurve(canvas, incPoints, chartHeight, AppColors.neoMint, withGradient: true, activeIndex: touchedIndex);

    // 2. Draw Expense Series (Red / NeoCoral)
    _drawSplineCurve(canvas, expPoints, chartHeight, AppColors.neoCoral, withGradient: false, activeIndex: touchedIndex);

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

    // Draw Scrub Guide
    if (touchedIndex != null && touchedIndex! < n) {
      final scrubX = points[touchedIndex!].dx;
      final guidePaint = Paint()
        ..color = AppColors.canvasBorder
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(scrubX, 0), Offset(scrubX, chartHeight), guidePaint);
    }

    _drawSplineCurve(canvas, points, chartHeight, color, withGradient: true, activeIndex: touchedIndex);
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
      // Invert Y and apply entry progress scaling
      final baseTargetY = topPad + (1.0 - norm) * plotH;
      final y = plotH + topPad - ((plotH + topPad - baseTargetY) * progress);
      points.add(Offset(x, y));
    }
    return points;
  }

  void _drawSplineCurve(
    Canvas canvas,
    List<Offset> points,
    double chartHeight,
    Color color, {
    required bool withGradient,
    int? activeIndex,
  }) {
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

    // Fill gradient (subtle and transparent)
    if (withGradient) {
      final gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.22 * progress),
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

    // Highlighted Point (either touched point or final endpoint)
    final highlightIdx = activeIndex ?? (points.length - 1);
    if (highlightIdx < points.length) {
      final targetPt = points[highlightIdx];
      canvas.drawCircle(targetPt, 7.0, Paint()..color = color.withValues(alpha: 0.25));
      canvas.drawCircle(targetPt, 4.0, Paint()..color = color);
      canvas.drawCircle(targetPt, 1.8, Paint()..color = AppColors.canvasCardSurface);
    }
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
        oldDelegate.labels != labels ||
        oldDelegate.touchedIndex != touchedIndex ||
        oldDelegate.progress != progress;
  }
}
