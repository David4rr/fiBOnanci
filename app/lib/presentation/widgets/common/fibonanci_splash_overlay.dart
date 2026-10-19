import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import 'fibonanci_logo_mark.dart';

/// Presentation overlay for the 3-Stage fiBOnanci Splash Gate with a
/// shared-element flight from screen center to the home dashboard header.
class FibonanciSplashOverlay extends StatelessWidget {
  final Animation<double> animation;
  final GlobalKey? targetKey;

  const FibonanciSplashOverlay({
    super.key,
    required this.animation,
    this.targetKey,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = animation.value;
        final morphT = (t / 0.48).clamp(0.0, 1.0);
        final pulseT = ((t - 0.28) / 0.20).clamp(0.0, 1.0);
        final logoPulse = 1.0 + (math.sin(pulseT * math.pi) * 0.045);

        final textInT = Curves.easeOutCubic.transform(
          ((t - 0.20) / 0.24).clamp(0.0, 1.0),
        );
        final textOutT = Curves.easeInCubic.transform(
          ((t - 0.48) / 0.16).clamp(0.0, 1.0),
        );
        final textOpacity = (textInT * (1.0 - textOutT)).clamp(0.0, 1.0);

        final curtainExitT = Curves.easeInOutCubic.transform(
          ((t - 0.52) / 0.40).clamp(0.0, 1.0),
        );
        final curtainOpacity = (1.0 - curtainExitT).clamp(0.0, 1.0);

        final flightT = ((t - 0.48) / 0.44).clamp(0.0, 1.0);
        final flightCurve = Curves.easeInOutCubic.transform(flightT);

        final mediaQuery = MediaQuery.of(context);
        final screenSize = mediaQuery.size;
        const startSize = 104.0;
        final startX = (screenSize.width - startSize) / 2;
        final startY = (screenSize.height - 182.0) / 2;

        Offset destOffset;
        double destSize = 24.0;
        final targetBox = targetKey?.currentContext?.findRenderObject() as RenderBox?;
        if (targetBox != null && targetBox.hasSize && targetBox.attached) {
          destOffset = targetBox.localToGlobal(Offset.zero);
          destSize = targetBox.size.width;
        } else {
          destOffset = Offset(20.0, mediaQuery.padding.top + 16.0);
        }

        final currentSize = ui.lerpDouble(startSize * logoPulse, destSize, flightCurve)!;
        final currentX = ui.lerpDouble(startX, destOffset.dx, flightCurve)!;
        final arcOffsetY = -24.0 * math.sin(flightT * math.pi);
        final currentY = ui.lerpDouble(startY, destOffset.dy, flightCurve)! + arcOffsetY;
        final showGlow = flightT < 0.65;

        return IgnorePointer(
          ignoring: t > 0.70,
          child: Material(
            key: const Key('fibonanci_splash_overlay'),
            color: Colors.transparent,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Opacity(
                    opacity: curtainOpacity,
                    child: const ColoredBox(color: AppColors.canvasBg),
                  ),
                ),
                if (textOpacity > 0.0)
                  Positioned(
                    left: 0,
                    right: 0,
                    top: startY + startSize + 24.0 + (12.0 * (1.0 - textInT) + 8.0 * textOutT),
                    child: Opacity(
                      opacity: textOpacity,
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
                                  style: TextStyle(color: AppColors.neoChartreuse),
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
                Positioned(
                  left: currentX,
                  top: currentY,
                  width: currentSize,
                  height: currentSize,
                  child: FibonanciLogoMark(
                    key: const Key('fibonanci_splash_logo'),
                    size: currentSize,
                    morphProgress: morphT,
                    showGlow: showGlow,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
