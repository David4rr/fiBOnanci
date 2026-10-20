import 'dart:math' as math;
import 'package:flutter/material.dart';

class PocketCashflowSplinePainter extends CustomPainter {
  final List<double> values;
  final Color lineColor;
  final Color fillColor;
  final double progress;
  final bool hasTransactions;

  PocketCashflowSplinePainter({
    required this.values,
    required this.lineColor,
    required this.fillColor,
    required this.progress,
    required this.hasTransactions,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0 || values.isEmpty) return;
    final n = values.length;
    final minVal = values.reduce(math.min);
    final maxVal = values.reduce(math.max);
    final isFlat = !hasTransactions || (maxVal - minVal) == 0;

    const topPad = 4.0;
    const botPad = 4.0;
    final plotH = size.height - topPad - botPad;
    final dx = n > 1 ? size.width / (n - 1) : size.width;
    final range = isFlat ? 1.0 : (maxVal - minVal);

    final points = List.generate(n, (i) {
      final norm = isFlat ? 0.5 : ((values[i] - minVal) / range).clamp(0.0, 1.0);
      final x = n > 1 ? i * dx : size.width / 2;
      final targetY = topPad + (1.0 - norm) * plotH;
      return Offset(x, size.height - ((size.height - targetY) * progress));
    });

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i], p1 = points[i + 1];
      final cx = (p0.dx + p1.dx) / 2;
      path.cubicTo(cx, p0.dy, cx, p1.dy, p1.dx, p1.dy);
    }

    final fillPath = Path.from(path)
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [fillColor, fillColor.withValues(alpha: 0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);

    final strokePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, strokePaint);

    if (progress >= 0.7) {
      final last = points.last;
      final alpha = ((progress - 0.7) / 0.3).clamp(0.0, 1.0);
      canvas.drawCircle(last, 4.0, Paint()..color = lineColor.withValues(alpha: 0.35 * alpha));
      canvas.drawCircle(last, 2.2, Paint()..color = lineColor.withValues(alpha: alpha));
      canvas.drawCircle(last, 1.0, Paint()..color = Colors.white.withValues(alpha: alpha));
    }
  }

  @override
  bool shouldRepaint(covariant PocketCashflowSplinePainter old) =>
      old.progress != progress || old.lineColor != lineColor || old.values != values;
}
