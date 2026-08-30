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

  testWidgets('Pocket creation flow via AddPocketModal in WalletScreen', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400 * 2, 900 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final db = AppDatabase(NativeDatabase.memory());
    final repo = DriftFinanceRepository(db);

    await tester.pumpWidget(FiBOnanciApp(database: db, repository: repo));
    await tester.pumpAndSettle();

    // 1. Switch to Wallets tab
    await tester.tap(find.byIcon(Icons.account_balance_wallet_outlined).last);
    await tester.pumpAndSettle();

    expect(find.text('Rekening & Dompet'), findsOneWidget);

    // 2. Switch to Kantong Tabungan segment
    final kantongTab = find.textContaining('Kantong Tabungan');
    expect(kantongTab, findsOneWidget);
    await tester.tap(kantongTab);
    await tester.pumpAndSettle();

    // Verify empty state is visible
    expect(find.text('Belum Ada Kantong Tabungan'), findsOneWidget);

    // 3. Tap "Buat Kantong Sekarang" button
    await tester.tap(find.text('Buat Kantong Sekarang'));
    await tester.pumpAndSettle();

    // Verify AddPocketModal opened
    expect(find.text('Buat Kantong Alokasi Baru'), findsOneWidget);

    // 4. Fill in Pocket Name
    final nameField = find.widgetWithText(TextField, 'Nama Kantong (cth: Tabungan Pensiun, Liburan)');
    expect(nameField, findsOneWidget);
    await tester.enterText(nameField, 'Dana Darurat 6 Bulan');

    // 5. Fill in Target
    final targetField = find.widgetWithText(TextField, 'Target Tabungan (Opsional)');
    expect(targetField, findsOneWidget);
    await tester.enterText(targetField, '50000000');

    // 6. Submit form
    final submitBtn = find.text('Buat Kantong Sekarang').last;
    await tester.tap(submitBtn);
    await tester.pumpAndSettle();

    // 7. Verify pocket is created and visible in list!
    expect(find.text('Dana Darurat 6 Bulan'), findsOneWidget);

    await db.close();
  });
}
