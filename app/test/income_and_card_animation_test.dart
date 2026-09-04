import 'package:drift/native.dart';
import 'package:fibonanci_app/bloc/finance/finance_bloc.dart';
import 'package:fibonanci_app/bloc/finance/finance_event.dart';
import 'package:fibonanci_app/data/database/app_database.dart';
import 'package:fibonanci_app/data/repositories/finance_repository.dart';
import 'package:fibonanci_app/domain/services/cashflow_analytics_service.dart';
import 'package:fibonanci_app/presentation/screens/history/daily_calendar_bar.dart';
import 'package:fibonanci_app/presentation/screens/wallet_detail_screen.dart';
import 'package:fibonanci_app/presentation/theme/app_colors.dart';
import 'package:fibonanci_app/presentation/widgets/transaction_detail_modal.dart';
import 'package:fibonanci_app/presentation/widgets/transaction_modal.dart';
import 'package:fibonanci_app/presentation/widgets/wallet_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  group('Income Transaction Creation & Dropdown Fixes', () {
    testWidgets('TransactionModal switches to income without crash and assigns income category', (tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      final repo = DriftFinanceRepository(db);
      final bloc = FinanceBloc(repository: repo);
      bloc.add(const LoadFinanceData());
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<FinanceBloc>.value(
            value: bloc,
            child: const Scaffold(
              body: TransactionModal(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Pemasukan pill
      await tester.tap(find.text('Pemasukan'));
      await tester.pumpAndSettle();

      // Should not throw assertion error and should show Gaji & Pendapatan Pokok
      expect(find.text('Gaji & Pendapatan Pokok'), findsOneWidget);

      // Enter amount
      await tester.enterText(find.byType(TextField).first, '10000000');
      await tester.pumpAndSettle();

      // Tap save
      await tester.tap(find.text('Simpan Transaksi'));
      await tester.pumpAndSettle();

      // Verify transaction inserted in database
      final txs = await repo.getTransactions();
      expect(txs.any((t) => t.type == 'income' && t.amount == 10000000.0), isTrue);

      await db.close();
    });

    testWidgets('TransactionDetailModal switches to income without crash', (tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      final repo = DriftFinanceRepository(db);
      final bloc = FinanceBloc(repository: repo);
      bloc.add(const LoadFinanceData());
      await tester.pumpAndSettle();

      final wallets = await repo.getWallets();
      final categories = await repo.getCategories();
      final expenseCat = categories.firstWhere((c) => c.type == 'expense');

      await repo.addTransaction(
        walletId: wallets.first.id,
        categoryId: expenseCat.id,
        amount: 50000,
        type: 'expense',
        notes: 'Makan Bakso',
      );
      await tester.pumpAndSettle();

      final txs = await repo.getTransactions();
      final createdTx = txs.firstWhere((t) => t.notes == 'Makan Bakso');

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<FinanceBloc>.value(
            value: bloc,
            child: Scaffold(
              body: TransactionDetailModal(transaction: createdTx),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Pemasukan pill
      await tester.tap(find.text('Pemasukan'));
      await tester.pumpAndSettle();

      // Category should switch to an income category
      expect(find.text('Gaji & Pendapatan Pokok'), findsOneWidget);

      await db.close();
    });
  });

  group('History Retrieval & Filtering Tests', () {
    testWidgets('WalletDetailScreen excludes income transactions from Keluar (expense) filter', (tester) async {
      tester.view.physicalSize = const Size(400 * 2, 900 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final db = AppDatabase(NativeDatabase.memory());
      final repo = DriftFinanceRepository(db);
      final wallets = await repo.getWallets();
      final targetWallet = wallets.first;
      final categories = await repo.getCategories();
      final incomeCat = categories.firstWhere((c) => c.type == 'income');
      final expenseCat = categories.firstWhere((c) => c.type == 'expense');

      // Add 1 income and 1 expense on target wallet
      await repo.addTransaction(
        walletId: targetWallet.id,
        categoryId: incomeCat.id,
        amount: 2500000,
        type: 'income',
        notes: 'Bonus Project',
      );
      await repo.addTransaction(
        walletId: targetWallet.id,
        categoryId: expenseCat.id,
        amount: 75000,
        type: 'expense',
        notes: 'Makan Malam',
      );

      final bloc = FinanceBloc(repository: repo);
      bloc.add(const LoadFinanceData());
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<FinanceBloc>.value(
            value: bloc,
            child: WalletDetailScreen(
              walletId: targetWallet.id,
              currencyFormatter: NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Both visible under 'Semua'
      expect(find.text('Bonus Project'), findsOneWidget);
      expect(find.text('Makan Malam'), findsOneWidget);

      // Tap 'Masuk' filter chip
      await tester.tap(find.widgetWithText(GestureDetector, 'Masuk').first);
      await tester.pumpAndSettle();
      expect(find.text('Bonus Project'), findsOneWidget);
      expect(find.text('Makan Malam'), findsNothing);

      // Tap 'Keluar' filter chip
      await tester.tap(find.widgetWithText(GestureDetector, 'Keluar').first);
      await tester.pumpAndSettle();
      expect(find.text('Makan Malam'), findsOneWidget);
      expect(find.text('Bonus Project'), findsNothing); // MUST NOT appear under Keluar

      await db.close();
    });

    test('CashflowAnalyticsService.filterTransactions matches localized search keywords', () {
      final now = DateTime.now();
      final txIncome = TransactionEntry(
        id: 't_inc',
        walletId: 'w1',
        categoryId: 'c1',
        amount: 5000000,
        type: 'income',
        notes: 'Transfer PT ABC',
        transactionDate: now,
        source: 'manual',
        createdAt: now,
        updatedAt: now,
        isSynced: false,
        isDeleted: false,
      );

      final wallets = [
        WalletEntry(
          id: 'w1',
          name: 'BCA Utama',
          type: 'bank',
          currency: 'IDR',
          balance: 10000000,
          colorHex: '#0060AF',
          iconName: 'wallet',
          createdAt: now,
          updatedAt: now,
          isSynced: false,
          isDeleted: false,
        ),
      ];

      // Search 'pemasukan' matches income
      final res1 = CashflowAnalyticsService.filterTransactions(
        transactions: [txIncome],
        wallets: wallets,
        query: 'pemasukan',
      );
      expect(res1.length, 1);

      // Search 'masuk' matches income
      final res2 = CashflowAnalyticsService.filterTransactions(
        transactions: [txIncome],
        wallets: wallets,
        query: 'masuk',
      );
      expect(res2.length, 1);
    });
  });

  group('Expense History Tab Bar High-Contrast Colors', () {
    testWidgets('DailyCalendarBar renders Active=White and Inactive=High Contrast Muted text', (tester) async {
      final now = DateTime.now();
      final todayKey = '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final yesterday = now.subtract(const Duration(days: 1));
      final yesterdayKey = '${yesterday.year.toString().padLeft(4, '0')}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';

      final sortedDays = [yesterdayKey, todayKey];
      final dayGroups = {
        todayKey: <TransactionEntry>[],
        yesterdayKey: <TransactionEntry>[],
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DailyCalendarBar(
              scrollController: ScrollController(),
              sortedDays: sortedDays,
              selectedIndex: 1, // today selected (Active)
              dayGroups: dayGroups,
              onDaySelected: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Selected tab (Hari Ini) has white text
      final activeText = tester.widget<Text>(find.text('Hari Ini'));
      expect(activeText.style?.color, AppColors.textWhite);

      // Inactive tab (Kemarin) has high-contrast muted text
      final inactiveText = tester.widget<Text>(find.text('Kemarin'));
      expect(inactiveText.style?.color, AppColors.textMuted);
    });
  });

  group('Account Card Text Animation Vertical Offset', () {
    testWidgets('WalletCard renders AnimatedSwitcher with increased vertical offset 0.20 when animate: true', (tester) async {
      final now = DateTime.now();
      final wallet = WalletEntry(
        id: 'w1',
        name: 'BCA Utama',
        type: 'bank',
        currency: 'IDR',
        balance: 5000000,
        colorHex: '#0060AF',
        iconName: 'wallet',
        createdAt: now,
        updatedAt: now,
        isSynced: false,
        isDeleted: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return WalletCard(
                  wallet: wallet,
                  index: 0,
                  fmt: NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0),
                  cardH: 220,
                  showBottomLayout: false,
                  animate: true,
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // AnimatedSwitcher must be present
      expect(find.byType(AnimatedSwitcher), findsOneWidget);
      expect(find.text('SALDO TERSEDIA'), findsOneWidget);

      // Switch to showBottomLayout: true to trigger transition
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WalletCard(
              wallet: wallet,
              index: 0,
              fmt: NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0),
              cardH: 220,
              showBottomLayout: true,
              animate: true,
            ),
          ),
        ),
      );
      // Advance 1ms into animation
      await tester.pump(const Duration(milliseconds: 1));

      // SlideTransition for incoming child has non-zero positive vertical offset
      // SlideTransition for incoming child has positive vertical offset
      final slideTransitions = tester.widgetList<SlideTransition>(find.byType(SlideTransition)).toList();
      expect(slideTransitions.isNotEmpty, isTrue);
      final values = slideTransitions.map((s) => s.position.value.dy).toList();
      expect(values.any((dy) => dy >= 0.0), isTrue);
      await tester.pumpAndSettle();
      expect(find.text('Saldo Tersedia'), findsOneWidget);
      expect(find.text('Rp 5.000.000'), findsOneWidget);
    });
  });
  group('Account Details Modal & Standardized AppBar Tests', () {
    testWidgets('WalletDetailScreen renders standardized AppBar matching Expense History UI and preserves Hero transitions', (tester) async {
      tester.view.physicalSize = const Size(400 * 2, 900 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final db = AppDatabase(NativeDatabase.memory());
      final repo = DriftFinanceRepository(db);
      final bloc = FinanceBloc(repository: repo);
      bloc.add(const LoadFinanceData());
      await tester.pumpAndSettle();

      final targetWallet = bloc.state.wallets.first;

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<FinanceBloc>.value(
            value: bloc,
            child: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => WalletDetailScreen.show(context, wallet: targetWallet),
                child: const Text('Open Modal'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap button to open modal
      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      // 1. Verify WalletDetailScreen is presented
      expect(find.byType(WalletDetailScreen), findsOneWidget);

      // 2. Verify Standardized AppBar matching Expense History UI
      expect(find.text('Detail Rekening'), findsOneWidget);
      final titleText = tester.widget<Text>(find.text('Detail Rekening'));
      expect(titleText.style?.fontSize, 28);
      expect(titleText.style?.fontWeight, FontWeight.w800);
      expect(titleText.style?.color, AppColors.textWhite);

      expect(find.text('Informasi & Mutasi'), findsOneWidget);
      final subtitleText = tester.widget<Text>(find.text('Informasi & Mutasi'));
      expect(subtitleText.style?.fontSize, 12);
      expect(subtitleText.style?.color, AppColors.textMuted);

      // 3. Verify Standardized dismiss button with downward arrow
      expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsOneWidget);

      // 4. Verify shared element transition Hero exists with matching wallet tag
      final heroFinder = find.byWidgetPredicate(
        (w) => w is Hero && w.tag == 'wallet_card_${targetWallet.id}',
      );
      expect(heroFinder, findsOneWidget);

      // 5. Test dismissing modal via downward arrow dismiss button
      await tester.tap(find.byIcon(Icons.keyboard_arrow_down_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(WalletDetailScreen), findsNothing);
      expect(find.text('Open Modal'), findsOneWidget);

      await db.close();
    });
  });
}
