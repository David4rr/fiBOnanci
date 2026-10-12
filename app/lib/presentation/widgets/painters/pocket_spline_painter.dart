import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'spline_chart_painter.dart';
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
      SplineCanvasHelper.drawScrubLine(canvas, points[touchedIndex!].dx, chartHeight);
    }
    SplineCanvasHelper.drawSplineCurve(canvas, points, chartHeight, lineColor, progress: progress, withGradient: true, activeIndex: touchedIndex);
    SplineCanvasHelper.drawBottomLabels(canvas, size, points, labels, bottomLabelHeight, topOffset: 2);
  }

  List<Offset> _calcPoints(List<double> vals, int n, double dx, double minVal, double maxVal, double topPad, double plotH, double totalWidth) {
    final List<Offset> points = [];
    final double baseMin = math.min(0.0, minVal);
    final bool isFlat = (maxVal - minVal) == 0;
    final double range = (maxVal - baseMin) <= 0 ? 1.0 : (maxVal - baseMin);

    for (int i = 0; i < n; i++) {
      final v = vals[i];
      final double norm = v <= 0
          ? 0.0
          : (isFlat ? 0.65 : ((v - baseMin) / range).clamp(0.0, 1.0));
      final x = n > 1 ? i * dx : totalWidth / 2;
      final baseTargetY = topPad + (1.0 - norm) * plotH;
      final y = plotH + topPad - ((plotH + topPad - baseTargetY) * progress);
      points.add(Offset(x, y));
    }
    return points;
  }

  @override
  bool shouldRepaint(covariant PocketSplinePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.touchedIndex != touchedIndex ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.values != values;
  }
}
