import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fibonanci_app/data/database/app_database.dart';
import 'package:fibonanci_app/domain/services/subscription_auto_deduct_runner.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    SubscriptionAutoDeductRunner.resetLockForTest();
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('SubscriptionAutoDeductRunner Tests', () {
    test('isDueForAutoDeduct correctly identifies due status', () {
      final now = DateTime(2026, 10, 15);

      final eligibleSub = SubscriptionEntry(
        id: 'sub-1',
        walletId: 'w-1',
        categoryId: 'c-1',
        title: 'Internet',
        cost: 350000,
        billingCycle: 'monthly',
        dueDay: 10, // already passed
        autoDeduct: true,
        status: 'active',
        isInstallment: false,
        paidCycles: 0,
        createdAt: now,
        updatedAt: now,
        isSynced: false,
        isDeleted: false,
      );
      expect(SubscriptionAutoDeductRunner.isDueForAutoDeduct(eligibleSub, referenceDate: now), isTrue);

      final notDueYetSub = eligibleSub.copyWith(dueDay: 20);
      expect(SubscriptionAutoDeductRunner.isDueForAutoDeduct(notDueYetSub, referenceDate: now), isFalse);

      final manualSub = eligibleSub.copyWith(autoDeduct: false);
      expect(SubscriptionAutoDeductRunner.isDueForAutoDeduct(manualSub, referenceDate: now), isFalse);

      final alreadyPaidSub = eligibleSub.copyWith(lastPaidDate: drift.Value(DateTime(2026, 10, 10)));
      expect(SubscriptionAutoDeductRunner.isDueForAutoDeduct(alreadyPaidSub, referenceDate: now), isFalse);

      final completedInstallment = eligibleSub.copyWith(
        isInstallment: true,
        totalCycles: const drift.Value(6),
        paidCycles: 6,
      );
      expect(SubscriptionAutoDeductRunner.isDueForAutoDeduct(completedInstallment, referenceDate: now), isFalse);
    });

    test('runAutoDeduct atomically debits wallet and logs recurring transaction', () async {
      // 1. Setup wallet with 1,000,000 balance
      final wallet = await (db.select(db.wallets)..limit(1)).getSingle();
      final initialBalance = wallet.balance;

      final category = await (db.select(db.categories)..limit(1)).getSingle();

      // 2. Insert auto-deduct subscription (dueDay = 5, cost = 200,000)
      const cost = 200000.0;
      const subId = 'sub-auto-deduct-test';
      final now = DateTime(2026, 10, 15);
      await db.into(db.subscriptions).insert(
        SubscriptionsCompanion(
          id: const drift.Value(subId),
          walletId: drift.Value(wallet.id),
          profileId: drift.Value(wallet.profileId),
          categoryId: drift.Value(category.id),
          title: const drift.Value('Gym Membership'),
          cost: const drift.Value(cost),
          billingCycle: const drift.Value('monthly'),
          dueDay: const drift.Value(5),
          autoDeduct: const drift.Value(true),
          status: const drift.Value('active'),
          createdAt: drift.Value(now),
          updatedAt: drift.Value(now),
        ),
      );

      // 3. Execute auto-deduct runner
      final deducted = await SubscriptionAutoDeductRunner.runAutoDeduct(
        db: db,
        referenceDate: now,
      );

      expect(deducted.length, 1);
      expect(deducted.first.id, subId);

      // 4. Verify wallet balance decreased atomically
      final updatedWallet = await (db.select(db.wallets)..where((t) => t.id.equals(wallet.id))).getSingle();
      expect(updatedWallet.balance, initialBalance - cost);

      // 5. Verify subscription state updated (lastPaidDate, paidCycles)
      final updatedSub = await (db.select(db.subscriptions)..where((t) => t.id.equals(subId))).getSingle();
      expect(updatedSub.paidCycles, 1);
      expect(updatedSub.lastPaidDate, isNotNull);

      // 6. Verify recurring transaction logged
      final tx = await (db.select(db.transactions)..where((t) => t.externalRef.equals('sub_$subId'))).getSingle();
      expect(tx.amount, cost);
      expect(tx.source, 'subscription_recurring');

      // 7. Re-running on same date is idempotent (no duplicate debit)
      final reDeducted = await SubscriptionAutoDeductRunner.runAutoDeduct(
        db: db,
        referenceDate: now,
      );
      expect(reDeducted, isEmpty);

      final walletAfterSecondRun = await (db.select(db.wallets)..where((t) => t.id.equals(wallet.id))).getSingle();
      expect(walletAfterSecondRun.balance, initialBalance - cost);
    });

    test('concurrent runAutoDeduct executions acquire lock and prevent double-debiting', () async {
      final wallet = await (db.select(db.wallets)..limit(1)).getSingle();
      final initialBalance = wallet.balance;
      final category = await (db.select(db.categories)..limit(1)).getSingle();

      const cost = 150000.0;
      const subId = 'sub-concurrent-test';
      final now = DateTime(2026, 10, 15);
      await db.into(db.subscriptions).insert(
        SubscriptionsCompanion(
          id: const drift.Value(subId),
          walletId: drift.Value(wallet.id),
          profileId: drift.Value(wallet.profileId),
          categoryId: drift.Value(category.id),
          title: const drift.Value('Concurrent Test Sub'),
          cost: const drift.Value(cost),
          billingCycle: const drift.Value('monthly'),
          dueDay: const drift.Value(5),
          autoDeduct: const drift.Value(true),
          status: const drift.Value('active'),
          createdAt: drift.Value(now),
          updatedAt: drift.Value(now),
        ),
      );

      final results = await Future.wait([
        SubscriptionAutoDeductRunner.runAutoDeduct(db: db, referenceDate: now),
        SubscriptionAutoDeductRunner.runAutoDeduct(db: db, referenceDate: now),
      ]);

      final totalDeducted = results[0].length + results[1].length;
      expect(totalDeducted, 1);
      expect(results.any((r) => r.length == 1), isTrue);
      expect(results.any((r) => r.isEmpty), isTrue);

      final updatedWallet = await (db.select(db.wallets)..where((t) => t.id.equals(wallet.id))).getSingle();
      expect(updatedWallet.balance, initialBalance - cost);
    });

    test('isDueForAutoDeduct clamps day 31 in shorter months like February and April', () {
      final sub31 = SubscriptionEntry(
        id: 'sub-31',
        walletId: 'w-1',
        categoryId: 'c-1',
        title: 'End of Month Cloud',
        cost: 50000,
        billingCycle: 'monthly',
        dueDay: 31,
        autoDeduct: true,
        status: 'active',
        isInstallment: false,
        paidCycles: 0,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
        isSynced: false,
        isDeleted: false,
      );

      expect(SubscriptionAutoDeductRunner.isDueForAutoDeduct(sub31, referenceDate: DateTime(2026, 2, 27)), isFalse);
      expect(SubscriptionAutoDeductRunner.isDueForAutoDeduct(sub31, referenceDate: DateTime(2026, 2, 28)), isTrue);
      expect(SubscriptionAutoDeductRunner.isDueForAutoDeduct(sub31, referenceDate: DateTime(2026, 4, 29)), isFalse);
      expect(SubscriptionAutoDeductRunner.isDueForAutoDeduct(sub31, referenceDate: DateTime(2026, 4, 30)), isTrue);
    });

    test('isDueForAutoDeduct handles yearly billing cycle without multi-month double charges', () {
      final yearlySub = SubscriptionEntry(
        id: 'sub-yearly',
        walletId: 'w-1',
        categoryId: 'c-1',
        title: 'Annual Cloud Backup',
        cost: 1200000,
        billingCycle: 'yearly',
        dueDay: 10,
        autoDeduct: true,
        status: 'active',
        isInstallment: false,
        paidCycles: 1,
        lastPaidDate: DateTime(2026, 1, 10),
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 10),
        isSynced: false,
        isDeleted: false,
      );

      expect(SubscriptionAutoDeductRunner.isDueForAutoDeduct(yearlySub, referenceDate: DateTime(2026, 2, 15)), isFalse);
      expect(SubscriptionAutoDeductRunner.isDueForAutoDeduct(yearlySub, referenceDate: DateTime(2026, 12, 15)), isFalse);
      expect(SubscriptionAutoDeductRunner.isDueForAutoDeduct(yearlySub, referenceDate: DateTime(2027, 1, 5)), isFalse);
      expect(SubscriptionAutoDeductRunner.isDueForAutoDeduct(yearlySub, referenceDate: DateTime(2027, 1, 10)), isTrue);
    });

    test('isDueForAutoDeduct handles weekly billing cycle correctly', () {
      final weeklySub = SubscriptionEntry(
        id: 'sub-weekly',
        walletId: 'w-1',
        categoryId: 'c-1',
        title: 'Weekly Water Delivery',
        cost: 25000,
        billingCycle: 'weekly',
        dueDay: 1,
        autoDeduct: true,
        status: 'active',
        isInstallment: false,
        paidCycles: 1,
        lastPaidDate: DateTime(2026, 10, 1),
        createdAt: DateTime(2026, 10, 1),
        updatedAt: DateTime(2026, 10, 1),
        isSynced: false,
        isDeleted: false,
      );

      expect(SubscriptionAutoDeductRunner.isDueForAutoDeduct(weeklySub, referenceDate: DateTime(2026, 10, 4)), isFalse);
      expect(SubscriptionAutoDeductRunner.isDueForAutoDeduct(weeklySub, referenceDate: DateTime(2026, 10, 7)), isFalse);
      expect(SubscriptionAutoDeductRunner.isDueForAutoDeduct(weeklySub, referenceDate: DateTime(2026, 10, 8)), isTrue);
    });

    test('markSubscriptionAsPaid ignores completed or deleted subscriptions and marks installment complete at final cycle', () async {
      final wallet = await (db.select(db.wallets)..limit(1)).getSingle();
      final initialBalance = wallet.balance;
      final category = await (db.select(db.categories)..limit(1)).getSingle();

      const subId = 'sub-guard-test';
      final now = DateTime(2026, 10, 15);

      await db.into(db.subscriptions).insert(
        SubscriptionsCompanion(
          id: const drift.Value(subId),
          walletId: drift.Value(wallet.id),
          profileId: drift.Value(wallet.profileId),
          categoryId: drift.Value(category.id),
          title: const drift.Value('Installment Plan'),
          cost: const drift.Value(100000.0),
          billingCycle: const drift.Value('monthly'),
          dueDay: const drift.Value(10),
          autoDeduct: const drift.Value(true),
          status: const drift.Value('active'),
          isInstallment: const drift.Value(true),
          totalCycles: const drift.Value(2),
          paidCycles: const drift.Value(1),
          createdAt: drift.Value(now),
          updatedAt: drift.Value(now),
        ),
      );

      await db.markSubscriptionAsPaid(subId);
      var sub = await (db.select(db.subscriptions)..where((t) => t.id.equals(subId))).getSingle();
      expect(sub.paidCycles, 2);
      expect(sub.status, 'completed');

      final balAfterCompletion = (await (db.select(db.wallets)..where((t) => t.id.equals(wallet.id))).getSingle()).balance;
      expect(balAfterCompletion, initialBalance - 100000.0);

      await db.markSubscriptionAsPaid(subId);
      sub = await (db.select(db.subscriptions)..where((t) => t.id.equals(subId))).getSingle();
      expect(sub.paidCycles, 2);
      expect(sub.status, 'completed');
      final balAfterRedundant = (await (db.select(db.wallets)..where((t) => t.id.equals(wallet.id))).getSingle()).balance;
      expect(balAfterRedundant, balAfterCompletion);

      const deletedSubId = 'sub-deleted-test';
      await db.into(db.subscriptions).insert(
        SubscriptionsCompanion(
          id: const drift.Value(deletedSubId),
          walletId: drift.Value(wallet.id),
          profileId: drift.Value(wallet.profileId),
          categoryId: drift.Value(category.id),
          title: const drift.Value('Deleted Sub'),
          cost: const drift.Value(50000.0),
          billingCycle: const drift.Value('monthly'),
          dueDay: const drift.Value(10),
          autoDeduct: const drift.Value(true),
          status: const drift.Value('cancelled'),
          isDeleted: const drift.Value(true),
          createdAt: drift.Value(now),
          updatedAt: drift.Value(now),
        ),
      );

      await db.markSubscriptionAsPaid(deletedSubId);
      final balAfterDeleted = (await (db.select(db.wallets)..where((t) => t.id.equals(wallet.id))).getSingle()).balance;
      expect(balAfterDeleted, balAfterCompletion);
    });
  });
}
