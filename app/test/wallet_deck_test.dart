import 'package:fibonanci_app/data/database/app_database.dart';
import 'package:fibonanci_app/data/repositories/finance_repository.dart';
import 'package:fibonanci_app/main.dart';
import 'package:fibonanci_app/presentation/widgets/bottom_nav_dock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  testWidgets('Tapping Card 2 on Dashboard switches to Wallets tab without hiding bottom nav bar', (WidgetTester tester) async {
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

    // Verify Home tab initially active
    expect(find.text('Hello David'), findsOneWidget);
    expect(find.text('7 Akun Riil'), findsOneWidget);

    // Tap Card 2 (7 Akun Riil) on Dashboard
    await tester.tap(find.text('7 Akun Riil'));
    await tester.pumpAndSettle();

    // Verify switched to Wallets tab!
    expect(find.text('Rekening & Dompet'), findsOneWidget);
    expect(find.text('TOTAL SALDO RIIL'), findsOneWidget);
    expect(find.text('Tren Arus Kas (Semua Rekening)'), findsOneWidget);

    // Verify bottom nav bar is STILL VISIBLE and present!
    expect(find.byType(BottomNavDock), findsOneWidget);
    expect(find.text('Wallets'), findsOneWidget);

    await db.close();
  });

  testWidgets('Test WalletCardDeck select shows chart and transaction history per wallet', (WidgetTester tester) async {
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

    // 1. Navigate to Wallets tab
    await tester.tap(find.byIcon(Icons.account_balance_wallet_outlined).last);
    await tester.pumpAndSettle();

    expect(find.text('Rekening & Dompet'), findsOneWidget);
    expect(find.text('TOTAL SALDO RIIL'), findsOneWidget);
    expect(find.text('Tren Arus Kas (Semua Rekening)'), findsOneWidget);

    // 2. Initial state: BCA Utama is visible in stacked cards
    final bcaFinder = find.text('BCA Utama');
    expect(bcaFinder, findsOneWidget);

    // 3. Tap BCA card -> opens rich detail sheet with chart and history
    await tester.tap(bcaFinder);
    await tester.pumpAndSettle();

    // Verify: Exactly ONE BCA Utama card exists in the tree (NO duplicate/double card!)
    expect(find.text('BCA Utama'), findsOneWidget);

    // Verify in-place expanded contents directly under the card
    expect(find.text('Tren Mutasi BCA Utama'), findsOneWidget);
    expect(find.text('Masuk'), findsWidgets);
    expect(find.text('Keluar'), findsWidgets);
    expect(find.text('Riwayat Transaksi'), findsOneWidget);
    expect(find.text('Ubah Saldo'), findsOneWidget);
    expect(find.text('Catat Transaksi'), findsOneWidget);
    // 4. Tap 'Ubah Saldo' -> opens edit balance modal
    await tester.tap(find.text('Ubah Saldo'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Penyesuaian Saldo: BCA Utama'), findsOneWidget);
    expect(find.text('Perbarui Saldo'), findsOneWidget);

    // 5. Submit update
    await tester.tap(find.text('Perbarui Saldo'));
    await tester.pumpAndSettle();

    // Modal dismissed
    expect(find.textContaining('Penyesuaian Saldo: BCA Utama'), findsNothing);

    // 6. Tap BCA card again to lift
    await tester.tap(bcaFinder);
    await tester.pumpAndSettle();
    expect(find.text('Detail Rekening'), findsOneWidget);

    // Dismiss lifted card by tapping close icon
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    // Expanded details collapsed
    expect(find.text('Tren Mutasi BCA Utama'), findsNothing);
    expect(find.text('Catat Transaksi'), findsNothing);
    // Card itself is still there in resting deck
    expect(find.text('BCA Utama'), findsOneWidget);

    await db.close();
  });
}
