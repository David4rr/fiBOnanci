import 'dart:io';
import 'package:drift/native.dart';
import 'package:fibonanci_app/bloc/finance/finance_bloc.dart';
import 'package:fibonanci_app/bloc/finance/finance_event.dart';
import 'package:fibonanci_app/bloc/finance/finance_state.dart';
import 'package:fibonanci_app/core/storage/profile_preferences_storage.dart';
import 'package:fibonanci_app/data/database/app_database.dart';
import 'package:fibonanci_app/data/repositories/finance_repository.dart';
import 'package:fibonanci_app/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OnboardingScreen 5-Step Native Flow Tests', () {
    late AppDatabase db;
    late DriftFinanceRepository repo;
    late FinanceBloc bloc;

    setUp(() async {
      ProfilePreferencesStorage.resetForTest();
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

    testWidgets('Renders Step 1 (Name), validates empty name, advances when filled', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: bloc,
            child: OnboardingScreen(onComplete: () {}),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('onb_lang_continue_btn')), findsOneWidget);
      await tester.tap(find.byKey(const Key('onb_lang_continue_btn')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('welcome_start_new_btn')), findsOneWidget);
      await tester.tap(find.byKey(const Key('welcome_start_new_btn')));
      await tester.pumpAndSettle();

      expect(find.text('Halo! Siapa namamu?'), findsOneWidget);
      expect(find.text('Langkah 1 dari 5'), findsOneWidget);

      // Cannot advance when empty
      await tester.tap(find.text('Lanjut'));
      await tester.pumpAndSettle();
      expect(find.text('Halo! Siapa namamu?'), findsOneWidget);

      // Enter name
      await tester.enterText(find.byType(TextField).first, 'Budi Santoso');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Lanjut'));
      await tester.pumpAndSettle();

      // Step 2 is shown
      expect(find.textContaining('Senang kenal, Budi'), findsOneWidget);
      expect(find.text('Langkah 2 dari 5'), findsOneWidget);
    });

    testWidgets('Walks through all 5 steps and completes onboarding', (tester) async {
      tester.view.physicalSize = const Size(430 * 2, 932 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      bool completed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: bloc,
              child: OnboardingScreen(onComplete: () => completed = true),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('onb_lang_continue_btn')), findsOneWidget);
      await tester.tap(find.byKey(const Key('onb_lang_continue_btn')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('welcome_start_new_btn')), findsOneWidget);
      await tester.tap(find.byKey(const Key('welcome_start_new_btn')));
      await tester.pumpAndSettle();

      // Step 1: Name
      await tester.enterText(find.byType(TextField).first, 'Budi Santoso');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lanjut'));
      await tester.pumpAndSettle();

      // Step 2: Username & Occupation
      expect(find.text('budi_santoso'), findsOneWidget);
      await tester.tap(find.text('Lanjut'));
      await tester.pumpAndSettle();

      // Step 3: Income (Skip)
      expect(find.text('Berapa pemasukanmu per bulan?'), findsOneWidget);
      expect(find.text('Lewati'), findsOneWidget);
      await tester.tap(find.text('Lewati'));
      await tester.pumpAndSettle();

      // Step 4: Wallet
      expect(find.text('Di mana uangmu sekarang?'), findsOneWidget);
      await tester.tap(find.text('Mandiri'));
      await tester.pumpAndSettle();

      final balanceInput = find.widgetWithText(TextField, '0');
      await tester.enterText(balanceInput, '2500000');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Lanjut'));
      await tester.pumpAndSettle();

      // Step 5: Celebration
      expect(find.textContaining('Selamat datang, Budi!'), findsOneWidget);
      expect(find.text('Mulai Aplikasi'), findsOneWidget);

      await tester.tap(find.text('Mulai Aplikasi'));
      await tester.pumpAndSettle();

      expect(completed, isTrue);
      expect(ProfilePreferencesStorage.isOnboardingCompleted(), isTrue);

      final wallets = await tester.runAsync(() async => await repo.getWallets());
      expect(wallets?.any((w) => w.name == 'Mandiri' && w.balance == 2500000.0), isTrue);
    });

    testWidgets('Import JSON from onboarding welcome screen restores data and completes onboarding', (tester) async {
      bool completed = false;
      final sampleJson = '''
      {
        "wallets": [
          {
            "id": "imported_w1",
            "name": "BCA Prioritas",
            "type": "bank",
            "currency": "IDR",
            "balance": 50000000.0,
            "colorHex": "#0060AF",
            "iconName": "landmark",
            "createdAt": "2026-08-20T10:00:00.000Z",
            "updatedAt": "2026-08-20T10:00:00.000Z",
            "isSynced": false,
            "isDeleted": false
          }
        ]
      }
      ''';

      final tempFile = File('${Directory.systemTemp.path}/fibonanci_test_backup.json');
      tempFile.writeAsStringSync(sampleJson);
      addTearDown(() {
        if (tempFile.existsSync()) tempFile.deleteSync();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: bloc,
              child: OnboardingScreen(onComplete: () => completed = true),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('onb_lang_en_btn')), findsOneWidget);
      await tester.tap(find.byKey(const Key('onb_lang_en_btn')));
      await tester.pumpAndSettle();
      expect(find.text('Choose Your Language'), findsOneWidget);

      await tester.tap(find.byKey(const Key('onb_lang_id_btn')));
      await tester.pumpAndSettle();
      expect(find.text('Pilih Bahasa'), findsOneWidget);

      await tester.tap(find.byKey(const Key('onb_lang_continue_btn')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('welcome_import_backup_btn')), findsOneWidget);
      await tester.tap(find.byKey(const Key('welcome_import_backup_btn')));
      await tester.pumpAndSettle();

      expect(find.text('Pulihkan Data (.JSON)'), findsOneWidget);
      expect(find.text('fibonanci_test_backup.json'), findsOneWidget);

      await tester.tap(find.text('fibonanci_test_backup.json'));
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 30));
      }
      await tester.pumpAndSettle();

      expect(completed, isTrue);
      expect(ProfilePreferencesStorage.isOnboardingCompleted(), isTrue);

      final wallets = await tester.runAsync(() async => await repo.getWallets());
      expect(wallets?.any((w) => w.name == 'BCA Prioritas' && w.balance == 50000000.0), isTrue);
    });
  });
}
