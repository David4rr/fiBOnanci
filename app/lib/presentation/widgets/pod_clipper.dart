import 'package:flutter/material.dart';

/// Custom Clipper to constrain BackdropFilter exactly to the pod geometry
class PodClipper extends CustomClipper<Path> {
  final bool isLeft;

  const PodClipper({required this.isLeft});

  @override
  Path getClip(Size size) => PodBorderPainter.buildPath(size, isLeft);

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// Custom Painter: Fills pod with translucent glass and strokes crisp 1.2px frosted border
class PodBorderPainter extends CustomPainter {
  final bool isLeft;

  const PodBorderPainter({required this.isLeft});

  static Path buildPath(Size size, bool isLeft) {
    final path = Path();
    final r = size.height / 2;
    const cutoutRadius = 34.0;

    if (isLeft) {
      path.moveTo(r, 0);
      path.lineTo(size.width, 0);
      path.arcToPoint(
        Offset(size.width, size.height),
        radius: const Radius.circular(cutoutRadius),
        clockwise: false,
      );
      path.lineTo(r, size.height);
      path.quadraticBezierTo(0, size.height, 0, size.height - r);
      path.lineTo(0, r);
      path.quadraticBezierTo(0, 0, r, 0);
    } else {
      path.moveTo(0, 0);
      path.lineTo(size.width - r, 0);
      path.quadraticBezierTo(size.width, 0, size.width, r);
      path.lineTo(size.width, size.height - r);
      path.quadraticBezierTo(size.width, size.height, size.width - r, size.height);
      path.lineTo(0, size.height);
      path.arcToPoint(
        const Offset(0, 0),
        radius: const Radius.circular(cutoutRadius),
        clockwise: false,
      );
    }
    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = buildPath(size, isLeft);

    final fillPaint = Paint()
      ..color = const Color(0xB813141C)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    final strokePaint = Paint()
      ..color = const Color(0x33FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
