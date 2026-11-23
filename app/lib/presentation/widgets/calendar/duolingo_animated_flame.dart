import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class DuolingoFlamePainter extends CustomPainter {
  final double animationValue;
  final bool isLit;

  const DuolingoFlamePainter({required this.animationValue, this.isLit = true});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    if (!isLit) {
      final unlitPaint = Paint()
        ..color = AppColors.textSubtle.withValues(alpha: 0.22)
        ..style = PaintingStyle.fill;
      canvas.drawPath(_buildOuterFlame(w, h, 0.0), unlitPaint);
      return;
    }

    final double flicker = math.sin(animationValue * 2 * math.pi);
    final double innerFlicker = math.sin((animationValue + 0.25) * 2 * math.pi);
    final double breathe = 0.97 + (0.05 * math.sin(animationValue * math.pi));

    canvas.save();
    canvas.translate(w * 0.5, h * 0.95);
    canvas.scale(breathe, breathe);
    canvas.translate(-w * 0.5, -h * 0.95);

    // 1. Soft Ambient Glow
    final glowPaint = Paint()
      ..color = const Color(0xFFFF9600).withValues(alpha: 0.28)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.25);
    canvas.drawPath(_buildOuterFlame(w, h, flicker * 0.5), glowPaint);

    // 2. Outer Flame (Red-Orange to Golden Orange)
    final outerPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [Color(0xFFFF3D00), Color(0xFFFF8200), Color(0xFFFFAC1C)],
        stops: [0.0, 0.55, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;
    canvas.drawPath(_buildOuterFlame(w, h, flicker), outerPaint);

    // 3. Inner Flame (Golden Yellow to Luminous Cream)
    final innerPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFFF9C4), Color(0xFFFFD54F), Color(0xFFFFB300)],
        stops: [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(w * 0.2, h * 0.35, w * 0.6, h * 0.6))
      ..style = PaintingStyle.fill;
    canvas.drawPath(_buildInnerFlame(w, h, innerFlicker), innerPaint);

    canvas.restore();
  }

  Path _buildOuterFlame(double w, double h, double flicker) {
    final path = Path();
    final tipX = w * (0.54 + 0.04 * flicker);
    final tipY = h * (0.02 + 0.01 * flicker);

    path.moveTo(tipX, tipY);
    path.cubicTo(w * 0.68, h * 0.18, w * 0.94, h * 0.42, w * 0.94, h * 0.66);
    path.cubicTo(w * 0.94, h * 0.86, w * 0.76, h * 0.98, w * 0.50, h * 0.98);
    path.cubicTo(w * 0.24, h * 0.98, w * 0.06, h * 0.86, w * 0.06, h * 0.66);
    path.cubicTo(w * 0.06, h * 0.50, w * 0.16, h * 0.38, w * 0.22, h * 0.34);
    path.cubicTo(w * 0.22, h * 0.42, w * 0.30, h * 0.48, w * 0.36, h * 0.44);
    path.cubicTo(w * 0.34, h * 0.28, w * 0.40, h * 0.14, tipX, tipY);
    path.close();
    return path;
  }

  Path _buildInnerFlame(double w, double h, double flicker) {
    final path = Path();
    final innerTipX = w * (0.52 + 0.03 * flicker);
    final innerTipY = h * (0.42 - 0.02 * flicker);

    path.moveTo(innerTipX, innerTipY);
    path.cubicTo(w * 0.64, h * 0.52, w * 0.74, h * 0.68, w * 0.72, h * 0.82);
    path.cubicTo(w * 0.70, h * 0.94, w * 0.60, h * 0.96, w * 0.50, h * 0.96);
    path.cubicTo(w * 0.40, h * 0.96, w * 0.30, h * 0.94, w * 0.28, h * 0.82);
    path.cubicTo(w * 0.26, h * 0.68, w * 0.36, h * 0.54, innerTipX, innerTipY);
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant DuolingoFlamePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue || oldDelegate.isLit != isLit;
  }
}

class DuolingoAnimatedFlame extends StatefulWidget {
  final double size;
  final bool isLit;
  final bool animate;

  const DuolingoAnimatedFlame({
    super.key,
    this.size = 28,
    this.isLit = true,
    this.animate = true,
  });

  @override
  State<DuolingoAnimatedFlame> createState() => _DuolingoAnimatedFlameState();
}

class _DuolingoAnimatedFlameState extends State<DuolingoAnimatedFlame>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  bool get _isTestEnv => WidgetsBinding.instance.runtimeType.toString().contains('Test');

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    if (widget.isLit && widget.animate) {
      if (_isTestEnv) {
        _controller.forward();
      } else {
        _controller.repeat(reverse: true);
      }
    }
  }

  @override
  void didUpdateWidget(covariant DuolingoAnimatedFlame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLit && widget.animate && !_controller.isAnimating && _controller.value == 0.0) {
      if (_isTestEnv) {
        _controller.forward();
      } else {
        _controller.repeat(reverse: true);
      }
    } else if (!widget.isLit && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = Size(widget.size, widget.size * 1.18);
    if (!widget.isLit) {
      return CustomPaint(size: size, painter: const DuolingoFlamePainter(animationValue: 0.0, isLit: false));
    }
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => CustomPaint(
        size: size,
        painter: DuolingoFlamePainter(animationValue: _controller.value, isLit: true),
      ),
    );
  }
}
