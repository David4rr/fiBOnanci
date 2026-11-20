import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class OnboardingHeader extends StatelessWidget {
  final IconData icon;
  final String question;
  final String helper;
  final Color? iconColor;

  const OnboardingHeader({
    super.key,
    required this.icon,
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
          child: Icon(icon, color: effectiveColor, size: 28),
        ),
        const SizedBox(height: 24),
        Text(
          question,
          style: AppTypography.heroGreeting.copyWith(
            fontSize: 26,
            height: 1.25,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          helper,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 28),
      ],
    );
  }
}
