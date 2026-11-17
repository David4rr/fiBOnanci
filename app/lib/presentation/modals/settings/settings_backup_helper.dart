import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';

import '../../../bloc/finance/finance_bloc.dart';
import '../../../bloc/finance/finance_event.dart';
import '../../../bloc/finance/finance_state.dart';
import '../../theme/app_colors.dart';

class SettingsBackupHelper {
  static Future<Directory> resolveExportDir() async {
    Directory dir = Directory.systemTemp;
    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      try {
        final dl = Directory('/storage/emulated/0/Download');
        dir = dl.existsSync() ? dl : (await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory());
      } catch (_) {}
    }
    return dir;
  }

  static Future<String> saveExportFile(String fileName, String content) async {
    final file = File('${(await resolveExportDir()).path}/$fileName');
    file.writeAsStringSync(content, flush: true);
    return file.path;
  }

  static Future<void> exportJsonBackup(BuildContext context, FinanceState state) async {
    final payload = {
      'exportedAt': DateTime.now().toIso8601String(),
      'profile': {'id': state.profile.id, 'username': state.profile.username, 'currency': state.profile.currency},
      'walletsCount': state.wallets.length,
      'pocketsCount': state.pockets.length,
      'subscriptionsCount': state.subscriptions.length,
      'transactionsCount': state.transactions.length,
      'profiles': state.profiles.map((e) => e.toJson()).toList(),
      'categories': state.categories.map((e) => e.toJson()).toList(),
      'wallets': state.wallets.map((e) => e.toJson()).toList(),
      'pockets': state.pockets.map((e) => e.toJson()).toList(),
      'subscriptions': state.subscriptions.map((e) => e.toJson()).toList(),
      'transactions': state.transactions.map((e) => e.toJson()).toList(),
    };
    final path = await saveExportFile(
      'fibonanci_backup_${state.profile.username}.json',
      const JsonEncoder.withIndent('  ').convert(payload),
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('File JSON disimpan: $path'),
        backgroundColor: AppColors.neoChartreuse,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  static Future<void> importJsonBackup(BuildContext context, FinanceState state) async {
    final dir = await resolveExportDir();
    File target = File('${dir.path}/fibonanci_backup_${state.profile.username}.json');
    if (!target.existsSync()) {
      final c = dir.listSync().whereType<File>().where(
        (f) => f.path.endsWith('.json') && f.path.contains('fibonanci_backup_'),
      ).toList()..sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
      if (c.isNotEmpty) target = c.first;
    }
    if (!target.existsSync()) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('File cadangan fibonanci_backup_*.json tidak ditemukan di Download'),
          backgroundColor: AppColors.neoCoral,
          behavior: SnackBarBehavior.floating,
        ));
      }
      return;
    }
    final decoded = jsonDecode(target.readAsStringSync()) as Map<String, dynamic>;
    if (!context.mounted) return;
    context.read<FinanceBloc>().add(ImportJsonBackupEvent(decoded));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Cadangan dipulihkan: ${target.path.split('/').last}'),
      backgroundColor: AppColors.neoMint,
      behavior: SnackBarBehavior.floating,
    ));
  }
}
