import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';

import 'package:fibonanci_app/data/database/app_database.dart';
import 'package:fibonanci_app/data/repositories/finance_repository.dart';
import 'package:fibonanci_app/main.dart';

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

      // 4. Tap BCA card in deck to trigger animated selection and open Full-Screen Details View
      final bcaFinder = find.text('BCA Utama').first;
      await tester.tap(bcaFinder);
      await tester.pumpAndSettle();

      // 5. Verify Full-Screen Header & Components (No cluttered Bento Grid)
      expect(find.text('Detail Rekening'), findsOneWidget);
      expect(find.text('Informasi & Mutasi'), findsOneWidget);
      expect(find.text('SALDO SAAT INI'), findsNothing);
      expect(find.text('ARUS KAS (30H)'), findsNothing);

      // Verify BottomNavDock is animated off-screen and faded out
      final dockSlide = tester.widget<AnimatedSlide>(find.byType(AnimatedSlide).first);
      expect(dockSlide.offset, const Offset(0, 1.8));
      final dockOpacity = tester.widget<AnimatedOpacity>(
        find.descendant(of: find.byType(AnimatedSlide), matching: find.byType(AnimatedOpacity)),
      );
      expect(dockOpacity.opacity, 0.0);
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
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Verified returned to resting wallet deck
      expect(find.text('Rekening & Dompet'), findsOneWidget);

      // Verified returned to resting wallet deck and BottomNavDock restored
      expect(find.text('Rekening & Dompet'), findsOneWidget);
      final restoredSlide = tester.widget<AnimatedSlide>(find.byType(AnimatedSlide).first);
      expect(restoredSlide.offset, Offset.zero);
      final restoredOpacity = tester.widget<AnimatedOpacity>(
        find.descendant(of: find.byType(AnimatedSlide), matching: find.byType(AnimatedOpacity)),
      );
      expect(restoredOpacity.opacity, 1.0);
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

      // 2. Open BCA detail overlay
      await tester.tap(find.text('BCA Utama').first);
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

      // 4. Re-open BCA detail overlay and tap Catat Transaksi
      await tester.tap(find.text('BCA Utama').first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Catat Transaksi'));
      await tester.pumpAndSettle();

      expect(find.text('Simpan Transaksi'), findsOneWidget);
      expect(find.text('Batal'), findsOneWidget);

      // Tap Batal button to dismiss
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();

      expect(find.text('Simpan Transaksi'), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 100));
    });
  });
}
