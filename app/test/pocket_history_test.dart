import 'package:drift/native.dart';
import 'package:fibonanci_app/bloc/finance/finance_bloc.dart';
import 'package:fibonanci_app/bloc/finance/finance_event.dart';
import 'package:fibonanci_app/bloc/finance/finance_state.dart';
import 'package:fibonanci_app/data/database/app_database.dart';
import 'package:fibonanci_app/data/repositories/finance_repository.dart';
import 'package:fibonanci_app/presentation/modals/pocket_detail_modal.dart';
import 'package:fibonanci_app/presentation/screens/wallet_screen.dart';
import 'package:fibonanci_app/presentation/widgets/pocket_transaction_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  group('Riwayat Kantong Tests', () {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final mockWallet = WalletEntry(
      id: 'w_bca',
      name: 'BCA Utama',
      type: 'bank',
      currency: 'IDR',
      balance: 5000000.0,
      colorHex: '#4D7CFE',
      iconName: 'bca',
      createdAt: DateTime(2026, 8, 1),
      updatedAt: DateTime(2026, 8, 1),
      isSynced: false,
      isDeleted: false,
    );

    final mockDepositTx = TransactionEntry(
      id: 'tx_dep_1',
      walletId: 'w_bca',
      categoryId: '11111111-1111-4111-8111-111111111111',
      amount: 500000.0,
      type: 'transfer',
      notes: 'Setoran ke Kantong Dana Darurat',
      transactionDate: DateTime(2026, 8, 29, 14, 30),
      source: 'manual',
      createdAt: DateTime(2026, 8, 29),
      updatedAt: DateTime(2026, 8, 29),
      isSynced: false,
      isDeleted: false,
    );

    final mockWithdrawalTx = TransactionEntry(
      id: 'tx_with_1',
      walletId: 'w_bca',
      categoryId: '11111111-1111-4111-8111-111111111111',
      amount: 150000.0,
      type: 'income',
      notes: 'Penarikan dari Kantong Dana Darurat',
      transactionDate: DateTime(2026, 8, 30, 10, 15),
      source: 'manual',
      createdAt: DateTime(2026, 8, 30),
      updatedAt: DateTime(2026, 8, 30),
      isSynced: false,
      isDeleted: false,
    );

    testWidgets('PocketTransactionTile displays deposit and withdrawal correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                PocketTransactionTile(
                  transaction: mockDepositTx,
                  wallets: [mockWallet],
                  currencyFormatter: currencyFormatter,
                ),
                PocketTransactionTile(
                  transaction: mockWithdrawalTx,
                  wallets: [mockWallet],
                  currencyFormatter: currencyFormatter,
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Check deposit tile
      expect(find.text('Setoran ke Kantong Dana Darurat'), findsOneWidget);
      expect(find.textContaining('Dari BCA Utama'), findsOneWidget);
      expect(find.text('+Rp 500.000'), findsOneWidget);
      expect(find.byIcon(Icons.south_west_rounded), findsOneWidget);

      // 2. Check withdrawal tile
      expect(find.text('Penarikan dari Kantong Dana Darurat'), findsOneWidget);
      expect(find.textContaining('Ke BCA Utama'), findsOneWidget);
      expect(find.text('-Rp 150.000'), findsOneWidget);
      expect(find.byIcon(Icons.north_east_rounded), findsOneWidget);
    });

    testWidgets('PocketDetailModal shows Riwayat Mutasi section and filtered items', (tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      final repo = DriftFinanceRepository(db);
      final bloc = FinanceBloc(repository: repo);

      bloc.add(const LoadFinanceData());
      await expectLater(
        bloc.stream,
        emitsThrough(predicate<FinanceState>((s) => s.status == FinanceStatus.success)),
      );
      final pocket = PocketEntry(
        id: 'p_darurat',
        name: 'Dana Darurat',
        type: 'emergency',
        targetAmount: 10000000.0,
        currentAmount: 500000.0,
        colorHex: '#7EF24E',
        iconName: 'emergency',
        createdAt: DateTime(2026, 8, 1),
        updatedAt: DateTime(2026, 8, 1),
        isSynced: false,
        isDeleted: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: bloc,
            child: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => PocketDetailModal.show(context, pocket: pocket),
                  child: const Text('Buka Modal'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Buka Modal'));
      await tester.pumpAndSettle();

      // Verify Header & Riwayat Mutasi section
      expect(find.text('Dana Darurat'), findsWidgets);
      expect(find.text('Riwayat Mutasi'), findsOneWidget);
      expect(find.text('Belum ada riwayat mutasi'), findsOneWidget);

      await db.close();
    });

    testWidgets('WalletScreen stays clean without global history, and displays Riwayat Mutasi when pocket is tapped', (tester) async {
      tester.view.physicalSize = const Size(400 * 2, 900 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final db = AppDatabase(NativeDatabase.memory());
      final repo = DriftFinanceRepository(db);
      final bloc = FinanceBloc(repository: repo);

      // Create a test pocket in database
      await repo.addPocket(
        name: 'Tabungan Nikah',
        type: 'dream',
        targetAmount: 50000000.0,
        initialAmount: 1000000.0,
        colorHex: '#4ECAFF',
        iconName: 'dream',
      );

      bloc.add(const LoadFinanceData());
      await expectLater(
        bloc.stream,
        emitsThrough(predicate<FinanceState>((s) => s.status == FinanceStatus.success && s.pockets.isNotEmpty && s.transactions.isNotEmpty)),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: bloc,
            child: const WalletScreen(initialSegment: 1),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify global Riwayat Mutasi Kantong is removed from WalletScreen (clean UI)
      expect(find.text('Riwayat Mutasi Kantong'), findsNothing);

      // Tap the pocket card to open its detail modal
      await tester.tap(find.text('Tabungan Nikah'));
      await tester.pumpAndSettle();

      // Verify Riwayat Mutasi section is visible inside the tapped pocket's modal
      expect(find.text('Riwayat Mutasi'), findsOneWidget);
      expect(find.text('1 mutasi'), findsOneWidget);
      expect(find.text('Setoran ke Kantong Tabungan Nikah (Awal)'), findsOneWidget);
      expect(find.text('+Rp 1.000.000'), findsOneWidget);

      await db.close();
    });
  });
}
