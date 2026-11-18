import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fibonanci_app/bloc/finance/finance_bloc.dart';
import 'package:fibonanci_app/bloc/finance/finance_event.dart';
import 'package:fibonanci_app/bloc/finance/finance_state.dart';
import 'package:fibonanci_app/core/storage/profile_preferences_storage.dart';
import 'package:fibonanci_app/data/database/app_database.dart';
import 'package:fibonanci_app/data/repositories/finance_repository.dart';

void main() {
  late AppDatabase db;
  late DriftFinanceRepository repository;
  late Directory tempDir;
  late File prefFile;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('fibonanci_pref_test_');
    prefFile = File('${tempDir.path}/profile_preferences.json');
    ProfilePreferencesStorage.setStorageFile(prefFile);

    db = AppDatabase(NativeDatabase.memory());
    repository = DriftFinanceRepository(db);
  });

  tearDown(() async {
    ProfilePreferencesStorage.resetForTest();
    await db.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('Safe-to-Spend & Budget Cycle Persistence Tests', () {
    test('persists safeToSpendWalletIds across FinanceBloc instances / app restart', () async {
      final bloc1 = FinanceBloc(repository: repository);
      addTearDown(bloc1.close);

      bloc1.add(const LoadFinanceData());
      await expectLater(
        bloc1.stream,
        emitsThrough(predicate<FinanceState>((s) => s.status == FinanceStatus.success)),
      );

      final initialWallets = bloc1.state.wallets;
      expect(initialWallets.isNotEmpty, isTrue);
      final targetWalletId = initialWallets.first.id;

      // Initially null (Semua Rekening)
      expect(bloc1.state.safeToSpendWalletIds, isNull);

      // User configures Safe-to-Spend to only use targetWalletId
      bloc1.add(SetSafeToSpendWalletsEvent({targetWalletId}));
      await expectLater(
        bloc1.stream,
        emitsThrough(predicate<FinanceState>((s) => s.safeToSpendWalletIds?.contains(targetWalletId) == true)),
      );

      // Also set budget cycle day to 15
      bloc1.add(const SetBudgetCycleDayEvent(15));
      await expectLater(
        bloc1.stream,
        emitsThrough(predicate<FinanceState>((s) => s.budgetCycleDay == 15)),
      );

      // Verify file was written to disk
      expect(await prefFile.exists(), isTrue);

      // Simulate App Restart by creating bloc2
      final bloc2 = FinanceBloc(repository: repository);
      addTearDown(bloc2.close);

      bloc2.add(const LoadFinanceData());
      await expectLater(
        bloc2.stream,
        emitsThrough(predicate<FinanceState>((s) =>
          s.status == FinanceStatus.success &&
          s.safeToSpendWalletIds != null &&
          s.safeToSpendWalletIds!.contains(targetWalletId) &&
          s.budgetCycleDay == 15)),
      );

      // Verify state in bloc2 has persisted wallet IDs and budget cycle day
      expect(bloc2.state.safeToSpendWalletIds, equals({targetWalletId}));
      expect(bloc2.state.budgetCycleDay, equals(15));
    });

    test('persists resetting back to Semua Rekening (null)', () async {
      // First save target wallet
      await ProfilePreferencesStorage.setSafeToSpendWallets('default_profile_1', {'wallet_1'});
      await ProfilePreferencesStorage.setBudgetCycleDay('default_profile_1', 25);

      final bloc = FinanceBloc(repository: repository);
      addTearDown(bloc.close);

      bloc.add(const LoadFinanceData());
      await expectLater(
        bloc.stream,
        emitsThrough(predicate<FinanceState>((s) => s.status == FinanceStatus.success)),
      );
      expect(bloc.state.budgetCycleDay, equals(25));

      // Reset to Semua Rekening (null)
      bloc.add(const SetSafeToSpendWalletsEvent(null));
      await expectLater(
        bloc.stream,
        emitsThrough(predicate<FinanceState>((s) => s.safeToSpendWalletIds == null)),
      );

      // Restart app
      final blocRestarted = FinanceBloc(repository: repository);
      addTearDown(blocRestarted.close);

      blocRestarted.add(const LoadFinanceData());
      await expectLater(
        blocRestarted.stream,
        emitsThrough(predicate<FinanceState>((s) => s.status == FinanceStatus.success)),
      );

      expect(blocRestarted.state.safeToSpendWalletIds, isNull);
      expect(blocRestarted.state.budgetCycleDay, equals(25));
    });
  });
}
