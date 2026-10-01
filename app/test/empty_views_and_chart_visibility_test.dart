import 'package:drift/native.dart';
import 'package:fibonanci_app/bloc/finance/finance_bloc.dart';
import 'package:fibonanci_app/bloc/finance/finance_event.dart';
import 'package:fibonanci_app/bloc/finance/finance_state.dart';
import 'package:fibonanci_app/data/database/app_database.dart';
import 'package:fibonanci_app/data/repositories/finance_repository.dart';
import 'package:fibonanci_app/presentation/screens/dashboard_screen.dart';
import 'package:fibonanci_app/presentation/screens/wallet_detail/wallet_detail_actions_and_chart.dart';
import 'package:fibonanci_app/presentation/screens/wallet_detail/wallet_detail_history_section.dart';
import 'package:fibonanci_app/presentation/screens/wallet_screen.dart';
import 'package:fibonanci_app/presentation/screens/subscription_screen.dart';
import 'package:fibonanci_app/presentation/widgets/dashboard_bento_grid.dart';
import 'package:fibonanci_app/presentation/widgets/pocket_stock_chart_card.dart';
import 'package:fibonanci_app/presentation/widgets/trend_spline_chart.dart';
import 'package:fibonanci_app/presentation/widgets/wallet_card_deck.dart';
import 'package:fibonanci_app/presentation/widgets/wallet_cashflow_summary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  group('Cardless Empty Views & Chart Card Hiding Tests', () {
    testWidgets('WalletPocketsView hides PocketStockChartCard and centers cardless empty state in SliverFillRemaining', (tester) async {
      final currencyFmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                WalletPocketsView(
                  pockets: const [],
                  totalPocketsAmount: 0.0,
                  transactions: const [],
                  currencyFormatter: currencyFmt,
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Chart card MUST be hidden when pockets are empty
      expect(find.byType(PocketStockChartCard), findsNothing);

      // Must use SliverFillRemaining to be vertically centered in the viewport
      expect(find.byType(SliverFillRemaining), findsOneWidget);

      // Cardless empty state text and icon MUST be present
      expect(find.text('Belum Ada Kantong Tabungan'), findsOneWidget);
      expect(find.byIcon(Icons.savings_outlined), findsOneWidget);
    });

    testWidgets('WalletCardDeck renders cardless empty state when wallets are empty', (tester) async {
      final currencyFmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WalletCardDeck(
              wallets: const [],
              fmt: currencyFmt,
              onSelectWallet: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Belum Ada Rekening'), findsOneWidget);
      expect(find.text('Ketuk tombol + di bawah untuk menambahkan'), findsOneWidget);
      expect(find.byIcon(Icons.account_balance_wallet_outlined), findsOneWidget);
    });

    testWidgets('WalletDetailActionsAndChart hides TrendSplineChart when wallet has 0 balance and 0 transactions', (tester) async {
      final emptyWallet = WalletEntry(
        id: 'empty_wallet_1',
        name: 'Rekening Kosong',
        type: 'bank',
        currency: 'IDR',
        balance: 0.0,
        colorHex: '#10B981',
        iconName: 'landmark',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isSynced: false,
        isDeleted: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WalletDetailActionsAndChart(
              wallet: emptyWallet,
              cardColor: const Color(0xFF10B981),
              transactions: const [],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TrendSplineChart), findsNothing);
    });

    testWidgets('WalletDetailHistorySection renders cardless empty state when transactions are empty', (tester) async {
      final currencyFmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
      final searchController = TextEditingController();
      final wallet = WalletEntry(
        id: 'test_wallet',
        name: 'Test Wallet',
        type: 'bank',
        currency: 'IDR',
        balance: 100000.0,
        colorHex: '#10B981',
        iconName: 'landmark',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isSynced: false,
        isDeleted: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                WalletDetailHistorySection(
                  filteredTx: const [],
                  wallet: wallet,
                  currencyFormatter: currencyFmt,
                  searchQuery: '',
                  searchController: searchController,
                  selectedFilter: WalletTxFilter.all,
                  onSearchChanged: (_) {},
                  onClearSearch: () {},
                  onFilterChanged: (_) {},
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Belum ada mutasi transaksi'), findsOneWidget);
      expect(find.byIcon(Icons.receipt_long_outlined), findsOneWidget);
    });

    testWidgets('WalletScreen hides balance, cashflow summary, and chart when wallets are empty', (tester) async {
      tester.view.physicalSize = const Size(400 * 2, 900 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final db = AppDatabase(NativeDatabase.memory());
      await db.select(db.wallets).get();
      await (db.delete(db.wallets)).go();
      final repo = DriftFinanceRepository(db);
      final bloc = FinanceBloc(repository: repo);
      addTearDown(bloc.close);
      addTearDown(db.close);

      bloc.add(const LoadFinanceData());
      await expectLater(
        bloc.stream,
        emitsThrough(predicate<FinanceState>((s) => s.status == FinanceStatus.success && s.wallets.isEmpty)),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: bloc,
            child: const WalletScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // In rekening tab, balance card, cashflow summary, and chart MUST be hidden
      expect(find.byType(WalletTotalBalanceCard), findsNothing);
      expect(find.byType(WalletCashflowSummary), findsNothing);
      expect(find.byType(TrendSplineChart), findsNothing);

      // Centered cardless empty state MUST be present
      expect(find.text('Belum Ada Rekening'), findsOneWidget);
      expect(find.text('Ketuk tombol + di bawah untuk menambahkan'), findsOneWidget);
    });

    testWidgets('DashboardScreen hides search, folder cards, and history when wallets are empty', (tester) async {
      tester.view.physicalSize = const Size(400 * 2, 900 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final db = AppDatabase(NativeDatabase.memory());
      await db.select(db.wallets).get();
      await (db.delete(db.wallets)).go();
      final repo = DriftFinanceRepository(db);
      final bloc = FinanceBloc(repository: repo);
      addTearDown(bloc.close);
      addTearDown(db.close);

      bloc.add(const LoadFinanceData());
      await expectLater(
        bloc.stream,
        emitsThrough(predicate<FinanceState>((s) => s.status == FinanceStatus.success && s.wallets.isEmpty)),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: bloc,
            child: const DashboardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // On home screen, search, bento grid ("card folder"), and history section MUST be hidden
      expect(find.byType(DashboardSearchBar), findsNothing);
      expect(find.byType(DashboardBentoGrid), findsNothing);
      expect(find.byType(DashboardHistorySection), findsNothing);
      expect(find.text('Riwayat Transaksi'), findsNothing);

      // Centered cardless empty state MUST be rendered
      expect(find.byType(DashboardEmptyWalletView), findsOneWidget);
      expect(find.text('Belum Ada Rekening Terhubung'), findsOneWidget);
    });

    testWidgets('SubscriptionScreen renders unified cardless empty state when subscriptions are empty', (tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      final repo = DriftFinanceRepository(db);
      final bloc = FinanceBloc(repository: repo);
      addTearDown(bloc.close);
      addTearDown(db.close);

      bloc.add(const LoadFinanceData());
      await expectLater(
        bloc.stream,
        emitsThrough(predicate<FinanceState>((s) => s.status == FinanceStatus.success && s.subscriptions.isEmpty)),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: bloc,
            child: const SubscriptionScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Belum Ada Tagihan Rutin'), findsOneWidget);
      expect(find.text('Ketuk tombol + di bawah untuk menambahkan'), findsOneWidget);
      expect(find.byIcon(Icons.receipt_long_outlined), findsOneWidget);
    });
  });
}
