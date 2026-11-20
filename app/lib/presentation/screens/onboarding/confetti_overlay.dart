import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class ConfettiParticle {
  final double x;
  final double y;
  final double vx;
  final double vy;
  final double size;
  final Color color;
  final double rotationSpeed;
  final bool isCircle;

  const ConfettiParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.color,
    required this.rotationSpeed,
    required this.isCircle,
  });
}

class ConfettiOverlay extends StatefulWidget {
  final Widget child;
  const ConfettiOverlay({super.key, required this.child});

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<ConfettiParticle> _particles;

  static const List<Color> _palette = [
    AppColors.neoChartreuse,
    AppColors.neoCoral,
    AppColors.neoCyan,
    AppColors.neoPurple,
    AppColors.neoMint,
    Color(0xFFFDE047),
  ];

  @override
  void initState() {
    super.initState();
    final rng = math.Random(42);
    _particles = List.generate(42, (i) {
      final angle = (rng.nextDouble() * math.pi) + math.pi;
      final speed = 180.0 + rng.nextDouble() * 260.0;
      return ConfettiParticle(
        x: 0,
        y: 0,
        vx: math.cos(angle) * speed * (rng.nextBool() ? 1 : -1) * 0.7,
        vy: -speed * (0.6 + rng.nextDouble() * 0.6),
        size: 5.0 + rng.nextDouble() * 6.0,
        color: _palette[i % _palette.length],
        rotationSpeed: (rng.nextDouble() - 0.5) * 8.0,
        isCircle: i % 3 == 0,
      );
    });

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (context, _) {
                if (_ctrl.value >= 1.0) return const SizedBox.shrink();
                return CustomPaint(
                  painter: _ConfettiPainter(
                    particles: _particles,
                    progress: _ctrl.value,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height * 0.35;
    final gravity = 480.0 * progress * progress;
    final opacity = (1.0 - progress).clamp(0.0, 1.0);

    for (final p in particles) {
      final t = progress;
      final currentX = centerX + (p.vx * t);
      final currentY = centerY + (p.vy * t) + gravity;

      final paint = Paint()
        ..color = p.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(currentX, currentY);
      canvas.rotate(p.rotationSpeed * progress * math.pi);

      if (p.isCircle) {
        canvas.drawCircle(Offset.zero, p.size / 2, paint);
      } else {
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: p.size,
            height: p.size * 0.6,
          ),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
