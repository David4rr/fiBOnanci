import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:fibonanci_app/core/native_bridge/notification_bridge.dart';
import 'package:fibonanci_app/core/notification_parser/notification_parser.dart';
import 'package:fibonanci_app/data/database/app_database.dart';
import 'package:fibonanci_app/data/repositories/finance_repository.dart';
import 'package:fibonanci_app/main.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  group('Pending Notification Inbox & Review Flow Tests', () {
    late AppDatabase db;
    late DriftFinanceRepository repo;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      repo = DriftFinanceRepository(db);
      NotificationBridge.clearPendingNotifications();
    });

    tearDown(() async {
      NotificationBridge.clearPendingNotifications();
      await db.close();
    });

    testWidgets('Dismissing notification review prompt retains item in pending inbox and does NOT auto-log', (tester) async {
      tester.view.physicalSize = const Size(400 * 2, 900 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final rawNotification = {
        'package': 'com.bca',
        'title': 'BCA mobile',
        'text': 'Add funds of Rp 250.000 to your account was successful.',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('com.fibonanci.app/notification_service'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'getPendingNotifications') {
            return [rawNotification];
          }
          if (methodCall.method == 'isPermissionGranted') {
            return true;
          }
          if (methodCall.method == 'updateAllowedPackages') {
            return true;
          }
          return null;
        },
      );

      // 1. Mount app on launch with pending notification
      await tester.pumpWidget(FiBOnanciApp(database: db, repository: repo));
      await tester.pumpAndSettle();

      // 2. Notification confirmation review modal appears on app open
      expect(find.text('Konfirmasi Notifikasi'), findsOneWidget);
      expect(find.text('250000'), findsOneWidget);

      // 3. User cancels/dismisses the modal (taps 'Abaikan' in review modal)
      await tester.tap(find.text('Abaikan').first);
      await tester.pumpAndSettle();
      // Review modal is dismissed
      expect(find.text('Konfirmasi Notifikasi'), findsNothing);
      // 4. Verify transaction was NOT auto-logged to database ledger
      final txs = await db.select(db.transactions).get();
      expect(txs.where((t) => t.amount == 250000.0), isEmpty);

      // 5. Verify notification is safely retained in pending inbox
      expect(NotificationBridge.pendingCount, 1);

      // 6. Open PendingInboxModal from Dashboard
      await tester.tap(find.byIcon(Icons.inbox_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Kotak Masuk Notifikasi'), findsOneWidget);
      expect(find.textContaining('Add funds of Rp 250.000'), findsOneWidget);
      expect(find.text('Review & Simpan'), findsOneWidget);
      expect(find.text('Abaikan'), findsOneWidget);

      // 7. Test 'Abaikan' discards the item and updates to empty state
      await tester.tap(find.text('Abaikan'));
      await tester.pumpAndSettle();

      expect(NotificationBridge.pendingCount, 0);
      expect(find.text('Tidak ada antrean notifikasi tertunda.\nSemua transaksi bank Anda sudah rapi tercatat!'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 100));
    });

    test('NotificationParser correctly parses add funds notification as income', () {
      final parsed = NotificationParser.parse(
        packageName: 'com.bca',
        title: 'BCA mobile',
        body: 'Add funds of Rp 500.000 to your account was successful.',
      );

      expect(parsed, isNotNull);
      expect(parsed!.amount, 500000.0);
      expect(parsed.type, 'income');
    });
  });
}
