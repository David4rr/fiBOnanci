import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'package:fibonanci_app/bloc/finance/finance_bloc.dart';
import 'package:fibonanci_app/bloc/finance/finance_event.dart';
import 'package:fibonanci_app/bloc/finance/finance_state.dart';
import 'package:fibonanci_app/data/database/app_database.dart';
import 'package:fibonanci_app/data/repositories/finance_repository.dart';
import 'package:fibonanci_app/main.dart';
import 'package:fibonanci_app/presentation/widgets/wallet_card.dart';
import 'package:fibonanci_app/presentation/widgets/wallet_card_pattern_painter.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  group('Wallet Deletion & Procedural Patterns Tests', () {
    late AppDatabase db;
    late DriftFinanceRepository repo;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      repo = DriftFinanceRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('WalletPatternHelper deterministically maps wallet IDs to varied patterns', () {
      final patterns = <WalletPatternType>{};

      // Test with multiple distinct IDs
      for (int i = 0; i < 20; i++) {
        final id = 'wallet-uuid-$i-test-seed';
        final pattern = WalletPatternHelper.getPatternForWallet(id);
        patterns.add(pattern);

        // Deterministic check: same ID always returns same pattern
        expect(WalletPatternHelper.getPatternForWallet(id), equals(pattern));
      }

      // Verify that diverse patterns from the 6 variations are utilized
      expect(patterns.length, greaterThanOrEqualTo(3));
      expect(WalletPatternType.values.length, 6);
    });

    test('deleteWallet soft-deletes wallet and disables associated notification rules', () async {
      // 1. Create a wallet with bound package
      await repo.addWallet(
        name: 'Rekening Cadangan Darurat',
        type: 'bank',
        initialBalance: 5000000.0,
        colorHex: '#60A5FA',
        iconName: 'wallet',
        boundPackageName: 'id.krom.bank',
      );

      var wallets = await repo.getWallets();
      final targetWallet = wallets.firstWhere((w) => w.name == 'Rekening Cadangan Darurat');

      var rules = await repo.getNotificationRulesForWallet(targetWallet.id);
      expect(rules.length, 1);
      expect(rules.first.isEnabled, isTrue);

      // 2. Delete wallet
      await repo.deleteWallet(targetWallet.id);

      // 3. Verify wallet is excluded from active wallets
      wallets = await repo.getWallets();
      expect(wallets.any((w) => w.id == targetWallet.id), isFalse);

      // 4. Verify notification rule is soft deleted / disabled
      rules = await repo.getNotificationRulesForWallet(targetWallet.id);
      expect(rules.isEmpty, isTrue);
    });

    test('FinanceBloc handles DeleteWalletEvent and recalculates state metrics', () async {
      final bloc = FinanceBloc(repository: repo);
      addTearDown(bloc.close);

      bloc.add(const LoadFinanceData());
      await Future.delayed(const Duration(milliseconds: 150));

      final initialWallets = bloc.state.wallets;
      expect(initialWallets.isNotEmpty, isTrue);

      final walletToDelete = initialWallets.first;
      bloc.add(DeleteWalletEvent(walletToDelete.id));

      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<FinanceState>((s) => !s.wallets.any((w) => w.id == walletToDelete.id)),
        ),
      );
    });

    testWidgets('WalletCard renders procedural pattern painter and tactile gradients', (tester) async {
      final wallets = await repo.getWallets();
      final wallet = wallets.first;
      final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WalletCard(
              wallet: wallet,
              index: 0,
              fmt: fmt,
              cardH: 200,
              showBottomLayout: true,
            ),
          ),
        ),
      );

      expect(find.text(wallet.name), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('Full UI wallet deletion flow via EditBalanceModal and WalletDetailOverlay', (tester) async {
      tester.view.physicalSize = const Size(400 * 2, 900 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(FiBOnanciApp(database: db, repository: repo));
      await tester.pumpAndSettle();

      // 1. Navigate to Wallets tab
      await tester.tap(find.text('7 Akun Riil'));
      await tester.pumpAndSettle();

      // 2. Tap BCA card in deck to lift it
      final bcaFinder = find.text('BCA Utama').first;
      await tester.tap(bcaFinder);
      await tester.pumpAndSettle();

      // 3. Verify WalletDetailOverlay appears with delete icon
      expect(find.text('Detail Rekening'), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);

      // 4. Tap delete icon to test confirmation dialog dismissal
      await tester.tap(find.byIcon(Icons.delete_outline_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Hapus Rekening?'), findsOneWidget);
      expect(find.text('Batal'), findsOneWidget);
      expect(find.text('Hapus'), findsOneWidget);

      // Tap Batal -> dialog cancels, overlay remains
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();
      expect(find.text('Detail Rekening'), findsOneWidget);

      // 5. Open Ubah Saldo to test EditBalanceModal deletion
      await tester.tap(find.text('Ubah Saldo'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Penyesuaian Saldo: BCA Utama'), findsOneWidget);
      expect(find.text('Hapus Rekening'), findsOneWidget);

      // Tap Hapus Rekening
      await tester.tap(find.text('Hapus Rekening'));
      await tester.pumpAndSettle();

      expect(find.text('Hapus Rekening?'), findsOneWidget);

      // Confirm deletion
      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle();

      // 6. Verify BCA Utama is no longer in active wallets!
      final activeWallets = await repo.getWallets();
      expect(activeWallets.any((w) => w.name.contains('BCA Utama')), isFalse);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 100));
    });
  });
}
