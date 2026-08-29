import 'package:fibonanci_app/data/database/app_database.dart';
import 'package:fibonanci_app/data/repositories/finance_repository.dart';
import 'package:fibonanci_app/main.dart';
import 'package:fibonanci_app/presentation/modals/budgeting_insights_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  final sampleSubscriptions = [
    SubscriptionEntry(
      id: 'sub-1',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isSynced: false,
      isDeleted: false,
      walletId: 'w-1',
      categoryId: 'c-1',
      title: 'Netflix Premium',
      cost: 186000.0,
      billingCycle: 'monthly',
      dueDay: 15,
      autoDeduct: true,
      status: 'active',
      lastPaidDate: null,
    ),
    SubscriptionEntry(
      id: 'sub-2',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isSynced: false,
      isDeleted: false,
      walletId: 'w-1',
      categoryId: 'c-1',
      title: 'Spotify Family',
      cost: 54000.0,
      billingCycle: 'monthly',
      dueDay: 20,
      autoDeduct: false,
      status: 'active',
      lastPaidDate: DateTime.now(), // Already paid this month
    ),
  ];

  testWidgets('BudgetingInsightsModal renders Swiss-editorial reference UI with fiBOnanci dark theme and Rupiah currency', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400 * 2, 900 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BudgetingInsightsModal(
            subscriptions: sampleSubscriptions,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Header Title & dismiss icon
    expect(find.text('Wawasan\nAnggaran &\nPengeluaran'), findsOneWidget);
    expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsOneWidget);

    // 2. Central Neo-Coral Geometric Circles CustomPaint exists
    expect(find.byType(CustomPaint), findsWidgets);

    // 3. Real Total Pending Bills section with Rupiah currency
    expect(find.text('Total Tagihan Bulan Ini'), findsOneWidget);
    expect(find.text('Rp 186.000'), findsOneWidget);
    expect(find.text('1 belum dibayar dari 2 tagihan aktif'), findsOneWidget);

    // 4. Real subscription cards (Netflix & Spotify)
    expect(find.text('Netflix Premium'), findsOneWidget);
    expect(find.text('-Rp 186.000'), findsOneWidget);
    expect(find.text('Spotify Family'), findsOneWidget);
    expect(find.text('-Rp 54.000'), findsOneWidget);
    expect(find.text('Lunas ✓'), findsOneWidget);

    // 5. VISA button is removed (not present)
    expect(find.text('VISA'), findsNothing);

    // 6. Bottom dock controls
    expect(find.byIcon(Icons.tune_rounded), findsOneWidget);
    expect(find.byIcon(Icons.grid_view_rounded), findsOneWidget);
    expect(find.text('2 Tagihan Aktif'), findsOneWidget);

    // 7. Toggle grid view
    await tester.tap(find.byIcon(Icons.grid_view_rounded));
    await tester.pumpAndSettle();
    expect(find.byType(GridView), findsOneWidget);

    // 8. Toggle back to carousel view
    await tester.tap(find.byIcon(Icons.view_carousel_rounded));
    await tester.pumpAndSettle();
    expect(find.byType(ListView), findsWidgets);

    // 9. Quick filter pill toggles to "Belum Lunas"
    await tester.tap(find.text('2 Tagihan Aktif'));
    await tester.pumpAndSettle();
    expect(find.text('1 Belum Lunas'), findsOneWidget);

    // Spotify (already paid) should be hidden in pending filter
    expect(find.text('Netflix Premium'), findsOneWidget);
    expect(find.text('Spotify Family'), findsNothing);
  });

  testWidgets('BudgetingInsightsModal renders empty state when no subscriptions exist', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400 * 2, 900 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BudgetingInsightsModal(
            subscriptions: [],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Belum Ada Tagihan Rutin'), findsOneWidget);
    expect(find.text('Total Tagihan Rutin'), findsOneWidget);
    expect(find.text('Rp 0'), findsOneWidget);
  });

  testWidgets('Tapping Pending Bills (Card 3) on Dashboard opens BudgetingInsightsModal with real data in Rupiah', (WidgetTester tester) async {
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

    // Find Pending Bills card (Card 3 in Bento Grid via metric label)
    final card3 = find.textContaining('Tagihan Bln Ini');
    expect(card3, findsOneWidget);

    // Tap Card 3
    await tester.tap(card3);
    await tester.pumpAndSettle();

    // Verify BudgetingInsightsModal opened
    expect(find.text('Wawasan\nAnggaran &\nPengeluaran'), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);
    expect(find.text('VISA'), findsNothing);

    // Dismiss using top down chevron
    await tester.tap(find.byIcon(Icons.keyboard_arrow_down_rounded));
    await tester.pumpAndSettle();

    // Modal dismissed, back to Dashboard
    expect(find.textContaining('Tagihan Bln Ini'), findsOneWidget);

    await db.close();
    await tester.pumpAndSettle();
  });
}
