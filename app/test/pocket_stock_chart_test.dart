import 'package:fibonanci_app/data/database/app_database.dart';
import 'package:fibonanci_app/presentation/widgets/pocket_stock_chart_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  testWidgets('PocketStockChartCard renders total, filter pills, and handles interaction', (tester) async {
    final now = DateTime(2026, 8, 29);

    final txDeposit = TransactionEntry(
      id: 'tx_1',
      walletId: 'w_1',
      categoryId: '11111111-1111-4111-8111-111111111111',
      amount: 100000.0,
      type: 'transfer',
      notes: 'Setoran ke Kantong Tabungan',
      transactionDate: now.subtract(const Duration(days: 2)),
      source: 'manual',
      createdAt: now,
      updatedAt: now,
      isSynced: false,
      isDeleted: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PocketStockChartCard(
            currentTotal: 500000.0,
            pocketsCount: 3,
            transactions: [txDeposit],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify header texts
    expect(find.text('TOTAL DANA TERKUMPUL'), findsOneWidget);
    expect(find.textContaining('500.000'), findsOneWidget);
    expect(find.textContaining('3 kantong'), findsOneWidget);

    // 2. Verify filter pills
    expect(find.text('1M'), findsOneWidget);
    expect(find.text('1B'), findsOneWidget);
    expect(find.text('1T'), findsOneWidget);
    expect(find.text('Semua'), findsOneWidget);

    // 3. Tap on '1B' filter
    await tester.tap(find.text('1B'));
    await tester.pumpAndSettle();

    // 4. Tap on '1T' filter
    await tester.tap(find.text('1T'));
    await tester.pumpAndSettle();

    // 5. Drag/scrub on the chart
    final chartFinder = find.byType(CustomPaint).first;
    await tester.drag(chartFinder, const Offset(50, 0));
    await tester.pumpAndSettle();
  });

  testWidgets('PocketStockChartCard updates dynamically when funds are added', (tester) async {
    final now = DateTime(2026, 8, 29);

    // Initially empty / no transactions
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PocketStockChartCard(
            currentTotal: 0.0,
            pocketsCount: 1,
            transactions: [],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('0'), findsWidgets);

    // Now user adds funds: 250.000
    final txDeposit = TransactionEntry(
      id: 'tx_now',
      walletId: 'w_1',
      categoryId: '11111111-1111-4111-8111-111111111111',
      amount: 250000.0,
      type: 'transfer',
      notes: 'Setoran ke Kantong Tabungan',
      transactionDate: now,
      source: 'manual',
      createdAt: now,
      updatedAt: now,
      isSynced: false,
      isDeleted: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PocketStockChartCard(
            currentTotal: 250000.0,
            pocketsCount: 1,
            transactions: [txDeposit],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify the new balance and positive upward trend
    expect(find.text('Rp 250.000'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_upward_rounded), findsOneWidget);
    expect(find.textContaining('+100.0%'), findsOneWidget);
  });
}
