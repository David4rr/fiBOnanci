import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../data/database/app_database.dart';
import 'subscription_notification_calculator.dart';

class LocalNotificationService {
  static final LocalNotificationService _instance = LocalNotificationService._internal();
  static LocalNotificationService get instance => _instance;

  final FlutterLocalNotificationsPlugin _plugin;
  bool _isInitialized = false;

  LocalNotificationService._internal({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  @visibleForTesting
  factory LocalNotificationService.forTest(FlutterLocalNotificationsPlugin plugin) {
    return LocalNotificationService._internal(plugin: plugin);
  }

  bool get isInitialized => _isInitialized;
  @visibleForTesting
  set isInitializedForTest(bool value) => _isInitialized = value;

  static const String channelId = 'fibonanci_bills_channel';
  static const String channelName = 'Pengingat Tagihan & Langganan';
  static const String channelDescription = 'Notifikasi offline pengingat jatuh tempo tagihan dan cicilan';

  Future<bool> initialize() async {
    if (_isInitialized) return true;
    try {
      tz.initializeTimeZones();
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: androidSettings);

      final initialized = await _plugin.initialize(settings: initSettings) ?? false;

      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(const AndroidNotificationChannel(
          channelId,
          channelName,
          description: channelDescription,
          importance: Importance.high,
          enableVibration: true,
          playSound: true,
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
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin == null) return false;
      final notifGranted = await androidPlugin.requestNotificationsPermission() ?? false;
      return notifGranted;
    } catch (_) {
      return false;
    }
  }

  Future<void> scheduleSubscriptionReminders(
    SubscriptionEntry sub, {
    DateTime? referenceDate,
  }) async {
    if (!_isInitialized) return;
    if (sub.isDeleted || sub.status != 'active') {
      await cancelSubscriptionReminders(sub.id);
      return;
    }

    final reminders = SubscriptionNotificationCalculator.calculateReminders(
      subscriptionId: sub.id,
      title: sub.title,
      cost: sub.cost,
      dueDay: sub.dueDay,
      billingCycle: sub.billingCycle,
      isInstallment: sub.isInstallment,
      totalCycles: sub.totalCycles,
      paidCycles: sub.paidCycles,
      deadlineDate: sub.deadlineDate,
      lastPaidDate: sub.lastPaidDate,
      referenceDate: referenceDate,
    );

    await cancelSubscriptionReminders(sub.id);

    for (final reminder in reminders) {
      try {
        await _plugin.zonedSchedule(
          id: reminder.id,
          title: reminder.title,
          body: reminder.body,
          scheduledDate: tz.TZDateTime.from(reminder.scheduledTime, tz.local),
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              channelId,
              channelName,
              channelDescription: channelDescription,
              importance: Importance.high,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
              visibility: NotificationVisibility.private,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          payload: reminder.payload,
        );
      } catch (e) {
        debugPrint('Failed to schedule reminder ${reminder.id}: $e');
      }
    }
  }

  Future<void> cancelSubscriptionReminders(String subscriptionId) async {
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
  }) async {
    if (!_isInitialized) return;
    try {
      await _plugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelName,
            channelDescription: channelDescription,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            visibility: NotificationVisibility.private,
          ),
        ),
        payload: payload,
      );
    } catch (e) {
      debugPrint('Failed to show instant notification: $e');
    }
  }
}
