import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'fibonanci_splash_overlay.dart';

/// 3-Stage Mathematical Vault Splash Screen Gate for fiBOnanci.
/// - Stage 1 (0.00 - 0.48): Central monolith rises & dual vault gates slide open
/// - Stage 2 (0.28 - 0.48): Biometric breathing pulse + fiBOnanci wordmark reveal
/// - Stage 3 (0.48 - 1.00): Shared element logo flight from center to top-left header
class FibonanciSplashGate extends StatefulWidget {
  static final ValueNotifier<bool> isSplashActive = ValueNotifier<bool>(false);
  static final GlobalKey dashboardLogoKey = GlobalKey();
  static final GlobalKey dashboardTextKey = GlobalKey();
  final Widget child;
  final Duration duration;

  const FibonanciSplashGate({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1650),
  });

  @override
  State<FibonanciSplashGate> createState() => _FibonanciSplashGateState();
}

class _FibonanciSplashGateState extends State<FibonanciSplashGate>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _isDone = false;

  @override
  void initState() {
    super.initState();
    FibonanciSplashGate.isSplashActive.value = true;
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          FibonanciSplashGate.isSplashActive.value = false;
          if (mounted) setState(() => _isDone = true);
        }
      })
      ..forward();
  }

  @override
  void dispose() {
    FibonanciSplashGate.isSplashActive.value = false;
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isDone) return widget.child;

    return Stack(
      children: [
        const Positioned.fill(child: ColoredBox(color: AppColors.canvasBg)),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = _controller.value;
            final enterT = Curves.easeOutCubic.transform(
              ((t - 0.50) / 0.42).clamp(0.0, 1.0),
            );
            final scale = ui.lerpDouble(0.96, 1.0, enterT)!;

            return Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: enterT,
                child: widget.child,
              ),
            );
          },
        ),
        Positioned.fill(
          child: FibonanciSplashOverlay(
            animation: _controller,
            targetKey: FibonanciSplashGate.dashboardLogoKey,
            targetTextKey: FibonanciSplashGate.dashboardTextKey,
          ),
        ),
      ],
    );
  }
}
