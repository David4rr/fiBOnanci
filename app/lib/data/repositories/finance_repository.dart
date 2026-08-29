import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';
import '../database/app_database.dart';

abstract class FinanceRepository {
  Stream<List<WalletEntry>> watchWallets();
  Stream<List<CategoryEntry>> watchCategories();
  Stream<List<TransactionEntry>> watchRecentTransactions({int limit = 50});
  Stream<List<SubscriptionEntry>> watchActiveSubscriptions();

  Future<List<WalletEntry>> getWallets();
  Future<List<CategoryEntry>> getCategories();
  Future<List<SubscriptionEntry>> getSubscriptions();
  Future<List<TransactionEntry>> getTransactions({int limit = 50});

  Future<void> addTransaction({
    required String walletId,
    required String categoryId,
    required double amount,
    required String type,
    String? destinationWalletId,
    String? notes,
    DateTime? transactionDate,
    String source = 'manual',
    String? externalRef,
  });

  Future<void> updateTransaction({
    required String transactionId,
    required String newWalletId,
    required double newAmount,
    required String newType,
    required String newCategoryId,
    String? newDestinationWalletId,
    String? newNotes,
  });

  Future<void> deleteTransaction(String transactionId);

  Future<void> addSubscription({
    required String title,
    required double cost,
    required int dueDay,
    required String walletId,
    required String categoryId,
    bool autoDeduct = false,
    String billingCycle = 'monthly',
  });

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
  });

  Future<void> deleteSubscription(String subscriptionId);

  Future<void> markSubscriptionAsPaid(String subscriptionId);

  Future<void> updateWalletBalance(String walletId, double newBalance);

  Future<void> addWallet({
    required String name,
    required String type,
    required double initialBalance,
    required String colorHex,
    required String iconName,
  });
}

class DriftFinanceRepository implements FinanceRepository {
  final AppDatabase db;
  static const _uuid = Uuid();

  DriftFinanceRepository(this.db);

  @override
  Stream<List<WalletEntry>> watchWallets() => db.watchActiveWallets();

  @override
  Stream<List<CategoryEntry>> watchCategories() => db.watchActiveCategories();

  @override
  Stream<List<TransactionEntry>> watchRecentTransactions({int limit = 50}) =>
      db.watchRecentTransactions(limit: limit);

  @override
  Stream<List<SubscriptionEntry>> watchActiveSubscriptions() =>
      db.watchActiveSubscriptions();

  @override
  Future<List<WalletEntry>> getWallets() =>
      (db.select(db.wallets)..where((t) => t.isDeleted.equals(false))).get();

  @override
  Future<List<TransactionEntry>> getTransactions({int limit = 50}) =>
      (db.select(db.transactions)
            ..where((t) => t.isDeleted.equals(false))
            ..orderBy([(t) => drift.OrderingTerm.desc(t.transactionDate)])
            ..limit(limit))
          .get();

  @override
  Future<List<CategoryEntry>> getCategories() =>
      (db.select(db.categories)..where((t) => t.isDeleted.equals(false))).get();

  @override
  Future<List<SubscriptionEntry>> getSubscriptions() =>
      (db.select(db.subscriptions)..where((t) => t.isDeleted.equals(false) & t.status.equals('active'))).get();

  @override
  Future<void> addTransaction({
    required String walletId,
    required String categoryId,
    required double amount,
    required String type,
    String? destinationWalletId,
    String? notes,
    DateTime? transactionDate,
    String source = 'manual',
    String? externalRef,
  }) {
    final now = DateTime.now().toUtc();
    return db.logTransactionWithBalanceMutation(
      tx: TransactionsCompanion(
        id: drift.Value(_uuid.v4()),
        walletId: drift.Value(walletId),
        categoryId: drift.Value(categoryId),
        amount: drift.Value(amount),
        type: drift.Value(type),
        destinationWalletId: destinationWalletId != null ? drift.Value(destinationWalletId) : const drift.Value(null),
        notes: notes != null && notes.isNotEmpty ? drift.Value(notes) : const drift.Value(null),
        transactionDate: drift.Value((transactionDate ?? now).toUtc()),
        source: drift.Value(source),
        externalRef: externalRef != null ? drift.Value(externalRef) : const drift.Value(null),
        createdAt: drift.Value(now),
        updatedAt: drift.Value(now),
      ),
    );
  }

  @override
  Future<void> updateTransaction({
    required String transactionId,
    required String newWalletId,
    required double newAmount,
    required String newType,
    required String newCategoryId,
    String? newDestinationWalletId,
    String? newNotes,
  }) {
    return db.updateTransactionWithWalletReassignment(
      txId: transactionId,
      newWalletId: newWalletId,
      newAmount: newAmount,
      newType: newType,
      newCategoryId: newCategoryId,
      newDestinationWalletId: newDestinationWalletId,
      newNotes: newNotes,
    );
  }

  @override
  Future<void> deleteTransaction(String transactionId) {
    return db.deleteTransactionWithBalanceReversal(transactionId);
  }

  @override
  Future<void> addSubscription({
    required String title,
    required double cost,
    required int dueDay,
    required String walletId,
    required String categoryId,
    bool autoDeduct = false,
    String billingCycle = 'monthly',
  }) {
    final now = DateTime.now().toUtc();
    return db.into(db.subscriptions).insert(
      SubscriptionsCompanion(
        id: drift.Value(_uuid.v4()),
        walletId: drift.Value(walletId),
        categoryId: drift.Value(categoryId),
        title: drift.Value(title),
        cost: drift.Value(cost),
        billingCycle: drift.Value(billingCycle),
        dueDay: drift.Value(dueDay),
        autoDeduct: drift.Value(autoDeduct),
        status: const drift.Value('active'),
        createdAt: drift.Value(now),
        updatedAt: drift.Value(now),
      ),
    );
  }

  @override
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
        updatedAt: drift.Value(now),
      ),
    );
  }

  @override
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

  @override
  Future<void> markSubscriptionAsPaid(String subscriptionId) {
    return db.markSubscriptionAsPaid(subscriptionId);
  }

  @override
  Future<void> updateWalletBalance(String walletId, double newBalance) {
    return db.updateWalletBalance(walletId, newBalance);
  }

  @override
  Future<void> addWallet({
    required String name,
    required String type,
    required double initialBalance,
    required String colorHex,
    required String iconName,
  }) {
    final now = DateTime.now().toUtc();
    return db.into(db.wallets).insert(
      WalletsCompanion(
        id: drift.Value(_uuid.v4()),
        name: drift.Value(name),
        type: drift.Value(type),
        balance: drift.Value(initialBalance),
        colorHex: drift.Value(colorHex),
        iconName: drift.Value(iconName),
        createdAt: drift.Value(now),
        updatedAt: drift.Value(now),
      ),
    );
  }
}
