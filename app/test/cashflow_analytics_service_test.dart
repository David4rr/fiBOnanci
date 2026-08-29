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
  });
}
