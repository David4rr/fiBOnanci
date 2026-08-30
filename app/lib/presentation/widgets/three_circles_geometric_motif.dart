import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Swiss-editorial Geometric Motif with 3 bold Neo-Green/Chartreuse circles.
class ThreeCirclesGeometricMotif extends StatelessWidget {
  final double height;
  final Color color;
  final double gap;

  const ThreeCirclesGeometricMotif({
    super.key,
    this.height = 180,
    this.color = AppColors.neoChartreuse,
    this.gap = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: ClipRect(
          child: CustomPaint(
            painter: ThreeCirclesGeometricPainter(
              color: color,
              gap: gap,
            ),
            size: Size(double.infinity, height),
          ),
        ),
      ),
    );
  }
}

/// Custom painter for the 3 Neo-Green Geometric Shapes.
///
/// Draws 3 identical large circles of diameter = size.height.
/// - Center circle: (size.width / 2, centerY)
/// - Left circle: (size.width / 2 - (2*radius + gap), centerY)
/// - Right circle: (size.width / 2 + (2*radius + gap), centerY)
///
/// Clipped at container boundaries to create dramatic Swiss-editorial
/// hourglass curves and negative space.
class ThreeCirclesGeometricPainter extends CustomPainter {
  final Color color;
  final double gap;

  const ThreeCirclesGeometricPainter({
    required this.color,
    this.gap = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final paint = Paint()
      ..color = color
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;

    final centerY = size.height / 2;
    final centerX = size.width / 2;
    final radius = size.height / 2;
    final offsetDist = 2 * radius + gap;

    // Center full circle
    canvas.drawCircle(Offset(centerX, centerY), radius, paint);

    // Left circle touching center circle
    canvas.drawCircle(Offset(centerX - offsetDist, centerY), radius, paint);

    // Right circle touching center circle
    canvas.drawCircle(Offset(centerX + offsetDist, centerY), radius, paint);
  }

  @override
  bool shouldRepaint(covariant ThreeCirclesGeometricPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.gap != gap;
  }
}
