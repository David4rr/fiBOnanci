import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:uuid/uuid.dart';

import 'package:fibonanci_app/bloc/finance/finance_bloc.dart';
import 'package:fibonanci_app/bloc/finance/finance_event.dart';
import 'package:fibonanci_app/core/native_bridge/notification_bridge.dart';
import 'package:fibonanci_app/core/native_bridge/notification_wallet_resolver.dart';
import 'package:fibonanci_app/data/database/app_database.dart';
import 'package:fibonanci_app/data/repositories/finance_repository.dart';
import 'package:fibonanci_app/presentation/modals/pending_inbox_modal.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  group('Multi-Profile Notification Routing & Reassignment Tests', () {
    late AppDatabase db;
    late DriftFinanceRepository repo;
    late ProfileEntry personalProfile;
    late ProfileEntry businessProfile;
    late String personalBcaId;
    late String businessBcaId;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      repo = DriftFinanceRepository(db);
      NotificationBridge.clearPendingNotifications();

      final profiles = await db.select(db.profiles).get();
      personalProfile = profiles.first;

      final bizId = const Uuid().v4();
      await db.into(db.profiles).insert(
        ProfilesCompanion(
          id: drift.Value(bizId),
          username: const drift.Value('pt_sukses'),
          fullName: const drift.Value('PT Sukses Abadi'),
          email: const drift.Value('corp@sukses.com'),
          isActive: const drift.Value(false),
          createdAt: drift.Value(DateTime.now().toUtc()),
          updatedAt: drift.Value(DateTime.now().toUtc()),
        ),
      );
      businessProfile = await (db.select(db.profiles)..where((t) => t.id.equals(bizId))).getSingle();

      personalBcaId = const Uuid().v4();
      await db.into(db.wallets).insert(
        WalletsCompanion(
          id: drift.Value(personalBcaId),
          profileId: drift.Value(personalProfile.id),
          name: const drift.Value('BCA Pribadi'),
          accountNumber: const drift.Value('5221234567'),
          type: const drift.Value('bank'),
          balance: const drift.Value(1000000.0),
          createdAt: drift.Value(DateTime.now().toUtc()),
          updatedAt: drift.Value(DateTime.now().toUtc()),
        ),
      );

      businessBcaId = const Uuid().v4();
      await db.into(db.wallets).insert(
        WalletsCompanion(
          id: drift.Value(businessBcaId),
          profileId: drift.Value(businessProfile.id),
          name: const drift.Value('BCA Bisnis'),
          accountNumber: const drift.Value('8899889900'),
          type: const drift.Value('bank'),
          balance: const drift.Value(50000000.0),
          createdAt: drift.Value(DateTime.now().toUtc()),
          updatedAt: drift.Value(DateTime.now().toUtc()),
        ),
      );
    });

    tearDown(() async {
      NotificationBridge.clearPendingNotifications();
      await db.close();
    });

    test('NotificationWalletResolver routes by account number suffix regardless of active profile', () async {
      final resBiz = await NotificationWalletResolver.resolve(
        db: db,
        pkg: 'com.bca',
        title: 'BCA mobile',
        text: 'Pembayaran QR sebesar Rp 75.000 di Vendor Corp berhasil. Rekening *9900',
        activeProfileId: personalProfile.id,
      );
      expect(resBiz, isNotNull);
      expect(resBiz!.id, businessBcaId);
      expect(resBiz.profileId, businessProfile.id);

      final resPersonal = await NotificationWalletResolver.resolve(
        db: db,
        pkg: 'com.bca',
        title: 'BCA mobile',
        text: 'Transfer keluar Rp 50.000 ke Teman berhasil. Trx Rekening *4567',
        activeProfileId: businessProfile.id,
      );
      expect(resPersonal, isNotNull);
      expect(resPersonal!.id, personalBcaId);
      expect(resPersonal.profileId, personalProfile.id);
    });

    testWidgets('PendingInboxModal allows switching transaction wallet and profile across workspaces', (tester) async {
      tester.view.physicalSize = const Size(400 * 2, 900 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final raw = {
        'package': 'com.bca',
        'title': 'BCA mobile',
        'text': 'Pembayaran QR sebesar Rp 100.000 di Supermarket berhasil. Rekening *4567',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      await NotificationBridge.handleRawNotification(raw, db);

      final bloc = FinanceBloc(repository: repo);
      addTearDown(bloc.close);
      bloc.add(const LoadFinanceData());
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: bloc,
            child: Scaffold(
              body: Builder(
                builder: (ctx) => Center(
                  child: ElevatedButton(
                    onPressed: () => PendingInboxModal.show(ctx, database: db),
                    child: const Text('Open Inbox'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Inbox'));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('inbox_switch_wallet_button')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('inbox_switch_wallet_button')));
      await tester.pumpAndSettle();
      expect(find.byType(InboxWalletReassignSheet), findsOneWidget);
      await tester.pumpAndSettle();
      final targetWalletFinder = find.byKey(ValueKey('reassign_wallet_$businessBcaId'));
      await tester.scrollUntilVisible(targetWalletFinder, 100, scrollable: find.byType(Scrollable).last);
      await tester.pumpAndSettle();
      expect(targetWalletFinder, findsOneWidget);
      await tester.tap(targetWalletFinder);
      await tester.pumpAndSettle();

      expect(find.text('BCA Bisnis'), findsOneWidget);

      final personalWalletAfter = await (db.select(db.wallets)..where((t) => t.id.equals(personalBcaId))).getSingle();
      final businessWalletAfter = await (db.select(db.wallets)..where((t) => t.id.equals(businessBcaId))).getSingle();
      expect(personalWalletAfter.balance, 1000000.0);
      expect(businessWalletAfter.balance, 49900000.0);

      final txs = await (db.select(db.transactions)..where((t) => t.amount.equals(100000.0))).get();
      expect(txs.first.walletId, businessBcaId);
      expect(txs.first.profileId, businessProfile.id);
    });
  });
}
