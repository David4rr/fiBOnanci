import 'package:fibonanci_app/data/database/app_database.dart';
import 'package:fibonanci_app/domain/services/cashflow_analytics_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CashflowAnalyticsService Unit Tests', () {
    final now = DateTime(2026, 8, 29);

    final walletA = WalletEntry(
      id: 'w_a',
      name: 'BCA Utama',
      type: 'bank',
      currency: 'IDR',
      balance: 1000000.0,
      colorHex: '#10B981',
      iconName: 'wallet',
      createdAt: now,
      updatedAt: now,
      isSynced: false,
      isDeleted: false,
    );

    final walletB = WalletEntry(
      id: 'w_b',
      name: 'GoPay',
      type: 'ewallet',
      currency: 'IDR',
      balance: 500000.0,
      colorHex: '#00AED6',
      iconName: 'smartphone',
      createdAt: now,
      updatedAt: now,
      isSynced: false,
      isDeleted: false,
    );

    final txIncome = TransactionEntry(
      id: 't1',
      walletId: 'w_a',
      categoryId: 'c1',
      amount: 5000000.0,
      type: 'income',
      notes: 'Gaji Bulanan',
      transactionDate: DateTime(2026, 8, 25),
      source: 'manual',
      createdAt: now,
      updatedAt: now,
      isSynced: false,
      isDeleted: false,
    );

    final txExpense = TransactionEntry(
      id: 't2',
      walletId: 'w_b',
      categoryId: 'c2',
      amount: 50000.0,
      type: 'expense',
      notes: 'Kopi Kenangan',
      transactionDate: DateTime(2026, 8, 28),
      source: 'manual',
      createdAt: now,
      updatedAt: now,
      isSynced: false,
      isDeleted: false,
    );

    final txOldMonth = TransactionEntry(
      id: 't3',
      walletId: 'w_a',
      categoryId: 'c1',
      amount: 1000000.0,
      type: 'income',
      notes: 'Bonus Juli',
      transactionDate: DateTime(2026, 7, 20),
      source: 'manual',
      createdAt: now,
      updatedAt: now,
      isSynced: false,
      isDeleted: false,
    );

    final allTx = [txIncome, txExpense, txOldMonth];

    test('calculateMonthlyCashflow aggregates current month income and expense', () {
      final flow = CashflowAnalyticsService.calculateMonthlyCashflow(allTx, referenceDate: now);
      expect(flow.income, 5000000.0);
      expect(flow.expense, 50000.0);
    });

    test('compute30DaySeries creates 30 daily buckets', () {
      final incSeries = CashflowAnalyticsService.compute30DaySeries(
        allTx,
        type: 'income',
        referenceDate: now,
      );
      expect(incSeries.length, 30);
      expect(incSeries.reduce((a, b) => a + b), 5000000.0);

      // Filtered to wallet B only
      final bSeries = CashflowAnalyticsService.compute30DaySeries(
        allTx,
        type: 'income',
        walletId: 'w_b',
        referenceDate: now,
      );
      expect(bSeries.reduce((a, b) => a + b), 0.0);
    });

    test('compute30DayLabels generates exactly 30 points with non-empty interval markers', () {
      final labels = CashflowAnalyticsService.compute30DayLabels(referenceDate: now);
      expect(labels.length, 30);
      final nonEmpty = labels.where((l) => l.isNotEmpty).toList();
      expect(nonEmpty.length, 5);
      expect(nonEmpty.last, '29/8');
    });

    test('filterTransactions filters by query, type, and wallet', () {
      final wallets = [walletA, walletB];

      // Query test
      final queryRes = CashflowAnalyticsService.filterTransactions(
        transactions: allTx,
        wallets: wallets,
        query: 'Kopi',
      );
      expect(queryRes.length, 1);
      expect(queryRes.first.notes, 'Kopi Kenangan');

      // Type filter
      final expRes = CashflowAnalyticsService.filterTransactions(
        transactions: allTx,
        wallets: wallets,
        typeFilter: 'expense',
      );
      expect(expRes.length, 1);
      expect(expRes.first.amount, 50000.0);

      // Wallet filter
      final walletBRes = CashflowAnalyticsService.filterTransactions(
        transactions: allTx,
        wallets: wallets,
        walletFilter: 'w_b',
      );
      expect(walletBRes.length, 1);
      expect(walletBRes.first.walletId, 'w_b');
    });

    test('computeWeeklySpending aggregates real expense amounts for Mon-Sun week', () {
      // 2026-08-29 is Saturday (weekday 6)
      // Monday is 2026-08-24, Friday is 2026-08-28 (txExpense 50000), Saturday is 2026-08-29
      final txSat = TransactionEntry(
        id: 't_sat',
        walletId: 'w_a',
        categoryId: 'c2',
        amount: 250000.0,
        type: 'expense',
        notes: 'Makan Malam Sabtu',
        transactionDate: DateTime(2026, 8, 29),
        source: 'manual',
        createdAt: now,
        updatedAt: now,
        isSynced: false,
        isDeleted: false,
      );

      final weekly = CashflowAnalyticsService.computeWeeklySpending(
        [...allTx, txSat],
        referenceDate: now,
      );

      expect(weekly.length, 7);
      // Friday is index 4 (weekday 5) -> 50.000
      expect(weekly[4], 50000.0);
      // Saturday is index 5 (weekday 6) -> 250.000
      expect(weekly[5], 250000.0);
      // Monday (index 0) -> 0.0
      expect(weekly[0], 0.0);
    });

    test('computePocketTrendSeries reflects deposit (upward) and withdrawal (downward) across filters', () {
      final txDeposit = TransactionEntry(
        id: 'tx_dep',
        walletId: 'w_a',
        categoryId: '11111111-1111-4111-8111-111111111111',
        amount: 50000.0,
        type: 'transfer',
        notes: 'Setoran ke Kantong Dana Darurat',
        transactionDate: DateTime(2026, 8, 28),
        source: 'manual',
        createdAt: now,
        updatedAt: now,
        isSynced: false,
        isDeleted: false,
      );

      final txWithdraw = TransactionEntry(
        id: 'tx_with',
        walletId: 'w_a',
        categoryId: '11111111-1111-4111-8111-111111111111',
        amount: 20000.0,
        type: 'income',
        notes: 'Penarikan dari Kantong Dana Darurat',
        transactionDate: DateTime(2026, 8, 29),
        source: 'manual',
        createdAt: now,
        updatedAt: now,
        isSynced: false,
        isDeleted: false,
      );

      // Current total is 100.000 after deposit +50k and withdrawal -20k (net +30k)
      final trend1M = CashflowAnalyticsService.computePocketTrendSeries(
        currentTotal: 100000.0,
        transactions: [txDeposit, txWithdraw],
        filter: '1M',
        referenceDate: now,
      );

      expect(trend1M.values.length, 7);
      expect(trend1M.currentBalance, 100000.0);
      expect(trend1M.isUpward, isTrue); // Started at 70.000, ended at 100.000 (+30k)
      expect(trend1M.delta, 30000.0);

      // Test 1B filter
      final trend1B = CashflowAnalyticsService.computePocketTrendSeries(
        currentTotal: 100000.0,
        transactions: [txDeposit, txWithdraw],
        filter: '1B',
        referenceDate: now,
      );
      expect(trend1B.values.length, 30);

      // Test 1T filter
      final trend1T = CashflowAnalyticsService.computePocketTrendSeries(
        currentTotal: 100000.0,
        transactions: [txDeposit, txWithdraw],
        filter: '1T',
        referenceDate: now,
      );
      expect(trend1T.values.length, 12);

      // Test Semua filter
      final trendAll = CashflowAnalyticsService.computePocketTrendSeries(
        currentTotal: 100000.0,
        transactions: [txDeposit, txWithdraw],
        filter: 'Semua',
        referenceDate: now,
      );
      expect(trendAll.values.length, 14);
    });

    test('computePocketTrendSeries reflects same-day deposit made today with upward trajectory', () {
      final txToday = TransactionEntry(
        id: 'tx_today',
        walletId: 'w_a',
        categoryId: '11111111-1111-4111-8111-111111111111',
        amount: 500000.0,
        type: 'transfer',
        notes: 'Setoran ke Kantong Tabungan Liburan',
        transactionDate: DateTime(2026, 8, 29, 15, 30),
        source: 'manual',
        createdAt: now,
        updatedAt: now,
        isSynced: false,
        isDeleted: false,
      );

      final trend1M = CashflowAnalyticsService.computePocketTrendSeries(
        currentTotal: 500000.0,
        transactions: [txToday],
        filter: '1M',
        referenceDate: DateTime(2026, 8, 29, 16, 0),
      );

      expect(trend1M.values.length, 7);
      expect(trend1M.currentBalance, 500000.0);
      expect(trend1M.initialBalance, 0.0);
      expect(trend1M.delta, 500000.0);
      expect(trend1M.percentChange, 100.0);
      expect(trend1M.isUpward, isTrue);
      expect(trend1M.values.last, 500000.0);
      expect(trend1M.values[5], 0.0);
    });
  });
}
