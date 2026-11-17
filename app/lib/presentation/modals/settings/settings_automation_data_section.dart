import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/finance/finance_bloc.dart';
import '../../../bloc/finance/finance_event.dart';
import '../../../bloc/finance/finance_state.dart';
import '../../../core/native_bridge/notification_bridge.dart';
import '../../../core/native_bridge/security_bridge.dart';
import '../../../core/notification_parser/bank_presets.dart';
import '../../../core/update/app_update_service.dart';
import '../../theme/app_colors.dart';
import '../app_update_modal.dart';
import '../notification_permission_modal.dart';
import 'profile_settings_tab.dart';
import 'settings_backup_helper.dart';

class SettingsAutomationDataSection extends StatefulWidget {
  final FinanceState state;
  final ValueChanged<SettingsSubRoute> onNavigate;
  final bool isGlobal;

  const SettingsAutomationDataSection({super.key, required this.state, required this.onNavigate, this.isGlobal = true});

  @override
  State<SettingsAutomationDataSection> createState() => _SettingsAutomationDataSectionState();
}

class _SettingsAutomationDataSectionState extends State<SettingsAutomationDataSection> {
  bool _permissionGranted = false, _biometricEnabled = false, _privacyScreenEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final granted = await NotificationBridge.isPermissionGranted();
    final sec = await SecurityBridge.getSecuritySettings();
    if (mounted) setState(() { _permissionGranted = granted; _biometricEnabled = sec.biometricLockEnabled; _privacyScreenEnabled = sec.privacyScreenEnabled; });
  }

  Future<void> _toggleBiometric(bool v) async {
    if (v && !await SecurityBridge.authenticateBiometric(reason: 'Konfirmasi untuk mengaktifkan Kunci Biometrik / PIN')) return;
    await SecurityBridge.setBiometricLockEnabled(v);
    if (mounted) setState(() => _biometricEnabled = v);
  }

  Future<void> _togglePrivacyScreen(bool v) async {
    await SecurityBridge.setPrivacyScreenEnabled(v);
    if (mounted) setState(() => _privacyScreenEnabled = v);
  }

  Future<void> _checkUpdate() async {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Memeriksa pembaruan...', style: TextStyle(color: AppColors.textDarkPrimary)),
      backgroundColor: AppColors.neoChartreuse,
      duration: Duration(milliseconds: 1000),
      behavior: SnackBarBehavior.floating,
    ));
    final update = await AppUpdateService.checkForUpdate();
    if (!mounted) return;
    if (update != null && update.hasUpdate) {
      AppUpdateModal.show(context, update);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Aplikasi sudah versi terbaru (v${AppUpdateService.currentVersion})', style: TextStyle(color: AppColors.textDarkPrimary)),
        backgroundColor: AppColors.neoMint,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.state;
    if (widget.isGlobal) {
      final activeCatCount = s.categories.where((c) => !c.isDeleted).length;
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SettingsStyle.sectionHeader('PENGATURAN GLOBAL • SEMUA PROFIL'),
        const SizedBox(height: 6),
        SettingsStyle.switchRow(switchKey: const Key('settings_privacy_switch'), title: 'Samarkan Nominal Saldo', value: s.isBalanceHidden, onChanged: (v) => context.read<FinanceBloc>().add(ToggleBalanceVisibilityEvent(v))),
        SettingsStyle.switchRow(switchKey: const Key('settings_refresh_rate_switch'), title: 'Mode Layar 120Hz (High FPS)', value: s.isHighRefreshRate, onChanged: (v) => context.read<FinanceBloc>().add(SetHighRefreshRateEvent(v))),
        SettingsStyle.switchRow(switchKey: const Key('settings_biometric_switch'), title: 'Kunci Biometrik / PIN Aplikasi', value: _biometricEnabled, onChanged: _toggleBiometric),
        SettingsStyle.switchRow(switchKey: const Key('settings_privacy_screen_switch'), title: 'Pelindung Layar Privasi (Recent Apps)', value: _privacyScreenEnabled, onChanged: _togglePrivacyScreen),
        SettingsStyle.menuRow(key: const Key('settings_encryption_status_row'), title: 'Enkripsi Database (SQLCipher)', valueText: 'AES-256 Aktif', valueColor: AppColors.neoChartreuse, onTap: () {}),
        SettingsStyle.menuRow(key: const Key('settings_category_menu_row'), title: 'Kategori Transaksi', valueText: '$activeCatCount Kategori', onTap: () => widget.onNavigate(SettingsSubRoute.categories)),
        SettingsStyle.menuRow(key: const Key('settings_notif_permission_row'), title: 'Listener Notifikasi Bank', valueText: _permissionGranted ? 'Aktif' : 'Mati', valueColor: _permissionGranted ? AppColors.neoMint : null, onTap: () async { await NotificationPermissionModal.show(context); await _checkPermission(); }),
        SettingsStyle.menuRow(key: const Key('settings_bank_apps_row'), title: 'Aplikasi Bank & E-Wallet', valueText: '${kPopularBankAppPresets.length} Didukung', onTap: () => widget.onNavigate(SettingsSubRoute.bankApps)),
        SettingsStyle.menuRow(key: const Key('settings_app_update_row'), title: 'Pembaruan Aplikasi', valueText: 'v${AppUpdateService.currentVersion}', valueColor: AppColors.neoChartreuse, onTap: _checkUpdate),
      ]);
    }

    final unsyncedCount = s.wallets.where((w) => !w.isSynced).length + s.transactions.where((t) => !t.isSynced).length +
        s.subscriptions.where((sub) => !sub.isSynced).length + s.pockets.where((p) => !p.isSynced).length;
    final uUpper = s.profile.username.toUpperCase();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SettingsStyle.sectionHeader('DATA & CADANGAN • @$uUpper'),
      const SizedBox(height: 6),
      SettingsStyle.menuRow(
        key: const Key('settings_export_csv_row'), title: 'Ekspor Transaksi (CSV / Excel)',
        valueText: '${s.transactions.length} Baris', onTap: () => widget.onNavigate(SettingsSubRoute.exportData),
      ),
      SettingsStyle.menuRow(
        key: const Key('settings_export_json_row'), title: 'Simpan Cadangan (JSON)',
        valueText: 'File .json', onTap: () => SettingsBackupHelper.exportJsonBackup(context, s),
      ),
      SettingsStyle.menuRow(
        key: const Key('settings_import_json_row'), title: 'Pulihkan Cadangan (Import JSON)',
        valueText: 'Pulihkan', valueColor: AppColors.neoMint, onTap: () => SettingsBackupHelper.importJsonBackup(context, s),
      ),
      const SizedBox(height: 28),
      SettingsStyle.sectionHeader('ZONA BAHAYA • @$uUpper', color: AppColors.neoCoral.withValues(alpha: 0.85)),
      const SizedBox(height: 6),
      SettingsStyle.menuRow(
        key: const Key('settings_clear_tx_row'), title: 'Bersihkan Riwayat Transaksi',
        valueText: '${s.transactions.length} Transaksi', valueColor: AppColors.neoCoral, onTap: () => widget.onNavigate(SettingsSubRoute.clearTransactions),
      ),
      SettingsStyle.menuRow(
        key: const Key('settings_delete_profile_row'), title: 'Hapus / Reset Profil Aktif',
        valueText: '@$uUpper', valueColor: AppColors.neoCoral, onTap: () => widget.onNavigate(SettingsSubRoute.deleteProfile),
      ),
      const SizedBox(height: 12),
      Text('fiBOnanci v${AppUpdateService.currentVersion} • $unsyncedCount perubahan lokal tersimpan offline', style: SettingsStyle.sub.copyWith(fontSize: 11)),
    ]);
  }
}
