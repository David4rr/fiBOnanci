import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../core/native_bridge/security_bridge.dart';

class DatabaseEncryption {
  static const List<int> _sqliteHeaderBytes = [
    83, 81, 76, 105, 116, 101, 32, 102, 111, 114, 109, 97, 116, 32, 51, 0,
  ];

  static String escapeKey(String key) => key.replaceAll("'", "''");

  static bool isPlaintextSqliteFile(File file) {
    if (!file.existsSync()) return false;
    final len = file.lengthSync();
    if (len < 16) return false;
    final raf = file.openSync(mode: FileMode.read);
    try {
      final header = raf.readSync(16);
      if (header.length < 16) return false;
      for (int i = 0; i < 16; i++) {
        if (header[i] != _sqliteHeaderBytes[i]) return false;
      }
      return true;
    } finally {
      raf.closeSync();
    }
  }

  static void migratePlaintextToEncryptedIfNeeded(File file, String key) {
    if (!isPlaintextSqliteFile(file)) return;
    final escaped = escapeKey(key);
    final rawDb = sqlite3.open(file.path);
    try {
      rawDb.execute("PRAGMA rekey = '$escaped';");
    } finally {
      rawDb.close();
    }
  }

  static void applyKey(Database rawDb, String key) {
    final escaped = escapeKey(key);
    rawDb.execute("PRAGMA key = '$escaped';");
  }

  static QueryExecutor openEncryptedFile(
    File file, {
    String? overrideKey,
    bool background = true,
  }) {
    return LazyDatabase(() async {
      final key = overrideKey ?? await SecurityBridge.getDatabaseEncryptionKey();
      migratePlaintextToEncryptedIfNeeded(file, key);
      if (background) {
        return NativeDatabase.createInBackground(
          file,
          setup: (rawDb) => applyKey(rawDb, key),
        );
      }
      return NativeDatabase(
        file,
        setup: (rawDb) => applyKey(rawDb, key),
      );
    });
  }
}
