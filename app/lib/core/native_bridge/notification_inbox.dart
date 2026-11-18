import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../data/database/app_database.dart';

/// Persistent buffer and review queue for incoming push notifications.
class NotificationInbox {
  static final List<Map<String, dynamic>> _pendingNotifications = [];
  static final ValueNotifier<int> pendingCountNotifier = ValueNotifier<int>(0);
  static bool _isLoaded = false;
  static File? _customStorageFile;

  @visibleForTesting
  static void setStorageFile(File? file) {
    _customStorageFile = file;
    _isLoaded = false;
  }

  static Future<File?> _resolveFile() async {
    if (_customStorageFile != null) return _customStorageFile;
    if (kIsWeb || Platform.environment.containsKey('FLUTTER_TEST')) return null;
    try {
      final dir = await getApplicationDocumentsDirectory();
      return File(p.join(dir.path, 'notification_inbox.json'));
    } catch (_) {
      return null;
    }
  }

  static Future<void> _saveToDisk() async {
    try {
      final file = await _resolveFile();
      if (file == null) return;
      final raw = jsonEncode(_pendingNotifications);
      await file.writeAsString(raw, flush: true);
    } catch (_) {}
  }

  static Future<void> init() async {
    if (_isLoaded && _customStorageFile == null) return;
    try {
      final file = await _resolveFile();
      if (file != null && await file.exists()) {
        final content = await file.readAsString();
        if (content.trim().isNotEmpty) {
          final List<dynamic> decoded = jsonDecode(content);
          _pendingNotifications.clear();
          for (final item in decoded) {
            if (item is Map) {
              _pendingNotifications.add(Map<String, dynamic>.from(item));
            }
          }
          pendingCountNotifier.value = _pendingNotifications.length;
        }
      }
      _isLoaded = true;
    } catch (_) {}
  }

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
      _pendingNotifications.add(Map<String, dynamic>.from(item));
      pendingCountNotifier.value = _pendingNotifications.length;
      _saveToDisk();
    }
  }

  static void updatePending(Map<String, dynamic> item) {
    final idx = _pendingNotifications.indexWhere((p) =>
      (item['transactionId'] != null && p['transactionId'] == item['transactionId']) ||
      (p['package'] == item['package'] && p['timestamp'] == item['timestamp'])
    );
    if (idx != -1) {
      _pendingNotifications[idx] = Map<String, dynamic>.from(item);
      _saveToDisk();
    }
  }

  /// Retrieve pending notifications buffered in memory, initializing from disk if needed
  static Future<List<Map<String, dynamic>>> getPendingRawNotifications() async {
    if (!_isLoaded) await init();
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
    _saveToDisk();
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
    _saveToDisk();
  }
}
