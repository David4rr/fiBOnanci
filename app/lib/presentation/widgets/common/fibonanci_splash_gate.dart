import 'package:flutter/material.dart';
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
        RepaintBoundary(child: widget.child),
        Positioned.fill(
          child: RepaintBoundary(
            child: FibonanciSplashOverlay(
              animation: _controller,
              targetKey: FibonanciSplashGate.dashboardLogoKey,
              targetTextKey: FibonanciSplashGate.dashboardTextKey,
            ),
          ),
        ),
      ],
    );
  }
}
