import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/finance/finance_bloc.dart';
import '../../../bloc/finance/finance_event.dart';
import '../../../bloc/finance/finance_state.dart';
import '../../../core/l10n/locale_notifier.dart';
import '../../theme/app_colors.dart';
import 'profile_settings_tab.dart';

export 'settings_style.dart';

class SettingsBudgetCycleSection extends StatelessWidget {
  final FinanceState state;
  final ValueChanged<SettingsSubRoute> onNavigate;
  const SettingsBudgetCycleSection({super.key, required this.state, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final wallets = state.wallets;
    final selectedIds = state.safeToSpendWalletIds ?? const <String>{};
    final isAllWallets = state.metrics.isAllWallets;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SettingsStyle.menuRow(
        key: const Key('settings_cycle_day_menu_row'), title: l10n.settingsCycleDayTitle,
        valueText: l10n.settingsCycleDayValue(state.budgetCycleDay, state.metrics.daysRemainingInMonth),
        onTap: () => onNavigate(SettingsSubRoute.cycleDay),
      ),
      if (wallets.isNotEmpty)
        SettingsStyle.menuRow(
          key: const Key('settings_sts_wallets_menu_row'), title: l10n.settingsStsWalletsTitle,
          valueText: isAllWallets ? l10n.settingsAllCount(wallets.length) : l10n.settingsActiveCount(selectedIds.length),
          onTap: () => onNavigate(SettingsSubRoute.stsWallets),
        ),
    ]);
  }
}

class SettingsCycleDaySubPage extends StatefulWidget {
  final FinanceState state;
  const SettingsCycleDaySubPage({super.key, required this.state});
  @override
  State<SettingsCycleDaySubPage> createState() => _SettingsCycleDaySubPageState();
}

class _SettingsCycleDaySubPageState extends State<SettingsCycleDaySubPage> {
  static const _presets = [1, 5, 15, 25, 28];
  late TextEditingController _ctrl;

  @override
  void initState() { super.initState(); _ctrl = TextEditingController(text: '${widget.state.budgetCycleDay}'); }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _setDay(int d) {
    final clamped = d.clamp(1, 31);
    _ctrl.text = '$clamped';
    context.read<FinanceBloc>().add(SetBudgetCycleDayEvent(clamped));
  }

  @override
  Widget build(BuildContext context) {
    final cur = widget.state.budgetCycleDay;
    final l10n = AppL10n.of(context);
    return ListView(physics: const BouncingScrollPhysics(), padding: const EdgeInsets.fromLTRB(24, 12, 24, 48), children: [
      SettingsStyle.sectionHeader(l10n.settingsCyclePresetHeader),
      const SizedBox(height: 6),
      for (int i = 0; i < _presets.length; i++)
        SettingsStyle.optionRow(
          key: Key('settings_cycle_day_${_presets[i]}'), title: l10n.settingsCycleDayEveryMonth(_presets[i]),
          selected: cur == _presets[i], onTap: () => _setDay(_presets[i]),
        ),
      const SizedBox(height: 20),
      SettingsStyle.sectionHeader(l10n.settingsCycleCustomHeader),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(
          child: TextField(
            key: const Key('settings_custom_cycle_day_input'), controller: _ctrl, keyboardType: TextInputType.number, style: SettingsStyle.title,
            decoration: InputDecoration(
              prefixText: l10n.settingsCycleDatePrefix, prefixStyle: SettingsStyle.sub, hintText: '1 - 31', hintStyle: SettingsStyle.sub, isDense: true,
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.canvasBorder)),
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.neoChartreuse)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          key: const Key('settings_custom_cycle_day_save'),
          onTap: () { final v = int.tryParse(_ctrl.text.trim()); if (v != null) _setDay(v); },
          child: Text(l10n.settingsCycleApplyBtn, style: SettingsStyle.accent),
        ),
      ]),
      const SizedBox(height: 14),
      Wrap(spacing: 6, runSpacing: 6, children: [
        for (int d = 1; d <= 31; d++)
          SettingsStyle.flatChip(key: Key('settings_cycle_grid_$d'), label: '$d', selected: cur == d, onTap: () => _setDay(d)),
      ]),
      const SizedBox(height: 16),
      Text(l10n.settingsCycleDaysRemaining(widget.state.metrics.daysRemainingInMonth), style: SettingsStyle.sub),
    ]);
  }
}

class SettingsStsWalletsSubPage extends StatelessWidget {
  final FinanceState state;
  const SettingsStsWalletsSubPage({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final wallets = state.wallets;
    final selectedIds = state.safeToSpendWalletIds ?? const <String>{};
    final isAllWallets = state.metrics.isAllWallets;
    final l10n = AppL10n.of(context);
    return ListView(physics: const BouncingScrollPhysics(), padding: const EdgeInsets.fromLTRB(24, 12, 24, 48), children: [
      SettingsStyle.sectionHeader(l10n.settingsStsOperationalHeader),
      const SizedBox(height: 6),
      SettingsStyle.optionRow(
        key: const Key('settings_sts_wallet_all'), title: l10n.settingsStsAllWallets(wallets.length),
        selected: isAllWallets, onTap: () => context.read<FinanceBloc>().add(const SetSafeToSpendWalletsEvent(null)),
      ),
      for (final w in wallets)
        SettingsStyle.optionRow(
          key: Key('settings_sts_wallet_${w.id}'), title: w.name, selected: !isAllWallets && selectedIds.contains(w.id),
          onTap: () {
            final sel = !isAllWallets && selectedIds.contains(w.id);
            final next = isAllWallets ? <String>{w.id} : Set<String>.from(selectedIds);
            if (!isAllWallets) sel ? next.remove(w.id) : next.add(w.id);
            context.read<FinanceBloc>().add(SetSafeToSpendWalletsEvent(next.isEmpty || next.length >= wallets.length ? null : next));
          },
        ),
    ]);
  }
}
