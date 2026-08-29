import 'package:fibonanci_app/presentation/modals/all_transactions_modal.dart';
import 'package:fibonanci_app/data/repositories/finance_repository.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:fibonanci_app/data/database/app_database.dart';
import 'package:fibonanci_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:uuid/uuid.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  testWidgets('Tapping Lihat Semua opens full-screen Swiss-editorial Expenses Modal with stacked cards and expand chart', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400 * 2, 950 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final db = AppDatabase(NativeDatabase.memory());
    final wallets = await db.select(db.wallets).get();
    final bca = wallets.firstWhere((w) => w.name.contains('BCA Utama'));
    final categories = await db.select(db.categories).get();

    const uuid = Uuid();
    final now = DateTime(2026, 8, 29, 14, 30);

    // Seed multiple expense items matching reference (Amazon, Spotify, Taco Bell)
    await db.logTransactionWithBalanceMutation(
      tx: TransactionsCompanion(
        id: drift.Value(uuid.v4()),
        walletId: drift.Value(bca.id),
        categoryId: drift.Value(categories.first.id),
        amount: const drift.Value(1234000.0),
        type: const drift.Value('expense'),
        notes: const drift.Value('Amazon Belanja'),
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
        amount: const drift.Value(26000.0),
        type: const drift.Value('expense'),
        notes: const drift.Value('Spotify Family'),
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
        amount: const drift.Value(25500.0),
        type: const drift.Value('expense'),
        notes: const drift.Value('Taco Bell Lunch'),
        transactionDate: drift.Value(now),
        createdAt: drift.Value(now),
        updatedAt: drift.Value(now),
      ),
    );

    final repo = DriftFinanceRepository(db);
    await tester.pumpWidget(FiBOnanciApp(database: db, repository: repo));
    await tester.pumpAndSettle();

    // 1. Verify 'Lihat Semua' exists on Dashboard
    expect(find.text('Lihat Semua'), findsOneWidget);

    // 2. Tap 'Lihat Semua' to open AllTransactionsModal (Expenses)
    await tester.tap(find.text('Lihat Semua'));
    await tester.pumpAndSettle();

    // 3. Verify Full-Screen Expenses Modal is open
    expect(find.byType(AllTransactionsModal), findsOneWidget);
    expect(find.text('Riwayat\nPengeluaran'), findsOneWidget);
    expect(find.descendant(of: find.byType(AllTransactionsModal), matching: find.text('Amazon Belanja')), findsOneWidget);
    expect(find.descendant(of: find.byType(AllTransactionsModal), matching: find.text('Spotify Family')), findsOneWidget);
    expect(find.descendant(of: find.byType(AllTransactionsModal), matching: find.text('Taco Bell Lunch')), findsOneWidget);

    // 4. Tap 'Taco Bell Lunch' inside modal to expand and reveal 7-day bar chart
    await tester.tap(find.descendant(of: find.byType(AllTransactionsModal), matching: find.text('Taco Bell Lunch')));
    await tester.pumpAndSettle();

    // 5. Verify 7-day bar chart days are displayed
    expect(find.descendant(of: find.byType(AllTransactionsModal), matching: find.text('Sen')), findsOneWidget);
    expect(find.descendant(of: find.byType(AllTransactionsModal), matching: find.text('Jum')), findsOneWidget);
    expect(find.descendant(of: find.byType(AllTransactionsModal), matching: find.text('Min')), findsOneWidget);
    expect(find.descendant(of: find.byType(AllTransactionsModal), matching: find.text('Kelola')), findsOneWidget);

    // 6. Test Search Bar inside modal
    await tester.enterText(find.descendant(of: find.byType(AllTransactionsModal), matching: find.byType(TextField)), 'Spotify');
    await tester.pumpAndSettle();

    expect(find.descendant(of: find.byType(AllTransactionsModal), matching: find.text('Spotify Family')), findsOneWidget);
    expect(find.descendant(of: find.byType(AllTransactionsModal), matching: find.text('Amazon Belanja')), findsNothing);

    // 7. Dismiss Modal with down chevron
    await tester.tap(find.byIcon(Icons.keyboard_arrow_down_rounded));
    await tester.pumpAndSettle();

    expect(find.byType(AllTransactionsModal), findsNothing);

    await db.close();
  });
}
