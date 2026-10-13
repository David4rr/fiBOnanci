import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/finance/finance_bloc.dart';
import '../../../bloc/finance/finance_event.dart';
import '../../../bloc/finance/finance_state.dart';
import '../../../core/notification_parser/bank_presets.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/common_widgets.dart';
import 'settings_automation_data_section.dart';
import 'settings_budget_cycle_section.dart';
import 'settings_category_section.dart';
import 'settings_financial_section.dart';

export 'settings_automation_data_section.dart';
export 'settings_budget_cycle_section.dart';
export 'settings_category_section.dart';
export 'settings_financial_section.dart';

enum SettingsSubRoute {
  currency('Mata Uang Utama', 'Pilih mata uang tampilan & atur kurs patokan IDR'),
  incomeTarget('Target Pemasukan Bulanan', 'Patokan rasio tagihan & tabungan di Audit Kesehatan'),
  cycleDay('Tanggal Mulai Siklus', 'Tanggal awal perhitungan siklus anggaran bulanan'),
  stsWallets('Rekening Safe-to-Spend', 'Pilih rekening yang dihitung dalam dana aman harian'),
  categories('Kategori Transaksi', 'Kelola daftar kategori pengeluaran & pemasukan'),
  bankApps('Aplikasi Bank & E-Wallet', 'Daftar aplikasi finansial yang didukung parser otomatis'),
  exportData('Ekspor Data Transaksi', 'Simpan laporan transaksi ke file CSV atau Excel (.xls)'),
  clearTransactions('Bersihkan Riwayat Transaksi', 'Hapus seluruh mutasi & reset saldo profil aktif'),
  deleteProfile('Hapus Profil', 'Hapus atau reset akun profil aktif dari perangkat');
  final String title;
  final String subtitle;
  const SettingsSubRoute(this.title, this.subtitle);
}

class ProfileSettingsTab extends StatefulWidget {
  final FinanceState state;
  final SettingsSubRoute? activeRoute;
  final ValueChanged<SettingsSubRoute?>? onNavigate;

  const ProfileSettingsTab({
    super.key,
    required this.state,
    this.activeRoute,
    this.onNavigate,
  });

  @override
  State<ProfileSettingsTab> createState() => _ProfileSettingsTabState();
}

class _ProfileSettingsTabState extends State<ProfileSettingsTab> {
  SettingsSubRoute? _localRoute;
  SettingsSubRoute? _displayedSubRoute;
  late final PageController _pageController = PageController(initialPage: _route != null ? 1 : 0);

  SettingsSubRoute? get _route => widget.onNavigate != null ? widget.activeRoute : _localRoute;

  @override
  void initState() {
    super.initState();
    _displayedSubRoute = _route;
  }

  @override
  void didUpdateWidget(covariant ProfileSettingsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    final r = _route;
    if (r != null) _displayedSubRoute = r;
    if ((r != null) != (oldWidget.activeRoute != null)) {
      FocusManager.instance.primaryFocus?.unfocus();
      SmoothPageView.animateTo(_pageController, r != null ? 1 : 0);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigate(SettingsSubRoute? route) {
    FocusManager.instance.primaryFocus?.unfocus();
    if (route != null) _displayedSubRoute = route;
    if (widget.onNavigate != null) {
      widget.onNavigate!(route);
    } else {
      setState(() => _localRoute = route);
      SmoothPageView.animateTo(_pageController, route != null ? 1 : 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final subRoute = _route ?? _displayedSubRoute;

    return SmoothPageView(
      controller: _pageController,
      children: [
        ListView(
          key: const ValueKey('settings_root'),
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 48),
            children: [
              SettingsAutomationDataSection(state: state, onNavigate: _navigate, isGlobal: true),
              const SizedBox(height: 28),
              SettingsFinancialSection(state: state, onNavigate: _navigate),
              SettingsBudgetCycleSection(state: state, onNavigate: _navigate),
              const SizedBox(height: 28),
              SettingsAutomationDataSection(state: state, onNavigate: _navigate, isGlobal: false),
            ],
        ),
        switch (subRoute) {
          SettingsSubRoute.currency => SettingsCurrencySubPage(key: const ValueKey('sub_currency'), state: state),
          SettingsSubRoute.incomeTarget => SettingsIncomeTargetSubPage(key: const ValueKey('sub_income'), state: state, onSaved: () => _navigate(null)),
            SettingsSubRoute.cycleDay => SettingsCycleDaySubPage(key: const ValueKey('sub_cycle'), state: state),
            SettingsSubRoute.stsWallets => SettingsStsWalletsSubPage(key: const ValueKey('sub_wallets'), state: state),
            SettingsSubRoute.categories => SettingsCategorySection(key: const ValueKey('sub_categories'), categories: state.categories),
            SettingsSubRoute.bankApps => const SettingsBankAppsSubPage(key: ValueKey('sub_banks')),
            SettingsSubRoute.exportData => SettingsExportSubPage(key: const ValueKey('sub_export'), state: state),
            SettingsSubRoute.clearTransactions => SettingsClearTxSubPage(key: const ValueKey('sub_clear'), state: state, onCleared: () => _navigate(null)),
            SettingsSubRoute.deleteProfile => SettingsDeleteProfileSubPage(key: const ValueKey('sub_delete_profile'), state: state, onDeleted: () => _navigate(null)),
            null => const SizedBox.shrink(),
        },
      ],
    );
  }
}

class SettingsDeleteProfileSubPage extends StatelessWidget {
  final FinanceState state;
  final VoidCallback onDeleted;
  const SettingsDeleteProfileSubPage({super.key, required this.state, required this.onDeleted});

  @override
  Widget build(BuildContext context) {
    final isMulti = state.profiles.length > 1;
    final u = state.profile.username;
    return ListView(padding: const EdgeInsets.fromLTRB(24, 16, 24, 48), children: [
      Text(
        isMulti
            ? 'Profil @$u beserta seluruh rekening, transaksi, kantong dana, dan langganannya akan dihapus dari perangkat. Anda akan beralih ke profil lain yang tersimpan.'
            : 'Profil @$u adalah satu-satunya profil. Menghapus profil ini akan meresetnya kembali ke pengaturan default.',
        style: SettingsStyle.title,
      ),
      const SizedBox(height: 20),
      GestureDetector(
        key: const Key('settings_confirm_delete_profile_button'),
        onTap: () { context.read<FinanceBloc>().add(DeleteProfileEvent(state.profile.id)); onDeleted(); },
        child: Text(isMulti ? 'Ya, Hapus Profil @$u' : 'Ya, Reset Profil @$u', style: SettingsStyle.accent.copyWith(color: AppColors.neoCoral)),
      ),
    ]);
  }
}

class SettingsBankAppsSubPage extends StatelessWidget {
  const SettingsBankAppsSubPage({super.key});
  @override
  Widget build(BuildContext context) => ListView.separated(
    physics: const BouncingScrollPhysics(), padding: const EdgeInsets.fromLTRB(24, 8, 24, 48),
    itemCount: kPopularBankAppPresets.length, separatorBuilder: (_, _) => SettingsStyle.hairline(),
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
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.fromLTRB(24, 16, 24, 48), children: [
    Text('Semua riwayat transaksi pada profil @${state.profile.username} akan dihapus dan saldo rekening dikembalikan ke 0.', style: SettingsStyle.title),
    const SizedBox(height: 20),
    GestureDetector(
      key: const Key('settings_confirm_clear_tx_button'),
      onTap: () { context.read<FinanceBloc>().add(ClearProfileTransactionsEvent(state.profile.id)); onCleared(); },
      child: Text('Ya, Bersihkan Semua Transaksi', style: SettingsStyle.accent.copyWith(color: AppColors.neoCoral)),
    ),
  ]);
}
