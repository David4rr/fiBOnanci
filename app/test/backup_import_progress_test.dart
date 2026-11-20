import 'dart:convert';
import 'package:drift/native.dart';
import 'package:fibonanci_app/bloc/finance/finance_bloc.dart';
import 'package:fibonanci_app/bloc/finance/finance_event.dart';
import 'package:fibonanci_app/bloc/finance/finance_state.dart';
import 'package:fibonanci_app/core/security/backup_cipher.dart';
import 'package:fibonanci_app/core/storage/profile_preferences_storage.dart';
import 'package:fibonanci_app/data/database/app_database.dart';
import 'package:fibonanci_app/data/repositories/finance_repository.dart';
import 'package:fibonanci_app/presentation/modals/settings/backup_export_modal.dart';
import 'package:fibonanci_app/presentation/screens/onboarding/onboarding_import_modal.dart';
import 'package:fibonanci_app/presentation/screens/onboarding/onboarding_import_progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Backup & Import Progress UI Tests', () {
    late AppDatabase db;
    late DriftFinanceRepository repo;
    late FinanceBloc bloc;

    setUp(() async {
      ProfilePreferencesStorage.resetForTest();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform, (MethodCall m) async => null,
      );
      db = AppDatabase(NativeDatabase.memory());
      repo = DriftFinanceRepository(db);
      bloc = FinanceBloc(repository: repo)..add(const LoadFinanceData());
      await bloc.stream.firstWhere((s) => s.status == FinanceStatus.success);
    });

    tearDown(() async {
      await bloc.close();
      await db.close();
      ProfilePreferencesStorage.resetForTest();
    });

    testWidgets('BackupExportModal shows progress stages then completes with summary', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () => BackupExportModal.show(ctx, state: bloc.state),
                child: const Text('Backup'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Backup'));
      await tester.pump();

      // Check progress header & steps
      expect(find.text('Menyimpan Cadangan JSON'), findsOneWidget);
      expect(find.text('Mengumpulkan Data Akun'), findsOneWidget);
      expect(find.text('Mengemas & Menyalin Teks'), findsOneWidget);
      expect(find.text('Menulis Berkas Penyimpanan'), findsOneWidget);

      // Advance through steps
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 30));
      }
      await tester.pumpAndSettle();

      // Completed view
      expect(find.text('Cadangan Berhasil Disimpan!'), findsOneWidget);
      expect(find.textContaining('LOKASI PENYIMPANAN:'), findsOneWidget);
      expect(find.text('Pilih Lokasi Lain / Bagikan Berkas'), findsOneWidget);
      expect(find.text('Selesai'), findsOneWidget);

      // Close modal
      await tester.tap(find.text('Selesai'));
      await tester.pumpAndSettle();
      expect(find.text('Cadangan Berhasil Disimpan!'), findsNothing);
    });

    testWidgets('OnboardingImportProgress handles error and retry cleanly', (tester) async {
      bool retried = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OnboardingImportProgress(
              step: 1,
              isSuccess: false,
              errorMessage: 'Format berkas tidak valid',
              onContinue: () {},
              onRetry: () => retried = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Gagal Memulihkan Data'), findsOneWidget);
      expect(find.text('Format berkas tidak valid'), findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);

      await tester.tap(find.text('Coba Lagi'));
      await tester.pumpAndSettle();
      expect(retried, isTrue);
    });

    testWidgets('OnboardingImportModal invalid JSON shows friendly error and allows retry', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: bloc,
              child: Builder(
                builder: (ctx) => ElevatedButton(
                  onPressed: () => OnboardingImportModal.show(ctx, onImportSuccess: () {}, initialJson: '{"invalid_data": 123}'),
                  child: const Text('Open Import'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Import'));
      await tester.pumpAndSettle();

      // Shows error message
      expect(find.textContaining('Data cadangan tidak valid'), findsOneWidget);
    });

    testWidgets('Encrypted JSON backup requires password and restores on correct password', (tester) async {
      bool restored = false;
      final rawData = {
        'wallets': [{
          'id': 'w_enc_1',
          'name': 'BCA Prioritas',
          'type': 'bank',
          'currency': 'IDR',
          'balance': 50000000.0,
          'colorHex': '#0066AE',
          'iconName': 'account_balance',
          'isSynced': false,
          'isDeleted': false,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        }],
      };
      final encryptedPayload = BackupCipher.encrypt(rawData, 'kuncirahas1a');
      final jsonStr = jsonEncode(encryptedPayload);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: bloc,
              child: Builder(
                builder: (ctx) => ElevatedButton(
                  onPressed: () => OnboardingImportModal.show(ctx, onImportSuccess: () => restored = true, initialJson: jsonStr),
                  child: const Text('Open Import Encrypted'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Import Encrypted'));
      await tester.pumpAndSettle();

      expect(find.text('Cadangan Terenkripsi (AES-256)'), findsOneWidget);
      expect(find.text('Buka Kunci & Pulihkan'), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, 'sandisalah');
      await tester.tap(find.text('Buka Kunci & Pulihkan'));
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.textContaining('Kata sandi salah'), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, 'kuncirahas1a');
      await tester.tap(find.text('Buka Kunci & Pulihkan'));
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 30));
      }
      await tester.pumpAndSettle();

      expect(restored, isTrue);
    });
  });
}
