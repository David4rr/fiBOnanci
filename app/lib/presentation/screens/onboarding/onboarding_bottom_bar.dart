import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/common_widgets.dart';

class OnboardingBottomBar extends StatelessWidget {
  final int currentStep;
  final bool canContinue;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const OnboardingBottomBar({
    super.key,
    required this.currentStep,
    required this.canContinue,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (currentStep == 2)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TextButton(
                onPressed: onSkip,
                child: const Text(
                  'Lewati',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13.5),
                ),
              ),
            ),
          PrimaryActionButton(
            text: currentStep == 4 ? 'Mulai Aplikasi' : 'Lanjut',
            icon: currentStep == 4
                ? Icons.check_circle_rounded
                : Icons.arrow_forward_rounded,
            onPressed: canContinue ? onNext : null,
          ),
        ],
      ),
    );
  }
}
