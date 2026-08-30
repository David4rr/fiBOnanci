import 'package:intl/date_symbol_data_local.dart';
import 'package:fibonanci_app/data/repositories/finance_repository.dart';
import 'package:flutter/material.dart';
import 'package:drift/native.dart';
import 'package:fibonanci_app/data/database/app_database.dart';
import 'package:fibonanci_app/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  testWidgets('FiBOnanciApp smoke test & screen navigation', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400 * 2, 900 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final db = AppDatabase(NativeDatabase.memory());
    await db.select(db.wallets).get(); // Trigger table creation & seed
    final repo = DriftFinanceRepository(db);
    await tester.pumpWidget(FiBOnanciApp(database: db, repository: repo));
    await tester.pumpAndSettle();
    expect(find.text('Hello David'), findsOneWidget);
    expect(find.text('Safe to Spend'), findsOneWidget);
    expect(find.text('Riwayat Transaksi'), findsOneWidget);
    expect(find.byIcon(Icons.add_rounded), findsOneWidget);

    // Tap center circular action button -> opens TransactionModal!
    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Catat Transaksi'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    // 2. Tap Tagihan icon on floating bottom dock
    await tester.tap(find.byIcon(Icons.receipt_long_outlined).last);
    await tester.pumpAndSettle();

    // 3. Verify Tagihan screen renders
    expect(find.text('Tagihan & Langganan'), findsOneWidget);

    await db.close();
  });
}
