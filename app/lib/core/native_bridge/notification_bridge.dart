import 'dart:async';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import '../../data/database/app_database.dart';
import '../notification_parser/notification_parser.dart';
import '../notification_parser/notification_text_sanitizer.dart';
import 'notification_inbox.dart';
import 'notification_wallet_resolver.dart';

export 'notification_inbox.dart';

typedef NotificationReviewPrompt = Future<bool?> Function(ParsedNotificationResult parsed, String rawPackage);

class NotificationBridge {
  static const _methodChannel = MethodChannel('com.fibonanci.app/notification_service');
  static const _eventChannel = EventChannel('com.fibonanci.app/live_notifications');

  StreamSubscription? _liveSubscription;
  bool _isProcessingPending = false;
  static ValueNotifier<int> get pendingCountNotifier => NotificationInbox.pendingCountNotifier;
  static int get pendingCount => NotificationInbox.pendingCount;

  static Future<bool> isPermissionGranted() async {
    try { return (await _methodChannel.invokeMethod<bool>('isPermissionGranted')) ?? false; } catch (_) { return false; }
  }

  static Future<void> openPermissionSettings() async {
    try { await _methodChannel.invokeMethod('openPermissionSettings'); } catch (_) {}
  }

  static Future<void> setHighRefreshRate(bool enabled) async {
    try { await _methodChannel.invokeMethod('setHighRefreshRate', {'enabled': enabled}); } catch (_) {}
  }
  static Future<List<Map<String, dynamic>>> getPendingRawNotifications() => NotificationInbox.getPendingRawNotifications();
  static void removePendingNotification(Map<String, dynamic> raw) => NotificationInbox.removePendingNotification(raw);
  static void confirmNotification(Map<String, dynamic> item) => NotificationInbox.confirmNotification(item);
  static Future<void> rejectNotification(Map<String, dynamic> item, AppDatabase db) => NotificationInbox.rejectNotification(item, db);
  static void clearPendingNotifications() => NotificationInbox.clearPendingNotifications();
  static Future<void> syncAllowedPackages(AppDatabase db) async {
    try {
      final activePackages = await db.getActiveNotificationPackages();
      await _methodChannel.invokeMethod('updateAllowedPackages', {'packages': activePackages});
    } catch (_) {}
  }

  static List<Map<String, String>>? _cachedInstalledApps;
  static List<Map<String, String>>? get cachedInstalledBankApps => _cachedInstalledApps;

  static Future<List<Map<String, String>>> getInstalledBankApps() async {
    try {
      final List<dynamic>? apps = await _methodChannel.invokeMethod('getInstalledBankApps');
      if (apps != null) {
        final parsed = apps.whereType<Map>().map((m) => Map<String, String>.from(m)).toList();
        parsed.sort((a, b) => (a['appName'] ?? '').compareTo(b['appName'] ?? ''));
        if (parsed.isNotEmpty) _cachedInstalledApps = parsed;
        return parsed;
      }
    } catch (_) {}
    return _cachedInstalledApps ?? [];
  }

  Future<void> startListening(
    AppDatabase db, {
    Function(String message)? onAutoLogged,
    NotificationReviewPrompt? onReviewPrompt,
  }) async {
    await syncAllowedPackages(db);
    await _processPendingNotifications(db, onAutoLogged: onAutoLogged);

    _liveSubscription?.cancel();
    try {
      _liveSubscription = _eventChannel.receiveBroadcastStream().listen((dynamic event) {
        if (event is Map) {
          handleRawNotification(Map<String, dynamic>.from(event), db, onAutoLogged: onAutoLogged);
        }
      }, onError: (_) {});
    } catch (_) {}
  }

  Future<void> onAppResumed(AppDatabase db, {Function(String message)? onAutoLogged}) async {
    await syncAllowedPackages(db);
    await _processPendingNotifications(db, onAutoLogged: onAutoLogged);
  }

  void stopListening() { _liveSubscription?.cancel(); _liveSubscription = null; }

  Future<void> _processPendingNotifications(
    AppDatabase db, {
    Function(String message)? onAutoLogged,
  }) async {
    if (_isProcessingPending) return;
    _isProcessingPending = true;
    try {
      final List<dynamic>? pending = await _methodChannel.invokeMethod('getPendingNotifications');
      if (pending != null) {
        for (final item in pending) {
          if (item is Map) {
            await handleRawNotification(Map<String, dynamic>.from(item), db, onAutoLogged: onAutoLogged);
          }
        }
      }
    } catch (_) {
    } finally {
      _isProcessingPending = false;
    }
  }

  static Future<void> handleRawNotification(
    Map<String, dynamic> raw,
    AppDatabase db, {
    Function(String message)? onAutoLogged,
  }) async {
    final pkg = raw['package'] as String? ?? '';
    final title = raw['title'] as String? ?? '';
    final text = raw['text'] as String? ?? '';
    final rawTs = raw['timestamp'];
    final ts = rawTs is num ? DateTime.fromMillisecondsSinceEpoch(rawTs.toInt()) : null;

    final parsed = NotificationParser.parse(packageName: pkg, title: title, body: text, timestamp: ts);
    if (parsed == null) return;

    final targetWallet = await NotificationWalletResolver.resolve(db: db, pkg: pkg, title: title, text: text);
    if (targetWallet == null) return;

    final categories = await db.select(db.categories).get();
    final defaultCat = categories.firstWhere((c) => c.type == parsed.type, orElse: () => categories.first);
    final now = DateTime.now().toUtc();

    if (parsed.externalRef != null) {
      final existing = await (db.select(db.transactions)
            ..where((t) => t.externalRef.equals(parsed.externalRef!) & t.isDeleted.equals(false)))
          .get();
      if (existing.isNotEmpty) return;
    }
    final txId = const Uuid().v4();
    await db.logTransactionWithBalanceMutation(
      tx: TransactionsCompanion(
        id: drift.Value(txId),
        walletId: drift.Value(targetWallet.id),
        categoryId: drift.Value(defaultCat.id),
        amount: drift.Value(parsed.amount),
        type: drift.Value(parsed.type),
        notes: drift.Value(parsed.counterparty),
        source: const drift.Value('notification_auto'),
        externalRef: drift.Value(parsed.externalRef),
        transactionDate: drift.Value(now),
        createdAt: drift.Value(now),
        updatedAt: drift.Value(now),
      ),
    );

    _syncBalanceSnapshotIfPresent(text, db, targetWallet.id);

    String? profileName;
    if (targetWallet.profileId != null) {
      final prof = await (db.select(db.profiles)..where((t) => t.id.equals(targetWallet.profileId!))).getSingleOrNull();
      profileName = prof?.fullName ?? prof?.username;
    }

    final inboxItem = Map<String, dynamic>.from(raw);
    inboxItem['transactionId'] = txId;
    inboxItem['amount'] = parsed.amount;
    inboxItem['type'] = parsed.type;
    inboxItem['counterparty'] = parsed.counterparty;
    inboxItem['walletName'] = targetWallet.name;
    inboxItem['walletId'] = targetWallet.id;
    inboxItem['profileId'] = targetWallet.profileId;
    inboxItem['profileName'] = profileName;

    NotificationInbox.addPending(inboxItem);
    final prefix = profileName != null ? '[$profileName] ${targetWallet.name}' : targetWallet.name;
    onAutoLogged?.call('$prefix: ${parsed.type == 'income' ? '+' : '-'}Rp ${parsed.amount.toStringAsFixed(0)} (${parsed.counterparty})');
  }
  static void _syncBalanceSnapshotIfPresent(String text, AppDatabase db, String walletId) async {
    final exactBal = NotificationTextSanitizer.extractBalance(text);
    if (exactBal != null && exactBal > 0) {
      await db.updateWalletBalance(walletId, exactBal);
    }
  }
}
