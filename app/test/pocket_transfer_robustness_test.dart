import 'package:drift/native.dart';
import 'package:fibonanci_app/bloc/finance/finance_bloc.dart';
import 'package:fibonanci_app/bloc/finance/finance_event.dart';
import 'package:fibonanci_app/bloc/finance/finance_state.dart';
import 'package:fibonanci_app/data/database/app_database.dart';
import 'package:fibonanci_app/data/repositories/finance_repository.dart';
import 'package:fibonanci_app/presentation/modals/pocket_detail_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  group('Pocket Deposit & Withdrawal Robustness Tests', () {
    late AppDatabase db;
    late DriftFinanceRepository repo;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repo = DriftFinanceRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('transferPocketFunds enforces positive amount and prevents overdraft', () async {
      final wallets = await db.select(db.wallets).get();
      final wallet = wallets.first;

      await repo.addPocket(
        name: 'Kantong Pensiun',
        type: 'retirement',
        targetAmount: 50000000.0,
        initialAmount: 100000.0,
        colorHex: '#3B82F6',
        iconName: 'flag',
        linkedWalletId: wallet.id,
      );
      final pockets = await repo.getPockets();
      final pocket = pockets.first;

      // 1. Zero or negative amount throws ArgumentError
      expect(
        () => repo.transferPocketFunds(
          pocketId: pocket.id,
          walletId: wallet.id,
          amount: 0.0,
          isDepositToPocket: true,
        ),
        throwsA(isA<ArgumentError>()),
      );

      expect(
        () => repo.transferPocketFunds(
          pocketId: pocket.id,
          walletId: wallet.id,
          amount: -50000.0,
          isDepositToPocket: false,
        ),
        throwsA(isA<ArgumentError>()),
      );

      // 2. Withdrawal exceeding pocket balance throws StateError
      expect(
        () => repo.transferPocketFunds(
          pocketId: pocket.id,
          walletId: wallet.id,
          amount: 200000.0,
          isDepositToPocket: false,
        ),
        throwsA(isA<StateError>()),
      );

      // 3. Deposit exceeding wallet balance throws StateError
      expect(
        () => repo.transferPocketFunds(
          pocketId: pocket.id,
          walletId: wallet.id,
          amount: wallet.balance + 1000000.0,
          isDepositToPocket: true,
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('transferPocketFunds auto-links pocket.linkedWalletId if null and scopes profileId', () async {
      final wallets = await db.select(db.wallets).get();
      final wallet = wallets.first;

      // Pocket created with 0 initial amount and null linkedWalletId
      await repo.addPocket(
        name: 'Kantong Darurat',
        type: 'emergency',
        initialAmount: 0.0,
        colorHex: '#10B981',
        iconName: 'shield',
      );
      var pockets = await repo.getPockets();
      expect(pockets.first.linkedWalletId, isNull);

      // Deposit 50,000 to pocket
      await repo.transferPocketFunds(
        pocketId: pockets.first.id,
        walletId: wallet.id,
        amount: 50000.0,
        isDepositToPocket: true,
      );

      pockets = await repo.getPockets();
      // Should now be linked to wallet.id
      expect(pockets.first.linkedWalletId, wallet.id);
      expect(pockets.first.currentAmount, 50000.0);

      // Verify transaction ledger has correct profileId
      final txs = await repo.getTransactions();
      final pocketTx = txs.firstWhere((t) => t.externalRef == 'pocket_${pockets.first.id}');
      expect(pocketTx.profileId, wallet.profileId);
      expect(pocketTx.walletId, wallet.id);
    });

    testWidgets('PocketDetailSheet isolates mutations and syncs live account list in Tarik Dana', (tester) async {
      final bloc = FinanceBloc(repository: repo);
      addTearDown(bloc.close);
      bloc.add(const LoadFinanceData());
      await expectLater(
        bloc.stream,
        emitsThrough(predicate<FinanceState>((s) => s.status == FinanceStatus.success && s.wallets.isNotEmpty)),
      );

      final wallets = bloc.state.wallets;
      final wallet1 = wallets[0];
      final wallet2 = wallets[1];

      // Add two pockets
      await repo.addPocket(
        name: 'Pocket A',
        type: 'savings',
        initialAmount: 300000.0,
        colorHex: '#3B82F6',
        iconName: 'flag',
        linkedWalletId: wallet1.id,
      );
      await repo.addPocket(
        name: 'Pocket B',
        type: 'savings',
        initialAmount: 150000.0,
        colorHex: '#F59E0B',
        iconName: 'flag',
        linkedWalletId: wallet1.id,
      );

      // Deposit into Pocket B from wallet1
      final pockets = await repo.getPockets();
      final pocketA = pockets.firstWhere((p) => p.name == 'Pocket A');
      final pocketB = pockets.firstWhere((p) => p.name == 'Pocket B');

      await repo.transferPocketFunds(
        pocketId: pocketB.id,
        walletId: wallet1.id,
        amount: 50000.0,
        isDepositToPocket: true,
      );

      // Open Pocket A modal
      await tester.pumpWidget(
        BlocProvider<FinanceBloc>.value(
          value: bloc,
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => PocketDetailModal.show(context, pocket: pocketA),
                  child: const Text('Buka Modal A'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Buka Modal A'));
      await tester.pumpAndSettle();

      // Pocket A must NOT show mutations of Pocket B
      expect(find.text('Setoran ke Kantong Pocket B'), findsNothing);
      expect(find.text('Setoran ke Kantong Pocket A (Awal)'), findsOneWidget);

      // Switch to Tarik Dana
      await tester.tap(find.text('Tarik Dana'));
      await tester.pumpAndSettle();

      expect(find.text('Tarik Dana ke Rekening'), findsOneWidget);
      expect(find.text('Rekening Tujuan'), findsOneWidget);

      // Account dropdown contains both wallets with correct formatted balances
      expect(find.byType(DropdownButton<String>), findsOneWidget);
      final dropdown = tester.widget<DropdownButton<String>>(find.byType(DropdownButton<String>));
      expect(dropdown.items?.length, wallets.length);

      // Tap Tarik Semua fills exact pocketA balance
      await tester.tap(find.textContaining('Tarik Semua'));
      await tester.pumpAndSettle();

      final controller = tester.widget<TextField>(find.widgetWithText(TextField, 'Nominal')).controller;
      expect(controller?.text, '300.000');

      // Select wallet2 from dropdown
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining(wallet2.name).last);
      await tester.pumpAndSettle();

      // Confirm withdrawal to wallet2
      await tester.tap(find.text('Konfirmasi'));
      await tester.pumpAndSettle();

      // Verify returned to Tab 0 and new mutation tile exists
      expect(find.text('Riwayat Mutasi'), findsOneWidget);
      expect(find.text('Penarikan dari Kantong Pocket A'), findsOneWidget);
      expect(find.textContaining(wallet2.name), findsOneWidget);

    });
  });
}
