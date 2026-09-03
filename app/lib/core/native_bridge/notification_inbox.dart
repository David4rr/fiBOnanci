import 'package:flutter/foundation.dart';
import '../../data/database/app_database.dart';

/// In-memory buffer and review queue for incoming push notifications.
class NotificationInbox {
  static final List<Map<String, dynamic>> _pendingNotifications = [];
  static final ValueNotifier<int> pendingCountNotifier = ValueNotifier<int>(0);

  static int get pendingCount => _pendingNotifications.length;

  static bool isDuplicatePending(Map<String, dynamic> item) {
    return _pendingNotifications.any((p) =>
      (item['transactionId'] != null && p['transactionId'] == item['transactionId']) ||
      (p['package'] == item['package'] &&
       p['text'] == item['text'] &&
       (p['timestamp'] == item['timestamp'] || (p['title'] == item['title'] && item['title'] != null)))
    );
  }

  static void addPending(Map<String, dynamic> item) {
    if (!isDuplicatePending(item)) {
      _pendingNotifications.add(item);
      pendingCountNotifier.value = _pendingNotifications.length;
    }
  }

  /// Retrieve pending notifications buffered in memory
  static Future<List<Map<String, dynamic>>> getPendingRawNotifications() async {
    pendingCountNotifier.value = _pendingNotifications.length;
    return List<Map<String, dynamic>>.from(_pendingNotifications);
  }

  /// Removes a processed or discarded notification from pending list
  static void removePendingNotification(Map<String, dynamic> raw) {
    _pendingNotifications.removeWhere((p) =>
      (raw['transactionId'] != null && p['transactionId'] == raw['transactionId']) ||
      (p['package'] == raw['package'] &&
       p['text'] == raw['text'] &&
       (p['timestamp'] == raw['timestamp'] || p['title'] == raw['title']))
    );
    pendingCountNotifier.value = _pendingNotifications.length;
  }

  /// Confirm that an auto-logged notification is correct; removes it from the inbox
  static void confirmNotification(Map<String, dynamic> item) {
    removePendingNotification(item);
  }

  /// Mark notification as incorrect: deletes the auto-logged transaction, reverts balance, and removes from inbox
  static Future<void> rejectNotification(Map<String, dynamic> item, AppDatabase db) async {
    final txId = item['transactionId'] as String?;
    if (txId != null && txId.isNotEmpty) {
      try {
        await db.deleteTransactionWithBalanceReversal(txId);
      } catch (_) {}
    }
    removePendingNotification(item);
  }

  /// Clears all pending notifications
  static void clearPendingNotifications() {
    _pendingNotifications.clear();
    pendingCountNotifier.value = 0;
  }
}
