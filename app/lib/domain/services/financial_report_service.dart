import 'dart:math' as math;
import '../../data/database/app_database.dart';

enum ReportPeriod {
  thisMonth('Bulan Ini'),
  lastMonth('Bulan Lalu'),
  threeMonths('3 Bulan'),
  allTime('Semua');

  final String label;
  const ReportPeriod(this.label);
}

class CategorySpendItem {
  final String categoryId;
  final String name;
  final String colorHex;
  final double amount;
  final double percentage;
  final int txCount;

  const CategorySpendItem({required this.categoryId, required this.name, required this.colorHex, required this.amount, required this.percentage, required this.txCount});
}

class WalletReportItem {
  final String walletId;
  final String name;
  final String colorHex;
  final double balance;
  final double income;
  final double expense;

  const WalletReportItem({required this.walletId, required this.name, required this.colorHex, required this.balance, required this.income, required this.expense});
}

class FinancialReportData {
  final ReportPeriod period;
  final double totalIncome;
  final double totalExpense;
  final double netCashflow;
  final double savingsRate;
  final double dailyAverageExpense;
  final int totalTxCount;
  final double totalWalletBalance;
  final double totalPocketBalance;
  final double totalNetWorth;
  final double monthlyCommittedBills;
  final List<CategorySpendItem> expenseByCategory;
  final List<CategorySpendItem> incomeByCategory;
  final List<WalletReportItem> walletBreakdown;

  const FinancialReportData({
    required this.period, required this.totalIncome, required this.totalExpense,
    required this.netCashflow, required this.savingsRate, required this.dailyAverageExpense,
    required this.totalTxCount, required this.totalWalletBalance, required this.totalPocketBalance,
    required this.totalNetWorth, required this.monthlyCommittedBills,
    required this.expenseByCategory, required this.incomeByCategory, required this.walletBreakdown,
  });
}

class FinancialReportService {
  static FinancialReportData generate({
    required List<WalletEntry> wallets,
    required List<PocketEntry> pockets,
    required List<CategoryEntry> categories,
    required List<TransactionEntry> transactions,
    required List<SubscriptionEntry> subscriptions,
    ReportPeriod period = ReportPeriod.thisMonth,
    DateTime? referenceDate,
  }) {
    final now = (referenceDate ?? DateTime.now()).toLocal();
    final activeWallets = wallets.where((w) => !w.isDeleted).toList();
    final activePockets = pockets.where((p) => !p.isDeleted).toList();
    final catMap = {for (final c in categories) c.id: c};

    final totalWalletBalance = activeWallets.fold<double>(0.0, (s, w) => s + w.balance);
    final totalPocketBalance = activePockets.fold<double>(0.0, (s, p) => s + p.currentAmount);
    final monthlyCommitted = subscriptions
        .where((s) => !s.isDeleted && s.status == 'active')
        .fold<double>(0.0, (sum, s) => sum + s.cost);

    final filteredTxs = transactions.where((tx) {
      if (tx.isDeleted) return false;
      if (tx.externalRef?.startsWith('pocket_') == true) return false;
      final d = tx.transactionDate.toLocal();
      switch (period) {
        case ReportPeriod.thisMonth:
          return d.year == now.year && d.month == now.month;
        case ReportPeriod.lastMonth:
          final prev = DateTime(now.year, now.month - 1, 1);
          return d.year == prev.year && d.month == prev.month;
        case ReportPeriod.threeMonths:
          final start = DateTime(now.year, now.month - 2, 1);
          return !d.isBefore(start);
        case ReportPeriod.allTime:
          return true;
      }
    }).toList();

    double totalIncome = 0.0;
    double totalExpense = 0.0;
    final expCatSum = <String, double>{};
    final expCatCount = <String, int>{};
    final incCatSum = <String, double>{};
    final incCatCount = <String, int>{};
    final walletInc = <String, double>{};
    final walletExp = <String, double>{};

    for (final tx in filteredTxs) {
      if (tx.type == 'income') {
        totalIncome += tx.amount;
        incCatSum[tx.categoryId] = (incCatSum[tx.categoryId] ?? 0.0) + tx.amount;
        incCatCount[tx.categoryId] = (incCatCount[tx.categoryId] ?? 0) + 1;
        walletInc[tx.walletId] = (walletInc[tx.walletId] ?? 0.0) + tx.amount;
      } else if (tx.type == 'expense') {
        totalExpense += tx.amount;
        expCatSum[tx.categoryId] = (expCatSum[tx.categoryId] ?? 0.0) + tx.amount;
        expCatCount[tx.categoryId] = (expCatCount[tx.categoryId] ?? 0) + 1;
        walletExp[tx.walletId] = (walletExp[tx.walletId] ?? 0.0) + tx.amount;
      }
    }

    final netCashflow = totalIncome - totalExpense;
    final savingsRate = totalIncome > 0
        ? ((netCashflow / totalIncome) * 100.0).clamp(-100.0, 100.0)
        : 0.0;

    final daysCount = _resolveActiveDays(period, now, filteredTxs);
    final dailyAvg = daysCount > 0 ? totalExpense / daysCount : 0.0;

    List<CategorySpendItem> buildCatList(Map<String, double> sums, Map<String, int> counts, double total) {
      final items = sums.entries.map((e) {
        final cat = catMap[e.key];
        return CategorySpendItem(
          categoryId: e.key,
          name: cat?.name ?? 'Lainnya',
          colorHex: cat?.colorHex ?? '#64748B',
          amount: e.value,
          percentage: total > 0 ? (e.value / total) * 100.0 : 0.0,
          txCount: counts[e.key] ?? 0,
        );
      }).toList()
        ..sort((a, b) => b.amount.compareTo(a.amount));
      return items;
    }

    final walletItems = activeWallets.map((w) {
      return WalletReportItem(
        walletId: w.id,
        name: w.name,
        colorHex: w.colorHex,
        balance: w.balance,
        income: walletInc[w.id] ?? 0.0,
        expense: walletExp[w.id] ?? 0.0,
      );
    }).toList()
      ..sort((a, b) => (b.expense + b.income).compareTo(a.expense + a.income));

    return FinancialReportData(
      period: period,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      netCashflow: netCashflow,
      savingsRate: savingsRate,
      dailyAverageExpense: dailyAvg,
      totalTxCount: filteredTxs.length,
      totalWalletBalance: totalWalletBalance,
      totalPocketBalance: totalPocketBalance,
      totalNetWorth: totalWalletBalance + totalPocketBalance,
      monthlyCommittedBills: monthlyCommitted,
      expenseByCategory: buildCatList(expCatSum, expCatCount, totalExpense),
      incomeByCategory: buildCatList(incCatSum, incCatCount, totalIncome),
      walletBreakdown: walletItems,
    );
  }

  static int _resolveActiveDays(ReportPeriod period, DateTime now, List<TransactionEntry> txs) {
    switch (period) {
      case ReportPeriod.thisMonth:
        return math.max(1, now.day);
      case ReportPeriod.lastMonth:
        return DateTime(now.year, now.month, 0).day;
      case ReportPeriod.threeMonths:
        final start = DateTime(now.year, now.month - 2, 1);
        return math.max(1, now.difference(start).inDays + 1);
      case ReportPeriod.allTime:
        if (txs.isEmpty) return 1;
        final earliest = txs.map((t) => t.transactionDate.toLocal()).reduce((a, b) => a.isBefore(b) ? a : b);
        return math.max(1, now.difference(earliest).inDays + 1);
    }
  }
}
