import 'package:drift/native.dart';
import 'package:fibonanci_app/bloc/finance/finance_bloc.dart';
import 'package:fibonanci_app/bloc/finance/finance_event.dart';
import 'package:fibonanci_app/bloc/finance/finance_state.dart';
import 'package:fibonanci_app/data/database/app_database.dart';
import 'package:fibonanci_app/data/repositories/finance_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() {
    initializeDateFormatting('id_ID', null);
  });

  group('Multi-Profile Workspace Financial Data Partitioning Tests', () {
    late AppDatabase db;
    late DriftFinanceRepository repo;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repo = DriftFinanceRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('Default profile owns initial seeded wallets and transactions', () async {
      final profiles = await repo.getProfiles();
      expect(profiles, isNotEmpty);
      final defaultProfile = profiles.first;

      final personalWallets = await repo.getWallets(profileId: defaultProfile.id);
      expect(personalWallets.length, 7);
      expect(personalWallets.any((w) => w.name == 'BCA Utama'), isTrue);
    });

    test('Creating second profile provides clean empty workspace', () async {
      await repo.addProfile(
        username: 'Bisnis',
        fullName: 'PT Maju Bersama',
        currency: 'IDR',
        monthlyIncomeTarget: 50000000.0,
      );

      final profiles = await repo.getProfiles();
      expect(profiles.length, 2);
      final bizProfile = profiles.firstWhere((p) => p.username == 'Bisnis');

      final bizWallets = await repo.getWallets(profileId: bizProfile.id);
      expect(bizWallets, isEmpty);

      final bizTxs = await repo.getTransactions(profileId: bizProfile.id);
      expect(bizTxs, isEmpty);

      final bizSubs = await repo.getSubscriptions(profileId: bizProfile.id);
      expect(bizSubs, isEmpty);
    });

    test('FinanceBloc partitions wallets and recalculates metrics on profile switch', () async {
      final bloc = FinanceBloc(repository: repo);
      addTearDown(bloc.close);

      bloc.add(const LoadFinanceData());
      await expectLater(
        bloc.stream,
        emitsThrough(predicate<FinanceState>((s) => s.status == FinanceStatus.success && s.wallets.length == 7)),
      );

      final personalBalance = bloc.state.metrics.totalRealBalance;
      expect(personalBalance, greaterThan(0));

      // Add a business profile
      bloc.add(const AddProfileEvent(
        username: 'Bisnis',
        fullName: 'PT Sukses Mandiri',
        currency: 'IDR',
      ));
      await expectLater(
        bloc.stream,
        emitsThrough(predicate<FinanceState>((s) => s.profiles.length == 2)),
      );

      final bizProfile = bloc.state.profiles.firstWhere((p) => p.username == 'Bisnis');

      // Switch to business profile
      bloc.add(SetActiveProfileEvent(bizProfile.id));
      await expectLater(
        bloc.stream,
        emitsThrough(predicate<FinanceState>((s) => s.activeProfile?.id == bizProfile.id && s.wallets.isEmpty)),
      );

      expect(bloc.state.wallets, isEmpty);
      expect(bloc.state.metrics.totalRealBalance, 0.0);

      // Add a business wallet in the business profile
      bloc.add(const AddWalletEvent(
        name: 'Rekening Giro Bisnis',
        type: 'bank',
        initialBalance: 25000000.0,
        colorHex: '#002D62',
        iconName: 'building_2',
      ));
      await expectLater(
        bloc.stream,
        emitsThrough(predicate<FinanceState>((s) => s.wallets.length == 1 && s.wallets.first.name == 'Rekening Giro Bisnis')),
      );

      expect(bloc.state.metrics.totalRealBalance, 25000000.0);

      // Switch BACK to personal profile
      final personalProfile = bloc.state.profiles.firstWhere((p) => p.username == 'David');
      bloc.add(SetActiveProfileEvent(personalProfile.id));
      await expectLater(
        bloc.stream,
        emitsThrough(predicate<FinanceState>((s) => s.activeProfile?.id == personalProfile.id && s.wallets.length == 7)),
      );

      // Verify personal profile has its original wallets and balance, completely isolated from business
      expect(bloc.state.wallets.length, 7);
      expect(bloc.state.wallets.any((w) => w.name == 'Rekening Giro Bisnis'), isFalse);
      expect(bloc.state.metrics.totalRealBalance, personalBalance);

      // Switch to business profile again to confirm persistence
      bloc.add(SetActiveProfileEvent(bizProfile.id));
      await expectLater(
        bloc.stream,
        emitsThrough(predicate<FinanceState>((s) => s.activeProfile?.id == bizProfile.id && s.wallets.length == 1)),
      );

      expect(bloc.state.wallets.first.name, 'Rekening Giro Bisnis');
      expect(bloc.state.metrics.totalRealBalance, 25000000.0);
    });
  });
}
