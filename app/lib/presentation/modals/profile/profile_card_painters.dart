import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

class ProfileWaveChartPainter extends CustomPainter {
  final List<double> scores;
  final Color strokeColor;

  const ProfileWaveChartPainter({required this.scores, this.strokeColor = AppColors.neoChartreuse});

  @override
  void paint(Canvas canvas, Size size) {
    if (scores.isEmpty) return;
    final strokePaint = Paint()..color = strokeColor..strokeWidth = 2.0..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    final points = <Offset>[];
    final n = scores.length;
    for (int i = 0; i < n; i++) {
      final x = n == 1 ? size.width / 2 : size.width * (i / (n - 1));
      final s = scores[i].clamp(0.0, 100.0);
      points.add(Offset(x, size.height * (0.88 - 0.76 * (s / 100.0))));
    }
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    if (points.length == 1) {
      path.lineTo(size.width, points.first.dy);
    } else {
      for (int i = 0; i < points.length - 1; i++) {
        final p0 = points[i];
        final p1 = points[i + 1];
        final midX = (p0.dx + p1.dx) / 2;
        path.cubicTo(midX, p0.dy, midX, p1.dy, p1.dx, p1.dy);
      }
    }
    final fillPath = Path.from(path)..lineTo(size.width, size.height)..lineTo(0, size.height)..close();
    final fillPaint = Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [strokeColor.withValues(alpha: 0.35), strokeColor.withValues(alpha: 0.0)]).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, strokePaint);
    int peakIdx = 0;
    double maxScore = scores[0];
    for (int i = 1; i < scores.length; i++) {
      if (scores[i] >= maxScore) { maxScore = scores[i]; peakIdx = i; }
    }
    final peak = points[peakIdx];
    canvas.drawCircle(peak, 5.0, Paint()..color = strokeColor.withValues(alpha: 0.35));
    canvas.drawCircle(peak, 2.5, Paint()..color = strokeColor);
  }

  @override
  bool shouldRepaint(covariant ProfileWaveChartPainter oldDelegate) => oldDelegate.scores != scores || oldDelegate.strokeColor != strokeColor;
}

class FinancialShieldPainter extends CustomPainter {
  const FinancialShieldPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.neoChartreuse
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width * 0.5, 0)
      ..lineTo(size.width, size.height * 0.25)
      ..lineTo(size.width * 0.82, size.height * 0.75)
      ..lineTo(size.width * 0.5, size.height)
      ..lineTo(size.width * 0.18, size.height * 0.75)
      ..lineTo(0, size.height * 0.25)
      ..close();

    canvas.drawPath(path, paint);

    final checkPaint = Paint()
      ..color = const Color(0xFF0C0D11)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final check = Path()
      ..moveTo(size.width * 0.32, size.height * 0.50)
      ..lineTo(size.width * 0.46, size.height * 0.65)
      ..lineTo(size.width * 0.70, size.height * 0.35);

    canvas.drawPath(check, checkPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ProfileFinancialTimelinePill extends StatelessWidget {
  final double realBalance;
  final double pendingBills;
  final double safeToSpend;

  const ProfileFinancialTimelinePill({
    super.key,
    required this.realBalance,
    required this.pendingBills,
    required this.safeToSpend,
  });

  String _formatCompact(double val) {
    if (val >= 1000000) return 'Rp ${(val / 1000000).toStringAsFixed(1)} Jt';
    if (val >= 1000) return 'Rp ${(val / 1000).toStringAsFixed(0)} Rb';
    return 'Rp ${val.toStringAsFixed(0)}';
  }

  Widget _buildTrackSegment(int leadingDots, bool hasSolidBar, int trailingDots) {
    const ink = Color(0xFF0C0D11);
    return SizedBox(
      height: 3,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 0; i < leadingDots; i++) ...[
            Container(width: 1.8, height: 1.8, decoration: const BoxDecoration(color: ink, shape: BoxShape.circle)),
            const SizedBox(width: 2.2),
          ],
          if (hasSolidBar) Container(width: 26, height: 2.5, decoration: BoxDecoration(color: ink, borderRadius: BorderRadius.circular(1))),
          for (int i = 0; i < trailingDots; i++) ...[
            const SizedBox(width: 2.2),
            Container(width: 1.8, height: 1.8, decoration: const BoxDecoration(color: ink, shape: BoxShape.circle)),
          ],
        ],
      ),
    );
  }

  Widget _buildCol(String title, String val, Widget track) {
    const ink = Color(0xFF0C0D11);
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 9.5, fontWeight: FontWeight.w800, color: ink, letterSpacing: 0.3)),
          const SizedBox(height: 3),
          track,
          const SizedBox(height: 3),
          Text(val, style: GoogleFonts.plusJakartaSans(fontSize: 9.5, fontWeight: FontWeight.w700, color: ink, fontFeatures: const [FontFeature.tabularFigures()])),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(color: AppColors.neoChartreuse, borderRadius: BorderRadius.circular(22)),
      child: Row(
        children: [
          _buildCol('SALDO RIIL', _formatCompact(realBalance), _buildTrackSegment(4, true, 0)),
          _buildCol('TAGIHAN', _formatCompact(pendingBills), _buildTrackSegment(2, true, 2)),
          _buildCol('SISA AMAN', _formatCompact(safeToSpend), _buildTrackSegment(0, true, 4)),
        ],
      ),
    );
  }
}

/// Proportional three-dot multitasking indicator matching iPadOS reference design.
class ProportionalThreeDots extends StatelessWidget {
  final VoidCallback onTap;
  const ProportionalThreeDots({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 44,
        height: 24,
        alignment: Alignment.center,
        color: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(Icons.more_horiz_rounded, size: 24, color: Colors.transparent),
            IgnorePointer(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  3,
                  (i) => Container(
                    margin: EdgeInsets.only(left: i > 0 ? 5.5 : 0.0),
                    width: 7.0,
                    height: 7.0,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF8E92A0)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
