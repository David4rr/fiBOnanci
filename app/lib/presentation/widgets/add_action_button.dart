import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

/// Concept 2: Interactive 3D Tilt & Slingshot (Physics & Gesture Toy).
class AddActionButton extends StatefulWidget {
  final VoidCallback onPressed;

  const AddActionButton({super.key, required this.onPressed});

  @override
  State<AddActionButton> createState() => _AddActionButtonState();
}

class _AddActionButtonState extends State<AddActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _elasticCurve;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _rotationAnimation;

  Offset _tiltOffset = Offset.zero;
  Offset _slingshotStart = Offset.zero;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _elasticCurve = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.88, end: 1.10)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.10, end: 0.98)
            .chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.98, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 30,
      ),
    ]).animate(_controller);

    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.25).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePointer(Offset localPosition) {
    const double radius = 28.0;
    final dx = ((localPosition.dx - radius) / radius).clamp(-1.0, 1.0);
    final dy = ((localPosition.dy - radius) / radius).clamp(-1.0, 1.0);
    setState(() => _tiltOffset = Offset(dx, dy));
  }

  void _triggerSlingshot() {
    setState(() {
      _isPressed = false;
      _slingshotStart = _tiltOffset;
    });

    _controller.forward(from: 0.0);
    HapticFeedback.mediumImpact();
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanDown: (details) {
        setState(() => _isPressed = true);
        _handlePointer(details.localPosition);
        HapticFeedback.selectionClick();
      },
      onPanUpdate: (details) => _handlePointer(details.localPosition),
      onPanEnd: (_) => _triggerSlingshot(),
      onPanCancel: () {
        setState(() {
          _isPressed = false;
          _slingshotStart = _tiltOffset;
        });
        _controller.forward(from: 0.0);
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final effectiveTilt = _controller.isAnimating
              ? Offset.lerp(
                  _slingshotStart,
                  Offset.zero,
                  _elasticCurve.value,
                )!
              : (_isPressed ? _tiltOffset : Offset.zero);

          final scale = _controller.isAnimating
              ? _scaleAnimation.value
              : (_isPressed ? 0.88 : 1.0);

          final tiltX = effectiveTilt.dx;
          final tiltY = effectiveTilt.dy;

          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.0025)
            ..rotateX(-tiltY * 0.40)
            ..rotateY(tiltX * 0.40)
            ..multiply(Matrix4.translationValues(tiltX * 3.0, tiltY * 3.0, 0.0));
          return Transform(
            transform: transform,
            alignment: Alignment.center,
            child: Transform.scale(
              scale: scale,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.neoChartreuse,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neoChartreuse.withValues(
                        alpha: _isPressed ? 0.45 : 0.35,
                      ),
                      blurRadius: _isPressed ? 10 : 16,
                      spreadRadius: _isPressed ? -3 : -2,
                      offset: Offset(
                        -tiltX * 6.0,
                        (_isPressed ? 2.0 : 4.0) - tiltY * 6.0,
                      ),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.30),
                      blurRadius: _isPressed ? 6 : 12,
                      offset: Offset(
                        -tiltX * 4.0,
                        (_isPressed ? 2.0 : 4.0) - tiltY * 4.0,
                      ),
                    ),
                  ],
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      center: Alignment(-tiltX * 0.65, -tiltY * 0.65),
                      radius: 0.85,
                      colors: [
                        Colors.white.withValues(alpha: 0.28),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.12),
                      ],
                    ),
                  ),
                  child: Center(
                    child: RotationTransition(
                      turns: _rotationAnimation,
                      child: Transform.translate(
                        offset: Offset(tiltX * 2.0, tiltY * 2.0),
                        child: const Icon(
                          Icons.add_rounded,
                          color: AppColors.textDarkPrimary,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
