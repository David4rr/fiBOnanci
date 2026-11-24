import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:fibonanci_app/core/notifications/in_app_notification_storage.dart';
import 'package:fibonanci_app/presentation/modals/inbox/pending_inbox_sheet.dart';
import 'package:fibonanci_app/presentation/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;
  late File testFile;

  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('inbox_tab_test_');
    testFile = File('${tempDir.path}/test_inbox_notifications.json');
    InAppNotificationStorage.resetForTest();
    InAppNotificationStorage.setStorageFile(testFile);
  });

  tearDown(() async {
    InAppNotificationStorage.resetForTest();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  Widget createTestWidget({List<Map<String, dynamic>> pending = const []}) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (ctx) => PendingInboxSheet(initialPending: pending),
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    );
  }

  group('PendingInboxSheet Combined Tabs Tests', () {
    testWidgets('renders tabs and switches between Transaksi and Pengingat', (tester) async {
      await InAppNotificationStorage.addNotification(
        title: 'Tagihan Indihome Besok',
        body: 'Rp 200.000 jatuh tempo besok.',
        category: 'bill',
      );

      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Kotak Masuk Notifikasi'), findsOneWidget);
      expect(find.text('Transaksi'), findsOneWidget);
      expect(find.text('Pengingat'), findsOneWidget);

      await tester.tap(find.text('Pengingat'));
      await tester.pumpAndSettle();

      expect(find.text('Tagihan Indihome Besok'), findsOneWidget);
      expect(find.text('Rp 200.000 jatuh tempo besok.'), findsOneWidget);
    });

    testWidgets('filters reminders by category in Pengingat tab', (tester) async {
      await InAppNotificationStorage.addNotification(
        title: 'Tagihan Indihome Besok',
        body: 'Rp 200.000 jatuh tempo besok.',
        category: 'bill',
      );
      await InAppNotificationStorage.addNotification(
        title: 'Mendekati Batas Belanja',
        body: 'Pengeluaran mencapai 85% kuota.',
        category: 'streak',
      );

      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pengingat'));
      await tester.pumpAndSettle();

      expect(find.text('Tagihan Indihome Besok'), findsOneWidget);
      expect(find.text('Mendekati Batas Belanja'), findsOneWidget);

      await tester.tap(find.text('Tagihan (1)'));
      await tester.pumpAndSettle();

      expect(find.text('Tagihan Indihome Besok'), findsOneWidget);
      expect(find.text('Mendekati Batas Belanja'), findsNothing);
    });

    testWidgets('marks reminder as read when tapped', (tester) async {
      await InAppNotificationStorage.addNotification(
        title: 'Tagihan Spotify',
        body: 'Rp 54.990 jatuh tempo hari ini.',
        category: 'bill',
      );

      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pengingat'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Tagihan Spotify'));
      await tester.pumpAndSettle();

      expect(InAppNotificationStorage.unreadCountNotifier.value, 0);
    });

    testWidgets('marks all reminders as read via action button', (tester) async {
      await InAppNotificationStorage.addNotification(title: 'Notif 1', body: 'Body 1');
      await InAppNotificationStorage.addNotification(title: 'Notif 2', body: 'Body 2');

      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pengingat'));
      await tester.pumpAndSettle();

      expect(find.text('Tandai Semua Dibaca'), findsOneWidget);
      await tester.tap(find.text('Tandai Semua Dibaca'));
      await tester.pumpAndSettle();

      expect(InAppNotificationStorage.unreadCountNotifier.value, 0);
    });

    testWidgets('swiping reminder card left triggers smooth delete without rectangular clip', (tester) async {
      await InAppNotificationStorage.addNotification(
        title: 'Tagihan Spotify',
        body: 'Rp 54.990 jatuh tempo hari ini.',
        category: 'bill',
      );

      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pengingat'));
      await tester.pumpAndSettle();

      expect(find.text('Tagihan Spotify'), findsOneWidget);

      // Drag left to delete
      await tester.drag(find.text('Tagihan Spotify'), const Offset(-300, 0));
      await tester.pumpAndSettle();

      expect(find.text('Tagihan Spotify'), findsNothing);
      expect(InAppNotificationStorage.notifications.isEmpty, isTrue);
    });
  });
}
