import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/finance/finance_bloc.dart';
import '../../../bloc/finance/finance_event.dart';
import '../../../bloc/finance/finance_state.dart';
import '../../../core/l10n/locale_notifier.dart';
import '../../../core/notification_parser/bank_presets.dart';
import '../../theme/app_colors.dart';
import 'settings_style.dart';

class SettingsDeleteProfileSubPage extends StatelessWidget {
  final FinanceState state;
  final VoidCallback onDeleted;
  const SettingsDeleteProfileSubPage({super.key, required this.state, required this.onDeleted});

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final isMulti = state.profiles.length > 1;
    final u = state.profile.username;
    return ListView(padding: const EdgeInsets.fromLTRB(24, 16, 24, 48), children: [
      Text(
        isMulti
            ? l10n.settingsDeleteProfileMultiDesc(u)
            : l10n.settingsDeleteProfileSingleDesc(u),
        style: SettingsStyle.title,
      ),
      const SizedBox(height: 20),
      GestureDetector(
        key: const Key('settings_confirm_delete_profile_button'),
        onTap: () {
          context.read<FinanceBloc>().add(DeleteProfileEvent(state.profile.id));
          onDeleted();
        },
        child: Text(isMulti ? l10n.settingsDeleteProfileConfirm(u) : l10n.settingsResetProfileConfirm(u), style: SettingsStyle.accent.copyWith(color: AppColors.neoCoral)),
      ),
    ]);
  }
}

class SettingsBankAppsSubPage extends StatelessWidget {
  const SettingsBankAppsSubPage({super.key});
  @override
  Widget build(BuildContext context) => ListView.builder(
    physics: const BouncingScrollPhysics(),
    padding: const EdgeInsets.fromLTRB(24, 8, 24, 48),
    itemCount: kPopularBankAppPresets.length,
    itemBuilder: (_, i) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(kPopularBankAppPresets[i].name, style: SettingsStyle.title),
        Text(kPopularBankAppPresets[i].packageName, style: SettingsStyle.sub),
      ]),
    ),
  );
}

class SettingsClearTxSubPage extends StatelessWidget {
  final FinanceState state;
  final VoidCallback onCleared;
  const SettingsClearTxSubPage({super.key, required this.state, required this.onCleared});
  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return ListView(padding: const EdgeInsets.fromLTRB(24, 16, 24, 48), children: [
      Text(l10n.settingsClearTxDesc(state.profile.username), style: SettingsStyle.title),
      const SizedBox(height: 20),
      GestureDetector(
        key: const Key('settings_confirm_clear_tx_button'),
        onTap: () {
          context.read<FinanceBloc>().add(ClearProfileTransactionsEvent(state.profile.id));
          onCleared();
        },
        child: Text(l10n.settingsClearTxConfirm, style: SettingsStyle.accent.copyWith(color: AppColors.neoCoral)),
      ),
    ]);
  }
}
