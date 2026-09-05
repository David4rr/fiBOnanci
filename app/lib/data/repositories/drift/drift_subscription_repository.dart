part of '../finance_repository.dart';

mixin DriftSubscriptionRepository on DriftRepoBase {
  Stream<List<SubscriptionEntry>> watchActiveSubscriptions() =>
      db.watchActiveSubscriptions();

  Future<List<SubscriptionEntry>> getSubscriptions() =>
      (db.select(db.subscriptions)..where((t) => t.isDeleted.equals(false) & t.status.equals('active'))).get();

  Future<void> addSubscription({
    required String title,
    required double cost,
    required int dueDay,
    required String walletId,
    required String categoryId,
    bool autoDeduct = false,
    String billingCycle = 'monthly',
    bool isInstallment = false,
    int? totalCycles,
    DateTime? deadlineDate,
  }) {
    final now = DateTime.now().toUtc();
    return db.into(db.subscriptions).insert(
      SubscriptionsCompanion(
        id: drift.Value(uuid.v4()),
        walletId: drift.Value(walletId),
        categoryId: drift.Value(categoryId),
        title: drift.Value(title),
        cost: drift.Value(cost),
        billingCycle: drift.Value(billingCycle),
        dueDay: drift.Value(dueDay),
        autoDeduct: drift.Value(autoDeduct),
        status: const drift.Value('active'),
        isInstallment: drift.Value(isInstallment),
        totalCycles: drift.Value(totalCycles),
        paidCycles: const drift.Value(0),
        deadlineDate: drift.Value(deadlineDate),
        createdAt: drift.Value(now),
        updatedAt: drift.Value(now),
      ),
    );
  }

  Future<void> updateSubscription({
    required String subscriptionId,
    required String title,
    required double cost,
    required int dueDay,
    required String walletId,
    required String categoryId,
    bool autoDeduct = false,
    String billingCycle = 'monthly',
    String status = 'active',
    bool isInstallment = false,
    int? totalCycles,
    int paidCycles = 0,
    DateTime? deadlineDate,
  }) async {
    final now = DateTime.now().toUtc();
    await (db.update(db.subscriptions)..where((t) => t.id.equals(subscriptionId))).write(
      SubscriptionsCompanion(
        title: drift.Value(title),
        cost: drift.Value(cost),
        dueDay: drift.Value(dueDay),
        walletId: drift.Value(walletId),
        categoryId: drift.Value(categoryId),
        autoDeduct: drift.Value(autoDeduct),
        billingCycle: drift.Value(billingCycle),
        status: drift.Value(status),
        isInstallment: drift.Value(isInstallment),
        totalCycles: drift.Value(totalCycles),
        paidCycles: drift.Value(paidCycles),
        deadlineDate: drift.Value(deadlineDate),
        updatedAt: drift.Value(now),
      ),
    );
  }

  Future<void> deleteSubscription(String subscriptionId) async {
    final now = DateTime.now().toUtc();
    await (db.update(db.subscriptions)..where((t) => t.id.equals(subscriptionId))).write(
      SubscriptionsCompanion(
        isDeleted: const drift.Value(true),
        status: const drift.Value('cancelled'),
        updatedAt: drift.Value(now),
      ),
    );
  }

  Future<void> markSubscriptionAsPaid(String subscriptionId) {
    return db.markSubscriptionAsPaid(subscriptionId);
  }
}
