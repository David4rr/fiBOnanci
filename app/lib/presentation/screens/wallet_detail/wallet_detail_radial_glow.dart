import 'package:flutter/material.dart';

class WalletDetailRadialGlow extends StatelessWidget {
  final Color cardColor;

  const WalletDetailRadialGlow({super.key, required this.cardColor});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -90,
      left: -60,
      right: -60,
      height: 420,
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topCenter,
              radius: 0.85,
              colors: [
                cardColor.withValues(alpha: 0.22),
                cardColor.withValues(alpha: 0.06),
                Colors.transparent,
              ],
              stops: const [0.0, 0.40, 1.0],
            ),
          ),
        ),
      ),
    );
  }
}
