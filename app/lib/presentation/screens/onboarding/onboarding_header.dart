import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

bool get _isFlutterTest => !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');

class OnboardingHeader extends StatelessWidget {
  final IconData? icon;
  final String? lottieAsset;
  final String question;
  final String helper;
  final Color? iconColor;

  const OnboardingHeader({
    super.key,
    this.icon,
    this.lottieAsset,
    required this.question,
    required this.helper,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = iconColor ?? AppColors.neoChartreuse;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (lottieAsset != null)
          Center(
            child: SizedBox(
              height: 176,
              width: 220,
              child: Lottie.asset(
                lottieAsset!,
                height: 176,
                animate: !_isFlutterTest,
                repeat: true,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => Icon(
                  icon ?? Icons.auto_awesome,
                  color: effectiveColor,
                  size: 56,
                ),
              ),
            ),
          )
        else
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: effectiveColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: effectiveColor.withValues(alpha: 0.28),
                width: 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: Icon(icon ?? Icons.auto_awesome, color: effectiveColor, size: 28),
          ),
        const SizedBox(height: 18),
        Text(
          question,
          style: AppTypography.heroGreeting.copyWith(
            fontSize: 26,
            height: 1.22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          helper,
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 13.5,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
