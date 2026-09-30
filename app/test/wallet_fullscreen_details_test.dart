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
      await tester.tap(find.byIcon(Icons.keyboard_arrow_down_rounded));
      await tester.pumpAndSettle();

      // Verified returned to resting wallet deck
      expect(find.byType(WalletDetailScreen), findsNothing);
      expect(find.text('Rekening & Dompet'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 100));
    });
  });
}
