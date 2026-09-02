import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';

import 'package:fibonanci_app/data/database/app_database.dart';
import 'package:fibonanci_app/data/repositories/finance_repository.dart';
import 'package:fibonanci_app/main.dart';
import 'package:fibonanci_app/presentation/screens/wallet_detail_screen.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  group('Full-Screen Wallet Account Details Tests', () {
    late AppDatabase db;
    late DriftFinanceRepository repo;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      repo = DriftFinanceRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    testWidgets('Renders compact minimalist account details with trend chart, search, and filter chips', (tester) async {
      tester.view.physicalSize = const Size(400 * 2, 950 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // 1. Seed initial data
      final wallets = await db.select(db.wallets).get();
      final bca = wallets.firstWhere((w) => w.name.contains('BCA Utama'));
      final categories = await db.select(db.categories).get();

      const uuid = Uuid();
      final now = DateTime.now().toUtc();

      // Log an income and an expense transaction
      await db.logTransactionWithBalanceMutation(
        tx: TransactionsCompanion(
          id: drift.Value(uuid.v4()),
          walletId: drift.Value(bca.id),
          categoryId: drift.Value(categories.first.id),
          amount: const drift.Value(500000.0),
          type: const drift.Value('income'),
          notes: const drift.Value('Bonus Proyek Freelance'),
          transactionDate: drift.Value(now),
          createdAt: drift.Value(now),
          updatedAt: drift.Value(now),
        ),
      );

      await db.logTransactionWithBalanceMutation(
        tx: TransactionsCompanion(
          id: drift.Value(uuid.v4()),
          walletId: drift.Value(bca.id),
          categoryId: drift.Value(categories.first.id),
          amount: const drift.Value(75000.0),
          type: const drift.Value('expense'),
          notes: const drift.Value('Makan Siang Resto'),
          transactionDate: drift.Value(now),
          createdAt: drift.Value(now),
          updatedAt: drift.Value(now),
        ),
      );

      // 2. Launch application
      await tester.pumpWidget(FiBOnanciApp(database: db, repository: repo));
      await tester.pumpAndSettle();

      // 3. Navigate to Wallets tab
      await tester.tap(find.text('7 Akun Riil'));
      await tester.pumpAndSettle();

      // 4. Tap 1: Expand BCA card in deck -> Tap 2: Open Full-Screen Detail Modal with Hero morph
      final bcaFinder = find.text('BCA Utama').first;
      await tester.tap(bcaFinder);
      await tester.pumpAndSettle();
      await tester.tap(bcaFinder);
      await tester.pumpAndSettle();
      // 5. Verify WalletDetailScreen Header & Components
      expect(find.byType(WalletDetailScreen), findsOneWidget);
      expect(find.text('Detail Rekening'), findsOneWidget);
      expect(find.text('Informasi & Mutasi'), findsOneWidget);
      expect(find.text('Ubah Saldo'), findsOneWidget);
      expect(find.text('Catat Transaksi'), findsOneWidget);
      // Verify 30-Day Trend Chart
      expect(find.text('Tren Mutasi BCA Utama'), findsOneWidget);

      // Verify Riwayat Transaksi (No filter chips visible by default)
      expect(find.text('Riwayat Transaksi'), findsOneWidget);
      expect(find.textContaining('Tipe:'), findsNothing);

      // Drag up to bring transaction list into viewport
      await tester.drag(find.byType(CustomScrollView).last, const Offset(0, -400));
      await tester.pumpAndSettle();

      expect(find.text('Bonus Proyek Freelance'), findsOneWidget);
      expect(find.text('Makan Siang Resto'), findsOneWidget);

      // 6. Test Interactive Search
      await tester.enterText(find.byType(TextField).first, 'Freelance');
      await tester.pumpAndSettle();

      expect(find.text('Bonus Proyek Freelance'), findsOneWidget);
      expect(find.text('Makan Siang Resto'), findsNothing);

      // Clear search
      await tester.enterText(find.byType(TextField).first, '');
      await tester.pumpAndSettle();

      expect(find.text('Bonus Proyek Freelance'), findsOneWidget);
      expect(find.text('Makan Siang Resto'), findsOneWidget);

      // 7. Test Filter Modal & Active Filter Chip (Pemasukan only)
      await tester.tap(find.byIcon(Icons.tune).last);
      await tester.pumpAndSettle();

      expect(find.text('Filter Transaksi'), findsOneWidget);
      await tester.tap(find.text('Pemasukan'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Terapkan Filter'));
      await tester.pumpAndSettle();

      // Active filter chip appears only when filter is active!
      expect(find.text('Tipe: MASUK'), findsOneWidget);
      expect(find.text('Bonus Proyek Freelance'), findsOneWidget);
      expect(find.text('Makan Siang Resto'), findsNothing);
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pumpAndSettle();

      // Verified returned to resting wallet deck
      expect(find.byType(WalletDetailScreen), findsNothing);
      expect(find.text('Rekening & Dompet'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('Modal close actions and cancel buttons dismiss EditBalanceModal and TransactionModal cleanly', (tester) async {
      tester.view.physicalSize = const Size(400 * 2, 950 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // 1. Launch application and navigate to Wallets tab
      await tester.pumpWidget(FiBOnanciApp(database: db, repository: repo));
      await tester.pumpAndSettle();

      await tester.tap(find.text('7 Akun Riil'));
      await tester.pumpAndSettle();

      // 2. Tap 1: Expand BCA card -> Tap 2: Open BCA detail modal
      final bcaFinder = find.text('BCA Utama').first;
      await tester.tap(bcaFinder);
      await tester.pumpAndSettle();
      await tester.tap(bcaFinder);
      await tester.pumpAndSettle();
      // 3. Open Ubah Saldo modal
      await tester.tap(find.text('Ubah Saldo'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Penyesuaian Saldo: BCA Utama'), findsOneWidget);
      expect(find.text('Perbarui Saldo'), findsOneWidget);
      expect(find.text('Batal'), findsOneWidget);

      // Tap Batal button to dismiss
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Penyesuaian Saldo: BCA Utama'), findsNothing);
      // Verify user STAYS on account details overlay!
      expect(find.text('Ubah Saldo'), findsOneWidget);
      expect(find.text('Catat Transaksi'), findsOneWidget);

      // 4. Tap Catat Transaksi from detail overlay
      await tester.tap(find.text('Catat Transaksi'));
      await tester.pumpAndSettle();

      expect(find.text('Simpan Transaksi'), findsOneWidget);
      expect(find.text('Batal'), findsOneWidget);

      // Tap Batal button to dismiss
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();

      expect(find.text('Simpan Transaksi'), findsNothing);
      // Verify user STAYS on account details overlay!
      expect(find.text('Ubah Saldo'), findsOneWidget);
      expect(find.text('Catat Transaksi'), findsOneWidget);

      // 5. Perform real balance update from account details
      await tester.tap(find.text('Ubah Saldo'));
      await tester.pumpAndSettle();

      final balanceField = find.descendant(of: find.byType(BottomSheet).last, matching: find.byType(TextField)).first;
      await tester.enterText(balanceField, '25000000');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Perbarui Saldo'));
      await tester.pumpAndSettle();
      // Verify user STAYS on account details overlay and sees updated balance!
      expect(find.text('Ubah Saldo'), findsOneWidget);
      expect(find.text('Catat Transaksi'), findsOneWidget);
      expect(find.textContaining('25.000.000'), findsWidgets);

      // 6. Record transaction from account details
      await tester.tap(find.text('Catat Transaksi'));
      await tester.pumpAndSettle();

      final amountField = find.descendant(of: find.byType(BottomSheet).last, matching: find.byType(TextField)).first;
      await tester.enterText(amountField, '750000');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Simpan Transaksi'));
      await tester.pumpAndSettle();
      // Verify user STAYS on account details overlay and transaction was logged!
      expect(find.text('Ubah Saldo'), findsOneWidget);
      expect(find.text('Catat Transaksi'), findsOneWidget);
      expect(find.textContaining('750.000'), findsWidgets);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 100));
    });
  });
}
