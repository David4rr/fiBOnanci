import 'dart:math' as math;
import 'package:flutter/material.dart' show DateTimeRange;
import 'package:intl/intl.dart';
import '../../data/database/app_database.dart';
import 'financial_report_models.dart';

export 'financial_report_models.dart';

class FinancialReportService {
  static DateTimeRange resolveGranularityRange(ReportGranularity granularity, int offset, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    switch (granularity) {
      case ReportGranularity.week:
        final monday = today.subtract(Duration(days: today.weekday - 1));
        final start = monday.add(Duration(days: offset * 7));
        return DateTimeRange(start: start, end: start.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59)));
      case ReportGranularity.month:
        final start = DateTime(now.year, now.month + offset, 1);
        return DateTimeRange(start: start, end: DateTime(start.year, start.month + 1, 0, 23, 59, 59));
      case ReportGranularity.quarter:
        final currentQ = ((now.month - 1) ~/ 3);
        final totalQ = now.year * 4 + currentQ + offset;
        final year = (totalQ / 4).floor();
        final q = totalQ - year * 4;
        final startMonth = q * 3 + 1;
        final start = DateTime(year, startMonth, 1);
        final end = DateTime(year, startMonth + 3, 0, 23, 59, 59);
        return DateTimeRange(start: start, end: end);
    }
  }

  static String formatGranularityLabel(
    ReportGranularity granularity,
    int offset,
    DateTime now, {
    String localeCode = 'id',
  }) {
    final range = resolveGranularityRange(granularity, offset, now);
    final isEn = localeCode == 'en';
    final intlLocale = isEn ? 'en_US' : 'id_ID';
    switch (granularity) {
      case ReportGranularity.week:
        if (offset == 0) return isEn ? 'This Week' : 'Minggu Ini';
        if (offset == -1) return isEn ? 'Last Week' : 'Minggu Lalu';
        return DateFormat('d MMM', intlLocale).format(range.start);
      case ReportGranularity.month:
        final label = DateFormat('MMMM', intlLocale).format(range.start);
        return range.start.year == now.year ? label : '$label ${range.start.year}';
      case ReportGranularity.quarter:
        final q = ((range.start.month - 1) ~/ 3) + 1;
        return 'Q$q ${range.start.year}';
    }
  }

  static FinancialReportData generate({
    required List<WalletEntry> wallets,
    required List<PocketEntry> pockets,
    required List<CategoryEntry> categories,
    required List<TransactionEntry> transactions,
    required List<SubscriptionEntry> subscriptions,
    ReportPeriod period = ReportPeriod.thisMonth,
    ReportGranularity? granularity,
    int periodOffset = 0,
    DateTime? referenceDate,
  }) {
    final now = (referenceDate ?? DateTime.now()).toLocal();
    final activeWallets = wallets.where((w) => !w.isDeleted).toList();
    final activePockets = pockets.where((p) => !p.isDeleted).toList();
    final catMap = {for (final c in categories) c.id: c};

    final totalWalletBalance = activeWallets.fold<double>(0.0, (s, w) => s + w.balance);
    final totalPocketBalance = activePockets.fold<double>(0.0, (s, p) => s + p.currentAmount);
    final monthlyCommitted = subscriptions.where((s) => !s.isDeleted && s.status == 'active').fold<double>(0.0, (sum, s) => sum + s.cost);
    final customRange = granularity != null ? resolveGranularityRange(granularity, periodOffset, now) : null;

    final filteredTxs = transactions.where((tx) {
      if (tx.isDeleted) return false;
      if (tx.externalRef?.startsWith('pocket_') == true) return false;
      final d = tx.transactionDate.toLocal();
      if (customRange != null) {
        return !d.isBefore(customRange.start) && !d.isAfter(customRange.end);
      }
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
      } else if (tx.type == 'expense' || tx.type == 'transfer') {
        totalExpense += tx.amount;
        expCatSum[tx.categoryId] = (expCatSum[tx.categoryId] ?? 0.0) + tx.amount;
        expCatCount[tx.categoryId] = (expCatCount[tx.categoryId] ?? 0) + 1;
        walletExp[tx.walletId] = (walletExp[tx.walletId] ?? 0.0) + tx.amount;
        if (tx.type == 'transfer' && tx.destinationWalletId != null) {
          totalIncome += tx.amount;
          walletInc[tx.destinationWalletId!] = (walletInc[tx.destinationWalletId!] ?? 0.0) + tx.amount;
        }
      }
    }

    final netCashflow = totalIncome - totalExpense;
    final savingsRate = totalIncome > 0
        ? ((netCashflow / totalIncome) * 100.0).clamp(-100.0, 100.0)
        : 0.0;

    final daysCount = customRange != null
        ? math.max(1, customRange.end.difference(customRange.start).inDays + 1)
        : _resolveActiveDays(period, now, filteredTxs);
    final dailyAvg = daysCount > 0 ? totalExpense / daysCount : 0.0;

    List<CategorySpendItem> buildCatList(Map<String, double> sums, Map<String, int> counts, double total) {
      return sums.entries.map((e) {
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
