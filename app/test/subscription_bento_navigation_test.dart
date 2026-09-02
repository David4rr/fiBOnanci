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

  testWidgets('Tapping Pending Bills (Card 3) on Dashboard navigates directly to Billing & Subscriptions page', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400 * 2, 900 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final db = AppDatabase(NativeDatabase.memory());
    await db.select(db.wallets).get();
    final repository = DriftFinanceRepository(db);

    await tester.pumpWidget(
      FiBOnanciApp(
        database: db,
        repository: repository,
      ),
    );
    await tester.pumpAndSettle();

    // Verify initial dashboard view
    expect(find.text('Safe to Spend'), findsOneWidget);
    expect(find.textContaining('Tagihan Bln Ini'), findsOneWidget);

    // Tap Card 3: Pending Bills
    final pendingBillsCard = find.textContaining('Tagihan Bln Ini');
    await tester.tap(pendingBillsCard);
    await tester.pumpAndSettle();

    // Verify we navigated to the Billing & Subscriptions page (SubscriptionScreen)
    expect(find.text('Tagihan & Langganan'), findsOneWidget);
    expect(find.textContaining('Kartu Terdaftar'), findsOneWidget);

    await db.close();
  });
}
