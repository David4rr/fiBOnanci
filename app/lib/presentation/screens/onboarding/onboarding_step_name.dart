import 'package:flutter/material.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const OnboardingHeader(
          icon: Icons.waving_hand_rounded,
          question: 'Halo! Siapa namamu?',
          helper: 'Kami pakai untuk menyapamu di beranda aplikasi.',
        ),
        AppTextField(
          controller: controller,
          hintText: 'Nama lengkap (contoh: Budi Santoso)',
          prefixIcon: const Icon(Icons.person_outline_rounded),
          textCapitalization: TextCapitalization.words,
        ),
      ],
    );
  }
}
