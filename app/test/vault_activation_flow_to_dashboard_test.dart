import 'package:drift/native.dart';
import 'package:fibonanci_app/bloc/finance/finance_bloc.dart';
import 'package:fibonanci_app/bloc/finance/finance_event.dart';
import 'package:fibonanci_app/core/storage/profile_preferences_storage.dart';
import 'package:fibonanci_app/data/database/app_database.dart';
import 'package:fibonanci_app/data/repositories/finance_repository.dart';
import 'package:fibonanci_app/presentation/screens/main_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  testWidgets('End-to-end: Clean production state creates wallet and populates Dashboard', (tester) async {
    tester.view.physicalSize = const Size(400 * 2, 900 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    ProfilePreferencesStorage.resetForTest();
    await ProfilePreferencesStorage.setOnboardingCompleted(false);

    final db = AppDatabase(NativeDatabase.memory());
    // Ensure schema is created before custom statements
    await db.select(db.wallets).get();
    // Wipe test seeded wallets to mirror 100% clean production environment!
    await db.customStatement('DELETE FROM wallets');
    await db.customStatement('DELETE FROM transactions');

    final repo = DriftFinanceRepository(db);
    final bloc = FinanceBloc(repository: repo)..add(const LoadFinanceData());

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<FinanceBloc>.value(
          value: bloc,
          child: MainShell(db: db),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Welcome screen is visible, then start new
    expect(find.byKey(const Key('welcome_start_new_btn')), findsOneWidget);
    await tester.tap(find.byKey(const Key('welcome_start_new_btn')));
    await tester.pumpAndSettle();

    // Verify Onboarding Step 1 is visible
    expect(find.text('Halo! Siapa namamu?'), findsOneWidget);

    // Enter name
    await tester.enterText(find.byType(TextField).first, 'Budi');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lanjut'));
    await tester.pumpAndSettle();

    // Step 2: Username & Occupation
    expect(find.textContaining('Senang kenal, Budi'), findsOneWidget);
    await tester.tap(find.text('Lanjut'));
    await tester.pumpAndSettle();

    // Step 3: Income (Skip)
    expect(find.text('Berapa pemasukanmu per bulan?'), findsOneWidget);
    await tester.tap(find.text('Lewati'));
    await tester.pumpAndSettle();

    // Step 4: Wallet
    expect(find.text('Di mana uangmu sekarang?'), findsOneWidget);
    final balanceInput = find.widgetWithText(TextField, '0');
    await tester.enterText(balanceInput, '1500000');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lanjut'));
    await tester.pumpAndSettle();

    // Step 5: Celebration
    expect(find.textContaining('Selamat datang, Budi!'), findsOneWidget);
    await tester.tap(find.text('Mulai Aplikasi'));
    await tester.pumpAndSettle();

    // 1. Must NOT show empty state
    expect(find.text('Belum Ada Rekening Terhubung'), findsNothing);

    // 2. Bento grid must display the active wallet and safe to spend
    expect(find.text('Safe to Spend'), findsOneWidget);
    expect(find.text('1 Akun Riil'), findsOneWidget);
    expect(find.textContaining('1.500.000'), findsWidgets);

    // 3. Must show Saldo Awal transaction
    expect(find.text('Saldo Awal'), findsOneWidget);

    // 4. Greeting must show personalized name
    expect(find.textContaining('budi'), findsWidgets);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await db.close();
  });

  testWidgets('When user already has wallets in database, Onboarding is skipped and Dashboard loads directly', (tester) async {
    tester.view.physicalSize = const Size(400 * 2, 900 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    ProfilePreferencesStorage.resetForTest();
    await ProfilePreferencesStorage.setOnboardingCompleted(false);

    final db = AppDatabase(NativeDatabase.memory());
    await db.select(db.wallets).get(); // ensure seeds exist (BCA & Mandiri)
    final repo = DriftFinanceRepository(db);
    final bloc = FinanceBloc(repository: repo)..add(const LoadFinanceData());

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<FinanceBloc>.value(
          value: bloc,
          child: MainShell(db: db),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Must NOT show onboarding
    expect(find.text('Halo! Siapa namamu?'), findsNothing);

    // Must show Dashboard Directly
    expect(find.text('Safe to Spend'), findsOneWidget);
    expect(ProfilePreferencesStorage.isOnboardingCompleted(), isTrue);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await db.close();
  });
}
