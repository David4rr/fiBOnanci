import '../../data/database/app_database.dart';
import 'calendar/cashflow_calendar_models.dart';
import 'calendar/cashflow_streak_calculator.dart';

export 'calendar/cashflow_calendar_models.dart';
export 'calendar/cashflow_streak_calculator.dart';

class CashflowCalendarService {
  static int getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  static String formatCompactAmount(double amount) {
    final abs = amount.abs();
    if (abs >= 1000000000) return '${(abs / 1000000000).toStringAsFixed(abs >= 10000000000 ? 0 : 1)}B';
    if (abs >= 1000000) return '${(abs / 1000000).toStringAsFixed(abs >= 10000000 ? 0 : 1)}M';
    if (abs >= 1000) return '${(abs / 1000).toStringAsFixed(0)}k';
    return abs.toInt().toString();
  }

  static String getCellLabel(DailyCashflowSummary summary) {
    if (summary.status == DayActivityStatus.neutral) return '';
    if (summary.isNoSpendDay && summary.totalIncome == 0.0) return 'Rp 0';
    if (summary.totalIncome > summary.totalExpense) return '+${formatCompactAmount(summary.netCashflow)}';
    if (summary.totalExpense > 0) return formatCompactAmount(summary.totalExpense);
    return '';
  }

  static int calculateCurrentStreak({
    required List<TransactionEntry> transactions,
    required double dailySafePace,
    DateTime? referenceDate,
    DateTime? trackingStartDate,
  }) {
    final now = referenceDate ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    DateTime? start = trackingStartDate != null
        ? DateTime(trackingStartDate.year, trackingStartDate.month, trackingStartDate.day)
        : null;

    final allDailyExpenses = <DateTime, double>{};
    for (final t in transactions) {
      if (t.isDeleted) continue;
      final txDay = DateTime(t.transactionDate.year, t.transactionDate.month, t.transactionDate.day);
      if (trackingStartDate == null && (start == null || txDay.isBefore(start))) {
        start = txDay;
      }
      if (t.type == 'expense') {
        allDailyExpenses[txDay] = (allDailyExpenses[txDay] ?? 0.0) + t.amount;
      }
    }

    final (streak, _) = CashflowStreakCalculator.calculateGlobalStreaks(
      allDailyExpenses: allDailyExpenses,
      effectiveTrackingStart: start,
      today: today,
      dailySafePace: dailySafePace,
    );
    return streak;
  }

  static MonthCashflowReport calculate({
    required List<TransactionEntry> transactions,
    required int year,
    required int month,
    double dailySafePace = 0.0,
    DateTime? referenceDate,
    DateTime? trackingStartDate,
  }) {
    final now = referenceDate ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final daysInMonth = getDaysInMonth(year, month);

    DateTime? effectiveTrackingStart;
    if (trackingStartDate != null) {
      final local = trackingStartDate.toLocal();
      effectiveTrackingStart = DateTime(local.year, local.month, local.day);
    }

    final monthTxs = <TransactionEntry>[];
    final allDailyExpenses = <DateTime, double>{};

    for (final t in transactions) {
      if (t.isDeleted) continue;
      final local = t.transactionDate.toLocal();
      final txDay = DateTime(local.year, local.month, local.day);
      if (effectiveTrackingStart == null || txDay.isBefore(effectiveTrackingStart)) {
        effectiveTrackingStart = txDay;
      }
      if (t.type == 'expense' || t.type == 'transfer') {
        allDailyExpenses[txDay] = (allDailyExpenses[txDay] ?? 0.0) + t.amount;
      }
      if (local.year == year && local.month == month) {
        monthTxs.add(t);
      }
    }

    final dailyMap = <int, DailyCashflowSummary>{};
    double monthIncome = 0.0;
    double monthExpense = 0.0;
    int totalNoSpend = 0;
    int totalHemat = 0;

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      final isFuture = date.isAfter(today);
      final isBeforeTracking = effectiveTrackingStart == null || date.isBefore(effectiveTrackingStart);

      final dayTxs = monthTxs.where((t) => t.transactionDate.toLocal().day == day).toList()
        ..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));

      double income = 0.0;
      double expense = 0.0;
      for (final tx in dayTxs) {
        if (tx.type == 'income') {
          income += tx.amount;
        } else if (tx.type == 'expense' || tx.type == 'transfer') {
          expense += tx.amount;
        }
      }

      monthIncome += income;
      monthExpense += expense;

      final isNoSpend = !isFuture && !isBeforeTracking && expense == 0.0;
      final isHemat = !isFuture && !isBeforeTracking &&
          (dailySafePace > 0 ? expense <= dailySafePace : expense == 0.0);

      if (isNoSpend) totalNoSpend++;
      if (isHemat) totalHemat++;

      DayActivityStatus status;
      if (isFuture || isBeforeTracking) {
        status = DayActivityStatus.neutral;
      } else if (expense == 0.0 && income == 0.0) {
        status = DayActivityStatus.noSpend;
      } else if (income > expense) {
        status = DayActivityStatus.netPositive;
      } else if (dailySafePace > 0 && expense > dailySafePace) {
        status = DayActivityStatus.overPace;
      } else if (expense > 0) {
        status = DayActivityStatus.safePace;
      } else {
        status = DayActivityStatus.noSpend;
      }

      dailyMap[day] = DailyCashflowSummary(
        date: date,
        totalIncome: income,
        totalExpense: expense,
        netCashflow: income - expense,
        transactionCount: dayTxs.length,
        transactions: dayTxs,
        status: status,
        isNoSpendDay: isNoSpend,
        isHematDay: isHemat,
        dailySafePace: dailySafePace,
      );
    }

    final (currentStreak, longestStreak) = CashflowStreakCalculator.calculateGlobalStreaks(
      allDailyExpenses: allDailyExpenses,
      effectiveTrackingStart: effectiveTrackingStart,
      today: today,
      dailySafePace: dailySafePace,
    );

    final currentWeekStreak = CashflowStreakCalculator.calculateCurrentWeekStreak(
      today: today,
      effectiveTrackingStart: effectiveTrackingStart,
      allDailyExpenses: allDailyExpenses,
      dailySafePace: dailySafePace,
      currentStreak: currentStreak,
    );

    return MonthCashflowReport(
      year: year,
      month: month,
      dailySummaries: dailyMap,
      totalHematDays: totalHemat,
      totalNoSpendDays: totalNoSpend,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      monthTotalIncome: monthIncome,
      monthTotalExpense: monthExpense,
      monthNetCashflow: monthIncome - monthExpense,
      currentWeekStreak: currentWeekStreak,
    );
  }
}
