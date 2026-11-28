import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/formatters/rupiah_input_formatter.dart';
import '../../../core/l10n/locale_notifier.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/currency_amount_field.dart';
import 'onboarding_header.dart';

class OnboardingStepIncome extends StatefulWidget {
  final TextEditingController incomeController;
  final VoidCallback onNext;

  const OnboardingStepIncome({
    super.key,
    required this.incomeController,
    required this.onNext,
  });

  @override
  State<OnboardingStepIncome> createState() => _OnboardingStepIncomeState();
}

class _OnboardingStepIncomeState extends State<OnboardingStepIncome> {
  @override
  void initState() {
    super.initState();
    widget.incomeController.addListener(_onChanged);
  }

  @override
  void dispose() {
    widget.incomeController.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final parsed = RupiahInputFormatter.parse(widget.incomeController.text.trim());
    final perDay = parsed > 0 ? (parsed / 30).round() : 0;
    final formattedDaily = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(perDay);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OnboardingHeader(
          lottieAsset: 'assets/lottie/onb_income.json',
          question: AppL10n.of(context).onbIncomeQuestion,
          helper: AppL10n.of(context).onbIncomeHelper,
          iconColor: AppColors.neoCyan,
        ),
        CurrencyAmountField(
          controller: widget.incomeController,
          labelText: AppL10n.of(context).onbIncomeLabel,
          hintText: '0',
        ),
        const SizedBox(height: 12),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: parsed > 0
              ? Container(
                  key: const ValueKey(true),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.canvasCardSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.canvasBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        size: 16,
                        color: AppColors.neoCyan,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppL10n.of(context).onbIncomePerDay(formattedDaily),
                        style: TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(key: ValueKey(false)),
        ),
      ],
    );
  }
}
