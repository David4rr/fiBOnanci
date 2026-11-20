import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';

import '../../../bloc/finance/finance_bloc.dart';
import '../../../bloc/finance/finance_event.dart';
import '../../../bloc/finance/finance_state.dart';
import '../../screens/onboarding/onboarding_import_modal.dart';
import 'backup_export_modal.dart';
import 'backup_password_prompt_modal.dart';

class SettingsBackupHelper {
  static Future<List<Directory>> getCandidateDirs() async {
    final List<Directory> dirs = [];
    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      if (Platform.isAndroid) {
        try {
          final dl = Directory('/storage/emulated/0/Download');
          if (dl.existsSync()) dirs.add(dl);
        } catch (_) {}
        try {
          final docs = Directory('/storage/emulated/0/Documents');
          if (docs.existsSync()) dirs.add(docs);
        } catch (_) {}
        try {
          final extDirs = await getExternalStorageDirectories(type: StorageDirectory.downloads);
          if (extDirs != null) dirs.addAll(extDirs);
        } catch (_) {}
      }
      try {
        final docs = await getApplicationDocumentsDirectory();
        dirs.add(docs);
      } catch (_) {}
    }
    dirs.add(Directory.systemTemp);
    return dirs;
  }

  static Future<Directory> resolveExportDir() async {
    final dirs = await getCandidateDirs();
    return dirs.first;
  }

  static Future<List<File>> scanBackupFiles() async {
    final dirs = await getCandidateDirs();
    final List<File> files = [];
    for (final dir in dirs) {
      try {
        if (dir.existsSync()) {
          final fList = dir.listSync().whereType<File>().where((f) {
            final p = f.path.toLowerCase();
            return p.endsWith('.json') || p.endsWith('.fib');
          });
          files.addAll(fList);
        }
      } catch (_) {}
    }
    files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
    final seen = <String>{};
    return files.where((f) => seen.add(f.path)).toList();
  }

  static Future<String> saveExportFile(String fileName, String content) async {
    final dirs = await getCandidateDirs();
    for (final dir in dirs) {
      try {
        if (!dir.existsSync()) dir.createSync(recursive: true);
        final file = File('${dir.path}/$fileName');
        file.writeAsStringSync(content, flush: true);
        return file.path;
      } catch (_) {
        continue;
      }
    }
    final file = File('${Directory.systemTemp.path}/$fileName');
    file.writeAsStringSync(content, flush: true);
    return file.path;
  }

  static Future<void> exportJsonBackup(BuildContext context, FinanceState state) async {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      await BackupExportModal.show(context, state: state);
    } else {
      await BackupPasswordPromptModal.show(context, onConfirmed: (password) {
        BackupExportModal.show(context, state: state, password: password);
      });
    }
  }

  static Future<void> importJsonBackup(BuildContext context, FinanceState state) async {
    await OnboardingImportModal.show(context, onImportSuccess: () {
      context.read<FinanceBloc>().add(const LoadFinanceData());
    });
  }
}
