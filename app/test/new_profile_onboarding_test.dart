import 'package:drift/native.dart';
import 'package:fibonanci_app/bloc/finance/finance_bloc.dart';
import 'package:fibonanci_app/bloc/finance/finance_event.dart';
import 'package:fibonanci_app/bloc/finance/finance_state.dart';
import 'package:fibonanci_app/core/storage/profile_preferences_storage.dart';
import 'package:fibonanci_app/data/database/app_database.dart';
import 'package:fibonanci_app/data/repositories/finance_repository.dart';
import 'package:fibonanci_app/l10n/app_localizations.dart';
import 'package:fibonanci_app/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  late AppDatabase db;
  late DriftFinanceRepository repo;
  late FinanceBloc bloc;

  setUp(() async {
    ProfilePreferencesStorage.resetForTest();
    db = AppDatabase(NativeDatabase.memory());
    await db.select(db.wallets).get();
    await db.customStatement('DELETE FROM wallets');
    await db.customStatement('DELETE FROM transactions');
    repo = DriftFinanceRepository(db);
    bloc = FinanceBloc(repository: repo)..add(const LoadFinanceData());
    await bloc.stream.firstWhere((s) => s.status == FinanceStatus.success);
  });

  tearDown(() async {
    await bloc.close();
    await db.close();
  });

  test('OnboardNewProfileEvent creates active profile and isolated initial wallet', () async {
    final oldProfileId = bloc.state.activeProfile!.id;
    final oldWallets = await repo.getWallets(profileId: oldProfileId);

    bloc.add(const OnboardNewProfileEvent(
      username: 'bisnis_vault',
      fullName: 'Bisnis Vault',
      occupation: 'Founder',
      monthlyIncomeTarget: 15000000,
      walletName: 'BCA Bisnis',
      walletType: 'bank',
      initialBalance: 5000000,
      colorHex: '#0060AF',
      iconName: 'landmark',
      createInitialTransaction: true,
    ));

    final updated = await bloc.stream.firstWhere(
      (s) => s.activeProfile?.username == 'bisnis_vault' && s.wallets.isNotEmpty && s.transactions.isNotEmpty,
    );

    expect(updated.activeProfile?.fullName, 'Bisnis Vault');
    expect(updated.activeProfile?.id, isNot(oldProfileId));
    expect(updated.wallets.length, 1);
    expect(updated.wallets.first.name, 'BCA Bisnis');
    expect(updated.wallets.first.balance, 5000000);
    expect(
      updated.transactions.any((t) => t.amount == 5000000 && t.walletId == updated.wallets.first.id),
      isTrue,
    );

    // Ensure old profile wallets were not polluted
    final oldWalletsAfter = await repo.getWallets(profileId: oldProfileId);
    expect(oldWalletsAfter.length, oldWallets.length);
  });

  testWidgets('OnboardingScreen(isNewProfile: true) skips welcome, blocks duplicate username, and creates profile', (tester) async {
    tester.view.physicalSize = const Size(400 * 2, 900 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final existingUsername = bloc.state.activeProfile!.username;
    bool completed = false;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('id'),
        home: BlocProvider<FinanceBloc>.value(
          value: bloc,
          child: OnboardingScreen(
            isNewProfile: true,
            onComplete: () => completed = true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Skips welcome screen and lands directly on Step 0 (Name)
    expect(find.byKey(const Key('welcome_start_new_btn')), findsNothing);
    expect(find.text('Halo! Siapa namamu?'), findsOneWidget);

    // Step 0 -> Name
    await tester.enterText(find.byType(TextField).first, 'Vault Kedua');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lanjut'));
    await tester.pumpAndSettle();

    // Step 1 -> Try duplicate username first
    await tester.enterText(find.byType(TextField).first, existingUsername);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lanjut'));
    await tester.pumpAndSettle();
    expect(find.text('Username sudah dipakai'), findsOneWidget);

    // Wait for snackbar to dismiss so it doesn't cover the bottom bar
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    // Fix username and continue
    await tester.enterText(find.byType(TextField).first, 'vault_kedua');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lanjut'));
    await tester.pumpAndSettle();

    // Step 2 -> Skip Income
    await tester.tap(find.text('Lewati'));
    await tester.pumpAndSettle();

    // Step 3 -> Wallet & Balance
    await tester.enterText(find.byType(TextField).last, '1000000');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lanjut'));
    await tester.pumpAndSettle();

    // Step 4 -> Finish
    await tester.tap(find.text('Mulai Aplikasi'));
    await tester.pumpAndSettle();

    expect(completed, isTrue);
    await tester.runAsync(() => bloc.stream.firstWhere(
          (s) => s.activeProfile?.username == 'vault_kedua' && s.wallets.isNotEmpty,
        ));
    expect(bloc.state.activeProfile?.username, 'vault_kedua');
    expect(bloc.state.wallets.first.balance, 1000000);
  });
}
