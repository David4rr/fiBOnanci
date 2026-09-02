import 'package:fibonanci_app/data/database/app_database.dart';
import 'package:fibonanci_app/data/repositories/finance_repository.dart';
import 'package:fibonanci_app/main.dart';
import 'package:fibonanci_app/presentation/widgets/bottom_nav_dock.dart';
import 'package:fibonanci_app/presentation/screens/wallet_detail_screen.dart';
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

    // 3. First Tap: Expands BCA card in the deck (revealing full physical ATM layout with chip/balance)
    await tester.tap(bcaFinder);
    await tester.pumpAndSettle();

    // Verify: BCA card is expanded in deck (showing masked card number or Saldo Tersedia)
    expect(find.text('Saldo Tersedia'), findsOneWidget);

    // 4. Second Tap on expanded BCA card: Opens rich detail bottom sheet modal with Hero transition
    await tester.tap(bcaFinder);
    await tester.pumpAndSettle();

    expect(find.byType(WalletDetailScreen), findsOneWidget);
    expect(find.text('Detail Rekening'), findsOneWidget);
    expect(find.text('Tren Mutasi BCA Utama'), findsOneWidget);
    expect(find.text('Masuk'), findsWidgets);
    expect(find.text('Keluar'), findsWidgets);
    expect(find.text('Riwayat Transaksi'), findsOneWidget);
    expect(find.text('Ubah Saldo'), findsOneWidget);
    expect(find.text('Catat Transaksi'), findsOneWidget);

    // 5. Tap 'Ubah Saldo' -> opens edit balance modal
    await tester.tap(find.text('Ubah Saldo'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Penyesuaian Saldo: BCA Utama'), findsOneWidget);
    expect(find.text('Perbarui Saldo'), findsOneWidget);

    // 6. Submit update
    await tester.tap(find.text('Perbarui Saldo'));
    await tester.pumpAndSettle();

    // Edit modal dismissed, returning to detail modal
    expect(find.textContaining('Penyesuaian Saldo: BCA Utama'), findsNothing);
    expect(find.text('Detail Rekening'), findsOneWidget);

    // 7. Dismiss detail screen by tapping back button
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();

    // Expanded details collapsed
    expect(find.text('Tren Mutasi BCA Utama'), findsNothing);
    expect(find.text('Catat Transaksi'), findsNothing);
    // Card itself is still there in resting deck
    expect(find.text('BCA Utama'), findsOneWidget);
    await db.close();
  });
}
