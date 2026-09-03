import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Contactless payment wave painter (•)))
class ContactlessPainter extends CustomPainter {
  final Color color;

  ContactlessPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final base = Offset(2, size.height / 2);

    // Dot
    canvas.drawCircle(base, 1.4, fillPaint);

    // Wave 1
    canvas.drawArc(
      Rect.fromCircle(center: base, radius: 4.5),
      -math.pi / 4,
      math.pi / 2,
      false,
      paint,
    );

    // Wave 2
    canvas.drawArc(
      Rect.fromCircle(center: base, radius: 8.5),
      -math.pi / 4,
      math.pi / 2,
      false,
      paint,
    );

    // Wave 3
    canvas.drawArc(
      Rect.fromCircle(center: base, radius: 12.5),
      -math.pi / 4,
      math.pi / 2,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant ContactlessPainter oldDelegate) => oldDelegate.color != color;
}
