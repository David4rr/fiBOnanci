import 'cashflow_calendar_models.dart';

class CashflowStreakCalculator {
  static (int current, int longest) calculateGlobalStreaks({
    required Map<DateTime, double> allDailyExpenses,
    required DateTime? effectiveTrackingStart,
    required DateTime today,
    required double dailySafePace,
  }) {
    if (effectiveTrackingStart == null || effectiveTrackingStart.isAfter(today)) {
      return (0, 0);
    }

    bool isDayHemat(DateTime d) {
      final exp = allDailyExpenses[DateTime(d.year, d.month, d.day)] ?? 0.0;
      return dailySafePace > 0 ? (exp <= dailySafePace) : (exp == 0.0);
    }

    int currentStreak = 0;
    DateTime cursor = today;
    while (!cursor.isBefore(effectiveTrackingStart)) {
      if (isDayHemat(cursor)) {
        currentStreak++;
        cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
      } else {
        break;
      }
    }

    int longestStreak = 0;
    int running = 0;
    cursor = effectiveTrackingStart;
    while (!cursor.isAfter(today)) {
      if (isDayHemat(cursor)) {
        running++;
        if (running > longestStreak) longestStreak = running;
      } else {
        running = 0;
      }
      cursor = DateTime(cursor.year, cursor.month, cursor.day + 1);
    }

    return (currentStreak, longestStreak);
  }

  static List<WeekStreakDay> calculateCurrentWeekStreak({
    required DateTime today,
    required DateTime? effectiveTrackingStart,
    required Map<DateTime, double> allDailyExpenses,
    required double dailySafePace,
    required int currentStreak,
  }) {
    // Current week: Monday to Sunday (S, S, R, K, J, S, M in Duolingo style)
    final monday = today.subtract(Duration(days: today.weekday - 1));
    const labels = ['S', 'S', 'R', 'K', 'J', 'S', 'M'];

    return List.generate(7, (i) {
      final d = DateTime(monday.year, monday.month, monday.day + i);
      final isToday = d.year == today.year && d.month == today.month && d.day == today.day;
      final isFuture = d.isAfter(today);
      final isBefore = effectiveTrackingStart != null && d.isBefore(effectiveTrackingStart);

      bool isStreakDay = false;
      if (!isFuture && !isBefore) {
        final exp = allDailyExpenses[d] ?? 0.0;
        final isHemat = dailySafePace > 0 ? (exp <= dailySafePace) : (exp == 0.0);
        final diffDays = today.difference(d).inDays;
        isStreakDay = isHemat && (diffDays >= 0 && diffDays < currentStreak);
      }

      return WeekStreakDay(
        date: d,
        dayLabel: labels[i],
        isStreakDay: isStreakDay,
        isToday: isToday,
        isFuture: isFuture,
      );
    });
  }
}
