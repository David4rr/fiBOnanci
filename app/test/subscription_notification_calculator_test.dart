import 'package:flutter_test/flutter_test.dart';
import 'package:fibonanci_app/core/notifications/subscription_notification_calculator.dart';

void main() {
  group('SubscriptionNotificationCalculator Tests', () {
    test('formatRupiah formats whole numbers with thousands dots and handles negatives', () {
      expect(SubscriptionNotificationCalculator.formatRupiah(50000), 'Rp 50.000');
      expect(SubscriptionNotificationCalculator.formatRupiah(1500000), 'Rp 1.500.000');
      expect(SubscriptionNotificationCalculator.formatRupiah(250), 'Rp 250');
      expect(SubscriptionNotificationCalculator.formatRupiah(-50000), '-Rp 50.000');
    });

    test('deterministic IDs produce distinct positive integer values', () {
      const subId = 'sub-uuid-12345';
      final h3 = SubscriptionNotificationCalculator.getH3Id(subId);
      final h1 = SubscriptionNotificationCalculator.getH1Id(subId);
      final h0 = SubscriptionNotificationCalculator.getH0Id(subId);
      final autoDeduct = SubscriptionNotificationCalculator.getAutoDeductId(subId);

      expect(h3 % 10, 3);
      expect(h1 % 10, 1);
      expect(h0 % 10, 0);
      expect(autoDeduct % 10, 9);
      expect({h3, h1, h0, autoDeduct}.length, 4);

      final allIds = SubscriptionNotificationCalculator.getAllReminderIds(subId);
      expect(allIds, [h3, h1, h0]);
    });

    test('computeNextDueDate rolls to next month if paid current month', () {
      final now = DateTime(2026, 10, 15);
      final lastPaid = DateTime(2026, 10, 10);
      final nextDue = SubscriptionNotificationCalculator.computeNextDueDate(
        dueDay: 20,
        lastPaidDate: lastPaid,
        referenceDate: now,
      );

      expect(nextDue, DateTime(2026, 11, 20));
    });

    test('computeNextDueDate keeps current month if unpaid and before due day', () {
      final now = DateTime(2026, 10, 15);
      final lastPaid = DateTime(2026, 9, 20);
      final nextDue = SubscriptionNotificationCalculator.computeNextDueDate(
        dueDay: 20,
        lastPaidDate: lastPaid,
        referenceDate: now,
      );

      expect(nextDue, DateTime(2026, 10, 20));
    });

    test('computeNextDueDate rolls to next month if unpaid but after due day', () {
      final now = DateTime(2026, 10, 25);
      final nextDue = SubscriptionNotificationCalculator.computeNextDueDate(
        dueDay: 20,
        referenceDate: now,
      );

      expect(nextDue, DateTime(2026, 11, 20));
    });

    test('computeNextDueDate clamps day for shorter months (e.g. Feb 31 -> 28)', () {
      final now = DateTime(2026, 1, 31);
      final nextDue = SubscriptionNotificationCalculator.computeNextDueDate(
        dueDay: 31,
        lastPaidDate: DateTime(2026, 1, 15),
        referenceDate: now,
      );

      expect(nextDue, DateTime(2026, 2, 28));
    });

    test('calculateReminders generates H-3, H-1, H-0 when all in future', () {
      final now = DateTime(2026, 10, 10, 8, 0);
      final reminders = SubscriptionNotificationCalculator.calculateReminders(
        subscriptionId: 'sub-netflix',
        title: 'Netflix',
        cost: 186000,
        dueDay: 20,
        referenceDate: now,
      );

      expect(reminders.length, 3);
      expect(reminders[0].daysBefore, 3);
      expect(reminders[0].scheduledTime, DateTime(2026, 10, 17, 9, 0));
      expect(reminders[0].title, 'Pengingat Tagihan: Netflix');

      expect(reminders[1].daysBefore, 1);
      expect(reminders[1].scheduledTime, DateTime(2026, 10, 19, 9, 0));

      expect(reminders[2].daysBefore, 0);
      expect(reminders[2].scheduledTime, DateTime(2026, 10, 20, 8, 0));
    });

    test('calculateReminders filters out reminders in the past', () {
      final now = DateTime(2026, 10, 18, 12, 0); // Past H-3 (Oct 17)
      final reminders = SubscriptionNotificationCalculator.calculateReminders(
        subscriptionId: 'sub-spotify',
        title: 'Spotify',
        cost: 54990,
        dueDay: 20,
        referenceDate: now,
      );

      expect(reminders.length, 2);
      expect(reminders.map((r) => r.daysBefore).toList(), [1, 0]);
    });

    test('calculateReminders returns empty list if installment completed', () {
      final now = DateTime(2026, 10, 10);
      final reminders = SubscriptionNotificationCalculator.calculateReminders(
        subscriptionId: 'sub-macbook',
        title: 'MacBook',
        cost: 2500000,
        dueDay: 25,
        isInstallment: true,
        totalCycles: 12,
        paidCycles: 12, // fully paid
        referenceDate: now,
      );

      expect(reminders, isEmpty);
    });

    test('calculateReminders returns empty list if past deadlineDate', () {
      final now = DateTime(2026, 10, 10);
      final reminders = SubscriptionNotificationCalculator.calculateReminders(
        subscriptionId: 'sub-macbook',
        title: 'MacBook',
        cost: 2500000,
        dueDay: 25,
        isInstallment: true,
        totalCycles: 6,
        paidCycles: 3,
        deadlineDate: DateTime(2026, 9, 25), // deadline passed
        referenceDate: now,
      );

      expect(reminders, isEmpty);
    });

    test('computeNextDueDate handles yearly cycle correctly', () {
      final now = DateTime(2026, 6, 15);
      final paidThisYear = DateTime(2026, 1, 10);
      final nextDue = SubscriptionNotificationCalculator.computeNextDueDate(
        dueDay: 10,
        billingCycle: 'yearly',
        lastPaidDate: paidThisYear,
        referenceDate: now,
      );
      expect(nextDue, DateTime(2027, 1, 10));

      final unpaidBeforeDue = SubscriptionNotificationCalculator.computeNextDueDate(
        dueDay: 20,
        billingCycle: 'yearly',
        lastPaidDate: null,
        referenceDate: DateTime(2026, 6, 10),
      );
      expect(unpaidBeforeDue, DateTime(2026, 6, 20));

      final unpaidAfterDue = SubscriptionNotificationCalculator.computeNextDueDate(
        dueDay: 10,
        billingCycle: 'yearly',
        lastPaidDate: null,
        referenceDate: DateTime(2026, 6, 20),
      );
      expect(unpaidAfterDue, DateTime(2027, 6, 10));
    });
  });
}
