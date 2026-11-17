import 'package:flutter/material.dart';

import '../../../bloc/finance/finance_state.dart';
import 'profile_settings_tab.dart';
import 'settings_backup_helper.dart';

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
      path = await SettingsBackupHelper.saveExportFile('fibonanci_transaksi_$u.csv', b.toString());
    } else {
      final b = StringBuffer('<?xml version="1.0"?><?mso-application progid="Excel.Sheet"?><Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet" xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"><Worksheet ss:Name="Transaksi"><Table>'
          '<Row><Cell><Data ss:Type="String">Tanggal</Data></Cell><Cell><Data ss:Type="String">Tipe</Data></Cell><Cell><Data ss:Type="String">Rekening</Data></Cell><Cell><Data ss:Type="String">Kategori</Data></Cell><Cell><Data ss:Type="String">Nominal (IDR)</Data></Cell><Cell><Data ss:Type="String">Catatan</Data></Cell></Row>');
      for (final t in s.transactions) {
        final d = t.transactionDate.toIso8601String().split('T').first;
        final n = (t.notes ?? '').replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;');
        b.write('<Row><Cell><Data ss:Type="String">$d</Data></Cell><Cell><Data ss:Type="String">${t.type}</Data></Cell><Cell><Data ss:Type="String">${wMap[t.walletId] ?? '-'}</Data></Cell><Cell><Data ss:Type="String">${cMap[t.categoryId] ?? '-'}</Data></Cell><Cell><Data ss:Type="Number">${t.amount.toStringAsFixed(0)}</Data></Cell><Cell><Data ss:Type="String">$n</Data></Cell></Row>');
      }
      b.write('</Table></Worksheet></Workbook>');
      path = await SettingsBackupHelper.saveExportFile('fibonanci_transaksi_$u.xls', b.toString());
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
