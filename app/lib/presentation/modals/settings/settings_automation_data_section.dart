import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/finance/finance_bloc.dart';
import '../../../bloc/finance/finance_event.dart';
import '../../../bloc/finance/finance_state.dart';
import '../../../core/native_bridge/notification_bridge.dart';
import '../../../core/native_bridge/security_bridge.dart';
import '../../../core/notification_parser/bank_presets.dart';
import '../../../core/update/app_update_service.dart';
import '../../../core/l10n/locale_notifier.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/common_widgets.dart';
import '../notification_permission_modal.dart';
import 'profile_settings_tab.dart';
import 'settings_backup_helper.dart';
import 'settings_language_selector.dart';
import 'settings_theme_selector.dart';

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

  @override
  Widget build(BuildContext context) {
    final s = widget.state;
    if (widget.isGlobal) {
      final l10n = AppL10n.of(context);
      final activeCatCount = s.categories.where((c) => !c.isDeleted).length;
        final isAndroidPlatform = Platform.isAndroid || Platform.environment.containsKey('FLUTTER_TEST');
        final notifStatus = !isAndroidPlatform ? l10n.settingsAndroidOnly : (_permissionGranted ? l10n.settingsActive : l10n.settingsOff);
        final notifColor = (!isAndroidPlatform || !_permissionGranted) ? null : AppColors.textIncome;
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SettingsStyle.sectionHeader(l10n.settingsGlobalHeader),
        const SizedBox(height: 6),
        SettingsStyle.switchRow(switchKey: const Key('settings_privacy_switch'), title: l10n.settingsHideBalance, value: s.isBalanceHidden, onChanged: (v) => context.read<FinanceBloc>().add(ToggleBalanceVisibilityEvent(v))),
        SettingsStyle.switchRow(switchKey: const Key('settings_refresh_rate_switch'), title: l10n.settingsHighRefreshRate, value: s.isHighRefreshRate, onChanged: (v) => context.read<FinanceBloc>().add(SetHighRefreshRateEvent(v))),
        SettingsStyle.switchRow(switchKey: const Key('settings_biometric_switch'), title: l10n.settingsBiometricLock, value: _biometricEnabled, onChanged: _toggleBiometric),
        SettingsStyle.switchRow(switchKey: const Key('settings_privacy_screen_switch'), title: l10n.settingsPrivacyScreen, value: _privacyScreenEnabled, onChanged: _togglePrivacyScreen),
        const SettingsThemeSelector(),
        const SettingsLanguageSelector(),
        SettingsStyle.menuRow(key: const Key('settings_encryption_status_row'), title: l10n.settingsEncryptionLabel, valueText: l10n.settingsEncryptionActive, valueColor: AppColors.textAccent),
        SettingsStyle.menuRow(key: const Key('settings_category_menu_row'), title: l10n.settingsCategoriesLabel, valueText: l10n.settingsCategoriesCount(activeCatCount), onTap: () => widget.onNavigate(SettingsSubRoute.categories)),
        SettingsStyle.menuRow(key: const Key('settings_notif_permission_row'), title: l10n.settingsNotifListenerLabel, valueText: notifStatus, valueColor: notifColor, onTap: () async {
          if (!isAndroidPlatform) {
            AppSnackBar.showInfo(context, 'Fitur Khusus Android', message: 'Listener Notifikasi Bank adalah fitur native Android.');
            return;
          }
          await NotificationPermissionModal.show(context);
          await _checkPermission();
        }),
        SettingsStyle.menuRow(key: const Key('settings_bank_apps_row'), title: l10n.settingsBankAppsLabel, valueText: l10n.settingsSupportedCount(kPopularBankAppPresets.length), onTap: () => widget.onNavigate(SettingsSubRoute.bankApps)),
        SettingsStyle.menuRow(
          key: const Key('settings_app_update_row'),
          title: l10n.settingsAboutAppLabel,
          valueText: 'v${AppUpdateService.currentVersion}',
          valueColor: AppColors.textAccent,
          onTap: () => widget.onNavigate(SettingsSubRoute.aboutApp),
        ),
      ]);
    }

    final unsyncedCount = s.wallets.where((w) => !w.isSynced).length + s.transactions.where((t) => !t.isSynced).length +
        s.subscriptions.where((sub) => !sub.isSynced).length + s.pockets.where((p) => !p.isSynced).length;
    final l10n = AppL10n.of(context);
    final uUpper = s.profile.username.toUpperCase();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SettingsStyle.sectionHeader(l10n.settingsDataBackupHeader(uUpper)),
      const SizedBox(height: 6),
      SettingsStyle.menuRow(
        key: const Key('settings_export_csv_row'), title: l10n.settingsExportCsv,
        valueText: '${s.transactions.length}', onTap: () => widget.onNavigate(SettingsSubRoute.exportData),
      ),
      SettingsStyle.menuRow(
        key: const Key('settings_export_json_row'), title: l10n.settingsExportJson,
        valueText: 'File .json', onTap: () => SettingsBackupHelper.exportJsonBackup(context, s),
      ),
      SettingsStyle.menuRow(
        key: const Key('settings_import_json_row'), title: l10n.settingsImportJson,
        valueText: 'JSON', valueColor: AppColors.textIncome, onTap: () => SettingsBackupHelper.importJsonBackup(context, s),
      ),
      const SizedBox(height: 28),
      SettingsStyle.sectionHeader(l10n.settingsDangerZoneHeader(uUpper), color: AppColors.neoCoral.withValues(alpha: 0.85)),
      const SizedBox(height: 6),
      SettingsStyle.menuRow(
        key: const Key('settings_clear_tx_row'), title: l10n.settingsClearTx,
        valueText: '${s.transactions.length}', valueColor: AppColors.neoCoral, onTap: () => widget.onNavigate(SettingsSubRoute.clearTransactions),
      ),
      SettingsStyle.menuRow(
        key: const Key('settings_delete_profile_row'), title: l10n.settingsDeleteProfile,
        valueText: '@$uUpper', valueColor: AppColors.neoCoral, onTap: () => widget.onNavigate(SettingsSubRoute.deleteProfile),
      ),
      const SizedBox(height: 12),
      Text('fiBOnanci v${AppUpdateService.currentVersion} • $unsyncedCount perubahan lokal tersimpan offline', style: SettingsStyle.sub.copyWith(fontSize: 11)),
    ]);
  }
}
