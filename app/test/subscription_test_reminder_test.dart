import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:fibonanci_app/core/notifications/local_notification_service.dart';
import 'package:fibonanci_app/data/database/app_database.dart';
import 'package:fibonanci_app/presentation/screens/subscription_detail/subscription_detail_actions.dart';

class _FakeFlutterLocalNotificationsPlugin extends Fake
    implements FlutterLocalNotificationsPlugin {
  bool zonedScheduleCalled = false;
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
  Future<void> zonedSchedule({
    required int id,
    String? title,
    String? body,
    required tz.TZDateTime scheduledDate,
    required NotificationDetails notificationDetails,
    required AndroidScheduleMode androidScheduleMode,
    String? payload,
    DateTimeComponents? matchDateTimeComponents,
  }) async {
    zonedScheduleCalled = true;
    lastTitle = title;
    lastBody = body;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeFlutterLocalNotificationsPlugin fakePlugin;
  late LocalNotificationService service;

  setUp(() {
    tz.initializeTimeZones();
    fakePlugin = _FakeFlutterLocalNotificationsPlugin();
    service = LocalNotificationService.forTest(fakePlugin);
    service.isInitializedForTest = true;
  });

  test('scheduleTestReminder schedules notification with custom title and body',
      () async {
    final ok = await service.scheduleTestReminder(
      delaySeconds: 5,
      title: 'Uji Tagihan',
      body: 'Testing 123',
    );

    expect(ok, isTrue);
    expect(fakePlugin.zonedScheduleCalled, isTrue);
    expect(fakePlugin.lastTitle, 'Uji Tagihan');
    expect(fakePlugin.lastBody, 'Testing 123');
  });

  testWidgets(
      'SubscriptionDetailActions does not render Uji Notifikasi Offline button when disabled',
      (tester) async {
    final sub = SubscriptionEntry(
      id: 'sub-test-1',
      profileId: 'p1',
      walletId: 'w1',
      categoryId: 'c1',
      title: 'Netflix Premium',
      cost: 186000,
      dueDay: 15,
      billingCycle: 'monthly',
      status: 'active',
      isInstallment: false,
      autoDeduct: false,
      paidCycles: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isSynced: false,
      isDeleted: false,
    );

    final wallet = WalletEntry(
      id: 'w1',
      profileId: 'p1',
      name: 'BCA Utama',
      type: 'bank',
      balance: 1000000,
      currency: 'IDR',
      colorHex: '#10B981',
      iconName: 'bca',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isSynced: false,
      isDeleted: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SubscriptionDetailActions(
            subscription: sub,
            wallet: wallet,
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('test_offline_reminder_button')), findsNothing);
    expect(find.text('Uji Notifikasi Offline (5 Detik)'), findsNothing);
    expect(find.text('Edit Tagihan'), findsOneWidget);
    expect(find.text('Hapus'), findsOneWidget);
  });
}
