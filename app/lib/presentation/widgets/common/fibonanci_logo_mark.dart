import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Pure Minimalist fiBOnanci Spiral Logo Mark.
/// Renders ONLY the continuous Fibonacci Golden Spiral (1:1:2:3:5:8)
/// without any rings, lines, or containers.
class FibonanciLogoMark extends StatelessWidget {
  final double size;
  final double morphProgress;
  final bool showGlow;

  const FibonanciLogoMark({
    super.key,
    this.size = 64.0,
    this.morphProgress = 1.0,
    this.showGlow = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _FibonanciLogoPainter(
          progress: morphProgress.clamp(0.0, 1.0),
          showGlow: showGlow,
        ),
      ),
    );
  }
}

class _FibonanciLogoPainter extends CustomPainter {
  final double progress;
  final bool showGlow;

  const _FibonanciLogoPainter({required this.progress, required this.showGlow});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final spiralT = Curves.easeInOutCubic.transform(progress.clamp(0.0, 1.0));

    if (showGlow && spiralT > 0.05) {
      final glowPaint = Paint()
        ..color = AppColors.neoChartreuse.withValues(alpha: 0.14 * spiralT)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.22);
      canvas.drawCircle(Offset(w * 0.5, h * 0.5), w * 0.32 * spiralT, glowPaint);
    }

    final fullSpiral = _buildGoldenSpiralPath(size);
    final metrics = fullSpiral.computeMetrics().toList();
    if (metrics.isNotEmpty) {
      final metric = metrics.first;
      final drawLen = metric.length * spiralT.clamp(0.02, 1.0);
      final activeSpiral = metric.extractPath(0, drawLen);

      final spiralPaint = Paint()
        ..shader = ui.Gradient.linear(
          Offset(w * 0.18, h * 0.78),
          Offset(w * 0.82, h * 0.18),
          const [AppColors.neoMint, AppColors.neoChartreuse],
        )
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = (w * 0.095).clamp(2.4, 7.6);

      canvas.save();
      // Subtle rotation morph as the spiral uncoils from seed (0.0 -> 1.0)
      final angle = (1.0 - spiralT) * (-math.pi * 0.35);
      final scale = ui.lerpDouble(0.55, 1.0, spiralT)!;
      canvas.translate(w * 0.5, h * 0.5);
      canvas.rotate(angle);
      canvas.scale(scale, scale);
      canvas.translate(-w * 0.5, -h * 0.5);

      canvas.drawPath(activeSpiral, spiralPaint);
      canvas.restore();
    }
  }
  Path _buildGoldenSpiralPath(Size size) {
    final w = size.width, h = size.height;
    final u = w * 0.052;
    // Mathematically centered 5-arc Fibonacci progression: x in [0.16..0.84], y in [0.29..0.71]
    final origin = Offset(w * 0.627, h * 0.552);
    return Path()
      ..moveTo(origin.dx, origin.dy)
      // Arc 1 (r = 1u): top-left
      ..arcTo(
        Rect.fromCircle(center: Offset(origin.dx, origin.dy + u), radius: u),
        -math.pi / 2,
        -math.pi / 2,
        false,
      )
      // Arc 2 (r = 2u): bottom-left
      ..arcTo(
        Rect.fromCircle(center: Offset(origin.dx + u, origin.dy + u), radius: 2 * u),
        math.pi,
        -math.pi / 2,
        false,
      )
      // Arc 3 (r = 3u): bottom-right
      ..arcTo(
        Rect.fromCircle(center: Offset(origin.dx + u, origin.dy), radius: 3 * u),
        math.pi / 2,
        -math.pi / 2,
        false,
      )
      // Arc 4 (r = 5u): top-right
      ..arcTo(
        Rect.fromCircle(center: Offset(origin.dx - u, origin.dy), radius: 5 * u),
        0,
        -math.pi / 2,
        false,
      )
      // Arc 5 (r = 8u): sweeping outer golden curve
      ..arcTo(
        Rect.fromCircle(center: Offset(origin.dx - u, origin.dy + 3 * u), radius: 8 * u),
        -math.pi / 2,
        -math.pi * 0.46,
        false,
      );
  }

  @override
  bool shouldRepaint(covariant _FibonanciLogoPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.showGlow != showGlow;
}
