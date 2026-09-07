import 'package:drift/native.dart';
import 'package:fibonanci_app/data/database/app_database.dart';
import 'package:fibonanci_app/presentation/widgets/common/expandable_search_filter_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late List<WalletEntry> mockWallets;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    mockWallets = await db.select(db.wallets).get();
  });

  tearDown(() async {
    await db.close();
  });

  Widget buildTestableWidget({
    required TextEditingController controller,
    String searchQuery = '',
    String typeFilter = 'all',
    String? walletFilter,
    required ValueChanged<String> onSearchChanged,
    required VoidCallback onClearSearch,
    required void Function(String, String?) onFilterApplied,
    VoidCallback? onClearTypeFilter,
    VoidCallback? onClearWalletFilter,
    String headerTitle = 'Filter Transaksi',
    String primaryFilterTitle = 'TIPE TRANSAKSI',
    List<FilterChoice> primaryFilterChoices = kDefaultTransactionTypeChoices,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: StatefulBuilder(
          builder: (context, setState) {
            return ExpandableSearchFilterBar(
              searchController: controller,
              searchQuery: searchQuery,
              typeFilter: typeFilter,
              walletFilter: walletFilter,
              wallets: mockWallets,
              onSearchChanged: onSearchChanged,
              onClearSearch: onClearSearch,
              onFilterApplied: onFilterApplied,
              onClearTypeFilter: onClearTypeFilter,
              onClearWalletFilter: onClearWalletFilter,
              headerTitle: headerTitle,
              primaryFilterTitle: primaryFilterTitle,
              primaryFilterChoices: primaryFilterChoices,
            );
          },
        ),
      ),
    );
  }

  testWidgets('ExpandableSearchFilterBar renders collapsed, expands on tune tap, and applies filter', (tester) async {
    final controller = TextEditingController();
    String currentType = 'all';
    String? currentWalletId;

    await tester.pumpWidget(
      buildTestableWidget(
        controller: controller,
        typeFilter: currentType,
        walletFilter: currentWalletId,
        onSearchChanged: (_) {},
        onClearSearch: () {},
        onFilterApplied: (type, walletId) {
          currentType = type;
          currentWalletId = walletId;
        },
      ),
    );

    // 1. Initial collapsed state: search bar is visible, filter panel is hidden
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byIcon(Icons.tune), findsOneWidget);
    expect(find.text('Filter Transaksi'), findsNothing);

    // 2. Tap tune button -> expands downward with smooth animation
    await tester.tap(find.byIcon(Icons.tune));
    await tester.pumpAndSettle();

    expect(find.text('Filter Transaksi'), findsOneWidget);
    expect(find.text('TIPE TRANSAKSI'), findsOneWidget);
    expect(find.text('Pengeluaran'), findsOneWidget);
    expect(find.text('Pemasukan'), findsOneWidget);
    expect(find.text('Terapkan Filter'), findsOneWidget);

    // 3. Select 'Pengeluaran' and tap 'Terapkan Filter'
    await tester.tap(find.text('Pengeluaran'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Terapkan Filter'));
    await tester.pumpAndSettle();

    // 4. Panel is collapsed back and filter applied
    expect(currentType, 'expense');
    expect(find.text('Filter Transaksi'), findsNothing);

    controller.dispose();
  });

  testWidgets('ExpandableSearchFilterBar displays active chips when collapsed and resets filter', (tester) async {
    final controller = TextEditingController();
    String currentType = 'expense';
    String? currentWalletId;
    bool typeCleared = false;

    await tester.pumpWidget(
      buildTestableWidget(
        controller: controller,
        typeFilter: currentType,
        walletFilter: currentWalletId,
        onSearchChanged: (_) {},
        onClearSearch: () {},
        onFilterApplied: (type, walletId) {
          currentType = type;
          currentWalletId = walletId;
        },
        onClearTypeFilter: () => typeCleared = true,
      ),
    );

    // Active chip is rendered
    expect(find.text('Tipe: EXPENSE'), findsOneWidget);

    // Tap clear on active filter chip
    await tester.tap(find.descendant(
      of: find.ancestor(of: find.text('Tipe: EXPENSE'), matching: find.byType(Container)).first,
      matching: find.byIcon(Icons.close),
    ));
    await tester.pumpAndSettle();
    expect(typeCleared, isTrue);

    controller.dispose();
  });

  testWidgets('ExpandableSearchFilterBar supports Subscription filter configuration', (tester) async {
    final controller = TextEditingController();
    String currentStatus = 'all';
    String? currentWalletId;

    await tester.pumpWidget(
      buildTestableWidget(
        controller: controller,
        typeFilter: currentStatus,
        walletFilter: currentWalletId,
        headerTitle: 'Filter Tagihan',
        primaryFilterTitle: 'STATUS PEMBAYARAN',
        primaryFilterChoices: kDefaultSubscriptionStatusChoices,
        onSearchChanged: (_) {},
        onClearSearch: () {},
        onFilterApplied: (type, walletId) {
          currentStatus = type;
          currentWalletId = walletId;
        },
      ),
    );

    // 1. Initial state
    expect(find.text('Filter Tagihan'), findsNothing);

    // 2. Expand
    await tester.tap(find.byIcon(Icons.tune));
    await tester.pumpAndSettle();

    expect(find.text('Filter Tagihan'), findsOneWidget);
    expect(find.text('STATUS PEMBAYARAN'), findsOneWidget);
    expect(find.text('Belum Bayar'), findsOneWidget);
    expect(find.text('Sudah Lunas'), findsOneWidget);

    // 3. Select 'Belum Bayar' and apply
    await tester.tap(find.text('Belum Bayar'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Terapkan Filter'));
    await tester.pumpAndSettle();

    expect(currentStatus, 'unpaid');
    expect(find.text('Filter Tagihan'), findsNothing);

    controller.dispose();
  });

  testWidgets('ExpandableSearchFilterBar floats over siblings without pushing them and closes on tap outside', (tester) async {
    final controller = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              ExpandableSearchFilterBar(
                searchController: controller,
                searchQuery: '',
                typeFilter: 'all',
                wallets: mockWallets,
                onSearchChanged: (_) {},
                onClearSearch: () {},
                onFilterApplied: (_, _) {},
              ),
              const Text('Sibling Content Below'),
            ],
          ),
        ),
      ),
    );

    // Initial position of sibling content
    final initialSiblingTop = tester.getTopLeft(find.text('Sibling Content Below')).dy;

    // Expand filter dropdown
    await tester.tap(find.byIcon(Icons.tune));
    await tester.pumpAndSettle();

    // Sibling content position has NOT changed at all!
    final expandedSiblingTop = tester.getTopLeft(find.text('Sibling Content Below')).dy;
    expect(expandedSiblingTop, equals(initialSiblingTop));

    // Filter panel is visible floating on top
    expect(find.text('Filter Transaksi'), findsOneWidget);

    // Tap outside (bottom of the screen) dismisses the floating dropdown
    await tester.tapAt(const Offset(200, 500));
    await tester.pumpAndSettle();

    expect(find.text('Filter Transaksi'), findsNothing);

    controller.dispose();
  });
}
