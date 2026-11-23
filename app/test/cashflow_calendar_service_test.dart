import 'package:flutter_test/flutter_test.dart';
import 'package:fibonanci_app/data/database/app_database.dart';
import 'package:fibonanci_app/domain/services/cashflow_calendar_service.dart';

void main() {
  group('CashflowCalendarService Tests', () {
    test('getDaysInMonth correctly handles leap years and standard months', () {
      expect(CashflowCalendarService.getDaysInMonth(2024, 2), 29); // Leap year
      expect(CashflowCalendarService.getDaysInMonth(2026, 2), 28); // Standard year
      expect(CashflowCalendarService.getDaysInMonth(2026, 4), 30);
      expect(CashflowCalendarService.getDaysInMonth(2026, 12), 31);
    });

    test('calculates empty month without tracking start as neutral and 0 streak', () {
      final ref = DateTime(2026, 11, 15);
      final report = CashflowCalendarService.calculate(
        transactions: [],
        year: 2026,
        month: 11,
        referenceDate: ref,
      );

      expect(report.year, 2026);
      expect(report.month, 11);
      expect(report.dailySummaries.length, 30);
      expect(report.monthTotalIncome, 0.0);
      expect(report.monthTotalExpense, 0.0);
      expect(report.monthNetCashflow, 0.0);
      // Untracked clean slate: no false 15-day streak!
      expect(report.totalNoSpendDays, 0);
      expect(report.currentNoSpendStreak, 0);
      expect(report.longestNoSpendStreak, 0);

      // All days are neutral when no tracking has begun
      expect(report.dailySummaries[1]!.status, DayActivityStatus.neutral);
      expect(report.dailySummaries[15]!.status, DayActivityStatus.neutral);
      expect(report.dailySummaries[16]!.status, DayActivityStatus.neutral);
    });

    test('when tracking starts mid-month, days before tracking start are neutral and do not inflate streak', () {
      final ref = DateTime(2026, 11, 22);
      final trackingStart = DateTime(2026, 11, 20); // Installed on Nov 20
      final report = CashflowCalendarService.calculate(
        transactions: [],
        year: 2026,
        month: 11,
        referenceDate: ref,
        trackingStartDate: trackingStart,
      );

      // Days 1..19 were before user joined: neutral, isNoSpendDay = false
      expect(report.dailySummaries[1]!.status, DayActivityStatus.neutral);
      expect(report.dailySummaries[1]!.isNoSpendDay, isFalse);
      expect(report.dailySummaries[19]!.status, DayActivityStatus.neutral);
      expect(report.dailySummaries[19]!.isNoSpendDay, isFalse);

      // Days 20..22 are tracked and spent 0: noSpend, isNoSpendDay = true
      expect(report.dailySummaries[20]!.status, DayActivityStatus.noSpend);
      expect(report.dailySummaries[20]!.isNoSpendDay, isTrue);
      expect(report.dailySummaries[22]!.status, DayActivityStatus.noSpend);
      expect(report.dailySummaries[22]!.isNoSpendDay, isTrue);

      // Exactly 3 days streak (Nov 20, 21, 22), NOT 22 days!
      expect(report.totalNoSpendDays, 3);
      expect(report.currentNoSpendStreak, 3);
      expect(report.longestNoSpendStreak, 3);
    });

    test('formatCompactAmount and getCellLabel format small nominals and status text cleanly', () {
      expect(CashflowCalendarService.formatCompactAmount(500), '500');
      expect(CashflowCalendarService.formatCompactAmount(25000), '25k');
      expect(CashflowCalendarService.formatCompactAmount(120000), '120k');
      expect(CashflowCalendarService.formatCompactAmount(1500000), '1.5M');
      expect(CashflowCalendarService.formatCompactAmount(12000000), '12M');

      final date = DateTime(2026, 11, 10);
      final noSpend = DailyCashflowSummary(
        date: date, totalIncome: 0, totalExpense: 0, netCashflow: 0,
        transactionCount: 0, transactions: [], status: DayActivityStatus.noSpend, isNoSpendDay: true,
      );
      expect(CashflowCalendarService.getCellLabel(noSpend), 'Rp 0');

      final expenseOnly = DailyCashflowSummary(
        date: date, totalIncome: 0, totalExpense: 75000, netCashflow: -75000,
        transactionCount: 1, transactions: [], status: DayActivityStatus.safePace, isNoSpendDay: false,
      );
      expect(CashflowCalendarService.getCellLabel(expenseOnly), '75k');

      final netPos = DailyCashflowSummary(
        date: date, totalIncome: 3000000, totalExpense: 500000, netCashflow: 2500000,
        transactionCount: 2, transactions: [], status: DayActivityStatus.netPositive, isNoSpendDay: false,
      );
      expect(CashflowCalendarService.getCellLabel(netPos), '+2.5M');

      final neutral = DailyCashflowSummary(
        date: date, totalIncome: 0, totalExpense: 0, netCashflow: 0,
        transactionCount: 0, transactions: [], status: DayActivityStatus.neutral, isNoSpendDay: false,
      );
      expect(CashflowCalendarService.getCellLabel(neutral), '');
    });

    test('accurately classifies netPositive, safePace, overPace, and ignores deleted transactions', () {
      final ref = DateTime(2026, 11, 20);
      final txs = [
        // Nov 1: Salary Income
        TransactionEntry(
          id: 'tx1', profileId: 'p1', walletId: 'w1', categoryId: 'c1', amount: 10000000, type: 'income',
          source: 'manual',
          transactionDate: DateTime(2026, 11, 1, 10, 0), createdAt: DateTime.now(), updatedAt: DateTime.now(),
          isSynced: false, isDeleted: false,
        ),
        // Nov 2: Normal Expense (50k <= 100k daily pace)
        TransactionEntry(
          id: 'tx2', profileId: 'p1', walletId: 'w1', categoryId: 'c1', amount: 50000, type: 'expense',
          source: 'manual',
          transactionDate: DateTime(2026, 11, 2, 12, 0), createdAt: DateTime.now(), updatedAt: DateTime.now(),
          isSynced: false, isDeleted: false,
        ),
        // Nov 3: Over Pace Expense (250k > 100k daily pace)
        TransactionEntry(
          id: 'tx3', profileId: 'p1', walletId: 'w1', categoryId: 'c1', amount: 250000, type: 'expense',
          source: 'manual',
          transactionDate: DateTime(2026, 11, 3, 19, 0), createdAt: DateTime.now(), updatedAt: DateTime.now(),
          isSynced: false, isDeleted: false,
        ),
        // Nov 4: Deleted big expense (should be ignored)
        TransactionEntry(
          id: 'tx4', profileId: 'p1', walletId: 'w1', categoryId: 'c1', amount: 9999999, type: 'expense',
          source: 'manual',
          transactionDate: DateTime(2026, 11, 4, 14, 0), createdAt: DateTime.now(), updatedAt: DateTime.now(),
          isSynced: false, isDeleted: true,
        ),
      ];

      final report = CashflowCalendarService.calculate(
        transactions: txs,
        year: 2026,
        month: 11,
        dailySafePace: 100000,
        referenceDate: ref,
      );

      // Day 1: Income > Expense -> netPositive
      final d1 = report.dailySummaries[1]!;
      expect(d1.status, DayActivityStatus.netPositive);
      expect(d1.totalIncome, 10000000);
      expect(d1.totalExpense, 0);
      expect(d1.netCashflow, 10000000);
      expect(d1.isNoSpendDay, isTrue); // 0 expense on day 1!

      // Day 2: 50k <= 100k -> safePace
      final d2 = report.dailySummaries[2]!;
      expect(d2.status, DayActivityStatus.safePace);
      expect(d2.totalExpense, 50000);
      expect(d2.isNoSpendDay, isFalse);

      // Day 3: 250k > 100k -> overPace
      final d3 = report.dailySummaries[3]!;
      expect(d3.status, DayActivityStatus.overPace);
      expect(d3.totalExpense, 250000);
      expect(d3.isNoSpendDay, isFalse);

      // Day 4: Deleted tx ignored -> noSpend
      final d4 = report.dailySummaries[4]!;
      expect(d4.status, DayActivityStatus.noSpend);
      expect(d4.totalExpense, 0);
      expect(d4.isNoSpendDay, isTrue);

      // Month aggregates
      expect(report.monthTotalIncome, 10000000);
      expect(report.monthTotalExpense, 300000);
      expect(report.monthNetCashflow, 9700000);

      // Streak check: Day 1 (Hemat), Day 2 (Hemat), Day 3 (Over pace - breaks!), Day 4-20 (Hemat)
      // Longest streak: 17 days (Day 4 to 20)
      // Current streak: 17 days (Day 4 to 20)
      expect(report.currentNoSpendStreak, 17);
      expect(report.longestNoSpendStreak, 17);
      expect(report.totalHematDays, 19); // 20 days elapsed up to ref date minus Day 3 (over pace)
    });

    test('continuous streak spans across month boundaries without resetting per month', () {
      final now = DateTime(2026, 11, 5);
      final txs = [
        // Oct 28: 40k expense (within 100k safe pace)
        TransactionEntry(
          id: 't_oct', profileId: 'p1', walletId: 'w1', categoryId: 'c1', amount: 40000, type: 'expense',
          source: 'manual', transactionDate: DateTime(2026, 10, 28, 12, 0),
          createdAt: DateTime.now(), updatedAt: DateTime.now(), isSynced: false, isDeleted: false,
        ),
        // Nov 3: 50k expense (within 100k safe pace)
        TransactionEntry(
          id: 't_nov', profileId: 'p1', walletId: 'w1', categoryId: 'c1', amount: 50000, type: 'expense',
          source: 'manual', transactionDate: DateTime(2026, 11, 3, 12, 0),
          createdAt: DateTime.now(), updatedAt: DateTime.now(), isSynced: false, isDeleted: false,
        ),
      ];

      // Safe pace = 100k. Tracking started Oct 28.
      // Oct 28, 29, 30, 31 (4 days) + Nov 1, 2, 3, 4, 5 (5 days) = 9 days continuous streak!
      final reportNov = CashflowCalendarService.calculate(
        transactions: txs,
        year: 2026,
        month: 11,
        dailySafePace: 100000,
        referenceDate: now,
      );
      expect(reportNov.currentStreak, 9);
      expect(reportNov.longestStreak, 9);

      // Navigating back to October report still retains the active continuous streak of 9!
      final reportOct = CashflowCalendarService.calculate(
        transactions: txs,
        year: 2026,
        month: 10,
        dailySafePace: 100000,
        referenceDate: now,
      );
      expect(reportOct.currentStreak, 9);
      expect(reportOct.longestStreak, 9);
    });

    test('exceeding safe to spend resets current streak', () {
      final now = DateTime(2026, 11, 5);
      final txs = [
        // Nov 1: 50k <= 100k (hemat)
        TransactionEntry(
          id: 'tx_s1', profileId: 'p1', walletId: 'w1', categoryId: 'c1', amount: 50000, type: 'expense',
          source: 'manual', transactionDate: DateTime(2026, 11, 1, 12, 0),
          createdAt: DateTime.now(), updatedAt: DateTime.now(), isSynced: false, isDeleted: false,
        ),
        // Nov 2: 250k > 100k (OVER PACE - STREAK RESETS!)
        TransactionEntry(
          id: 'tx_s2', profileId: 'p1', walletId: 'w1', categoryId: 'c1', amount: 250000, type: 'expense',
          source: 'manual', transactionDate: DateTime(2026, 11, 2, 12, 0),
          createdAt: DateTime.now(), updatedAt: DateTime.now(), isSynced: false, isDeleted: false,
        ),
        // Nov 3: 0 (hemat)
        // Nov 4: 0 (hemat)
        // Nov 5: 30k <= 100k (hemat)
        TransactionEntry(
          id: 'tx_s3', profileId: 'p1', walletId: 'w1', categoryId: 'c1', amount: 30000, type: 'expense',
          source: 'manual', transactionDate: DateTime(2026, 11, 5, 12, 0),
          createdAt: DateTime.now(), updatedAt: DateTime.now(), isSynced: false, isDeleted: false,
        ),
      ];

      final report = CashflowCalendarService.calculate(
        transactions: txs,
        year: 2026,
        month: 11,
        dailySafePace: 100000,
        referenceDate: now,
      );

      // Streak from Nov 5 backward: Nov 5 (30k <= 100k), Nov 4 (0), Nov 3 (0) -> 3 days!
      // Nov 2 was 250k > 100k, so streak stopped at Nov 3!
      expect(report.currentStreak, 3);
      expect(report.longestStreak, 3);

      // Verify currentWeekStreak has 7 days
      expect(report.currentWeekStreak.length, 7);
      // Nov 3, 4, 5 are active streak days
      final streakDays = report.currentWeekStreak.where((w) => w.isStreakDay).toList();
      expect(streakDays.length, 3);
    });
  });
}
