import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../bloc/finance/finance_bloc.dart';
import '../../../bloc/finance/finance_event.dart';
import '../../../bloc/finance/finance_state.dart';
import '../../../core/formatters/app_currency.dart';
import '../../../core/formatters/rupiah_input_formatter.dart';
import '../../theme/app_colors.dart';
import 'profile_settings_tab.dart';

class SettingsFinancialSection extends StatelessWidget {
  final FinanceState state;
  final ValueChanged<SettingsSubRoute> onNavigate;

  const SettingsFinancialSection({super.key, required this.state, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final profile = state.profile;
    final target = profile.monthlyIncomeTarget;
    final hasTarget = target != null && target > 0;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SettingsStyle.sectionHeader('PENGATURAN PROFIL • @${profile.username.toUpperCase()}'),
      const SizedBox(height: 6),
      SettingsStyle.menuRow(
        key: const Key('settings_currency_menu_row'), title: 'Mata Uang Utama',
        valueText: profile.currency, onTap: () => onNavigate(SettingsSubRoute.currency),
      ),
      SettingsStyle.hairline(),
      SettingsStyle.menuRow(
        key: const Key('settings_income_target_row'), title: 'Target Pemasukan Bulanan',
        valueText: hasTarget ? AppCurrency.forCode(profile.currency).format(target) : 'Atur',
        onTap: () => onNavigate(SettingsSubRoute.incomeTarget),
      ),
      SettingsStyle.hairline(),
    ]);
  }
}

class SettingsCurrencySubPage extends StatefulWidget {
  final FinanceState state;
  const SettingsCurrencySubPage({super.key, required this.state});
  @override
  State<SettingsCurrencySubPage> createState() => _SettingsCurrencySubPageState();
}

class _SettingsCurrencySubPageState extends State<SettingsCurrencySubPage> {
  static const _currencies = [
    ('IDR', 'Rupiah Indonesia (Rp)'), ('USD', 'US Dollar (\$)'), ('EUR', 'Euro (€)'),
    ('SGD', 'Singapore Dollar (S\$)'), ('MYR', 'Malaysian Ringgit (RM)'), ('JPY', 'Japanese Yen (¥)'),
  ];
  bool _editingRate = false;
  late TextEditingController _rateCtrl;

  @override
  void initState() {
    super.initState();
    _rateCtrl = TextEditingController(text: RupiahInputFormatter.format(AppCurrency.rateFor(widget.state.profile.currency)));
  }
  @override
  void dispose() { _rateCtrl.dispose(); super.dispose(); }

  void _selectCurrency(String code) {
    final p = widget.state.profile;
    if (p.currency == code) return;
    _editingRate = false;
    context.read<FinanceBloc>().add(UpdateProfileEvent(
      profileId: p.id, username: p.username, fullName: p.fullName, email: p.email, phone: p.phone,
      avatarPath: p.avatarPath, occupation: p.occupation, bio: p.bio, currency: code, monthlyIncomeTarget: p.monthlyIncomeTarget,
    ));
  }
  void _saveRate() {
    final parsed = RupiahInputFormatter.parse(_rateCtrl.text.trim());
    if (parsed > 0) context.read<FinanceBloc>().add(SetExchangeRateEvent(widget.state.profile.currency, parsed));
    setState(() => _editingRate = false);
  }

  @override
  Widget build(BuildContext context) {
    final code = widget.state.profile.currency;
    return ListView(physics: const BouncingScrollPhysics(), padding: const EdgeInsets.fromLTRB(24, 12, 24, 48), children: [
        SettingsStyle.sectionHeader('PILIH MATA UANG'),
        const SizedBox(height: 6),
        for (int i = 0; i < _currencies.length; i++) ...[
          if (i > 0) SettingsStyle.hairline(),
          SettingsStyle.optionRow(
            key: Key('settings_currency_${_currencies[i].$1}'), title: '${_currencies[i].$1} — ${_currencies[i].$2}',
            selected: code == _currencies[i].$1, onTap: () => _selectCurrency(_currencies[i].$1),
          ),
        ],
        if (code != 'IDR') ...[
          const SizedBox(height: 24),
          SettingsStyle.sectionHeader('KURS KONVERSI (1 $code KE IDR)'),
          const SizedBox(height: 6),
          SettingsStyle.menuRow(
            key: const Key('settings_exchange_rate_row'), title: 'Kurs 1 $code',
            valueText: 'Rp ${RupiahInputFormatter.format(AppCurrency.rateFor(code))}',
            trailingAction: GestureDetector(
              key: const Key('settings_sync_rate_button'),
              onTap: () => context.read<FinanceBloc>().add(const SyncExchangeRatesEvent()),
              child: Icon(Icons.sync_rounded, size: 16, color: AppCurrency.isLiveRate ? AppColors.neoMint : AppColors.textMuted),
            ),
            onTap: () => setState(() { _editingRate = !_editingRate; if (_editingRate) _rateCtrl.text = RupiahInputFormatter.format(AppCurrency.rateFor(code)); }),
          ),
          if (_editingRate)
            Row(children: [
              Expanded(
                child: TextField(
                  key: const Key('settings_exchange_rate_input'), controller: _rateCtrl, keyboardType: TextInputType.number,
                  inputFormatters: [RupiahInputFormatter()], style: SettingsStyle.title,
                  decoration: InputDecoration(
                    prefixText: 'Rp ', prefixStyle: SettingsStyle.sub, hintText: '16.000', hintStyle: SettingsStyle.sub, isDense: true,
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12))),
                    focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.neoChartreuse)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(key: const Key('settings_exchange_rate_save'), onTap: _saveRate, child: Text('Simpan', style: SettingsStyle.accent)),
            ]),
        ],
      ],
    );
  }
}

class SettingsIncomeTargetSubPage extends StatefulWidget {
  final FinanceState state;
  final VoidCallback onSaved;
  const SettingsIncomeTargetSubPage({super.key, required this.state, required this.onSaved});
  @override
  State<SettingsIncomeTargetSubPage> createState() => _SettingsIncomeTargetSubPageState();
}

class _SettingsIncomeTargetSubPageState extends State<SettingsIncomeTargetSubPage> {
  late TextEditingController _ctrl;
  @override
  void initState() {
    super.initState();
    final p = widget.state.profile;
    final t = p.monthlyIncomeTarget;
    _ctrl = TextEditingController(text: t != null && t > 0 ? AppCurrency.formatIdrForInput(t, p.currency) : '');
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _save() {
    final p = widget.state.profile;
    final parsedIdr = AppCurrency.parseInputToIdr(_ctrl.text.trim(), p.currency);
    context.read<FinanceBloc>().add(UpdateProfileEvent(
      profileId: p.id, username: p.username, fullName: p.fullName, email: p.email, phone: p.phone,
      avatarPath: p.avatarPath, occupation: p.occupation, bio: p.bio, currency: p.currency,
      monthlyIncomeTarget: parsedIdr > 0 ? parsedIdr : null,
    ));
    widget.onSaved();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.state.profile.currency;
    return ListView(padding: const EdgeInsets.fromLTRB(24, 12, 24, 48), children: [
      SettingsStyle.sectionHeader('NOMINAL TARGET BULANAN ($c)'),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(
          child: TextField(
            key: const Key('settings_income_target_input'), controller: _ctrl, autofocus: true, keyboardType: TextInputType.number,
            inputFormatters: [RupiahInputFormatter()], style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textWhite),
            decoration: InputDecoration(
              prefixText: AppCurrency.symbolFor(c), prefixStyle: SettingsStyle.value, hintText: '0', hintStyle: SettingsStyle.sub,
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15))),
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.neoChartreuse)),
            ),
          ),
        ),
        const SizedBox(width: 14),
        GestureDetector(key: const Key('settings_income_target_save'), onTap: _save, child: Text('Simpan', style: SettingsStyle.accent)),
      ]),
    ]);
  }
}
