import 'package:flutter/material.dart';
import '../../../core/l10n/locale_notifier.dart';
import '../../theme/app_colors.dart';

class OnboardingBottomBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final bool canContinue;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const OnboardingBottomBar({
    super.key,
    required this.currentStep,
    this.totalSteps = 5,
    required this.canContinue,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final label = currentStep == totalSteps - 1 ? l10n.onbStartApp : l10n.onbContinue;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 10, 20, 22),
      child: Row(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(totalSteps, (idx) {
              final active = idx == currentStep;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                margin: const EdgeInsets.only(right: 6),
                width: active ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: active
                      ? AppColors.neoChartreuse
                      : AppColors.textMuted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
          const Spacer(),
          if (currentStep == 2)
            TextButton(
              onPressed: onSkip,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textMuted,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              child: Text(l10n.onbSkip, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
            ),
          TextButton(
            onPressed: canContinue ? onNext : null,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.neoChartreuse,
              disabledForegroundColor: AppColors.textMuted.withValues(alpha: 0.35),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(width: 6),
                const Icon(Icons.play_arrow_rounded, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
