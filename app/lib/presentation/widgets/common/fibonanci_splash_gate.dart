import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import 'fibonanci_logo_mark.dart';

/// 3-Stage Geometric Morphing Splash Screen Overlay for fiBOnanci.
/// - Stage 1 (0.00 - 0.38): Golden Ratio seed & Fibonacci spiral unfolding
/// - Stage 2 (0.32 - 0.78): Circle-to-Folder-Tab vault morph + fiBOnanci wordmark reveal
/// - Stage 3 (0.78 - 1.00): Vault scale-through & seamless dissolve into MainShell
class FibonanciSplashGate extends StatefulWidget {
  static final ValueNotifier<bool> isSplashActive = ValueNotifier<bool>(false);
  final Widget child;
  final Duration duration;

  const FibonanciSplashGate({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1450),
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
    return Stack(
      children: [
        widget.child,
        if (!_isDone)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final t = _controller.value;
                final morphT = ((t) / 0.76).clamp(0.0, 1.0);
                final textT = Curves.easeOutCubic.transform(
                  ((t - 0.28) / 0.42).clamp(0.0, 1.0),
                );
                final exitT = Curves.easeInOutCubic.transform(
                  ((t - 0.76) / 0.24).clamp(0.0, 1.0),
                );
                final curtainOpacity = (1.0 - exitT).clamp(0.0, 1.0);
                final exitScale = ui.lerpDouble(1.0, 1.07, exitT)!;

                return IgnorePointer(
                  ignoring: t > 0.75,
                  child: Opacity(
                    opacity: curtainOpacity,
                    child: Material(
                      key: const Key('fibonanci_splash_overlay'),
                      color: AppColors.canvasBg,
                      child: Transform.scale(
                        scale: exitScale,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FibonanciLogoMark(
                                key: const Key('fibonanci_splash_logo'),
                                size: 96,
                                morphProgress: morphT,
                                showGlow: true,
                              ),
                              const SizedBox(height: 22),
                              Opacity(
                                opacity: textT,
                                child: Transform.translate(
                                  offset: Offset(0, 12 * (1.0 - textT)),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 28,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: -0.9,
                                            color: AppColors.textWhite,
                                          ),
                                          children: const [
                                            TextSpan(text: 'fi'),
                                            TextSpan(
                                              text: 'BO',
                                              style: TextStyle(
                                                color: AppColors.neoChartreuse,
                                              ),
                                            ),
                                            TextSpan(text: 'nanci'),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'φ 1.618 • ON-DEVICE VAULT',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1.4,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
