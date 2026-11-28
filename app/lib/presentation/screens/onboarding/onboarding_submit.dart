import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/finance/finance_bloc.dart';
import '../../../bloc/finance/finance_event.dart';
import '../../../core/formatters/rupiah_input_formatter.dart';
import '../../../core/storage/profile_preferences_storage.dart';
import 'onboarding_screen.dart';

class OnboardingSubmit {
  static Future<void> openNewProfile(BuildContext context) {
    final bloc = context.read<FinanceBloc>();
    return Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (ctx) => BlocProvider.value(
          value: bloc,
          child: OnboardingScreen(
            isNewProfile: true,
            onComplete: () => Navigator.of(ctx).pop(),
          ),
        ),
      ),
    );
  }

  static Future<void> execute({
    required BuildContext context,
    required String fullName,
    required String username,
    required String occupation,
    required String incomeText,
    required String walletName,
    required String walletType,
    required String balanceText,
    required VoidCallback onComplete,
    bool isNewProfile = false,
  }) async {
    final name = fullName.trim().isEmpty ? 'Pengguna' : fullName.trim();
    final uname = username.trim().isEmpty
        ? name.toLowerCase().replaceAll(' ', '_')
        : username.trim();
    final occ = occupation.trim().isEmpty ? null : occupation.trim();
    final income = RupiahInputFormatter.parse(incomeText.trim());
    final wName = walletName.trim().isEmpty ? 'Rekening Utama' : walletName.trim();
    final balance = RupiahInputFormatter.parse(balanceText.trim());
    final isCash = walletType == 'cash';
    final isEwallet = walletType == 'ewallet';
    final colorHex = isCash ? '#10B981' : (isEwallet ? '#26D9D9' : '#0060AF');
    final iconName = isCash ? 'wallet' : (isEwallet ? 'smartphone' : 'landmark');

    final bloc = context.read<FinanceBloc>();
    if (isNewProfile) {
      bloc.add(OnboardNewProfileEvent(
        username: uname,
        fullName: name,
        occupation: occ,
        monthlyIncomeTarget: income > 0 ? income : null,
        avatarPath: 'preset:avatar_1',
        currency: 'IDR',
        walletName: wName,
        walletType: walletType,
        initialBalance: balance,
        colorHex: colorHex,
        iconName: iconName,
        createInitialTransaction: balance > 0,
      ));
      onComplete();
      return;
    }

    final pId = (bloc.state.activeProfile?.id != null &&
            bloc.state.activeProfile!.id.isNotEmpty &&
            bloc.state.activeProfile!.id != 'default_fallback')
        ? bloc.state.activeProfile!.id
        : (bloc.state.profiles.where((p) => p.isActive).firstOrNull?.id ??
            'default_profile_1');

    bloc.add(UpdateProfileEvent(
      profileId: pId,
      fullName: name,
      username: uname,
      occupation: occ,
      monthlyIncomeTarget: income > 0 ? income : null,
      avatarPath: 'preset:avatar_1',
      currency: 'IDR',
    ));

    bloc.add(AddWalletEvent(
      name: wName,
      type: walletType,
      initialBalance: balance,
      colorHex: colorHex,
      iconName: iconName,
      createInitialTransaction: balance > 0,
    ));

    await ProfilePreferencesStorage.setOnboardingCompleted(true);
    onComplete();
  }
}
