import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../bloc/finance/finance_bloc.dart';
import '../../../bloc/finance/finance_event.dart';
import '../../../bloc/finance/finance_state.dart';
import '../../theme/app_colors.dart';
import 'profile_settings_tab.dart';
class SettingsStyle {
  static final title = GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.90));
  static final sub = GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.w400, color: AppColors.textMuted);
  static final value = GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.55), fontFeatures: const [FontFeature.tabularFigures()]);
  static final accent = GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.neoChartreuse, fontFeatures: const [FontFeature.tabularFigures()]);

  static Widget sectionHeader(String text, {Color? color}) => Text(
    text, style: GoogleFonts.plusJakartaSans(fontSize: 10.5, fontWeight: FontWeight.w700, color: color ?? Colors.white.withValues(alpha: 0.36), letterSpacing: 1.0),
  );
  static Widget hairline([double vertical = 0]) => Padding(
    padding: EdgeInsets.symmetric(vertical: vertical), child: Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
  );
  static Widget segmentedTrack({required List<Widget> children}) => Container(
    padding: const EdgeInsets.all(3), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.035), borderRadius: BorderRadius.circular(10)), child: Row(children: children),
  );
  static Widget switchRow({required Key switchKey, required String title, required bool value, required ValueChanged<bool> onChanged}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(title, style: SettingsStyle.title),
      Transform.scale(scale: 0.85, alignment: Alignment.centerRight, child: Switch.adaptive(key: switchKey, value: value, activeTrackColor: AppColors.neoChartreuse, onChanged: onChanged)),
    ]),
  );
  static Widget menuRow({
    Key? key, required String title, required String valueText,
    required VoidCallback onTap, Color? titleColor, Color? valueColor, Widget? trailingAction,
  }) => GestureDetector(
    key: key, behavior: HitTestBehavior.opaque, onTap: onTap,
    child: Padding(padding: const EdgeInsets.symmetric(vertical: 13), child: Row(children: [
      Expanded(child: Text(title, style: SettingsStyle.title.copyWith(color: titleColor))),
      if (trailingAction != null) ...[trailingAction, const SizedBox(width: 10)],
      Text(valueText, style: value.copyWith(color: valueColor)), const SizedBox(width: 4),
      Icon(Icons.chevron_right_rounded, size: 17, color: valueColor ?? Colors.white24),
    ])),
  );
  static Widget optionRow({
    Key? key, required String title, String? subtitle, required bool selected, required VoidCallback onTap,
  }) => GestureDetector(
    key: key, behavior: HitTestBehavior.opaque, onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: SettingsStyle.title.copyWith(color: selected ? AppColors.textWhite : Colors.white70, fontWeight: selected ? FontWeight.w600 : FontWeight.w500)),
          if (subtitle != null) ...[const SizedBox(height: 2), Text(subtitle, style: sub)],
        ])),
        if (selected) const Icon(Icons.check_rounded, size: 18, color: AppColors.neoChartreuse),
      ]),
    ),
  );
  static Widget flatChip({Key? key, required String label, required bool selected, required VoidCallback onTap}) => GestureDetector(
    key: key, behavior: HitTestBehavior.opaque, onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150), padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? Colors.white.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(8), border: Border.all(color: selected ? Colors.white.withValues(alpha: 0.22) : Colors.transparent, width: 0.8),
      ),
      child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: selected ? FontWeight.w600 : FontWeight.w500, color: selected ? AppColors.textWhite : AppColors.textMuted)),
    ),
  );
}

class SettingsBudgetCycleSection extends StatelessWidget {
  final FinanceState state;
  final ValueChanged<SettingsSubRoute> onNavigate;
  const SettingsBudgetCycleSection({super.key, required this.state, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final wallets = state.wallets;
    final selectedIds = state.safeToSpendWalletIds ?? const <String>{};
    final isAllWallets = state.metrics.isAllWallets;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SettingsStyle.menuRow(
        key: const Key('settings_cycle_day_menu_row'), title: 'Tanggal Mulai Siklus',
        valueText: 'Tgl ${state.budgetCycleDay} (${state.metrics.daysRemainingInMonth} hr)',
        onTap: () => onNavigate(SettingsSubRoute.cycleDay),
      ),
      if (wallets.isNotEmpty) ...[
        SettingsStyle.hairline(),
        SettingsStyle.menuRow(
          key: const Key('settings_sts_wallets_menu_row'), title: 'Rekening Safe-to-Spend',
          valueText: isAllWallets ? 'Semua (${wallets.length})' : '${selectedIds.length} Aktif',
          onTap: () => onNavigate(SettingsSubRoute.stsWallets),
        ),
      ],
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
    return ListView(physics: const BouncingScrollPhysics(), padding: const EdgeInsets.fromLTRB(24, 12, 24, 48), children: [
      SettingsStyle.sectionHeader('PRESET TANGGAL SIKLUS'),
      const SizedBox(height: 6),
      for (int i = 0; i < _presets.length; i++) ...[
        if (i > 0) SettingsStyle.hairline(),
        SettingsStyle.optionRow(
          key: Key('settings_cycle_day_${_presets[i]}'), title: 'Tanggal ${_presets[i]} setiap bulan',
          selected: cur == _presets[i], onTap: () => _setDay(_presets[i]),
        ),
      ],
      const SizedBox(height: 20),
      SettingsStyle.sectionHeader('TANGGAL KUSTOM (1–31)'),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(
          child: TextField(
            key: const Key('settings_custom_cycle_day_input'), controller: _ctrl, keyboardType: TextInputType.number, style: SettingsStyle.title,
            decoration: InputDecoration(
              prefixText: 'Tanggal ', prefixStyle: SettingsStyle.sub, hintText: '1 - 31', hintStyle: SettingsStyle.sub, isDense: true,
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12))),
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.neoChartreuse)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          key: const Key('settings_custom_cycle_day_save'),
          onTap: () { final v = int.tryParse(_ctrl.text.trim()); if (v != null) _setDay(v); },
          child: Text('Terapkan', style: SettingsStyle.accent),
        ),
      ]),
      const SizedBox(height: 14),
      Wrap(spacing: 6, runSpacing: 6, children: [
        for (int d = 1; d <= 31; d++)
          SettingsStyle.flatChip(key: Key('settings_cycle_grid_$d'), label: '$d', selected: cur == d, onTap: () => _setDay(d)),
      ]),
      const SizedBox(height: 16),
      Text('${widget.state.metrics.daysRemainingInMonth} hari tersisa pada siklus berjalan saat ini.', style: SettingsStyle.sub),
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
    return ListView(physics: const BouncingScrollPhysics(), padding: const EdgeInsets.fromLTRB(24, 12, 24, 48), children: [
      SettingsStyle.sectionHeader('REKENING DANA OPERASIONAL'),
      const SizedBox(height: 6),
      SettingsStyle.optionRow(
        key: const Key('settings_sts_wallet_all'), title: 'Semua Rekening (${wallets.length})',
        selected: isAllWallets, onTap: () => context.read<FinanceBloc>().add(const SetSafeToSpendWalletsEvent(null)),
      ),
      for (final w in wallets) ...[
        SettingsStyle.hairline(),
        SettingsStyle.optionRow(
          key: Key('settings_sts_wallet_${w.id}'), title: w.name, selected: !isAllWallets && selectedIds.contains(w.id),
          onTap: () {
            final sel = !isAllWallets && selectedIds.contains(w.id);
            final next = isAllWallets ? <String>{w.id} : Set<String>.from(selectedIds);
            if (!isAllWallets) sel ? next.remove(w.id) : next.add(w.id);
            context.read<FinanceBloc>().add(SetSafeToSpendWalletsEvent(next.isEmpty || next.length >= wallets.length ? null : next));
          },
        ),
      ],
    ]);
  }
}
