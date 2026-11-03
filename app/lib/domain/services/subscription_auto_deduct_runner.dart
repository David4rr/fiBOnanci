import 'dart:math';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import '../../core/notifications/local_notification_service.dart';
import '../../core/notifications/subscription_notification_calculator.dart';
import '../../data/database/app_database.dart';
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

    if (sub.billingCycle == 'yearly') {
      final isCycleDue = sub.lastPaidDate == null ||
          (sub.lastPaidDate!.year < now.year &&
              now.difference(sub.lastPaidDate!).inDays >= 365);
      if (!isCycleDue) return false;
    } else if (sub.billingCycle == 'weekly') {
      final isCycleDue = sub.lastPaidDate == null ||
          now.difference(sub.lastPaidDate!).inDays >= 7;
      if (!isCycleDue) return false;
      return true;
    } else {
      final isPaidThisMonth = sub.lastPaidDate != null &&
          sub.lastPaidDate!.year == now.year &&
          sub.lastPaidDate!.month == now.month;
      if (isPaidThisMonth) return false;
    }

    final maxDaysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final clampedDueDay = min(sub.dueDay, maxDaysInMonth);
    if (now.day < clampedDueDay) return false;

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

        await LocalNotificationService.instance.showInstantReceipt(
          id: receiptId,
          title: 'Tagihan Berhasil Didebet: ${sub.title}',
          body: 'Pembayaran $formattedAmount telah otomatis dipotong dari dompet.',
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
