import 'package:flutter/material.dart';
import '../../../core/l10n/locale_notifier.dart';
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
    return Padding(
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
                ? AppL10n.of(context).onbTopBarReady
                : AppL10n.of(context).onbTopBarStep(currentStep + 1, totalSteps),
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}
