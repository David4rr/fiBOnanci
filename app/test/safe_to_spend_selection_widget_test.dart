import 'package:fibonanci_app/data/database/app_database.dart';
import 'package:fibonanci_app/data/repositories/finance_repository.dart';
import 'package:fibonanci_app/main.dart';
import 'package:flutter/material.dart';
import 'package:fibonanci_app/presentation/widgets/common/common_widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  testWidgets('Dashboard Safe-to-Spend modal displays calculation breakdown without redundant chips', (WidgetTester tester) async {
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

    // 3. Modal shows formula breakdown
    expect(find.text('Smart Safe-to-Spend'), findsOneWidget);
    expect(find.text('Total Saldo Riil'), findsOneWidget);
    expect(find.text('Sisa Tagihan Bulan Ini'), findsOneWidget);
    expect(find.text('Sisa Aman Bulan Ini'), findsOneWidget);

    // 4. Redundant chips and selector are eliminated from modal
    expect(find.text('SUMBER REKENING PENGELUARAN'), findsNothing);
    expect(find.byType(AppChoiceChip), findsNothing);
    expect(
      find.text('Pilihan rekening operasional dapat diatur di Pengaturan > Siklus Anggaran & Safe-to-Spend.'),
      findsOneWidget,
    );

    await db.close();
  });
}
