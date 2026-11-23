import '../../../data/database/app_database.dart';

enum DayActivityStatus {
  noSpend,
  netPositive,
  safePace,
  overPace,
  neutral,
}

class WeekStreakDay {
  final DateTime date;
  final String dayLabel;
  final bool isStreakDay;
  final bool isToday;
  final bool isFuture;

  const WeekStreakDay({
    required this.date,
    required this.dayLabel,
    required this.isStreakDay,
    required this.isToday,
    required this.isFuture,
  });
}

class DailyCashflowSummary {
  final DateTime date;
  final double totalIncome;
  final double totalExpense;
  final double netCashflow;
  final int transactionCount;
  final List<TransactionEntry> transactions;
  final DayActivityStatus status;
  final bool isNoSpendDay;
  final bool isHematDay;
  final double dailySafePace;

  const DailyCashflowSummary({
    required this.date,
    required this.totalIncome,
    required this.totalExpense,
    required this.netCashflow,
    required this.transactionCount,
    required this.transactions,
    required this.status,
    required this.isNoSpendDay,
    this.isHematDay = false,
    this.dailySafePace = 0.0,
  });
}

class MonthCashflowReport {
  final int year;
  final int month;
  final Map<int, DailyCashflowSummary> dailySummaries;
  final int totalHematDays;
  final int totalNoSpendDays;
  final int currentStreak;
  final int longestStreak;
  final double monthTotalIncome;
  final double monthTotalExpense;
  final double monthNetCashflow;
  final List<WeekStreakDay> currentWeekStreak;

  const MonthCashflowReport({
    required this.year,
    required this.month,
    required this.dailySummaries,
    required this.totalHematDays,
    required this.totalNoSpendDays,
    required this.currentStreak,
    required this.longestStreak,
    required this.monthTotalIncome,
    required this.monthTotalExpense,
    required this.monthNetCashflow,
    this.currentWeekStreak = const [],
  });

  int get currentNoSpendStreak => currentStreak;
  int get longestNoSpendStreak => longestStreak;
}
