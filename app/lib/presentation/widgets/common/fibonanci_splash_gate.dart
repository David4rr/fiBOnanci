import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import 'fibonanci_logo_mark.dart';

/// 3-Stage Mathematical Vault Splash Screen Gate for fiBOnanci.
/// - Stage 1 (0.00 - 0.58): Central monolith rises & dual vault gates slide open
/// - Stage 2 (0.34 - 0.60): Biometric breathing pulse + fiBOnanci wordmark reveal
/// - Stage 3 (0.58 - 1.00): Luxurious depth cross-dissolve & parallel rise into MainShell
class FibonanciSplashGate extends StatefulWidget {
  static final ValueNotifier<bool> isSplashActive = ValueNotifier<bool>(false);
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
              ((t - 0.58) / 0.42).clamp(0.0, 1.0),
            );
            final scale = ui.lerpDouble(0.93, 1.0, enterT)!;
            final translateY = ui.lerpDouble(24.0, 0.0, enterT)!;

            return Transform.translate(
              offset: Offset(0, translateY),
              child: Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: enterT,
                  child: widget.child,
                ),
              ),
            );
          },
        ),
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final t = _controller.value;
              final morphT = ((t) / 0.58).clamp(0.0, 1.0);
              final textT = Curves.easeOutCubic.transform(
                ((t - 0.24) / 0.34).clamp(0.0, 1.0),
              );
              final exitT = Curves.easeInOutCubic.transform(
                ((t - 0.58) / 0.42).clamp(0.0, 1.0),
              );
              final curtainOpacity = (1.0 - exitT).clamp(0.0, 1.0);
              final exitScale = ui.lerpDouble(1.0, 1.10, exitT)!;
              final exitTranslateY = ui.lerpDouble(0.0, -28.0, exitT)!;

              final pulseT = ((t - 0.34) / 0.26).clamp(0.0, 1.0);
              final logoPulse = 1.0 + (math.sin(pulseT * math.pi) * 0.045);

              return IgnorePointer(
                ignoring: t > 0.70,
                child: Opacity(
                  opacity: curtainOpacity,
                  child: Material(
                    key: const Key('fibonanci_splash_overlay'),
                    color: AppColors.canvasBg,
                    child: Transform.translate(
                      offset: Offset(0, exitTranslateY),
                      child: Transform.scale(
                        scale: exitScale,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Transform.scale(
                                scale: logoPulse,
                                child: FibonanciLogoMark(
                                  key: const Key('fibonanci_splash_logo'),
                                  size: 104,
                                  morphProgress: morphT,
                                  showGlow: true,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Opacity(
                                opacity: textT,
                                child: Transform.translate(
                                  offset: Offset(0, 14 * (1.0 - textT)),
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
                                          letterSpacing: 2.2,
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
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
