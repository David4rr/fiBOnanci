import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:fibonanci_app/data/database/app_database.dart';
import 'package:fibonanci_app/domain/services/safe_to_spend_service.dart';
import 'package:fibonanci_app/presentation/widgets/dashboard_bento_grid.dart';
import 'package:fibonanci_app/presentation/modals/dashboard_modals.dart';

void main() {
  setUpAll(() {
    initializeDateFormatting('id_ID', null);
  });

  group('Dashboard Total Asset & Dynamic Daily Pace Smart Text Tests', () {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    final w1 = WalletEntry(
      id: 'w1',
      name: 'BCA Utama',
      type: 'bank',
      currency: 'IDR',
      balance: 5000000.0,
      colorHex: '#10B981',
      iconName: 'account_balance',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isSynced: true,
      isDeleted: false,
    );

    final w2 = WalletEntry(
      id: 'w2',
      name: 'Mandiri Tabungan',
      type: 'bank',
      currency: 'IDR',
      balance: 15000000.0,
      colorHex: '#3B82F6',
      iconName: 'account_balance',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isSynced: true,
      isDeleted: false,
    );

    final w3 = WalletEntry(
      id: 'w3',
      name: 'SeaBank Vault',
      type: 'bank',
      currency: 'IDR',
      balance: 30000000.0,
      colorHex: '#F59E0B',
      iconName: 'account_balance',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isSynced: true,
      isDeleted: false,
    );

    final List<WalletEntry> allWallets = [w1, w2, w3]; // Grand total assets = 50,000,000

    testWidgets('Card 2 preserves Total Asset (50M across 3 wallets) even when Safe-to-Spend is isolated to 1 wallet (5M)', (tester) async {
      // User selects only w1 (BCA = 5M) for Safe-to-Spend
      final metrics = SafeToSpendService.calculate(
        wallets: allWallets,
        subscriptions: const [],
        selectedWalletIds: {'w1'},
        referenceDate: DateTime(2026, 11, 1),
      );

      expect(metrics.totalRealBalance, equals(50000000.0)); // Grand total assets
      expect(metrics.operationalBalance, equals(5000000.0)); // Operational wallet only
      expect(metrics.safeToSpendMonthly, equals(5000000.0));
      expect(metrics.selectedWalletsCount, equals(1));
      expect(metrics.isAllWallets, isFalse);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DashboardBentoGrid(
              metrics: metrics,
              wallets: allWallets,
              subscriptions: const [],
              currencyFormatter: currencyFormatter,
              onNavigateToWallets: () {},
              onNavigateToSubscriptions: () {},
              todayExpense: 0.0,
            ),
          ),
        ),
      );

      // Card 1: Safe-to-Spend shows operational amount
      expect(find.text('Rp 5.000.000'), findsWidgets);
      expect(find.text('Safe to Spend (1 Akun)'), findsOneWidget);

      // Card 2: Total Real Balance shows true Grand Total Assets (50M) and all 3 accounts
      expect(find.text('Rp 50.000.000'), findsOneWidget);
      expect(find.text('3 Akun Riil'), findsOneWidget);

      // Card 4: Alokasi Harian displays smart text for 0 expenses today
      expect(find.text('Wow, belum belanja hari ini! ✨'), findsOneWidget);
    });

    testWidgets('Card 4 dynamically updates smart text when user has spent today', (tester) async {
      final metrics = SafeToSpendService.calculate(
        wallets: allWallets,
        subscriptions: const [],
        selectedWalletIds: null, // all wallets
        referenceDate: DateTime(2026, 11, 1),
      );

      // Daily allowance = 50M / 30 days ≈ 1,666,666 / day
      final dailyAllowance = metrics.safeToSpendDaily;

      // Scenario 1: User spent 500,000 today (under budget)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DashboardBentoGrid(
              metrics: metrics,
              wallets: allWallets,
              subscriptions: const [],
              currencyFormatter: currencyFormatter,
              onNavigateToWallets: () {},
              onNavigateToSubscriptions: () {},
              todayExpense: 500000.0,
            ),
          ),
        ),
      );

      final remaining = dailyAllowance - 500000.0;
      final expectedRemainingStr = currencyFormatter.format(remaining);
      expect(find.text('Sisa $expectedRemainingStr hari ini'), findsOneWidget);

      // Tap Card 4 to open DailyPaceModal
      await tester.tap(find.text('Sisa $expectedRemainingStr hari ini'));
      await tester.pumpAndSettle();

      // Verify smart contextual banner in modal
      expect(find.text('Keren! Pengeluaran hari ini masih aman di bawah batas alokasi harian.'), findsOneWidget);
      expect(find.text('Pengeluaran Hari Ini'), findsOneWidget);
      expect(find.text('Sisa Kuota Hari Ini'), findsOneWidget);
    });

    testWidgets('DailyPaceModal shows encouraging empty-expense banner when todayExpense is 0', (tester) async {
      final metrics = SafeToSpendService.calculate(
        wallets: allWallets,
        subscriptions: const [],
        selectedWalletIds: {'w1'},
        referenceDate: DateTime(2026, 11, 1),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () => DailyPaceModal.show(ctx, metrics, todayExpense: 0.0),
                child: const Text('Open Modal'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      expect(find.text('Wow! Hari ini kamu belum melakukan pengeluaran sama sekali. Alokasi harianmu masih utuh!'), findsOneWidget);
      expect(find.text('Pengeluaran Hari Ini'), findsOneWidget);
      expect(find.text('Batas Aman Belanja / Hari'), findsOneWidget);
    });
  });
}
