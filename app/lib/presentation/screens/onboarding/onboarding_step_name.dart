import 'package:flutter/material.dart';
import '../../../core/l10n/locale_notifier.dart';
import '../../widgets/common/app_text_field.dart';
import 'onboarding_header.dart';

class OnboardingStepName extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onNext;

  const OnboardingStepName({
    super.key,
    required this.controller,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OnboardingHeader(
          lottieAsset: 'assets/lottie/onb_name.json',
          question: l10n.onbNameQuestion,
          helper: l10n.onbNameHelper,
        ),
        AppTextField(
          controller: controller,
          hintText: l10n.onbNameHint,
          prefixIcon: const Icon(Icons.person_outline_rounded),
          textCapitalization: TextCapitalization.words,
        ),
      ],
    );
  }
}
