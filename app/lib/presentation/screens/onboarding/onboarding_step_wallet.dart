import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/l10n/locale_notifier.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/currency_amount_field.dart';
import 'onboarding_header.dart';

class OnboardingWalletSuggestion {
  final String name;
  final String type;
  const OnboardingWalletSuggestion(this.name, this.type);
}

const List<OnboardingWalletSuggestion> kWalletSuggestions = [
  OnboardingWalletSuggestion('BCA', 'bank'),
  OnboardingWalletSuggestion('Mandiri', 'bank'),
  OnboardingWalletSuggestion('BRI', 'bank'),
  OnboardingWalletSuggestion('BNI', 'bank'),
  OnboardingWalletSuggestion('Jago', 'bank'),
  OnboardingWalletSuggestion('SeaBank', 'bank'),
  OnboardingWalletSuggestion('GoPay', 'ewallet'),
  OnboardingWalletSuggestion('OVO', 'ewallet'),
  OnboardingWalletSuggestion('DANA', 'ewallet'),
  OnboardingWalletSuggestion('Tunai', 'cash'),
];

class OnboardingStepWallet extends StatelessWidget {
  final TextEditingController walletNameController;
  final String walletType;
  final ValueChanged<String> onWalletTypeChanged;
  final TextEditingController balanceController;
  final VoidCallback onNext;

  const OnboardingStepWallet({
    super.key,
    required this.walletNameController,
    required this.walletType,
    required this.onWalletTypeChanged,
    required this.balanceController,
    required this.onNext,
  });

  Widget _buildTypeToggle(String type, String label, IconData icon) {
    final isSelected = walletType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onWalletTypeChanged(type);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.neoChartreuse : AppColors.canvasCardSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.neoChartreuse : AppColors.canvasBorder,
            ),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 15,
                    color: isSelected ? AppColors.textDarkPrimary : AppColors.textWhite,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? AppColors.textDarkPrimary : AppColors.textWhite,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OnboardingHeader(
          lottieAsset: 'assets/lottie/onb_wallet.json',
          question: l10n.onboardingWalletQuestion,
          helper: l10n.onboardingWalletHelper,
          iconColor: AppColors.neoCoral,
        ),
        AppTextField(
          controller: walletNameController,
          hintText: l10n.onboardingWalletHint,
          prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: kWalletSuggestions.map((s) {
            final label = s.type == 'cash' ? l10n.onboardingWalletTypeCash : s.name;
            final isSelected = walletNameController.text == label;
            return InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                walletNameController.text = label;
                onWalletTypeChanged(s.type);
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.canvasCardSurface : AppColors.canvasBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.neoChartreuse : AppColors.canvasBorder,
                  ),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? AppColors.textAccent : AppColors.textMuted,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 18),
        Text(
          l10n.onboardingWalletTypeLabel,
          style: TextStyle(color: AppColors.textMuted, fontSize: 12.5, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildTypeToggle('bank', 'Bank', Icons.account_balance_rounded),
            const SizedBox(width: 8),
            _buildTypeToggle('ewallet', 'E-wallet', Icons.smartphone_rounded),
            const SizedBox(width: 8),
            _buildTypeToggle('cash', l10n.onboardingWalletTypeCash, Icons.payments_rounded),
          ],
        ),
        const SizedBox(height: 20),
        CurrencyAmountField(
          controller: balanceController,
          labelText: l10n.onboardingWalletBalanceLabel,
          hintText: '0',
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            l10n.onboardingWalletBalanceHelper,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 11.5,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
