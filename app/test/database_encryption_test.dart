import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

import 'package:fibonanci_app/core/native_bridge/security_bridge.dart';
import 'package:fibonanci_app/data/database/app_database.dart';
import 'package:fibonanci_app/data/database/database_encryption.dart';
import 'package:fibonanci_app/presentation/widgets/common/app_lock_gate.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SQLite3MultipleCiphers Encryption & Auto-Migration Tests', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('fibonanci_enc_test_');
    });

    tearDown(() async {
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('Migrates existing plaintext database to encrypted in-place and preserves all rows', () async {
      final dbFile = File('${tempDir.path}/legacy_plaintext.sqlite');
      const testKey = '9f8e7d6c5b4a39281706f5e4d3c2b1a09f8e7d6c5b4a39281706f5e4d3c2b1a0';

      // 1. Create a legacy plaintext database and seed initial data
      final plainDb = AppDatabase(NativeDatabase(dbFile));
      final initialWallets = await plainDb.select(plainDb.wallets).get();
      expect(initialWallets, isNotEmpty);
      await plainDb.close();

      // Verify on-disk file starts with "SQLite format 3\x00"
      expect(DatabaseEncryption.isPlaintextSqliteFile(dbFile), isTrue);

      // 2. Open with DatabaseEncryption (triggers automatic in-place rekey migration)
      final encryptedDb = AppDatabase(
        DatabaseEncryption.openEncryptedFile(
          dbFile,
          overrideKey: testKey,
          background: false,
        ),
      );
      final migratedWallets = await encryptedDb.select(encryptedDb.wallets).get();
      expect(migratedWallets.length, equals(initialWallets.length));
      await encryptedDb.close();

      // 3. Verify on-disk file is NO LONGER plaintext ("SQLite format 3\x00" header is gone)
      expect(DatabaseEncryption.isPlaintextSqliteFile(dbFile), isFalse);

      // 4. Verify opening raw database WITHOUT key fails with SqliteException (not a database)
      final rawUnauthenticated = sqlite3.open(dbFile.path);
      expect(
        () => rawUnauthenticated.select('SELECT count(*) FROM wallets;'),
        throwsA(isA<SqliteException>()),
      );
      rawUnauthenticated.close();
    });

    testWidgets('AppLockGate displays lock overlay when biometricLockEnabled is true and unlocks on auth', (tester) async {
      const channel = MethodChannel('com.fibonanci.app/notification_service');
      bool authShouldSucceed = false;

      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'getSecuritySettings') {
          return {
            'biometricLockEnabled': true,
            'privacyScreenEnabled': true,
            'isDeviceSecure': true,
          };
        }
        if (call.method == 'authenticateBiometric') {
          return authShouldSucceed;
        }
        return null;
      });
      addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, null));

      await tester.pumpWidget(
        const MaterialApp(
          home: AppLockGate(
            child: Scaffold(body: Text('RAHASIA_SALDO_UTAMA')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initial auth returned false -> Lock overlay MUST be shown
      expect(find.byKey(const Key('app_lock_overlay')), findsOneWidget);
      expect(find.text('Brankas Terkunci'), findsOneWidget);

      // Now allow biometric auth to succeed and tap unlock button
      authShouldSucceed = true;
      await tester.tap(find.byKey(const Key('app_lock_unlock_btn')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('app_lock_overlay')), findsNothing);
      expect(find.text('RAHASIA_SALDO_UTAMA'), findsOneWidget);
      await SecurityBridge.setBiometricLockEnabled(false);
    });
  });
}
