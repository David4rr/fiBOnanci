import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:fibonanci_app/core/notifications/in_app_notification_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;
  late File testFile;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('notif_storage_test_');
    testFile = File('${tempDir.path}/test_notifications.json');
    InAppNotificationStorage.resetForTest();
    InAppNotificationStorage.setStorageFile(testFile);
  });

  tearDown(() async {
    InAppNotificationStorage.resetForTest();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('InAppNotificationStorage Tests', () {
    test('initial state is empty with zero unread', () {
      expect(InAppNotificationStorage.notifications, isEmpty);
      expect(InAppNotificationStorage.unreadCountNotifier.value, 0);
    });

    test('addNotification prepends item and increments unread count', () async {
      await InAppNotificationStorage.addNotification(
        title: 'Tagihan Indihome Besok',
        body: 'Rp 200.000 jatuh tempo besok.',
        category: 'bill',
      );

      expect(InAppNotificationStorage.notifications.length, 1);
      expect(InAppNotificationStorage.notifications.first.title, 'Tagihan Indihome Besok');
      expect(InAppNotificationStorage.notifications.first.category, 'bill');
      expect(InAppNotificationStorage.notifications.first.isRead, isFalse);
      expect(InAppNotificationStorage.unreadCountNotifier.value, 1);

      await InAppNotificationStorage.addNotification(
        title: 'Mendekati Batas Belanja',
        body: 'Pengeluaran mencapai 85% kuota.',
        category: 'streak',
      );

      expect(InAppNotificationStorage.notifications.length, 2);
      expect(InAppNotificationStorage.notifications.first.title, 'Mendekati Batas Belanja');
      expect(InAppNotificationStorage.unreadCountNotifier.value, 2);
    });

    test('markAsRead updates item state and recalculates unread count', () async {
      await InAppNotificationStorage.addNotification(
        title: 'Tagihan Netflix (H-3)',
        body: 'Rp 186.000 jatuh tempo 3 hari lagi.',
        category: 'bill',
      );
      final id = InAppNotificationStorage.notifications.first.id;

      expect(InAppNotificationStorage.unreadCountNotifier.value, 1);
      await InAppNotificationStorage.markAsRead(id);

      expect(InAppNotificationStorage.notifications.first.isRead, isTrue);
      expect(InAppNotificationStorage.unreadCountNotifier.value, 0);
    });

    test('markAllAsRead marks all notifications as read', () async {
      await InAppNotificationStorage.addNotification(title: 'Notif 1', body: 'Body 1');
      await InAppNotificationStorage.addNotification(title: 'Notif 2', body: 'Body 2');

      expect(InAppNotificationStorage.unreadCountNotifier.value, 2);
      await InAppNotificationStorage.markAllAsRead();

      expect(InAppNotificationStorage.unreadCountNotifier.value, 0);
      expect(InAppNotificationStorage.notifications.every((n) => n.isRead), isTrue);
    });

    test('deleteNotification removes single item and recalculates', () async {
      await InAppNotificationStorage.addNotification(title: 'Notif 1', body: 'Body 1');
      await InAppNotificationStorage.addNotification(title: 'Notif 2', body: 'Body 2');

      final deleteId = InAppNotificationStorage.notifications.first.id;
      await InAppNotificationStorage.deleteNotification(deleteId);

      expect(InAppNotificationStorage.notifications.length, 1);
      expect(InAppNotificationStorage.unreadCountNotifier.value, 1);
    });

    test('clearAll removes all items', () async {
      await InAppNotificationStorage.addNotification(title: 'Notif 1', body: 'Body 1');
      await InAppNotificationStorage.addNotification(title: 'Notif 2', body: 'Body 2');

      await InAppNotificationStorage.clearAll();

      expect(InAppNotificationStorage.notifications, isEmpty);
      expect(InAppNotificationStorage.unreadCountNotifier.value, 0);
    });

    test('caps notifications list at 50 items', () async {
      for (int i = 0; i < 60; i++) {
        await InAppNotificationStorage.addNotification(title: 'Notif $i', body: 'Body $i');
      }

      expect(InAppNotificationStorage.notifications.length, 50);
      expect(InAppNotificationStorage.notifications.first.title, 'Notif 59');
    });

    test('persistence round trip reloads saved items from disk', () async {
      await InAppNotificationStorage.addNotification(
        title: 'Tagihan Spotify',
        body: 'Rp 54.990 jatuh tempo hari ini.',
        category: 'bill',
      );

      // Re-init with same file
      InAppNotificationStorage.resetForTest();
      InAppNotificationStorage.setStorageFile(testFile);
      await InAppNotificationStorage.init();

      expect(InAppNotificationStorage.notifications.length, 1);
      expect(InAppNotificationStorage.notifications.first.title, 'Tagihan Spotify');
      expect(InAppNotificationStorage.unreadCountNotifier.value, 1);
    });
  });
}
