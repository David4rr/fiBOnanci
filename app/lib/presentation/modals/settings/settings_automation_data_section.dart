import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import '../../../bloc/finance/finance_bloc.dart';
import '../../../bloc/finance/finance_event.dart';
import '../../../bloc/finance/finance_state.dart';
import '../../../core/native_bridge/notification_bridge.dart';
import '../../../core/native_bridge/security_bridge.dart';
import '../../../core/notification_parser/bank_presets.dart';
import '../../theme/app_colors.dart';
import 'profile_settings_tab.dart';

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
  void initState() { super.initState(); _checkPermission(); }
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

  static Future<Directory> _resolveExportDir() async {
    Directory dir = Directory.systemTemp;
    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      try { final dl = Directory('/storage/emulated/0/Download'); dir = dl.existsSync() ? dl : (await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory()); } catch (_) {}
    }
    return dir;
  }
  static Future<String> saveExportFile(String fileName, String content) async {
    final file = File('${(await _resolveExportDir()).path}/$fileName');
    file.writeAsStringSync(content, flush: true);
    return file.path;
  }
  Future<void> _exportJsonBackup() async {
    final s = widget.state;
    final payload = {
      'exportedAt': DateTime.now().toIso8601String(),
      'profile': {'id': s.profile.id, 'username': s.profile.username, 'currency': s.profile.currency},
      'walletsCount': s.wallets.length, 'pocketsCount': s.pockets.length, 'subscriptionsCount': s.subscriptions.length, 'transactionsCount': s.transactions.length,
      'profiles': s.profiles.map((e) => e.toJson()).toList(), 'categories': s.categories.map((e) => e.toJson()).toList(),
      'wallets': s.wallets.map((e) => e.toJson()).toList(), 'pockets': s.pockets.map((e) => e.toJson()).toList(),
      'subscriptions': s.subscriptions.map((e) => e.toJson()).toList(), 'transactions': s.transactions.map((e) => e.toJson()).toList(),
    };
    final path = await saveExportFile('fibonanci_backup_${s.profile.username}.json', const JsonEncoder.withIndent('  ').convert(payload));
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('File JSON disimpan: $path'), backgroundColor: AppColors.neoChartreuse, behavior: SnackBarBehavior.floating));
  }
  Future<void> _importJsonBackup() async {
    final dir = await _resolveExportDir();
    File target = File('${dir.path}/fibonanci_backup_${widget.state.profile.username}.json');
    if (!target.existsSync()) {
      final c = dir.listSync().whereType<File>().where((f) => f.path.endsWith('.json') && f.path.contains('fibonanci_backup_')).toList()..sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
      if (c.isNotEmpty) target = c.first;
    }
    if (!target.existsSync()) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('File cadangan fibonanci_backup_*.json tidak ditemukan di Download'), backgroundColor: AppColors.neoCoral, behavior: SnackBarBehavior.floating));
      return;
    }
    final decoded = jsonDecode(target.readAsStringSync()) as Map<String, dynamic>;
    if (!mounted) return;
    context.read<FinanceBloc>().add(ImportJsonBackupEvent(decoded));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cadangan dipulihkan: ${target.path.split('/').last}'), backgroundColor: AppColors.neoMint, behavior: SnackBarBehavior.floating));
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
        SettingsStyle.menuRow(key: const Key('settings_notif_permission_row'), title: 'Listener Notifikasi Bank', valueText: _permissionGranted ? 'Aktif' : 'Mati', valueColor: _permissionGranted ? AppColors.neoMint : null, onTap: () async { await NotificationBridge.openPermissionSettings(); await _checkPermission(); }),
        SettingsStyle.menuRow(key: const Key('settings_bank_apps_row'), title: 'Aplikasi Bank & E-Wallet', valueText: '${kPopularBankAppPresets.length} Didukung', onTap: () => widget.onNavigate(SettingsSubRoute.bankApps)),
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
        valueText: 'File .json', onTap: _exportJsonBackup,
      ),
      SettingsStyle.menuRow(
        key: const Key('settings_import_json_row'), title: 'Pulihkan Cadangan (Import JSON)',
        valueText: 'Pulihkan', valueColor: AppColors.neoMint, onTap: _importJsonBackup,
      ),
      const SizedBox(height: 28),
      SettingsStyle.sectionHeader('ZONA BAHAYA • @$uUpper', color: AppColors.neoCoral.withValues(alpha: 0.85)),
      const SizedBox(height: 6),
      SettingsStyle.menuRow(
        key: const Key('settings_clear_tx_row'), title: 'Bersihkan Riwayat Transaksi', valueText: 'Reset',
        titleColor: AppColors.neoCoral, valueColor: AppColors.neoCoral.withValues(alpha: 0.8),
        onTap: () => widget.onNavigate(SettingsSubRoute.clearTransactions),
      ),
      SettingsStyle.menuRow(
        key: const Key('settings_delete_profile_row'),
        title: s.profiles.length > 1 ? 'Hapus Profil (@${s.profile.username})' : 'Reset Profil (@${s.profile.username})',
        valueText: s.profiles.length > 1 ? 'Hapus' : 'Reset',
        titleColor: AppColors.neoCoral, valueColor: AppColors.neoCoral.withValues(alpha: 0.8),
        onTap: () => widget.onNavigate(SettingsSubRoute.deleteProfile),
      ),
      Text('SQLite Drift v6 • $unsyncedCount belum sinkron • 100% On-Device Offline', style: SettingsStyle.sub.copyWith(fontSize: 10.5, color: Colors.white24)),
    ]);
  }
}

class SettingsExportSubPage extends StatefulWidget {
  final FinanceState state;
  const SettingsExportSubPage({super.key, required this.state});
  @override
  State<SettingsExportSubPage> createState() => _SettingsExportSubPageState();
}

class _SettingsExportSubPageState extends State<SettingsExportSubPage> {
  String? _savedPath;

  Future<void> _export({required bool asExcel}) async {
    final s = widget.state;
    final wMap = {for (final w in s.wallets) w.id: w.name};
    final cMap = {for (final c in s.categories) c.id: c.name};
    final u = s.profile.username.toLowerCase();
    final String path;
    if (!asExcel) {
      final b = StringBuffer('\uFEFFTanggal,Tipe,Rekening,Kategori,Nominal (IDR),Catatan\n');
      for (final t in s.transactions) {
        final d = t.transactionDate.toIso8601String().split('T').first;
        final n = (t.notes ?? '').replaceAll('"', '""').replaceAll('\n', ' ');
        b.writeln('$d,${t.type},"${wMap[t.walletId] ?? '-'}","${cMap[t.categoryId] ?? '-'}",${t.amount.toStringAsFixed(0)},"$n"');
      }
      path = await _SettingsAutomationDataSectionState.saveExportFile('fibonanci_transaksi_$u.csv', b.toString());
    } else {
      final b = StringBuffer('<?xml version="1.0"?><?mso-application progid="Excel.Sheet"?><Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet" xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"><Worksheet ss:Name="Transaksi"><Table>'
          '<Row><Cell><Data ss:Type="String">Tanggal</Data></Cell><Cell><Data ss:Type="String">Tipe</Data></Cell><Cell><Data ss:Type="String">Rekening</Data></Cell><Cell><Data ss:Type="String">Kategori</Data></Cell><Cell><Data ss:Type="String">Nominal (IDR)</Data></Cell><Cell><Data ss:Type="String">Catatan</Data></Cell></Row>');
      for (final t in s.transactions) {
        final d = t.transactionDate.toIso8601String().split('T').first;
        final n = (t.notes ?? '').replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;');
        b.write('<Row><Cell><Data ss:Type="String">$d</Data></Cell><Cell><Data ss:Type="String">${t.type}</Data></Cell><Cell><Data ss:Type="String">${wMap[t.walletId] ?? '-'}</Data></Cell><Cell><Data ss:Type="String">${cMap[t.categoryId] ?? '-'}</Data></Cell><Cell><Data ss:Type="Number">${t.amount.toStringAsFixed(0)}</Data></Cell><Cell><Data ss:Type="String">$n</Data></Cell></Row>');
      }
      b.write('</Table></Worksheet></Workbook>');
      path = await _SettingsAutomationDataSectionState.saveExportFile('fibonanci_transaksi_$u.xls', b.toString());
    }
    if (mounted) setState(() => _savedPath = path);
  }

  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.fromLTRB(24, 12, 24, 48), children: [
    SettingsStyle.sectionHeader('PILIH FORMAT FILE LAPORAN'),
    const SizedBox(height: 6),
    SettingsStyle.optionRow(key: const Key('settings_export_csv_file_btn'), title: 'Simpan File CSV (.csv)', subtitle: 'Format koma terpisah (UTF-8 BOM), kompatibel semua spreadsheet', selected: _savedPath?.endsWith('.csv') ?? false, onTap: () => _export(asExcel: false)),
    SettingsStyle.optionRow(key: const Key('settings_export_excel_file_btn'), title: 'Simpan File Excel (.xls)', subtitle: 'Format tabel buku kerja Microsoft Excel / Google Sheets', selected: _savedPath?.endsWith('.xls') ?? false, onTap: () => _export(asExcel: true)),
    if (_savedPath != null) ...[const SizedBox(height: 16), Text('Berhasil disimpan ke:\n$_savedPath', key: const Key('settings_export_saved_path'), style: SettingsStyle.accent)],
  ]);
}
