import 'package:flutter/material.dart';

/// Clean offline-safe Ko-fi button featuring the Ko-fi cup & heart mark.
class KofiSupportButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final double height;

  const KofiSupportButton({
    super.key,
    required this.label,
    required this.onTap,
    this.height = 50,
  });

  static const Color kofiRed = Color(0xFFFF5E5B);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kofiRed,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 26,
                height: 20,
                child: CustomPaint(painter: _KofiCupPainter()),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KofiCupPainter extends CustomPainter {
  const _KofiCupPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cupPaint = Paint()..color = Colors.white..style = PaintingStyle.fill;

    // Mug body
    final cupRect = RRect.fromLTRBAndCorners(
      w * 0.08,
      h * 0.12,
      w * 0.74,
      h * 0.90,
      topLeft: const Radius.circular(2),
      topRight: const Radius.circular(2),
      bottomLeft: Radius.circular(w * 0.24),
      bottomRight: Radius.circular(w * 0.24),
    );
    canvas.drawRRect(cupRect, cupPaint);

    // Mug handle
    final handlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.10
      ..strokeCap = StrokeCap.round;
    final handleRect = Rect.fromLTRB(w * 0.68, h * 0.24, w * 0.92, h * 0.64);
    canvas.drawArc(handleRect, -1.4, 2.8, false, handlePaint);

    // Heart inside mug
    final cx = w * 0.41;
    final cy = h * 0.50;
    final hs = w * 0.14;
    final heart = Path()
      ..moveTo(cx, cy + hs * 0.85)
      ..cubicTo(cx - hs * 1.3, cy + hs * 0.1, cx - hs * 1.1, cy - hs * 0.9, cx, cy - hs * 0.25)
      ..cubicTo(cx + hs * 1.1, cy - hs * 0.9, cx + hs * 1.3, cy + hs * 0.1, cx, cy + hs * 0.85)
      ..close();
    canvas.drawPath(heart, Paint()..color = KofiSupportButton.kofiRed);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
