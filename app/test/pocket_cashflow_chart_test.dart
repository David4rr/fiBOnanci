import 'package:fibonanci_app/data/database/app_database.dart';
import 'package:fibonanci_app/presentation/modals/pocket/pocket_detail_views.dart';
import 'package:fibonanci_app/presentation/widgets/bento_folder_card.dart';
import 'package:fibonanci_app/presentation/widgets/pocket_cashflow_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  final mockPocket = PocketEntry(
    id: 'pocket_123',
    name: 'Liburan Jepang',
    type: 'savings',
    colorHex: '#D4F442',
    iconName: 'savings',
    currentAmount: 1500000.0,
    targetAmount: 5000000.0,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    isSynced: false,
    isDeleted: false,
  );

  testWidgets('PocketCashflowChart renders empty state baseline with Arus Kas label', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 150,
            height: 100,
            child: PocketCashflowChart(
              pocket: mockPocket,
              transactions: const [],
              isDark: true,
              primaryColor: Colors.white,
              secondaryColor: Colors.white70,
              accentColor: Colors.greenAccent,
              currencyFormatter: currencyFormatter,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Arus Kas'), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);
  });

  testWidgets('PocketCashflowChart computes and renders inflow and outflow figures', (tester) async {
    final now = DateTime.now();
    final depositTx = TransactionEntry(
      id: 'tx_dep',
      walletId: 'w_1',
      categoryId: 'cat_1',
      amount: 1500000.0,
      type: 'transfer',
      notes: 'Setoran ke Kantong Liburan Jepang',
      externalRef: 'pocket_pocket_123',
      transactionDate: now.subtract(const Duration(days: 3)),
      source: 'manual',
      createdAt: now,
      updatedAt: now,
      isSynced: false,
      isDeleted: false,
    );

    final withdrawTx = TransactionEntry(
      id: 'tx_wdr',
      walletId: 'w_1',
      categoryId: 'cat_1',
      amount: 200000.0,
      type: 'income',
      notes: 'Penarikan dari Kantong Liburan Jepang',
      externalRef: 'pocket_pocket_123',
      transactionDate: now.subtract(const Duration(days: 1)),
      source: 'manual',
      createdAt: now,
      updatedAt: now,
      isSynced: false,
      isDeleted: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 160,
            height: 100,
            child: PocketCashflowChart(
              pocket: mockPocket,
              transactions: [depositTx, withdrawTx],
              isDark: false,
              primaryColor: Colors.black,
              secondaryColor: Colors.black54,
              accentColor: Colors.teal,
              currencyFormatter: currencyFormatter,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('+1.5jt'), findsOneWidget);
    expect(find.text('-200rb'), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);
  });

  testWidgets('PocketDetailHeader mounts PocketCashflowChart inside BentoFolderCard', (tester) async {
    final now = DateTime.now();
    final depositTx = TransactionEntry(
      id: 'tx_dep_2',
      walletId: 'w_1',
      categoryId: 'cat_1',
      amount: 500000.0,
      type: 'transfer',
      notes: 'Setoran ke Kantong Liburan Jepang',
      externalRef: 'pocket_pocket_123',
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
          body: PocketDetailHeader(
            pocket: mockPocket,
            pocketColor: const Color(0xFF14161D),
            currencyFormatter: currencyFormatter,
            transactions: [depositTx],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(BentoFolderCard), findsOneWidget);
    expect(find.byType(PocketCashflowChart), findsOneWidget);
    expect(find.textContaining('1.500.000'), findsOneWidget);
    expect(find.text('+500rb'), findsOneWidget);
    expect(find.text('Liburan Jepang'), findsOneWidget);
  });

  testWidgets('PocketDetailHeader is responsive on small screen (320px) with enlarged text scale (1.5x)', (tester) async {
    tester.view.physicalSize = const Size(320 * 2, 600 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final hugePocket = PocketEntry(
      id: 'pocket_huge',
      name: 'Tabungan Pensiun Masa Depan Bahagia Sejahtera',
      type: 'retirement',
      colorHex: '#14B8A6',
      iconName: 'elderly',
      currentAmount: 95000000000.0,
      targetAmount: 100000000000.0,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
      isSynced: false,
      isDeleted: false,
    );

    final now = DateTime.now();
    final largeTxs = [
      TransactionEntry(
        id: 'tx_large_dep',
        walletId: 'w_1',
        categoryId: 'cat_1',
        amount: 75000000000.0,
        type: 'transfer',
        notes: 'Setoran ke Kantong Tabungan Pensiun',
        externalRef: 'pocket_pocket_huge',
        transactionDate: now.subtract(const Duration(days: 2)),
        source: 'manual',
        createdAt: now,
        updatedAt: now,
        isSynced: false,
        isDeleted: false,
      ),
      TransactionEntry(
        id: 'tx_large_wdr',
        walletId: 'w_1',
        categoryId: 'cat_1',
        amount: 25000000000.0,
        type: 'income',
        notes: 'Penarikan dari Kantong Tabungan Pensiun',
        externalRef: 'pocket_pocket_huge',
        transactionDate: now.subtract(const Duration(days: 1)),
        source: 'manual',
        createdAt: now,
        updatedAt: now,
        isSynced: false,
        isDeleted: false,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 600),
            textScaler: TextScaler.linear(1.5),
          ),
          child: Scaffold(
            body: PocketDetailHeader(
              pocket: hugePocket,
              pocketColor: const Color(0xFF14B8A6),
              currencyFormatter: currencyFormatter,
              transactions: largeTxs,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Ensure no overflow errors occurred and all key elements rendered
    expect(tester.takeException(), isNull);
    expect(find.byType(PocketCashflowChart), findsOneWidget);
    expect(find.text('+75M'), findsOneWidget);
    expect(find.text('-25M'), findsOneWidget);
    expect(find.text('Tabungan Pensiun Masa Depan Bahagia Sejahtera'), findsOneWidget);
  });

  testWidgets('PocketDetailHeader flightShuttleBuilder excludes PocketCashflowChart during flight', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PocketDetailHeader(
            pocket: mockPocket,
            pocketColor: const Color(0xFFD4F442),
            currencyFormatter: currencyFormatter,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final heroFinder = find.byType(Hero);
    expect(heroFinder, findsOneWidget);
    final hero = tester.widget<Hero>(heroFinder);
    expect(hero.flightShuttleBuilder, isNotNull);

    final flightContext = tester.element(heroFinder);
    final shuttleWidget = hero.flightShuttleBuilder!(
      flightContext,
      const AlwaysStoppedAnimation(0.5),
      HeroFlightDirection.push,
      flightContext,
      flightContext,
    );

    await tester.pumpWidget(MaterialApp(home: Scaffold(body: shuttleWidget)));
    // The flight shuttle MUST NOT contain PocketCashflowChart
    expect(find.byType(PocketCashflowChart), findsNothing);
    expect(find.byType(BentoFolderCard), findsOneWidget);
  });
}
