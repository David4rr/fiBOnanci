import 'package:flutter/material.dart';
import '../../../core/l10n/locale_notifier.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/app_text_field.dart';
import 'onboarding_header.dart';

class OnboardingStepUsername extends StatelessWidget {
  final String firstName;
  final TextEditingController usernameController;
  final TextEditingController occupationController;
  final VoidCallback onNext;

  const OnboardingStepUsername({
    super.key,
    required this.firstName,
    required this.usernameController,
    required this.occupationController,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final displayFirst = firstName.trim().isEmpty ? 'kawan' : firstName.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OnboardingHeader(
          lottieAsset: 'assets/lottie/onb_username.json',
          question: l10n.onbUsernameQuestion(displayFirst),
          helper: l10n.onbUsernameHelper,
          iconColor: AppColors.neoMint,
        ),
        AppTextField(
          controller: usernameController,
          hintText: l10n.onbUsernameHint,
          prefixIcon: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            child: Text(
              '@',
              style: TextStyle(
                color: AppColors.neoMint,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          onChanged: (val) {
            final clean = val.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]'), '');
            if (clean != val) {
              usernameController.value = TextEditingValue(
                text: clean,
                selection: TextSelection.collapsed(offset: clean.length),
              );
            }
          },
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            l10n.onbUsernameRule,
            style: TextStyle(color: AppColors.textMuted, fontSize: 11.5),
          ),
        ),
        const SizedBox(height: 18),
        AppTextField(
          controller: occupationController,
          hintText: l10n.onbOccupationHint,
          prefixIcon: const Icon(Icons.work_outline_rounded),
          textCapitalization: TextCapitalization.sentences,
        ),
      ],
    );
  }
}
