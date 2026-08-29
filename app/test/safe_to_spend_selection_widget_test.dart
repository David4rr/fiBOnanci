import 'package:fibonanci_app/data/database/app_database.dart';
import 'package:fibonanci_app/data/repositories/finance_repository.dart';
import 'package:fibonanci_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  testWidgets('Dashboard Safe-to-Spend modal allows choosing spending accounts and updates live', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400 * 2, 900 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final db = AppDatabase(NativeDatabase.memory());
    await db.select(db.wallets).get();
    final repo = DriftFinanceRepository(db);

    await tester.pumpWidget(FiBOnanciApp(database: db, repository: repo));
    await tester.pumpAndSettle();

    // 1. Initial dashboard shows Safe to Spend card
    expect(find.text('Safe to Spend'), findsOneWidget);

    // 2. Tap Safe to Spend Bento card -> opens modal
    await tester.tap(find.text('Safe to Spend'));
    await tester.pumpAndSettle();

    expect(find.text('Smart Safe-to-Spend'), findsOneWidget);
    expect(find.text('SUMBER REKENING PENGELUARAN'), findsOneWidget);
    expect(find.textContaining('Semua (7)'), findsWidgets);

    // 3. Tap "BCA Utama" chip in the modal to isolate to BCA
    final bcaChip = find.widgetWithText(FilterChip, 'BCA Utama');
    expect(bcaChip, findsOneWidget);
    await tester.tap(bcaChip);
    await tester.pumpAndSettle();

    // Verification: Now 1 Dipilih is shown
    expect(find.text('1 Dipilih'), findsOneWidget);
    expect(find.text('Saldo Rekening Terpilih'), findsOneWidget);

    // 4. Tap "Semua (7)" chip to reset back to all accounts
    await tester.tap(find.widgetWithText(FilterChip, 'Semua (7)'));
    await tester.pumpAndSettle();

    expect(find.text('Semua (7)'), findsWidgets);
    expect(find.text('Total Saldo Riil'), findsOneWidget);

    await db.close();
  });
}
