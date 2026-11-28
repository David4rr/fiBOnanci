import 'dart:math';

import '../../data/database/app_database.dart';

/// Pure deterministic calendar and budget-cycle math for subscriptions and installments.
/// Single source of truth used by UI selectors, Safe-to-Spend, Auto-Deduct, notifications, and DB v7 migration.
class SubscriptionScheduleService {
  /// Strips time components to local calendar date (00:00:00).
  static DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Resolves a valid calendar date for [year] and [month] (handles month > 12 or < 1)
  /// clamping [dueDay] to the month's maximum day (e.g., 31 -> 28 in Feb).
  static DateTime clampedMonthDate(int year, int month, int dueDay) {
    final normalized = DateTime(year, month, 1);
    final maxDays = DateTime(normalized.year, normalized.month + 1, 0).day;
    final clampedDay = dueDay.clamp(1, maxDays);
    return DateTime(normalized.year, normalized.month, clampedDay);
  }

  /// Default month offset when adding a new subscription:
  /// If [dueDay] has already passed in [referenceDate]'s month, defaults to next month (1);
  /// otherwise defaults to current month (0).
  static int defaultMonthOffset({
    required int dueDay,
    required DateTime referenceDate,
  }) {
    return referenceDate.day > dueDay ? 1 : 0;
  }

  /// Computes the explicit first due date given [dueDay], [monthOffset], and [referenceDate].
  static DateTime resolveFirstDueDate({
    required int dueDay,
    required int monthOffset,
    required DateTime referenceDate,
    String billingCycle = 'monthly',
  }) {
    final today = dateOnly(referenceDate);
    if (billingCycle == 'weekly') {
      final targetWeekday = dueDay.clamp(1, 7);
      final daysAhead = (targetWeekday - today.weekday) % 7;
      return dateOnly(today.add(Duration(days: daysAhead + (monthOffset * 7))));
    }
    if (billingCycle == 'yearly') {
      return clampedMonthDate(today.year + monthOffset, today.month, dueDay);
    }
    return clampedMonthDate(today.year, today.month + monthOffset, dueDay);
  }

  /// Updates [currentNextDueDate] when the due-day slider moves to [newDueDay].
  static DateTime applyDayChange({
    required DateTime currentNextDueDate,
    required int newDueDay,
    required bool preserveMonth,
    required DateTime referenceDate,
  }) {
    if (preserveMonth) {
      return clampedMonthDate(currentNextDueDate.year, currentNextDueDate.month, newDueDay);
    }
    final offset = defaultMonthOffset(dueDay: newDueDay, referenceDate: referenceDate);
    return resolveFirstDueDate(dueDay: newDueDay, monthOffset: offset, referenceDate: referenceDate);
  }

  /// Advances [currentNextDueDate] by exactly one [billingCycle] while preserving [dueDay]
  /// (so day 31 recovers from Feb 28 -> Mar 31).
  static DateTime advanceNextDueDate({
    required DateTime currentNextDueDate,
    required int dueDay,
    required String billingCycle,
  }) {
    final base = dateOnly(currentNextDueDate);
    if (billingCycle == 'weekly') {
      return dateOnly(base.add(const Duration(days: 7)));
    }
    if (billingCycle == 'yearly') {
      return clampedMonthDate(base.year + 1, base.month, dueDay);
    }
    return clampedMonthDate(base.year, base.month + 1, dueDay);
  }

  /// Rewinds [currentNextDueDate] by one [billingCycle] when reversing a paid subscription transaction.
  static DateTime rewindNextDueDate({
    required DateTime currentNextDueDate,
    required int dueDay,
    required String billingCycle,
  }) {
    final base = dateOnly(currentNextDueDate);
    if (billingCycle == 'weekly') {
      return dateOnly(base.subtract(const Duration(days: 7)));
    }
    if (billingCycle == 'yearly') {
      return clampedMonthDate(base.year - 1, base.month, dueDay);
    }
    return clampedMonthDate(base.year, base.month - 1, dueDay);
  }

  /// Exclusive upper bound of the active budget cycle for [referenceDate] and [cycleDay].
  /// For cycleDay <= 1: first day of next calendar month.
  /// For cycleDay > 1: next occurrence of cycleDay (clamped to month length).
  static DateTime nextCutoffDate({
    required DateTime referenceDate,
    int cycleDay = 1,
  }) {
    final now = dateOnly(referenceDate);
    if (cycleDay <= 1) {
      return DateTime(now.year, now.month + 1, 1);
    }
    final curMax = DateTime(now.year, now.month + 1, 0).day;
    final curCut = min(cycleDay, curMax);
    if (now.day < curCut) {
      return DateTime(now.year, now.month, curCut);
    }
    final nxtMax = DateTime(now.year, now.month + 2, 0).day;
    final nxtCut = min(cycleDay, nxtMax);
    return DateTime(now.year, now.month + 1, nxtCut);
  }

  /// Returns true if [sub] is an active, uncompleted bill whose [SubscriptionEntry.nextDueDate]
  /// falls before the end of the active budget cycle.
  static bool isPendingInCycle(
    SubscriptionEntry sub, {
    required DateTime referenceDate,
    int cycleDay = 1,
  }) {
    if (sub.isDeleted || sub.status != 'active') return false;
    if (sub.isInstallment && sub.totalCycles != null && sub.paidCycles >= sub.totalCycles!) {
      return false;
    }
    if (sub.isInstallment && sub.deadlineDate != null && referenceDate.isAfter(sub.deadlineDate!)) {
      return false;
    }
    final cutoff = nextCutoffDate(referenceDate: referenceDate, cycleDay: cycleDay);
    return dateOnly(sub.nextDueDate).isBefore(cutoff);
  }

  /// Computes the explicit [deadlineDate] (end of final installment cycle) starting from [firstDueDate].
  static DateTime calculateInstallmentDeadline({
    required DateTime firstDueDate,
    required int dueDay,
    required int totalCycles,
    int paidCycles = 0,
  }) {
    final remaining = (totalCycles - paidCycles).clamp(1, 120);
    final end = clampedMonthDate(
      firstDueDate.year,
      firstDueDate.month + remaining - 1,
      dueDay,
    );
    return DateTime(end.year, end.month, end.day, 23, 59, 59);
  }

  /// Converts a legacy Drift v6 row (which lacked nextDueDate) into an explicit v7 nextDueDate
  /// during database schema migration or v6 JSON backup import.
  static DateTime migrateLegacyNextDueDate({
    required int dueDay,
    required String billingCycle,
    required DateTime createdAt,
    DateTime? lastPaidDate,
  }) {
    if (lastPaidDate != null) {
      return advanceNextDueDate(
        currentNextDueDate: lastPaidDate,
        dueDay: dueDay,
        billingCycle: billingCycle,
      );
    }
    final created = dateOnly(createdAt.toLocal());
    if (billingCycle == 'weekly') {
      final targetWeekday = dueDay.clamp(1, 7);
      final daysAhead = (targetWeekday - created.weekday) % 7;
      return dateOnly(created.add(Duration(days: daysAhead)));
    }
    if (billingCycle == 'yearly') {
      final candidate = clampedMonthDate(created.year, created.month, dueDay);
      return created.isAfter(candidate)
          ? clampedMonthDate(created.year + 1, created.month, dueDay)
          : candidate;
    }
    final offset = defaultMonthOffset(dueDay: dueDay, referenceDate: created);
    return resolveFirstDueDate(
      dueDay: dueDay,
      monthOffset: offset,
      referenceDate: created,
      billingCycle: billingCycle,
    );
  }
}
