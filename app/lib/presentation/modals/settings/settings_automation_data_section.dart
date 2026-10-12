import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import '../../../bloc/finance/finance_bloc.dart';
import '../../../bloc/finance/finance_event.dart';
import '../../../bloc/finance/finance_state.dart';
import '../../../core/native_bridge/notification_bridge.dart';
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
  bool _permissionGranted = false;
  @override
  void initState() { super.initState(); _checkPermission(); }
  Future<void> _checkPermission() async {
    final granted = await NotificationBridge.isPermissionGranted();
    if (mounted) setState(() => _permissionGranted = granted);
  }

  static Future<String> saveExportFile(String fileName, String content) async {
    Directory dir = Directory.systemTemp;
    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      try {
        final dl = Directory('/storage/emulated/0/Download');
        dir = dl.existsSync() ? dl : (await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory());
      } catch (_) {}
    }
    final file = File('${dir.path}/$fileName');
    file.writeAsStringSync(content, flush: true);
    return file.path;
  }

  Future<void> _exportJsonBackup() async {
    final s = widget.state;
    final payload = {
      'exportedAt': DateTime.now().toIso8601String(),
      'profile': {'id': s.profile.id, 'username': s.profile.username, 'currency': s.profile.currency},
      'walletsCount': s.wallets.length, 'pocketsCount': s.pockets.length,
      'subscriptionsCount': s.subscriptions.length, 'transactionsCount': s.transactions.length,
    };
    final path = await saveExportFile('fibonanci_backup_${s.profile.username}.json', const JsonEncoder.withIndent('  ').convert(payload));
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('File JSON disimpan: $path'), backgroundColor: AppColors.neoChartreuse, behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.state;
    if (widget.isGlobal) {
      final activeCatCount = s.categories.where((c) => !c.isDeleted).length;
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SettingsStyle.sectionHeader('PENGATURAN GLOBAL • SEMUA PROFIL'),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Samarkan Nominal Saldo', style: SettingsStyle.title),
            Transform.scale(
              scale: 0.85, alignment: Alignment.centerRight,
              child: Switch.adaptive(
                key: const Key('settings_privacy_switch'), value: s.isBalanceHidden, activeTrackColor: AppColors.neoChartreuse,
                onChanged: (v) => context.read<FinanceBloc>().add(ToggleBalanceVisibilityEvent(v)),
              ),
            ),
          ]),
        ),
        SettingsStyle.hairline(),
        SettingsStyle.menuRow(
          key: const Key('settings_category_menu_row'), title: 'Kategori Transaksi',
          valueText: '$activeCatCount Kategori', onTap: () => widget.onNavigate(SettingsSubRoute.categories),
        ),
        SettingsStyle.hairline(),
        SettingsStyle.menuRow(
          key: const Key('settings_notif_permission_row'), title: 'Listener Notifikasi Bank',
          valueText: _permissionGranted ? 'Aktif' : 'Mati', valueColor: _permissionGranted ? AppColors.neoMint : null,
          onTap: () async { await NotificationBridge.openPermissionSettings(); await _checkPermission(); },
        ),
        SettingsStyle.hairline(),
        SettingsStyle.menuRow(
          key: const Key('settings_bank_apps_row'), title: 'Aplikasi Bank & E-Wallet',
          valueText: '${kPopularBankAppPresets.length} Didukung', onTap: () => widget.onNavigate(SettingsSubRoute.bankApps),
        ),
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
      SettingsStyle.hairline(),
      SettingsStyle.menuRow(
        key: const Key('settings_export_json_row'), title: 'Simpan Cadangan (JSON)',
        valueText: 'File .json', onTap: _exportJsonBackup,
      ),
      const SizedBox(height: 28),
      SettingsStyle.sectionHeader('ZONA BAHAYA • @$uUpper', color: AppColors.neoCoral.withValues(alpha: 0.85)),
      const SizedBox(height: 6),
      SettingsStyle.menuRow(
        key: const Key('settings_clear_tx_row'), title: 'Bersihkan Riwayat Transaksi', valueText: 'Reset',
        titleColor: AppColors.neoCoral, valueColor: AppColors.neoCoral.withValues(alpha: 0.8),
        onTap: () => widget.onNavigate(SettingsSubRoute.clearTransactions),
      ),
      Divider(color: AppColors.neoCoral.withValues(alpha: 0.12), height: 1),
      SettingsStyle.menuRow(
        key: const Key('settings_delete_profile_row'),
        title: s.profiles.length > 1 ? 'Hapus Profil (@${s.profile.username})' : 'Reset Profil (@${s.profile.username})',
        valueText: s.profiles.length > 1 ? 'Hapus' : 'Reset',
        titleColor: AppColors.neoCoral, valueColor: AppColors.neoCoral.withValues(alpha: 0.8),
        onTap: () => widget.onNavigate(SettingsSubRoute.deleteProfile),
      ),
      const SizedBox(height: 20),
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
    SettingsStyle.optionRow(
      key: const Key('settings_export_csv_file_btn'), title: 'Simpan File CSV (.csv)',
      subtitle: 'Format koma terpisah (UTF-8 BOM), kompatibel semua spreadsheet',
      selected: _savedPath?.endsWith('.csv') ?? false, onTap: () => _export(asExcel: false),
    ),
    SettingsStyle.hairline(),
    SettingsStyle.optionRow(
      key: const Key('settings_export_excel_file_btn'), title: 'Simpan File Excel (.xls)',
      subtitle: 'Format tabel buku kerja Microsoft Excel / Google Sheets',
      selected: _savedPath?.endsWith('.xls') ?? false, onTap: () => _export(asExcel: true),
    ),
    if (_savedPath != null) ...[
      const SizedBox(height: 16),
      Text('Berhasil disimpan ke:\n$_savedPath', key: const Key('settings_export_saved_path'), style: SettingsStyle.accent),
    ],
  ]);
}
