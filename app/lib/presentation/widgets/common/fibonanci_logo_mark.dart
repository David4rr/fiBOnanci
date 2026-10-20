import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Pure Mathematical "The Phi Vault" (Φ = 1.618) Logo Mark for fiBOnanci.
///
/// Features a central monolithic pillar flanked by dual symmetrical vault gates
/// with exact Fibonacci sequence proportions (34, 55, 89, 210).
class FibonanciLogoMark extends StatelessWidget {
  final double size;
  final double morphProgress;
  final bool showGlow;
  final Color? color;

  const FibonanciLogoMark({
    super.key,
    this.size = 64.0,
    this.morphProgress = 1.0,
    this.showGlow = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _FibonanciPhiVaultPainter(
          progress: morphProgress.clamp(0.0, 1.0),
          showGlow: showGlow,
          overrideColor: color,
        ),
      ),
    );
  }
}

class _FibonanciPhiVaultPainter extends CustomPainter {
  final double progress;
  final bool showGlow;
  final Color? overrideColor;

  static final Path _leftGatePath = Path()
    ..moveTo(97.0, 39.0)
    ..arcToPoint(
      const Offset(97.0, 217.0),
      radius: const Radius.circular(89.0),
      clockwise: false,
    )
    ..lineTo(97.0, 183.0)
    ..arcToPoint(
      const Offset(97.0, 73.0),
      radius: const Radius.circular(55.0),
      clockwise: true,
    )
    ..close();

  static final Path _rightGatePath = Path()
    ..moveTo(159.0, 39.0)
    ..arcToPoint(
      const Offset(159.0, 217.0),
      radius: const Radius.circular(89.0),
      clockwise: true,
    )
    ..lineTo(159.0, 183.0)
    ..arcToPoint(
      const Offset(159.0, 73.0),
      radius: const Radius.circular(55.0),
      clockwise: false,
    )
    ..close();

  static final Shader _defaultShader = ui.Gradient.linear(
    const Offset(128.0 - 89.0, 128.0 - 89.0),
    const Offset(128.0 + 89.0, 128.0 + 89.0),
    const [AppColors.neoMint, AppColors.neoChartreuse],
  );

  const _FibonanciPhiVaultPainter({
    required this.progress,
    required this.showGlow,
    this.overrideColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 256.0;
    canvas.save();
    canvas.scale(s, s);

    const cx = 128.0, cy = 128.0;
    final pillarT = Curves.easeOutCubic.transform(
      (progress / 0.55).clamp(0.0, 1.0),
    );
    final gateT = Curves.easeOutBack.transform(
      ((progress - 0.25) / 0.75).clamp(0.0, 1.0),
    );

    if (showGlow && progress > 0.08) {
      final glowPaint = Paint()
        ..color = (overrideColor ?? AppColors.neoChartreuse).withValues(
          alpha: 0.20 * progress,
        )
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 256.0 * 0.26);
      canvas.drawCircle(const Offset(cx, cy), 256.0 * 0.36 * progress, glowPaint);
    }

    final fillPaint = Paint()..style = PaintingStyle.fill;
    if (overrideColor != null) {
      fillPaint.color = overrideColor!;
    } else {
      fillPaint.shader = _defaultShader;
    }

    if (pillarT > 0.01) {
      final pillarH = 210.0 * pillarT;
      final cornerRadius = 17.0.clamp(1.0, pillarH * 0.5);
      final pillarRect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: const Offset(cx, cy), width: 34.0, height: pillarH),
        Radius.circular(cornerRadius),
      );
      canvas.drawRRect(pillarRect, fillPaint);
    }

    if (gateT > 0.01) {
      final gateOffset = (1.0 - gateT) * 24.0;
      final gateScale = ui.lerpDouble(0.72, 1.0, gateT)!;

      canvas.save();
      canvas.translate(cx, cy);
      canvas.scale(gateScale, gateScale);
      canvas.translate(-cx + gateOffset, -cy);
      canvas.drawPath(_leftGatePath, fillPaint);
      canvas.restore();

      canvas.save();
      canvas.translate(cx, cy);
      canvas.scale(gateScale, gateScale);
      canvas.translate(-cx - gateOffset, -cy);
      canvas.drawPath(_rightGatePath, fillPaint);
      canvas.restore();
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _FibonanciPhiVaultPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.showGlow != showGlow ||
      oldDelegate.overrideColor != overrideColor;
}
