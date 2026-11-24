import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class OnboardingTopBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final VoidCallback onBack;

  const OnboardingTopBar({
    super.key,
    required this.currentStep,
    this.totalSteps = 5,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (currentStep + 1) / totalSteps.toDouble(),
              minHeight: 4,
              backgroundColor: AppColors.canvasCardSurface,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.neoChartreuse),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_rounded, color: AppColors.textWhite, size: 22),
                onPressed: onBack,
              ),
              const Spacer(),
              Text(
                currentStep == totalSteps - 1
                    ? 'Siap!'
                    : 'Langkah ${currentStep + 1} dari $totalSteps',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
        ),
      ],
    );
  }
}
