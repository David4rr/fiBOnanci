import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import '../../core/l10n/locale_notifier.dart';
import '../../core/notifications/local_notification_service.dart';
import '../../core/notifications/subscription_notification_calculator.dart';
import '../../data/database/app_database.dart';
import 'subscription_schedule_service.dart';
class SubscriptionAutoDeductRunner {
  static bool _isRunning = false;

  @visibleForTesting
  static bool get isRunning => _isRunning;

  @visibleForTesting
  static void resetLockForTest() => _isRunning = false;

  static bool isDueForAutoDeduct(SubscriptionEntry sub, {DateTime? referenceDate}) {
    if (sub.isDeleted || sub.status != 'active' || !sub.autoDeduct) return false;

    final now = referenceDate ?? DateTime.now();

    if (sub.isInstallment) {
      if (sub.totalCycles != null && sub.paidCycles >= sub.totalCycles!) return false;
      if (sub.deadlineDate != null && now.isAfter(sub.deadlineDate!)) return false;
    }

    final today = SubscriptionScheduleService.dateOnly(now);
    final due = SubscriptionScheduleService.dateOnly(sub.nextDueDate);
    if (today.isBefore(due)) return false;

    if (sub.billingCycle == 'yearly') {
      if (sub.lastPaidDate != null && sub.lastPaidDate!.year >= due.year) return false;
    } else if (sub.billingCycle == 'weekly') {
      if (sub.lastPaidDate != null && now.difference(sub.lastPaidDate!).inDays < 7) return false;
    } else {
      if (sub.lastPaidDate != null &&
          sub.lastPaidDate!.year == due.year &&
          sub.lastPaidDate!.month == due.month) {
        return false;
      }
    }

    return true;
  }

  static Future<List<SubscriptionEntry>> runAutoDeduct({
    required AppDatabase db,
    DateTime? referenceDate,
    Function(SubscriptionEntry sub)? onDeducted,
  }) async {
    if (_isRunning) return const [];
    _isRunning = true;

    try {
      final now = referenceDate ?? DateTime.now();
    final activeSubs = await (db.select(db.subscriptions)
          ..where((t) =>
              t.isDeleted.equals(false) &
              t.status.equals('active') &
              t.autoDeduct.equals(true)))
        .get();

    final deducted = <SubscriptionEntry>[];

    for (final sub in activeSubs) {
      if (!isDueForAutoDeduct(sub, referenceDate: now)) continue;

      try {
        await db.markSubscriptionAsPaid(sub.id, paymentDate: now);
        deducted.add(sub);
        onDeducted?.call(sub);

        final receiptId = SubscriptionNotificationCalculator.getAutoDeductId(sub.id);
        final formattedAmount = SubscriptionNotificationCalculator.formatRupiah(sub.cost);

        final l10n = AppL10n.current;
        await LocalNotificationService.instance.showInstantReceipt(
          id: receiptId,
          title: l10n.notifAutoDeductTitle(sub.title),
          body: l10n.notifAutoDeductBody(formattedAmount),
          payload: sub.id,
        );
      } catch (_) {}
    }

      return deducted;
    } finally {
      _isRunning = false;
    }
  }
}
