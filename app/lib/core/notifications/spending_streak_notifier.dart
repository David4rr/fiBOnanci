import 'package:flutter/foundation.dart';
import '../../data/database/app_database.dart';
import '../../domain/services/cashflow_calendar_service.dart';
import 'local_notification_service.dart';

class SpendingStreakAlert {
  final String title;
  final String body;
  final int alertLevel;

  const SpendingStreakAlert({
    required this.title,
    required this.body,
    required this.alertLevel,
  });
}

class SpendingStreakNotifier {
  static String? _lastAlertDateKey;
  static int _lastAlertLevel = 0;

  @visibleForTesting
  static void resetStateForTest() {
    _lastAlertDateKey = null;
    _lastAlertLevel = 0;
  }

  static SpendingStreakAlert? evaluateAlert({
    required double todayExpense,
    required double dailySafePace,
    required int streak,
  }) {
    if (dailySafePace <= 0) return null;

    if (todayExpense >= dailySafePace) {
      final body = streak > 1
          ? 'Pengeluaran hari ini telah melampaui kuota harian. Pertahankan kendali agar streak hemat $streak hari tidak terhenti.'
          : 'Pengeluaran hari ini telah melampaui kuota harian Safe-to-Spend. Tahan pengeluaran sebelum siklus berganti.';
      return SpendingStreakAlert(
        title: 'Batas Belanja Harian Terlampaui',
        body: body,
        alertLevel: 2,
      );
    }

    if (todayExpense >= dailySafePace * 0.8) {
      final percent = (todayExpense / dailySafePace * 100).round();
      final body = streak > 1
          ? 'Pengeluaran hari ini mencapai $percent% dari kuota. Batasi belanja agar streak hemat $streak hari tetap terjaga.'
          : 'Pengeluaran hari ini telah mencapai $percent% dari alokasi harian Safe-to-Spend.';
      return SpendingStreakAlert(
        title: 'Mendekati Batas Belanja Harian',
        body: body,
        alertLevel: 1,
      );
    }

    return null;
  }

  static Future<bool> checkAndNotify({
    required List<TransactionEntry> transactions,
    required double dailySafePace,
    int? currentStreak,
    DateTime? referenceDate,
  }) async {
    final now = referenceDate ?? DateTime.now();
    final todayKey = '${now.year}-${now.month}-${now.day}';

    double todayExpense = 0.0;
    for (final t in transactions) {
      if (t.isDeleted || t.type != 'expense') continue;
      if (t.transactionDate.year == now.year &&
          t.transactionDate.month == now.month &&
          t.transactionDate.day == now.day) {
        todayExpense += t.amount;
      }
    }

    final streak = currentStreak ??
        CashflowCalendarService.calculateCurrentStreak(
          transactions: transactions,
          dailySafePace: dailySafePace,
          referenceDate: now,
        );

    final alert = evaluateAlert(
      todayExpense: todayExpense,
      dailySafePace: dailySafePace,
      streak: streak,
    );

    if (alert == null) return false;
    if (_lastAlertDateKey == todayKey && _lastAlertLevel >= alert.alertLevel) {
      return false;
    }

    _lastAlertDateKey = todayKey;
    _lastAlertLevel = alert.alertLevel;

    await LocalNotificationService.instance.showInstantReceipt(
      id: 998000 + alert.alertLevel,
      title: alert.title,
      body: alert.body,
    );

    return true;
  }
}
