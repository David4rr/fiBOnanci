import 'dart:io';

import 'package:drift/native.dart';
import 'package:fibonanci_app/data/database/app_database.dart';
import 'package:fibonanci_app/domain/services/safe_to_spend_service.dart';
import 'package:fibonanci_app/domain/services/subscription_auto_deduct_runner.dart';
import 'package:fibonanci_app/domain/services/subscription_schedule_service.dart';
import 'package:fibonanci_app/presentation/widgets/subscription_start_cycle_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sqlite3/sqlite3.dart' as raw_sqlite;

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  group('SubscriptionScheduleService & Next-Month Billing Tests', () {
    test('Nov 28 creation with dueDay 5 resolves to Dec 5 and is excluded from Nov Safe-to-Spend', () {
      final nov28 = DateTime(2026, 11, 28);
      final offset = SubscriptionScheduleService.defaultMonthOffset(
        dueDay: 5,
        referenceDate: nov28,
      );
      expect(offset, 1);

      final firstDue = SubscriptionScheduleService.resolveFirstDueDate(
        dueDay: 5,
        monthOffset: offset,
        referenceDate: nov28,
      );
      expect(firstDue, DateTime(2026, 12, 5));

      final wallet = WalletEntry(
        id: 'w1',
        name: 'BCA',
        type: 'bank',
        currency: 'IDR',
        balance: 5000000.0,
        colorHex: '#0060AF',
        iconName: 'wallet',
        createdAt: nov28,
        updatedAt: nov28,
        isSynced: false,
        isDeleted: false,
      );

      final dec5Bill = SubscriptionEntry(
        id: 's-dec-5',
        walletId: 'w1',
        categoryId: 'c1',
        title: 'Cicilan Motor',
        cost: 1200000.0,
        billingCycle: 'monthly',
        dueDay: 5,
        nextDueDate: firstDue,
        autoDeduct: true,
        status: 'active',
        lastPaidDate: null,
        isInstallment: true,
        totalCycles: 6,
        paidCycles: 0,
        deadlineDate: SubscriptionScheduleService.calculateInstallmentDeadline(
          firstDueDate: firstDue,
          dueDay: 5,
          totalCycles: 6,
        ),
        createdAt: nov28,
        updatedAt: nov28,
        isSynced: false,
        isDeleted: false,
      );

      // Standard calendar cycle (cycleDay = 1): Dec 5 is next month -> 0 pending in Nov
      final novMetrics = SafeToSpendService.calculate(
        wallets: [wallet],
        subscriptions: [dec5Bill],
        referenceDate: nov28,
        cycleDay: 1,
      );
      expect(novMetrics.pendingBills, 0.0);
      expect(novMetrics.pendingBillsCount, 0);
      expect(novMetrics.safeToSpendMonthly, 5000000.0);

      // Payday cycle (cycleDay = 25): Nov 25..Dec 24 covers Dec 5 -> pending!
      final paydayMetrics = SafeToSpendService.calculate(
        wallets: [wallet],
        subscriptions: [dec5Bill],
        referenceDate: nov28,
        cycleDay: 25,
      );
      expect(paydayMetrics.pendingBills, 1200000.0);
      expect(paydayMetrics.pendingBillsCount, 1);
      expect(paydayMetrics.safeToSpendMonthly, 3800000.0);

      // Auto-deduct MUST NOT fire on Nov 28, MUST fire on Dec 5
      expect(SubscriptionAutoDeductRunner.isDueForAutoDeduct(dec5Bill, referenceDate: nov28), isFalse);
      expect(SubscriptionAutoDeductRunner.isDueForAutoDeduct(dec5Bill, referenceDate: DateTime(2026, 12, 4)), isFalse);
      expect(SubscriptionAutoDeductRunner.isDueForAutoDeduct(dec5Bill, referenceDate: DateTime(2026, 12, 5)), isTrue);
    });

    test('Handles month-end clamping, leap years, year rollover, and rewind accurately', () {
      final jan31 = DateTime(2028, 1, 31);
      final feb29 = SubscriptionScheduleService.advanceNextDueDate(
        currentNextDueDate: jan31,
        dueDay: 31,
        billingCycle: 'monthly',
      );
      expect(feb29, DateTime(2028, 2, 29));

      final mar31 = SubscriptionScheduleService.advanceNextDueDate(
        currentNextDueDate: feb29,
        dueDay: 31,
        billingCycle: 'monthly',
      );
      expect(mar31, DateTime(2028, 3, 31));

      final janNextYear = SubscriptionScheduleService.advanceNextDueDate(
        currentNextDueDate: DateTime(2026, 12, 5),
        dueDay: 5,
        billingCycle: 'monthly',
      );
      expect(janNextYear, DateTime(2027, 1, 5));

      final decPrevYear = SubscriptionScheduleService.rewindNextDueDate(
        currentNextDueDate: janNextYear,
        dueDay: 5,
        billingCycle: 'monthly',
      );
      expect(decPrevYear, DateTime(2026, 12, 5));
    });

    test('Migrates legacy Drift v6 subscriptions table to v7 with explicit next_due_date', () async {
      final tempDir = await Directory.systemTemp.createTemp('fibonanci_v6_mig_');
      addTearDown(() => tempDir.delete(recursive: true));
      final dbFile = File('${tempDir.path}/legacy_v6.sqlite');

      final raw = raw_sqlite.sqlite3.open(dbFile.path);
      raw.execute('''
        CREATE TABLE profiles (id TEXT PRIMARY KEY, created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL, is_synced INTEGER NOT NULL DEFAULT 0, is_deleted INTEGER NOT NULL DEFAULT 0, username TEXT NOT NULL DEFAULT 'David', full_name TEXT NOT NULL DEFAULT 'David', email TEXT, phone TEXT, avatar_path TEXT, occupation TEXT, bio TEXT, currency TEXT NOT NULL DEFAULT 'IDR', monthly_income_target REAL, is_active INTEGER NOT NULL DEFAULT 1);
        CREATE TABLE categories (id TEXT PRIMARY KEY, created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL, is_synced INTEGER NOT NULL DEFAULT 0, is_deleted INTEGER NOT NULL DEFAULT 0, name TEXT NOT NULL, type TEXT NOT NULL, icon_name TEXT NOT NULL, color_hex TEXT NOT NULL);
        CREATE TABLE wallets (id TEXT PRIMARY KEY, created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL, is_synced INTEGER NOT NULL DEFAULT 0, is_deleted INTEGER NOT NULL DEFAULT 0, profile_id TEXT, name TEXT NOT NULL, type TEXT NOT NULL, currency TEXT NOT NULL DEFAULT 'IDR', balance REAL NOT NULL DEFAULT 0, color_hex TEXT NOT NULL, icon_name TEXT NOT NULL, account_number TEXT);
        CREATE TABLE transactions (id TEXT PRIMARY KEY, created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL, is_synced INTEGER NOT NULL DEFAULT 0, is_deleted INTEGER NOT NULL DEFAULT 0, profile_id TEXT, wallet_id TEXT NOT NULL, category_id TEXT NOT NULL, amount REAL NOT NULL, type TEXT NOT NULL, destination_wallet_id TEXT, notes TEXT, transaction_date INTEGER NOT NULL, source TEXT NOT NULL DEFAULT 'manual', external_ref TEXT);
        CREATE TABLE notification_rules (id TEXT PRIMARY KEY, created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL, is_synced INTEGER NOT NULL DEFAULT 0, is_deleted INTEGER NOT NULL DEFAULT 0, profile_id TEXT, package_name TEXT NOT NULL, wallet_id TEXT NOT NULL, is_enabled INTEGER NOT NULL DEFAULT 1, auto_confirm INTEGER NOT NULL DEFAULT 0, default_category_id TEXT);
        CREATE TABLE pockets (id TEXT PRIMARY KEY, created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL, is_synced INTEGER NOT NULL DEFAULT 0, is_deleted INTEGER NOT NULL DEFAULT 0, profile_id TEXT, name TEXT NOT NULL, type TEXT NOT NULL DEFAULT 'savings', target_amount REAL, current_amount REAL NOT NULL DEFAULT 0, color_hex TEXT NOT NULL, icon_name TEXT NOT NULL, target_date INTEGER, linked_wallet_id TEXT, notes TEXT);
        CREATE TABLE subscriptions (id TEXT PRIMARY KEY, created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL, is_synced INTEGER NOT NULL DEFAULT 0, is_deleted INTEGER NOT NULL DEFAULT 0, profile_id TEXT, wallet_id TEXT NOT NULL, category_id TEXT NOT NULL, title TEXT NOT NULL, cost REAL NOT NULL, billing_cycle TEXT NOT NULL DEFAULT 'monthly', due_day INTEGER NOT NULL, auto_deduct INTEGER NOT NULL DEFAULT 0, status TEXT NOT NULL DEFAULT 'active', last_paid_date INTEGER, is_installment INTEGER NOT NULL DEFAULT 0, total_cycles INTEGER, paid_cycles INTEGER NOT NULL DEFAULT 0, deadline_date INTEGER);
        PRAGMA user_version = 6;
      ''');

      final nov28Sec = DateTime(2026, 11, 28).millisecondsSinceEpoch ~/ 1000;
      raw.execute(
        "INSERT INTO profiles (id, created_at, updated_at, username, full_name, is_active) VALUES ('default_profile_1', ?, ?, 'David', 'David', 1)",
        [nov28Sec, nov28Sec],
      );
      raw.execute(
        "INSERT INTO categories (id, created_at, updated_at, name, type, icon_name, color_hex) VALUES ('c1', ?, ?, 'Tagihan', 'expense', 'receipt', '#FF0000')",
        [nov28Sec, nov28Sec],
      );
      raw.execute(
        "INSERT INTO wallets (id, created_at, updated_at, profile_id, name, type, balance, color_hex, icon_name) VALUES ('w1', ?, ?, 'default_profile_1', 'BCA', 'bank', 1000000, '#0060AF', 'wallet')",
        [nov28Sec, nov28Sec],
      );
      raw.execute(
        "INSERT INTO subscriptions (id, created_at, updated_at, profile_id, wallet_id, category_id, title, cost, billing_cycle, due_day) VALUES ('sub-v6', ?, ?, 'default_profile_1', 'w1', 'c1', 'Legacy Dec Bill', 250000, 'monthly', 5)",
        [nov28Sec, nov28Sec],
      );
      raw.close();

      final db = AppDatabase(NativeDatabase(dbFile));
      addTearDown(db.close);

      final subs = await db.select(db.subscriptions).get();
      expect(subs.length, 1);
      expect(subs.first.nextDueDate, DateTime(2026, 12, 5));
    });

    test('restoreJsonBackup migrates legacy v6 subscription JSON and fails fast on corrupt payload', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final wallet = (await db.select(db.wallets).get()).first;
      final cat = (await db.select(db.categories).get()).first;

      await db.restoreJsonBackup({
        'subscriptions': [
          {
            'id': 'legacy-json-1',
            'createdAt': DateTime(2026, 11, 28).millisecondsSinceEpoch,
            'updatedAt': DateTime(2026, 11, 28).millisecondsSinceEpoch,
            'isSynced': false,
            'isDeleted': false,
            'profileId': 'default_profile_1',
            'walletId': wallet.id,
            'categoryId': cat.id,
            'title': 'Legacy JSON Bill',
            'cost': 150000.0,
            'billingCycle': 'monthly',
            'dueDay': 5,
            'autoDeduct': false,
            'status': 'active',
            'lastPaidDate': null,
            'isInstallment': false,
            'totalCycles': null,
            'paidCycles': 0,
            'deadlineDate': null,
          },
        ],
      });

      final restored = await (db.select(db.subscriptions)..where((t) => t.id.equals('legacy-json-1'))).getSingle();
      expect(restored.nextDueDate, DateTime(2026, 12, 5));

      expect(
        () => db.restoreJsonBackup({
          'subscriptions': [
            {'id': 'corrupt-sub', 'title': 'Missing required fields'},
          ],
        }),
        throwsA(anything),
      );
    });

    testWidgets('SubscriptionDueSchedulePicker displays date pill and opens calendar picker cleanly', (tester) async {
      final ref = DateTime(2026, 11, 28);
      int dueDay = 5;
      DateTime nextDue = DateTime(2026, 12, 5);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return SubscriptionDueSchedulePicker(
                  dueDay: dueDay,
                  nextDueDate: nextDue,
                  referenceDate: ref,
                  onDayChanged: (d) => setState(() => dueDay = d),
                  onNextDueDateChanged: (dt) => setState(() {
                    dueDay = dt.day;
                    nextDue = dt;
                  }),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('5 Des 2026'), findsOneWidget);
      expect(find.textContaining('Bulan Ini'), findsNothing);
      expect(find.textContaining('Bulan Depan'), findsNothing);

      // Tap date pill to open date picker
      await tester.tap(find.text('5 Des 2026'));
      await tester.pumpAndSettle();
      expect(find.byType(DatePickerDialog), findsOneWidget);
    });
  });
}
