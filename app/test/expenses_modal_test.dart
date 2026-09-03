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
    final now = DateTime.now();
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
  testWidgets('ExpenseHistoryScreen groups transactions into daily tabs and only loads selected day cards', (WidgetTester tester) async {
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
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));

    // 1. Transaction on Today
    await db.logTransactionWithBalanceMutation(
      tx: TransactionsCompanion(
        id: drift.Value(uuid.v4()),
        walletId: drift.Value(bca.id),
        categoryId: drift.Value(categories.first.id),
        amount: const drift.Value(45000.0),
        type: const drift.Value('expense'),
        notes: const drift.Value('Kopi Janji Jiwa Hari Ini'),
        transactionDate: drift.Value(today),
        createdAt: drift.Value(today),
        updatedAt: drift.Value(today),
      ),
    );

    // 2. Transaction on Yesterday
    await db.logTransactionWithBalanceMutation(
      tx: TransactionsCompanion(
        id: drift.Value(uuid.v4()),
        walletId: drift.Value(bca.id),
        categoryId: drift.Value(categories.first.id),
        amount: const drift.Value(85000.0),
        type: const drift.Value('expense'),
        notes: const drift.Value('Makan Siang Kemarin'),
        transactionDate: drift.Value(yesterday),
        createdAt: drift.Value(yesterday),
        updatedAt: drift.Value(yesterday),
      ),
    );

    final repo = DriftFinanceRepository(db);
    await tester.pumpWidget(FiBOnanciApp(database: db, repository: repo));
    await tester.pumpAndSettle();

    // Open Expense History screen via Lihat Semua
    await tester.tap(find.text('Lihat Semua'));
    await tester.pumpAndSettle();

    // Verify both day tabs exist inside AllTransactionsModal: 'Hari Ini' and 'Kemarin'
    expect(find.descendant(of: find.byType(AllTransactionsModal), matching: find.text('Hari Ini')), findsOneWidget);
    expect(find.descendant(of: find.byType(AllTransactionsModal), matching: find.text('Kemarin')), findsOneWidget);

    // Selected day is 'Hari Ini' by default -> only today's card is visible inside modal
    expect(find.descendant(of: find.byType(AllTransactionsModal), matching: find.text('Kopi Janji Jiwa Hari Ini')), findsOneWidget);
    expect(find.descendant(of: find.byType(AllTransactionsModal), matching: find.text('Makan Siang Kemarin')), findsNothing);

    // Tap 'Kemarin' tab -> switches view and loads yesterday's card!
    await tester.tap(find.descendant(of: find.byType(AllTransactionsModal), matching: find.text('Kemarin')));
    await tester.pumpAndSettle();

    expect(find.descendant(of: find.byType(AllTransactionsModal), matching: find.text('Makan Siang Kemarin')), findsOneWidget);
    expect(find.descendant(of: find.byType(AllTransactionsModal), matching: find.text('Kopi Janji Jiwa Hari Ini')), findsNothing);

    await db.close();
  });

  testWidgets('ExpenseHistoryScreen search queries match across all days and Today tab is on the right', (WidgetTester tester) async {
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
    final today = DateTime.now();
    final threeDaysAgo = today.subtract(const Duration(days: 3));

    // 1. Transaction Today
    await db.logTransactionWithBalanceMutation(
      tx: TransactionsCompanion(
        id: drift.Value(uuid.v4()),
        walletId: drift.Value(bca.id),
        categoryId: drift.Value(categories.first.id),
        amount: const drift.Value(35000.0),
        type: const drift.Value('expense'),
        notes: const drift.Value('Kopi Kenangan'),
        transactionDate: drift.Value(today),
        createdAt: drift.Value(today),
        updatedAt: drift.Value(today),
      ),
    );

    // 2. Transaction 3 days ago
    await db.logTransactionWithBalanceMutation(
      tx: TransactionsCompanion(
        id: drift.Value(uuid.v4()),
        walletId: drift.Value(bca.id),
        categoryId: drift.Value(categories.first.id),
        amount: const drift.Value(120000.0),
        type: const drift.Value('expense'),
        notes: const drift.Value('Buku Arsitektur'),
        transactionDate: drift.Value(threeDaysAgo),
        createdAt: drift.Value(threeDaysAgo),
        updatedAt: drift.Value(threeDaysAgo),
      ),
    );

    final repo = DriftFinanceRepository(db);
    await tester.pumpWidget(FiBOnanciApp(database: db, repository: repo));
    await tester.pumpAndSettle();

    // Test Dashboard Search: searching 'Buku' (which is from 3 days ago) works on dashboard search!
    await tester.enterText(find.byType(TextField).first, 'Buku');
    await tester.pumpAndSettle();
    expect(find.text('Hasil Pencarian (1)'), findsOneWidget);
    expect(find.text('Buku Arsitektur'), findsOneWidget);

    // Clear search on dashboard
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    // Open Expense History
    await tester.tap(find.text('Lihat Semua'));
    await tester.pumpAndSettle();

    // Verify Today is selected and on the right side
    expect(find.descendant(of: find.byType(AllTransactionsModal), matching: find.text('HARI INI')), findsOneWidget);
    expect(find.descendant(of: find.byType(AllTransactionsModal), matching: find.text('Kopi Kenangan')), findsOneWidget);

    // Search inside Expense History for 'Buku' (from 3 days ago)
    await tester.enterText(
      find.descendant(of: find.byType(AllTransactionsModal), matching: find.byType(TextField)),
      'Buku',
    );
    await tester.pumpAndSettle();

    // Both results are searched directly and displayed without being blocked by day tabs!
    expect(find.descendant(of: find.byType(AllTransactionsModal), matching: find.text('Hasil Pencarian: 1 Transaksi')), findsOneWidget);
    expect(find.descendant(of: find.byType(AllTransactionsModal), matching: find.text('Buku Arsitektur')), findsOneWidget);
    expect(find.descendant(of: find.byType(AllTransactionsModal), matching: find.text('Kopi Kenangan')), findsNothing);

    // Verify search bar in Expense History is non-pill
    final container = tester.widget<Container>(
      find.ancestor(
        of: find.descendant(of: find.byType(AllTransactionsModal), matching: find.byType(TextField)),
        matching: find.byType(Container),
      ).first,
    );
    final decoration = container.decoration as BoxDecoration;
    final borderRadius = decoration.borderRadius as BorderRadius;
    expect(borderRadius.topLeft.x, lessThanOrEqualTo(12.0)); // Non-pill rectangular radius (10px)


    // Verify search bar has height 46 and exact same hint text as Dashboard
    expect(container.constraints?.minHeight ?? (container.constraints?.maxHeight), 46.0);
    final textField = tester.widget<TextField>(
      find.descendant(of: find.byType(AllTransactionsModal), matching: find.byType(TextField)),
    );
    expect(textField.decoration?.hintText, 'Cari transaksi, rekening, merchant...');

    // Verify Icons.tune filter button exists in search bar (consistent with Dashboard)
    final tuneButton = find.descendant(of: find.byType(AllTransactionsModal), matching: find.byIcon(Icons.tune));
    expect(tuneButton, findsOneWidget);

    // Tap tune button -> opens TransactionFilterModal
    await tester.tap(tuneButton);
    await tester.pumpAndSettle();

    expect(find.text('Filter Transaksi'), findsOneWidget);
    // Select 'Pengeluaran' filter
    await tester.tap(find.text('Pengeluaran').last);
    await tester.pumpAndSettle();
    // Tap 'Terapkan Filter'
    await tester.tap(find.text('Terapkan Filter'));
    await tester.pumpAndSettle();

    // Verify active filter chip 'Tipe: EXPENSE' appears below search bar (consistent with Dashboard)
    expect(find.descendant(of: find.byType(AllTransactionsModal), matching: find.text('Tipe: EXPENSE')), findsOneWidget);

    // Tap close icon on active filter chip -> clears filter
    final chipContainer = find.ancestor(
      of: find.descendant(of: find.byType(AllTransactionsModal), matching: find.text('Tipe: EXPENSE')),
      matching: find.byType(Container),
    ).first;
    await tester.tap(find.descendant(of: chipContainer, matching: find.byIcon(Icons.close)));
    await tester.pumpAndSettle();
    expect(find.descendant(of: find.byType(AllTransactionsModal), matching: find.text('Tipe: EXPENSE')), findsNothing);
    await db.close();
  });

  testWidgets('ExpenseHistoryScreen has Hero card history, 3-month horizontal scrollable timeline, and spacious indicator', (WidgetTester tester) async {
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
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    // Seed 1 transaction Today and 1 transaction 30 days ago (within 3 months)
    await db.logTransactionWithBalanceMutation(
      tx: TransactionsCompanion(
        id: drift.Value(uuid.v4()),
        walletId: drift.Value(bca.id),
        categoryId: drift.Value(categories.first.id),
        amount: const drift.Value(45000.0),
        type: const drift.Value('expense'),
        notes: const drift.Value('Kopi Susu Hari Ini'),
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
        amount: const drift.Value(85000.0),
        type: const drift.Value('expense'),
        notes: const drift.Value('Makan Sebulan Lalu'),
        transactionDate: drift.Value(thirtyDaysAgo),
        createdAt: drift.Value(thirtyDaysAgo),
        updatedAt: drift.Value(thirtyDaysAgo),
      ),
    );

    final repo = DriftFinanceRepository(db);
    await tester.pumpWidget(FiBOnanciApp(database: db, repository: repo));
    await tester.pumpAndSettle();

    // 1. Verify Hero card history on Dashboard (search bar has NO hero)
    expect(
      find.byWidgetPredicate((w) => w is Hero && w.tag == 'expense_history_search_bar'),
      findsNothing,
    );
    expect(
      find.byWidgetPredicate((w) => w is Hero && w.tag == 'expense_history_card_history'),
      findsOneWidget,
    );

    // 2. Open Expense History
    await tester.tap(find.text('Lihat Semua'));
    await tester.pumpAndSettle();

    // 3. Verify Hero card history inside Expense History screen (and NO search bar hero)
    expect(
      find.descendant(
        of: find.byType(AllTransactionsModal),
        matching: find.byWidgetPredicate((w) => w is Hero && w.tag == 'expense_history_search_bar'),
      ),
      findsNothing,
    );
    expect(
      find.descendant(
        of: find.byType(AllTransactionsModal),
        matching: find.byWidgetPredicate((w) => w is Hero && w.tag == 'expense_history_card_history'),
      ),
      findsOneWidget,
    );
    // 4. Verify Today is default view and Today's card is visible
    expect(find.descendant(of: find.byType(AllTransactionsModal), matching: find.text('HARI INI')), findsOneWidget);
    expect(find.descendant(of: find.byType(AllTransactionsModal), matching: find.text('Kopi Susu Hari Ini')), findsOneWidget);
    expect(find.descendant(of: find.byType(AllTransactionsModal), matching: find.text('Makan Sebulan Lalu')), findsNothing);

    // 5. Verify horizontal scroll controller is scrollable (can scroll left across 3 months)
    final scrollable = find.descendant(
      of: find.byType(AllTransactionsModal),
      matching: find.byType(SingleChildScrollView),
    ).last;
    expect(scrollable, findsOneWidget);

    // Scroll left to navigate back in time across the 3-month range
    await tester.drag(scrollable, const Offset(300, 0));
    await tester.pumpAndSettle();

    await db.close();
  });

  testWidgets('ExpenseHistoryScreen displays all entries without 3-month limit and renders minimalist non-pill date tabs', (WidgetTester tester) async {
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
    final now = DateTime.now();
    final sixMonthsAgo = now.subtract(const Duration(days: 180));
    final oneYearAgo = now.subtract(const Duration(days: 365));

    // Seed transactions: Today, 6 months ago, and 1 year ago
    await db.logTransactionWithBalanceMutation(
      tx: TransactionsCompanion(
        id: drift.Value(uuid.v4()),
        walletId: drift.Value(bca.id),
        categoryId: drift.Value(categories.first.id),
        amount: const drift.Value(50000.0),
        type: const drift.Value('expense'),
        notes: const drift.Value('Makan Hari Ini'),
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
        amount: const drift.Value(1250000.0),
        type: const drift.Value('expense'),
        notes: const drift.Value('Tiket Pesawat 6 Bulan Lalu'),
        transactionDate: drift.Value(sixMonthsAgo),
        createdAt: drift.Value(sixMonthsAgo),
        updatedAt: drift.Value(sixMonthsAgo),
      ),
    );

    await db.logTransactionWithBalanceMutation(
      tx: TransactionsCompanion(
        id: drift.Value(uuid.v4()),
        walletId: drift.Value(bca.id),
        categoryId: drift.Value(categories.first.id),
        amount: const drift.Value(2400000.0),
        type: const drift.Value('expense'),
        notes: const drift.Value('Langganan Cloud Setahun Lalu'),
        transactionDate: drift.Value(oneYearAgo),
        createdAt: drift.Value(oneYearAgo),
        updatedAt: drift.Value(oneYearAgo),
      ),
    );

    final repo = DriftFinanceRepository(db);
    await tester.pumpWidget(FiBOnanciApp(database: db, repository: repo));
    await tester.pumpAndSettle();

    // Open Expense History
    await tester.tap(find.text('Lihat Semua'));
    await tester.pumpAndSettle();

    // 1. Search for 6-month-old transaction -> must be found (no 3-month limit!)
    final searchField = find.descendant(of: find.byType(AllTransactionsModal), matching: find.byType(TextField));
    await tester.enterText(searchField, 'Pesawat');
    await tester.pumpAndSettle();

    expect(find.descendant(of: find.byType(AllTransactionsModal), matching: find.text('Tiket Pesawat 6 Bulan Lalu')), findsOneWidget);

    // Clear search
    await tester.enterText(searchField, '');
    await tester.pumpAndSettle();

    // 2. Search for 1-year-old transaction -> must also be found without limit
    await tester.enterText(searchField, 'Setahun');
    await tester.pumpAndSettle();
    expect(find.descendant(of: find.byType(AllTransactionsModal), matching: find.text('Langganan Cloud Setahun Lalu')), findsOneWidget);

    // Clear search again
    await tester.enterText(searchField, '');
    await tester.pumpAndSettle();

    // 3. Verify non-pill date tabs: day tab containers use BorderRadius.zero
    final animatedContainers = tester.widgetList<AnimatedContainer>(
      find.descendant(of: find.byType(AllTransactionsModal), matching: find.byType(AnimatedContainer)),
    );
    // Find day tab with BoxDecoration
    final dayTabContainer = animatedContainers.firstWhere(
      (c) => c.decoration is BoxDecoration && (c.decoration as BoxDecoration).border != null,
    );
    final boxDeco = dayTabContainer.decoration as BoxDecoration;
    expect(boxDeco.borderRadius, BorderRadius.zero);

    await db.close();
  });
}
