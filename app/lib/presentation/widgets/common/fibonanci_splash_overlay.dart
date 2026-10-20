import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import 'fibonanci_logo_mark.dart';

/// Presentation overlay for the 3-Stage fiBOnanci Splash Gate with a
/// shared-element flight for both logo mark and wordmark text from screen
/// center to the home dashboard header.
class FibonanciSplashOverlay extends StatefulWidget {
  final Animation<double> animation;
  final GlobalKey? targetKey;
  final GlobalKey? targetTextKey;

  const FibonanciSplashOverlay({
    super.key,
    required this.animation,
    this.targetKey,
    this.targetTextKey,
  });

  @override
  State<FibonanciSplashOverlay> createState() => _FibonanciSplashOverlayState();
}

class _FibonanciSplashOverlayState extends State<FibonanciSplashOverlay> {
  static final TextStyle _startTextStyle = GoogleFonts.plusJakartaSans(
    fontSize: 28.0,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.9,
    height: 1.2,
    color: AppColors.textWhite,
  );
  static final TextStyle _targetTextStyle = AppTypography.heroGreeting;

  Offset? _cachedDestOffset;
  double _cachedDestSize = 24.0;
  Offset? _cachedDestTextOffset;

  void _resolveTargetOffsets(EdgeInsets padding) {
    if (_cachedDestOffset == null && widget.targetKey != null) {
      final box = widget.targetKey!.currentContext?.findRenderObject() as RenderBox?;
      if (box != null && box.hasSize && box.attached) {
        _cachedDestOffset = box.localToGlobal(Offset.zero);
        _cachedDestSize = box.size.width;
      }
    }
    if (_cachedDestTextOffset == null && widget.targetTextKey != null) {
      final textBox = widget.targetTextKey!.currentContext?.findRenderObject() as RenderBox?;
      if (textBox != null && textBox.hasSize && textBox.attached) {
        _cachedDestTextOffset = textBox.localToGlobal(Offset.zero);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animation,
      builder: (context, _) {
        final t = widget.animation.value;
        final morphT = (t / 0.48).clamp(0.0, 1.0);
        final pulseT = ((t - 0.28) / 0.20).clamp(0.0, 1.0);
        final logoPulse = 1.0 + (math.sin(pulseT * math.pi) * 0.045);

        final textInT = Curves.easeOutCubic.transform(
          ((t - 0.20) / 0.24).clamp(0.0, 1.0),
        );
        final subExitT = Curves.easeInCubic.transform(
          ((t - 0.48) / 0.12).clamp(0.0, 1.0),
        );
        final subOpacity = (textInT * (1.0 - subExitT)).clamp(0.0, 1.0);

        final curtainExitT = Curves.easeInOutCubic.transform(
          ((t - 0.50) / 0.44).clamp(0.0, 1.0),
        );
        final curtainOpacity = (1.0 - curtainExitT).clamp(0.0, 1.0);

        final flightT = ((t - 0.48) / 0.48).clamp(0.0, 1.0);
        final flightCurve = Curves.easeInOutCubic.transform(flightT);
        final screenSize = MediaQuery.sizeOf(context);
        final padding = MediaQuery.paddingOf(context);
        const startSize = 104.0;
        final startX = (screenSize.width - startSize) / 2;
        final startY = (screenSize.height - 182.0) / 2;

        _resolveTargetOffsets(padding);
        final destOffset = _cachedDestOffset ?? Offset(20.0, padding.top + 16.0);
        final destSize = _cachedDestSize;
        final destTextOffset = _cachedDestTextOffset ??
            Offset(destOffset.dx + destSize + 8.0, destOffset.dy - 1.0);

        final currentSize = ui.lerpDouble(startSize * logoPulse, destSize, flightCurve)!;
        final currentX = ui.lerpDouble(startX, destOffset.dx, flightCurve)!;
        final currentY = ui.lerpDouble(startY, destOffset.dy, flightCurve)!;
        final showGlow = t <= 0.48;

        const startTextWidth = 132.0;
        final startTextX = (screenSize.width - startTextWidth) / 2;
        final startTextY = startY + startSize + 24.0;
        final initialSlideY = 12.0 * (1.0 - textInT);

        final currentTextX = ui.lerpDouble(startTextX, destTextOffset.dx, flightCurve)!;
        final currentTextY = ui.lerpDouble(
          startTextY + initialSlideY,
          destTextOffset.dy,
          flightCurve,
        )!;

        final currentTextStyle = TextStyle.lerp(_startTextStyle, _targetTextStyle, flightCurve)!;

        return IgnorePointer(
          ignoring: t > 0.70,
          child: Material(
            key: const Key('fibonanci_splash_overlay'),
            color: Colors.transparent,
            child: Stack(
              children: [
                if (curtainOpacity > 0.0)
                  Positioned.fill(
                    child: ColoredBox(
                      color: AppColors.canvasBg.withValues(alpha: curtainOpacity),
                    ),
                  ),
                if (subOpacity > 0.0)
                  Positioned(
                    left: 0,
                    right: 0,
                    top: startTextY + 38.0 + initialSlideY,
                    child: Text(
                      'φ 1.618 • ON-DEVICE VAULT',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2.2,
                        color: AppColors.textMuted.withValues(alpha: subOpacity),
                      ),
                    ),
                  ),
                if (textInT > 0.0)
                  Positioned(
                    left: currentTextX,
                    top: currentTextY,
                    child: RichText(
                      key: const Key('fibonanci_splash_text'),
                      text: TextSpan(
                        style: currentTextStyle.copyWith(
                          color: currentTextStyle.color?.withValues(alpha: textInT),
                        ),
                        children: [
                          const TextSpan(text: 'fi'),
                          TextSpan(
                            text: 'BO',
                            style: TextStyle(
                              color: AppColors.neoChartreuse.withValues(alpha: textInT),
                            ),
                          ),
                          const TextSpan(text: 'nanci'),
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
