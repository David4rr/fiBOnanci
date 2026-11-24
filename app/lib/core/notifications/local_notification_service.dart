import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../data/database/app_database.dart';
import 'in_app_notification_storage.dart';
import 'subscription_notification_calculator.dart';

class LocalNotificationService {
  static LocalNotificationService _instance = LocalNotificationService._internal();
  static LocalNotificationService get instance => _instance;
  @visibleForTesting
  static set instanceForTest(LocalNotificationService val) => _instance = val;

  final FlutterLocalNotificationsPlugin _plugin;
  bool _isInitialized = false;

  LocalNotificationService._internal({FlutterLocalNotificationsPlugin? plugin}) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  @visibleForTesting
  factory LocalNotificationService.forTest(FlutterLocalNotificationsPlugin plugin) => LocalNotificationService._internal(plugin: plugin);

  bool get isInitialized => _isInitialized;
  @visibleForTesting
  set isInitializedForTest(bool value) => _isInitialized = value;

  static const String channelId = 'fibonanci_bills_channel';
  static const String channelName = 'Pengingat Tagihan & Langganan';
  static const String channelDescription = 'Notifikasi offline pengingat jatuh tempo tagihan dan cicilan';

  static NotificationDetails _createNotificationDetails({required String title, required String body}) => NotificationDetails(
    android: AndroidNotificationDetails(
      channelId, channelName, channelDescription: channelDescription,
      importance: Importance.high, priority: Priority.high, icon: 'ic_stat_fibonanci',
      color: const Color(0xFF10B981), visibility: NotificationVisibility.private,
      styleInformation: BigTextStyleInformation(body, contentTitle: title),
    ),
  );

  Future<bool> initialize() async {
    if (_isInitialized) return true;
    try {
      tz.initializeTimeZones();
      const androidSettings = AndroidInitializationSettings('ic_stat_fibonanci');
      const darwinSettings = DarwinInitializationSettings(requestAlertPermission: false, requestBadgePermission: false, requestSoundPermission: false);
      const initSettings = InitializationSettings(android: androidSettings, iOS: darwinSettings, macOS: darwinSettings);
      final initialized = await _plugin.initialize(settings: initSettings) ?? false;
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(const AndroidNotificationChannel(
          channelId, channelName, description: channelDescription, importance: Importance.high, enableVibration: true, playSound: true,
        ));
      }
      _isInitialized = initialized;
      return initialized;
    } catch (e) {
      if (!e.runtimeType.toString().contains('LateInitializationError')) {
        debugPrint('LocalNotificationService initialize error: $e');
      }
      return false;
    }
  }

  Future<bool> requestPermissions() async {
    try {
      return await _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission() ?? false;
    } catch (_) { return false; }
  }

  Future<bool> canScheduleExactAlarms() async {
    try {
      return await _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.canScheduleExactNotifications() ?? false;
    } catch (_) { return false; }
  }

  Future<bool> requestExactAlarmsPermission() async {
    try {
      return await _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestExactAlarmsPermission() ?? false;
    } catch (_) { return false; }
  }

  Future<void> scheduleSubscriptionReminders(SubscriptionEntry sub, {DateTime? referenceDate}) async {
    if (!_isInitialized) await initialize();
    if (!_isInitialized) return;
    if (sub.isDeleted || sub.status != 'active') {
      await cancelSubscriptionReminders(sub.id);
      return;
    }

    final reminders = SubscriptionNotificationCalculator.calculateReminders(
      subscriptionId: sub.id, title: sub.title, cost: sub.cost, dueDay: sub.dueDay,
      billingCycle: sub.billingCycle, isInstallment: sub.isInstallment, totalCycles: sub.totalCycles,
      paidCycles: sub.paidCycles, deadlineDate: sub.deadlineDate, lastPaidDate: sub.lastPaidDate, referenceDate: referenceDate,
    );

    await cancelSubscriptionReminders(sub.id);
    for (final reminder in reminders) {
      await _scheduleWithFallback(
        id: reminder.id, title: reminder.title, body: reminder.body,
        scheduledDate: tz.TZDateTime.from(reminder.scheduledTime, tz.local),
        payload: reminder.payload,
      );
    }
  }

  Future<void> cancelSubscriptionReminders(String subscriptionId) async {
    if (!_isInitialized) await initialize();
    if (!_isInitialized) return;
    for (final id in SubscriptionNotificationCalculator.getAllReminderIds(subscriptionId)) {
      try {
        await _plugin.cancel(id: id);
      } catch (_) {}
    }
  }

  Future<void> syncAllSubscriptionReminders(
    List<SubscriptionEntry> subscriptions, {
    DateTime? referenceDate,
  }) async {
    for (final sub in subscriptions) {
      if (sub.isDeleted || sub.status != 'active') {
        await cancelSubscriptionReminders(sub.id);
      } else {
        await scheduleSubscriptionReminders(sub, referenceDate: referenceDate);
      }
    }
  }

  Future<void> showInstantReceipt({
    required int id,
    required String title,
    required String body,
    String? payload,
    String category = 'bill',
  }) async {
    if (!_isInitialized) await initialize();
    if (!_isInitialized) return;
    try {
      final details = _createNotificationDetails(title: title, body: body);
      await _plugin.show(id: id, title: title, body: body, notificationDetails: details, payload: payload);
      await InAppNotificationStorage.addNotification(
        title: title, body: body, category: category, payload: payload,
      );
    } catch (e) {
      debugPrint('Failed to show instant notification: $e');
    }
  }

  Future<bool> scheduleTestReminder({int delaySeconds = 5, String? title, String? body}) async {
    if (!_isInitialized) await initialize();
    if (!_isInitialized) return false;
    final scheduledDate = tz.TZDateTime.now(tz.local).add(Duration(seconds: delaySeconds));
    final resolvedTitle = title ?? 'Pengingat Tagihan';
    final resolvedBody = body ?? 'Notifikasi offline berhasil. fiBOnanci siap mengingatkan.';
    await InAppNotificationStorage.addNotification(title: resolvedTitle, body: resolvedBody, category: 'bill');
    return _scheduleWithFallback(
      id: 999999, title: resolvedTitle, body: resolvedBody, scheduledDate: scheduledDate,
    );
  }

  Future<bool> _scheduleWithFallback({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    String? payload,
  }) async {
    final canExact = await canScheduleExactAlarms();
    final mode = canExact ? AndroidScheduleMode.exactAllowWhileIdle : AndroidScheduleMode.inexactAllowWhileIdle;
    final notifDetails = _createNotificationDetails(title: title, body: body);
    try {
      await _plugin.zonedSchedule(
        id: id, title: title, body: body, scheduledDate: scheduledDate,
        notificationDetails: notifDetails, androidScheduleMode: mode, payload: payload,
      );
      return true;
    } catch (_) {
      if (canExact) {
        try {
          await _plugin.zonedSchedule(
            id: id, title: title, body: body, scheduledDate: scheduledDate,
            notificationDetails: notifDetails, androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle, payload: payload,
          );
          return true;
        } catch (_) {}
      }
      return false;
    }
  }
}
