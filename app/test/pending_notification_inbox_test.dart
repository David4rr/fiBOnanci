import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:fibonanci_app/core/native_bridge/notification_bridge.dart';
import 'package:fibonanci_app/data/database/app_database.dart';
import 'package:fibonanci_app/data/repositories/finance_repository.dart';
import 'package:fibonanci_app/main.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  group('Auto-Log Notification Inbox & Correct/Incorrect Review Tests', () {
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

    testWidgets('Auto-logs notification on launch, displays in inbox, and "Benar" (Correct) confirms transaction', (tester) async {
      tester.view.physicalSize = const Size(400 * 2, 900 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final rawNotification = {
        'package': 'com.bca',
        'title': 'BCA mobile',
        'text': 'Pembayaran QR sebesar Rp 35.000 di Kopi Kenangan berhasil.',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('com.fibonanci.app/notification_service'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'getPendingNotifications') {
            return [rawNotification];
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

      // 2. Verify transaction was automatically logged to database ledger without blocking popups
      final txs = await db.select(db.transactions).get();
      final loggedTx = txs.where((t) => t.amount == 35000.0 && !t.isDeleted).firstOrNull;
      expect(loggedTx, isNotNull);
      expect(loggedTx!.type, 'expense');

      // 3. Verify notification is buffered in inbox with pending badge count 1
      expect(NotificationBridge.pendingCount, 1);

      // 4. Open PendingInboxModal from Dashboard
      await tester.tap(find.byIcon(Icons.inbox_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Kotak Masuk Notifikasi'), findsOneWidget);
      expect(find.textContaining('Pembayaran QR sebesar Rp 35.000'), findsOneWidget);
      expect(find.text('Benar'), findsOneWidget);
      expect(find.text('Salah'), findsOneWidget);

      // 5. Tap 'Benar' (Correct) to confirm
      await tester.tap(find.text('Benar'));
      await tester.pumpAndSettle();

      // 6. Verify item is removed from inbox and empty state appears
      expect(NotificationBridge.pendingCount, 0);
      expect(find.text('Tidak ada antrean notifikasi tertunda.\nSemua transaksi bank Anda sudah rapi tercatat!'), findsOneWidget);

      // 7. Verify transaction remains securely in database history
      final postConfirmTxs = await db.select(db.transactions).get();
      final activeTx = postConfirmTxs.where((t) => t.amount == 35000.0 && !t.isDeleted).firstOrNull;
      expect(activeTx, isNotNull);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('Auto-logs notification, and "Salah" (Incorrect) deletes history entry and reverses balance', (tester) async {
      tester.view.physicalSize = const Size(400 * 2, 900 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Fetch primary wallet initial balance
      final walletsBefore = await db.select(db.wallets).get();
      final bcaWallet = walletsBefore.firstWhere((w) => w.name.toLowerCase().contains('bca'));
      final initialBalance = bcaWallet.balance;

      final rawNotification = {
        'package': 'com.bca',
        'title': 'BCA mobile',
        'text': 'Transfer keluar Rp 200.000 ke Budi Santoso berhasil.',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('com.fibonanci.app/notification_service'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'getPendingNotifications') {
            return [rawNotification];
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

      // 2. Verify transaction auto-logged and balance deducted
      final walletsAfterAutoLog = await db.select(db.wallets).get();
      final bcaAfterAutoLog = walletsAfterAutoLog.firstWhere((w) => w.id == bcaWallet.id);
      expect(bcaAfterAutoLog.balance, initialBalance - 200000.0);

      final txs = await db.select(db.transactions).get();
      final loggedTx = txs.where((t) => t.amount == 200000.0 && !t.isDeleted).firstOrNull;
      expect(loggedTx, isNotNull);

      // 3. Open PendingInboxModal from Dashboard
      await tester.tap(find.byIcon(Icons.inbox_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Kotak Masuk Notifikasi'), findsOneWidget);
      expect(find.text('Salah'), findsOneWidget);
      expect(find.text('Benar'), findsOneWidget);

      // 4. Tap 'Salah' (Incorrect) to reject and delete
      await tester.tap(find.text('Salah'));
      await tester.pumpAndSettle();

      // 5. Verify item removed from inbox and empty state displayed
      expect(NotificationBridge.pendingCount, 0);
      expect(find.text('Tidak ada antrean notifikasi tertunda.\nSemua transaksi bank Anda sudah rapi tercatat!'), findsOneWidget);

      // 6. Verify transaction is soft-deleted from SQLite
      final txsAfterReject = await db.select(db.transactions).get();
      final activeTxs = txsAfterReject.where((t) => t.id == loggedTx!.id && !t.isDeleted);
      expect(activeTxs, isEmpty);

      // 7. Verify wallet balance is atomically restored to original balance
      final walletsRestored = await db.select(db.wallets).get();
      final bcaRestored = walletsRestored.firstWhere((w) => w.id == bcaWallet.id);
      expect(bcaRestored.balance, initialBalance);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('Swiping card RIGHT confirms transaction (Benar)', (tester) async {
      tester.view.physicalSize = const Size(400 * 2, 900 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final rawNotification = {
        'package': 'com.bca',
        'title': 'BCA mobile',
        'text': 'Pembayaran QR sebesar Rp 45.000 di Starbucks berhasil.',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('com.fibonanci.app/notification_service'),
        (MethodCall methodCall) async => methodCall.method == 'getPendingNotifications' ? [rawNotification] : null,
      );

      await tester.pumpWidget(FiBOnanciApp(database: db, repository: repo));
      await tester.pumpAndSettle();

      // Open inbox
      await tester.tap(find.byIcon(Icons.inbox_outlined));
      await tester.pumpAndSettle();

      expect(find.textContaining('Pembayaran QR sebesar Rp 45.000'), findsOneWidget);

      // Swipe card to the right (drag with positive offset)
      await tester.drag(find.text('Pembayaran QR sebesar Rp 45.000 di Starbucks berhasil.'), const Offset(500, 0));
      await tester.pumpAndSettle();

      // Verified removed from inbox
      expect(NotificationBridge.pendingCount, 0);
      expect(find.text('Tidak ada antrean notifikasi tertunda.\nSemua transaksi bank Anda sudah rapi tercatat!'), findsOneWidget);

      // Verified transaction remains in database
      final txs = await db.select(db.transactions).get();
      final activeTx = txs.where((t) => t.amount == 45000.0 && !t.isDeleted).firstOrNull;
      expect(activeTx, isNotNull);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('Swiping card LEFT deletes transaction and restores balance (Salah)', (tester) async {
      tester.view.physicalSize = const Size(400 * 2, 900 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final walletsBefore = await db.select(db.wallets).get();
      final bcaWallet = walletsBefore.firstWhere((w) => w.name.toLowerCase().contains('bca'));
      final initialBalance = bcaWallet.balance;

      final rawNotification = {
        'package': 'com.bca',
        'title': 'BCA mobile',
        'text': 'Transfer keluar Rp 150.000 ke Tokopedia berhasil.',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('com.fibonanci.app/notification_service'),
        (MethodCall methodCall) async => methodCall.method == 'getPendingNotifications' ? [rawNotification] : null,
      );

      await tester.pumpWidget(FiBOnanciApp(database: db, repository: repo));
      await tester.pumpAndSettle();

      // Open inbox
      await tester.tap(find.byIcon(Icons.inbox_outlined));
      await tester.pumpAndSettle();

      expect(find.textContaining('Transfer keluar Rp 150.000'), findsOneWidget);

      // Swipe card to the left (drag with negative offset)
      await tester.drag(find.text('Transfer keluar Rp 150.000 ke Tokopedia berhasil.'), const Offset(-500, 0));
      await tester.pumpAndSettle();

      // Verified removed from inbox
      expect(NotificationBridge.pendingCount, 0);

      // Verified transaction soft deleted
      final txs = await db.select(db.transactions).get();
      final activeTxs = txs.where((t) => t.amount == 150000.0 && !t.isDeleted);
      expect(activeTxs, isEmpty);

      // Verified wallet balance restored
      final walletsRestored = await db.select(db.wallets).get();
      final bcaRestored = walletsRestored.firstWhere((w) => w.id == bcaWallet.id);
      expect(bcaRestored.balance, initialBalance);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 100));
    });
    testWidgets('Incomplete right swipe (canceling accept) springs back and item remains in inbox', (tester) async {
      tester.view.physicalSize = const Size(400 * 2, 900 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final rawNotification = {
        'package': 'com.bca',
        'title': 'BCA mobile',
        'text': 'Pembayaran QR sebesar Rp 55.000 di Janji Jiwa berhasil.',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('com.fibonanci.app/notification_service'),
        (MethodCall methodCall) async => methodCall.method == 'getPendingNotifications' ? [rawNotification] : null,
      );

      await tester.pumpWidget(FiBOnanciApp(database: db, repository: repo));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.inbox_outlined));
      await tester.pumpAndSettle();

      expect(find.textContaining('Pembayaran QR sebesar Rp 55.000'), findsOneWidget);

      // Drag only 40 pixels to the right (under the 100 threshold)
      await tester.drag(find.text('Pembayaran QR sebesar Rp 55.000 di Janji Jiwa berhasil.'), const Offset(40, 0));
      await tester.pumpAndSettle();

      // Verified NOT confirmed: item stays in inbox
      expect(NotificationBridge.pendingCount, 1);
      expect(find.textContaining('Pembayaran QR sebesar Rp 55.000'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('Incomplete left swipe (canceling delete) springs back and item remains in inbox', (tester) async {
      tester.view.physicalSize = const Size(400 * 2, 900 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final rawNotification = {
        'package': 'com.bca',
        'title': 'BCA mobile',
        'text': 'Pembayaran QR sebesar Rp 75.000 di Fore Coffee berhasil.',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('com.fibonanci.app/notification_service'),
        (MethodCall methodCall) async => methodCall.method == 'getPendingNotifications' ? [rawNotification] : null,
      );

      await tester.pumpWidget(FiBOnanciApp(database: db, repository: repo));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.inbox_outlined));
      await tester.pumpAndSettle();

      expect(find.textContaining('Pembayaran QR sebesar Rp 75.000'), findsOneWidget);

      // Drag only -40 pixels to the left (under the 100 threshold)
      await tester.drag(find.text('Pembayaran QR sebesar Rp 75.000 di Fore Coffee berhasil.'), const Offset(-40, 0));
      await tester.pumpAndSettle();

      // Verified NOT deleted: item stays in inbox
      expect(NotificationBridge.pendingCount, 1);
      expect(find.textContaining('Pembayaran QR sebesar Rp 75.000'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 100));
    });
    testWidgets('Swipe action triggers only when swiped at least 50% of screen width (cancel if < 50%)', (tester) async {
      tester.view.physicalSize = const Size(400 * 2, 900 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final rawNotification = {
        'package': 'com.bca',
        'title': 'BCA mobile',
        'text': 'Pembayaran QR sebesar Rp 90.000 di Starbucks berhasil.',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('com.fibonanci.app/notification_service'),
        (MethodCall methodCall) async => methodCall.method == 'getPendingNotifications' ? [rawNotification] : null,
      );

      await tester.pumpWidget(FiBOnanciApp(database: db, repository: repo));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.inbox_outlined));
      await tester.pumpAndSettle();

      // Logical screen width is 400. 50% is 200.
      // 1. Drag 150px (37.5% < 50%) -> MUST CANCEL and spring back!
      await tester.drag(find.text('Pembayaran QR sebesar Rp 90.000 di Starbucks berhasil.'), const Offset(150, 0));
      await tester.pumpAndSettle();

      expect(NotificationBridge.pendingCount, 1);
      // 2. Drag 260px (260 - 18px touch slop = 242px > 200px threshold = > 50%) -> MUST TRIGGER confirm!
      await tester.drag(find.text('Pembayaran QR sebesar Rp 90.000 di Starbucks berhasil.'), const Offset(260, 0));
      await tester.pumpAndSettle();

      expect(NotificationBridge.pendingCount, 0);
      expect(find.text('Tidak ada antrean notifikasi tertunda.\nSemua transaksi bank Anda sudah rapi tercatat!'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 100));
    });
    testWidgets('Simulation feature allows picking preset and adds notification to inbox for review', (tester) async {
      tester.view.physicalSize = const Size(400 * 2, 900 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('com.fibonanci.app/notification_service'),
        (MethodCall methodCall) async => methodCall.method == 'getPendingNotifications' ? [] : null,
      );

      // Mount app with empty pending notifications
      await tester.pumpWidget(FiBOnanciApp(database: db, repository: repo));
      await tester.pumpAndSettle();

      // Open empty inbox
      await tester.tap(find.byIcon(Icons.inbox_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Coba Simulasi Notifikasi Masuk'), findsOneWidget);
      expect(find.text('Simulasi'), findsOneWidget);

      // Tap Simulation trigger
      await tester.tap(find.text('Coba Simulasi Notifikasi Masuk'));
      await tester.pumpAndSettle();

      expect(find.text('Pilih Skenario Notifikasi'), findsOneWidget);
      expect(find.text('SeaBank'), findsOneWidget);
      expect(find.text('QRIS Superindo Rp 125.000 (Pengeluaran)'), findsOneWidget);

      // Tap SeaBank preset (Transfer masuk Rp 500.000)
      await tester.tap(find.text('SeaBank'));
      await tester.pumpAndSettle();

      // Verify notification is added to inbox
      expect(NotificationBridge.pendingCount, 1);
      expect(find.textContaining('Transfer masuk sebesar Rp 500.000'), findsOneWidget);

      // Verify transaction is logged in SQLite database as income
      final txs = await db.select(db.transactions).get();
      final incomeTx = txs.where((t) => t.amount == 500000.0 && !t.isDeleted).firstOrNull;
      expect(incomeTx, isNotNull);
      expect(incomeTx!.type, 'income');

      // Swipe right to confirm simulated transaction
      await tester.drag(find.textContaining('Transfer masuk sebesar Rp 500.000'), const Offset(500, 0));
      await tester.pumpAndSettle();

      // Verify inbox empty again
      expect(NotificationBridge.pendingCount, 0);
      expect(find.text('Tidak ada antrean notifikasi tertunda.\nSemua transaksi bank Anda sudah rapi tercatat!'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 100));
    });

    test('NotificationBridge rejectNotification deletes transaction and removes item', () async {
      final wallets = await db.select(db.wallets).get();
      final wallet = wallets.first;
      final initialBal = wallet.balance;

      final rawNotification = {
        'package': 'com.bca',
        'title': 'BCA mobile',
        'text': 'Transfer keluar Rp 50.000 ke John Doe berhasil.',
        'timestamp': 123456789,
      };

      // Process incoming raw notification
      await NotificationBridge.handleRawNotification(rawNotification, db);

      final pending = await NotificationBridge.getPendingRawNotifications();
      expect(pending.isNotEmpty, isTrue);

      final loggedItem = pending.first;
      final txId = loggedItem['transactionId'] as String?;
      expect(txId, isNotNull);

      // Reject notification
      await NotificationBridge.rejectNotification(loggedItem, db);

      expect(NotificationBridge.pendingCount, 0);
      final txs = await db.select(db.transactions).get();
      final activeTx = txs.where((t) => t.id == txId && !t.isDeleted);
      expect(activeTx, isEmpty);

      final updatedWallet = await (db.select(db.wallets)..where((w) => w.id.equals(wallet.id))).getSingle();
      expect(updatedWallet.balance, initialBal);
    });
  });
}
