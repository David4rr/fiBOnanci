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

  const _FibonanciPhiVaultPainter({
    required this.progress,
    required this.showGlow,
    this.overrideColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final s = w / 256.0;
    final cx = w * 0.5, cy = h * 0.5;

    // Stage 1 & 2 timing curves
    final pillarT = Curves.easeOutCubic.transform(
      (progress / 0.55).clamp(0.0, 1.0),
    );
    final gateT = Curves.easeOutBack.transform(
      ((progress - 0.25) / 0.75).clamp(0.0, 1.0),
    );

    // Subtle luminous aura
    if (showGlow && progress > 0.08) {
      final glowPaint = Paint()
        ..color = (overrideColor ?? AppColors.neoChartreuse).withValues(
          alpha: 0.20 * progress,
        )
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.26);
      canvas.drawCircle(Offset(cx, cy), w * 0.36 * progress, glowPaint);
    }

    final fillPaint = Paint()..style = PaintingStyle.fill;
    if (overrideColor != null) {
      fillPaint.color = overrideColor!;
    } else {
      fillPaint.shader = ui.Gradient.linear(
        Offset(cx - 89 * s, cy - 89 * s),
        Offset(cx + 89 * s, cy + 89 * s),
        const [AppColors.neoMint, AppColors.neoChartreuse],
      );
    }

    // Draw central monolith (grows from center origin)
    if (pillarT > 0.01) {
      final pillarH = 210.0 * s * pillarT;
      final cornerRadius = (17.0 * s).clamp(1.0, pillarH * 0.5);
      final pillarRect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy), width: 34.0 * s, height: pillarH),
        Radius.circular(cornerRadius),
      );
      canvas.drawRRect(pillarRect, fillPaint);
    }

    // Draw dual symmetrical vault gates (slide out from monolith)
    if (gateT > 0.01) {
      final gateOffset = (1.0 - gateT) * (24.0 * s);
      final gateScale = ui.lerpDouble(0.72, 1.0, gateT)!;

      // Left vault gate
      canvas.save();
      canvas.translate(cx, cy);
      canvas.scale(gateScale, gateScale);
      canvas.translate(-cx + gateOffset, -cy);
      canvas.drawPath(_buildLeftGate(cx, cy, s), fillPaint);
      canvas.restore();

      // Right vault gate
      canvas.save();
      canvas.translate(cx, cy);
      canvas.scale(gateScale, gateScale);
      canvas.translate(-cx - gateOffset, -cy);
      canvas.drawPath(_buildRightGate(cx, cy, s), fillPaint);
      canvas.restore();
    }
  }

  Path _buildLeftGate(double cx, double cy, double s) {
    return Path()
      ..moveTo(cx - 31.0 * s, cy - 89.0 * s)
      ..arcToPoint(
        Offset(cx - 31.0 * s, cy + 89.0 * s),
        radius: Radius.circular(89.0 * s),
        clockwise: false,
      )
      ..lineTo(cx - 31.0 * s, cy + 55.0 * s)
      ..arcToPoint(
        Offset(cx - 31.0 * s, cy - 55.0 * s),
        radius: Radius.circular(55.0 * s),
        clockwise: true,
      )
      ..close();
  }

  Path _buildRightGate(double cx, double cy, double s) {
    return Path()
      ..moveTo(cx + 31.0 * s, cy - 89.0 * s)
      ..arcToPoint(
        Offset(cx + 31.0 * s, cy + 89.0 * s),
        radius: Radius.circular(89.0 * s),
        clockwise: true,
      )
      ..lineTo(cx + 31.0 * s, cy + 55.0 * s)
      ..arcToPoint(
        Offset(cx + 31.0 * s, cy - 55.0 * s),
        radius: Radius.circular(55.0 * s),
        clockwise: false,
      )
      ..close();
  }

  @override
  bool shouldRepaint(covariant _FibonanciPhiVaultPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.showGlow != showGlow ||
      oldDelegate.overrideColor != overrideColor;
}
