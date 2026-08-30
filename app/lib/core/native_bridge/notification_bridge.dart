import 'dart:async';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import '../../data/database/app_database.dart';
import '../notification_parser/notification_parser.dart';
import '../notification_parser/parsed_notification.dart';
typedef NotificationReviewPrompt = Future<bool?> Function(ParsedNotificationResult parsed, String rawPackage);


class NotificationBridge {
  static const _methodChannel = MethodChannel('com.fibonanci.app/notification_service');
  static const _eventChannel = EventChannel('com.fibonanci.app/live_notifications');

  StreamSubscription? _liveSubscription;

  /// Check if Android Notification Listener permission is granted by user
  static Future<bool> isPermissionGranted() async {
    try {
      final bool granted = await _methodChannel.invokeMethod('isPermissionGranted');
      return granted;
    } catch (_) {
      return false;
    }
  }

  /// Open Android OS "Notification Access" Settings page directly
  static Future<void> openPermissionSettings() async {
    try {
      await _methodChannel.invokeMethod('openPermissionSettings');
    } catch (_) {}
  }

  /// Retrieve pending notifications buffered in Android SharedPreferences
  static Future<List<Map<String, dynamic>>> getPendingRawNotifications() async {
    try {
      final List<dynamic>? pending = await _methodChannel.invokeMethod('getPendingNotifications');
      if (pending != null) {
        return pending.whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList();
      }
    } catch (_) {}
    return [];
  }

  /// Sync active package whitelist from Drift database to Android SharedPreferences
  static Future<void> syncAllowedPackages(AppDatabase db) async {
    try {
      final activePackages = await db.getActiveNotificationPackages();
      await _methodChannel.invokeMethod('updateAllowedPackages', {
        'packages': activePackages,
      });
    } catch (_) {}
  }

  /// Query installed banking apps from Android OS
  static Future<List<Map<String, String>>> getInstalledBankApps() async {
    try {
      final List<dynamic>? apps = await _methodChannel.invokeMethod('getInstalledBankApps');
      if (apps != null) {
        return apps.whereType<Map>().map((m) => Map<String, String>.from(m)).toList();
      }
    } catch (_) {}
    return [];
  }
  /// Start background/live listener and process pending buffered notifications
  void startListening(
    AppDatabase db, {
    Function(String message)? onAutoLogged,
    NotificationReviewPrompt? onReviewPrompt,
  }) async {
    // 0. Synchronize active package whitelist to Android background listener
    await syncAllowedPackages(db);

    // 1. Process any pending notifications buffered while app was inactive
    await _processPendingNotifications(db, onAutoLogged: onAutoLogged, onReviewPrompt: onReviewPrompt);
    // 2. Listen to real-time live notifications while app is in foreground
    _liveSubscription?.cancel();
    try {
      _liveSubscription = _eventChannel.receiveBroadcastStream().listen((dynamic event) {
        if (event is Map) {
          final map = Map<String, dynamic>.from(event);
          _handleRawNotification(map, db, onAutoLogged: onAutoLogged, onReviewPrompt: onReviewPrompt);
        }
      }, onError: (_) {});
    } catch (_) {}
  }
  void stopListening() {
    _liveSubscription?.cancel();
    _liveSubscription = null;
  }

  Future<void> _processPendingNotifications(
    AppDatabase db, {
    Function(String message)? onAutoLogged,
    NotificationReviewPrompt? onReviewPrompt,
  }) async {
    try {
      final List<dynamic>? pending = await _methodChannel.invokeMethod('getPendingNotifications');
      if (pending != null) {
        for (final item in pending) {
          if (item is Map) {
            final map = Map<String, dynamic>.from(item);
            await _handleRawNotification(map, db, onAutoLogged: onAutoLogged, onReviewPrompt: onReviewPrompt);
          }
        }
      }
    } catch (_) {}
  }

  Future<void> _handleRawNotification(
    Map<String, dynamic> raw,
    AppDatabase db, {
    Function(String message)? onAutoLogged,
    NotificationReviewPrompt? onReviewPrompt,
  }) async {
    final pkg = raw['package'] as String? ?? '';
    final title = raw['title'] as String? ?? '';
    final text = raw['text'] as String? ?? '';

    // Run through deterministic on-device parser
    final ParsedNotificationResult? parsed = NotificationParser.parse(
      packageName: pkg,
      title: title,
      body: text,
    );

    if (parsed == null) return;

    // If interactive review prompt is registered (app open), show modal to let user confirm/change wallet
    if (onReviewPrompt != null) {
      final handled = await onReviewPrompt(parsed, pkg);
      if (handled != null) return; // User reviewed and committed via modal
    }

    // Resolve matching wallet in database
    final wallets = await db.select(db.wallets).get();
    if (wallets.isEmpty) return;

    WalletEntry? targetWallet;

    // 1. Priority: Match against dynamic NotificationRules from SQLite
    final rule = await db.getNotificationRuleForPackage(pkg);
    if (rule != null) {
      targetWallet = wallets.where((w) => w.id == rule.walletId).firstOrNull;
    }

    // 2. Secondary fallback: Heuristic keyword matching on package & notification text
    if (targetWallet == null) {
      final lowText = '$title $text'.toLowerCase();

      if (pkg.contains('seabank') ||
          pkg.contains('bke') ||
          pkg.contains('digitalbank') ||
          pkg.contains('sea.bank') ||
          lowText.contains('seabank')) {
        targetWallet = wallets.firstWhere((w) => w.name.toLowerCase().contains('seabank'), orElse: () => wallets.first);
      } else if (pkg.contains('bcadigital') || pkg.contains('blu') || lowText.contains('blu')) {
        targetWallet = wallets.firstWhere((w) => w.name.toLowerCase().contains('blu'), orElse: () => wallets.first);
      } else if (pkg.contains('bca') || lowText.contains('bca')) {
        targetWallet = wallets.firstWhere((w) => w.name.toLowerCase().contains('bca utama'), orElse: () => wallets.first);
      } else if (pkg.contains('mandiri') || lowText.contains('mandiri') || lowText.contains('livin')) {
        targetWallet = wallets.firstWhere((w) => w.name.toLowerCase().contains('mandiri'), orElse: () => wallets.first);
      } else if (pkg.contains('jago') || lowText.contains('jago')) {
        targetWallet = wallets.firstWhere((w) => w.name.toLowerCase().contains('jago'), orElse: () => wallets.first);
      } else if (pkg.contains('ovo') || lowText.contains('ovo')) {
        targetWallet = wallets.firstWhere((w) => w.name.toLowerCase().contains('ovo'), orElse: () => wallets.first);
      } else if (pkg.contains('shopee') || lowText.contains('shopee')) {
        final shopeeWallets = wallets.where((w) => w.name.toLowerCase().contains('shopee')).toList();
        if (shopeeWallets.isNotEmpty) {
          targetWallet = shopeeWallets.first;
        } else {
          // Auto-create ShopeePay wallet on-the-fly if not in database
          final newId = const Uuid().v4();
          final now = DateTime.now().toUtc();
          await db.into(db.wallets).insert(
            WalletsCompanion(
              id: drift.Value(newId),
              name: const drift.Value('ShopeePay'),
              type: const drift.Value('ewallet'),
              balance: const drift.Value(0.0),
              colorHex: const drift.Value('#EE4D2D'),
              iconName: const drift.Value('shopping_bag'),
              createdAt: drift.Value(now),
              updatedAt: drift.Value(now),
            ),
          );
          targetWallet = await (db.select(db.wallets)..where((t) => t.id.equals(newId))).getSingle();
        }
      } else {
        // Fallback: check if notification text names a wallet
        for (final w in wallets) {
          if (lowText.contains(w.name.toLowerCase())) {
            targetWallet = w;
            break;
          }
        }
      }
    }

    targetWallet ??= wallets.first;

    // Resolve default category
    final categories = await db.select(db.categories).get();
    final defaultCat = categories.firstWhere(
      (c) => c.type == parsed.type,
      orElse: () => categories.first,
    );

    final now = DateTime.now().toUtc();
    const uuid = Uuid();

    // Check duplicate externalRef
    if (parsed.externalRef != null) {
      final existing = await (db.select(db.transactions)
            ..where((t) => t.externalRef.equals(parsed.externalRef!)))
          .get();
      if (existing.isNotEmpty) return; // Prevent duplicate ingestion
    }

    // Commit to SQLite and atomically adjust balance
    await db.logTransactionWithBalanceMutation(
      tx: TransactionsCompanion(
        id: drift.Value(uuid.v4()),
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

    // If notification contains real-time ending balance snapshot, sync exact wallet balance
    final balanceSnapshotRegex = RegExp(
      r'Saldo\s+saat\s+ini\s+(?:sebesar\s+)?(?:Rp\.?|IDR)\s*([0-9.,]+)',
      caseSensitive: false,
    );
    final balSnapMatch = balanceSnapshotRegex.firstMatch(text);
    if (balSnapMatch != null) {
      String cleaned = balSnapMatch.group(1)!.replaceAll(' ', '');
      if (cleaned.contains(',') && cleaned.lastIndexOf(',') == cleaned.length - 3) {
        cleaned = cleaned.substring(0, cleaned.length - 3).replaceAll(RegExp(r'[.,]'), '');
      } else {
        cleaned = cleaned.replaceAll(RegExp(r'[.,]'), '');
      }
      final exactRealBal = double.tryParse(cleaned);
      if (exactRealBal != null && exactRealBal > 0) {
        await db.updateWalletBalance(targetWallet.id, exactRealBal);
      }
    }

    onAutoLogged?.call('${targetWallet.name}: ${parsed.type == 'income' ? '+' : '-'}Rp ${parsed.amount.toStringAsFixed(0)} (${parsed.counterparty})');
  }
}
