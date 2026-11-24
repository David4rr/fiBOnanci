import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fibonanci_app/core/notifications/local_notification_service.dart';
import 'package:fibonanci_app/core/notifications/spending_streak_notifier.dart';
import 'package:fibonanci_app/data/database/app_database.dart';

class _FakeNotificationsPlugin extends Fake
    implements FlutterLocalNotificationsPlugin {
  bool showCalled = false;
  String? lastTitle;
  String? lastBody;

  @override
  Future<bool?> initialize({
    required InitializationSettings settings,
    void Function(NotificationResponse)? onDidReceiveNotificationResponse,
    void Function(NotificationResponse)?
        onDidReceiveBackgroundNotificationResponse,
  }) async =>
      true;

  @override
  Future<void> show({
    required int id,
    String? title,
    String? body,
    NotificationDetails? notificationDetails,
    String? payload,
  }) async {
    showCalled = true;
    lastTitle = title;
    lastBody = body;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SpendingStreakNotifier.resetStateForTest();
  });

  group('SpendingStreakNotifier.evaluateAlert', () {
    test('returns null when dailySafePace is zero or negative', () {
      expect(
        SpendingStreakNotifier.evaluateAlert(
          todayExpense: 100000,
          dailySafePace: 0,
          streak: 3,
        ),
        isNull,
      );
    });

    test('returns null when spending is below 80% of daily quota', () {
      expect(
        SpendingStreakNotifier.evaluateAlert(
          todayExpense: 70000,
          dailySafePace: 100000,
          streak: 3,
        ),
        isNull,
      );
    });

    test('returns level 1 warning when spending reaches 80% of daily quota', () {
      final alert = SpendingStreakNotifier.evaluateAlert(
        todayExpense: 85000,
        dailySafePace: 100000,
        streak: 5,
      );

      expect(alert, isNotNull);
      expect(alert!.alertLevel, 1);
      expect(alert.title, 'Mendekati Batas Belanja Harian');
      expect(alert.body, contains('streak hemat 5 hari'));
      // Zero emoji check
      expect(RegExp(r'[\u{1F300}-\u{1F9FF}]', unicode: true).hasMatch(alert.title), isFalse);
      expect(RegExp(r'[\u{1F300}-\u{1F9FF}]', unicode: true).hasMatch(alert.body), isFalse);
    });

    test('returns level 2 exceeded alert when spending exceeds daily quota', () {
      final alert = SpendingStreakNotifier.evaluateAlert(
        todayExpense: 120000,
        dailySafePace: 100000,
        streak: 7,
      );

      expect(alert, isNotNull);
      expect(alert!.alertLevel, 2);
      expect(alert.title, 'Batas Belanja Harian Terlampaui');
      expect(alert.body, contains('streak hemat 7 hari'));
      // Zero emoji check
      expect(RegExp(r'[\u{1F300}-\u{1F9FF}]', unicode: true).hasMatch(alert.title), isFalse);
      expect(RegExp(r'[\u{1F300}-\u{1F9FF}]', unicode: true).hasMatch(alert.body), isFalse);
    });
  });

  group('SpendingStreakNotifier.checkAndNotify', () {
    test('triggers notification and throttles duplicate alerts on same day', () async {
      final fake = _FakeNotificationsPlugin();
      final service = LocalNotificationService.forTest(fake);
      service.isInitializedForTest = true;
      LocalNotificationService.instanceForTest = service;

      final now = DateTime(2026, 11, 24, 14, 0);
      final txs = [
        TransactionEntry(
          id: 'tx-1',
          profileId: 'p1',
          walletId: 'w1',
          categoryId: 'c1',
          amount: 85000,
          type: 'expense',
          source: 'manual',
          transactionDate: now,
          createdAt: now,
          updatedAt: now,
          isSynced: false,
          isDeleted: false,
        ),
      ];

      final notifiedFirst = await SpendingStreakNotifier.checkAndNotify(
        transactions: txs,
        dailySafePace: 100000,
        currentStreak: 4,
        referenceDate: now,
      );

      expect(notifiedFirst, isTrue);
      expect(fake.showCalled, isTrue);
      expect(fake.lastTitle, 'Mendekati Batas Belanja Harian');

      // Duplicate call on same day with same level should be throttled
      fake.showCalled = false;
      final notifiedAgain = await SpendingStreakNotifier.checkAndNotify(
        transactions: txs,
        dailySafePace: 100000,
        currentStreak: 4,
        referenceDate: now,
      );

      expect(notifiedAgain, isFalse);
      expect(fake.showCalled, isFalse);
    });
  });
}
