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
    String? boundPackageName,
  });

  Stream<List<NotificationRuleEntry>> watchNotificationRules();
  Future<List<NotificationRuleEntry>> getNotificationRules();
  Future<List<NotificationRuleEntry>> getNotificationRulesForWallet(String walletId);
  Future<void> bindWalletToPackage({
    required String walletId,
    required String packageName,
    bool isEnabled = true,
  });
  Future<void> unbindPackage(String packageName);

  Stream<List<PocketEntry>> watchPockets();
  Future<List<PocketEntry>> getPockets();

  Future<void> addPocket({
    required String name,
    required String type,
    double? targetAmount,
    double initialAmount = 0.0,
    required String colorHex,
    required String iconName,
    DateTime? targetDate,
    String? linkedWalletId,
    String? notes,
  });

  Future<void> updatePocket({
    required String pocketId,
    required String name,
    required String type,
    double? targetAmount,
    required String colorHex,
    required String iconName,
    DateTime? targetDate,
    String? linkedWalletId,
    String? notes,
  });

  Future<void> deletePocket(String pocketId);

  Future<void> transferPocketFunds({
    required String pocketId,
    required String walletId,
    required double amount,
    required bool isDepositToPocket,
    String? notes,
  });

  Stream<List<ProfileEntry>> watchProfiles();
  Future<List<ProfileEntry>> getProfiles();
  Future<ProfileEntry?> getActiveProfile();

  Future<void> addProfile({
    required String username,
    required String fullName,
    String? email,
    String? phone,
    String? avatarPath,
    String? occupation,
    String? bio,
    String currency = 'IDR',
    double? monthlyIncomeTarget,
    bool setActive = false,
  });

  Future<void> updateProfile({
    required String profileId,
    required String username,
    required String fullName,
    String? email,
    String? phone,
    String? avatarPath,
    String? occupation,
    String? bio,
    String currency = 'IDR',
    double? monthlyIncomeTarget,
  });

  Future<void> deleteProfile(String profileId);
  Future<void> setActiveProfile(String profileId);
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
    String? boundPackageName,
  }) async {
    final now = DateTime.now().toUtc();
    final walletId = _uuid.v4();
    await db.into(db.wallets).insert(
      WalletsCompanion(
        id: drift.Value(walletId),
        name: drift.Value(name),
        type: drift.Value(type),
        balance: drift.Value(initialBalance),
        colorHex: drift.Value(colorHex),
        iconName: drift.Value(iconName),
        createdAt: drift.Value(now),
        updatedAt: drift.Value(now),
      ),
    );
    if (boundPackageName != null && boundPackageName.trim().isNotEmpty) {
      await db.upsertNotificationRule(
        walletId: walletId,
        packageName: boundPackageName.trim(),
      );
    }
  }

  @override
  Stream<List<NotificationRuleEntry>> watchNotificationRules() => db.watchNotificationRules();

  @override
  Future<List<NotificationRuleEntry>> getNotificationRules() =>
      (db.select(db.notificationRules)..where((t) => t.isDeleted.equals(false))).get();

  @override
  Future<List<NotificationRuleEntry>> getNotificationRulesForWallet(String walletId) =>
      db.getNotificationRulesForWallet(walletId);

  @override
  Future<void> bindWalletToPackage({
    required String walletId,
    required String packageName,
    bool isEnabled = true,
  }) =>
      db.upsertNotificationRule(
        walletId: walletId,
        packageName: packageName,
        isEnabled: isEnabled,
      );

  @override
  Future<void> unbindPackage(String packageName) => db.unbindPackage(packageName);

  @override
  Stream<List<PocketEntry>> watchPockets() => db.watchActivePockets();

  @override
  Future<List<PocketEntry>> getPockets() => db.getActivePockets();

  @override
  Future<void> addPocket({
    required String name,
    required String type,
    double? targetAmount,
    double initialAmount = 0.0,
    required String colorHex,
    required String iconName,
    DateTime? targetDate,
    String? linkedWalletId,
    String? notes,
  }) async {
    final now = DateTime.now().toUtc();
    final pocketId = _uuid.v4();
    await db.createPocket(
      PocketsCompanion(
        id: drift.Value(pocketId),
        name: drift.Value(name),
        type: drift.Value(type),
        targetAmount: drift.Value(targetAmount),
        currentAmount: drift.Value(initialAmount),
        colorHex: drift.Value(colorHex),
        iconName: drift.Value(iconName),
        targetDate: drift.Value(targetDate),
        linkedWalletId: drift.Value(linkedWalletId),
        notes: drift.Value(notes),
        createdAt: drift.Value(now),
        updatedAt: drift.Value(now),
      ),
    );

    if (initialAmount > 0) {
      String? effectiveWalletId = linkedWalletId;
      if (effectiveWalletId == null) {
        final existingWallets = await (db.select(db.wallets)..where((t) => t.isDeleted.equals(false))).get();
        if (existingWallets.isNotEmpty) {
          effectiveWalletId = existingWallets.first.id;
        }
      }

      if (effectiveWalletId != null) {
        await db.into(db.transactions).insert(
          TransactionsCompanion(
            id: drift.Value(_uuid.v4()),
            walletId: drift.Value(effectiveWalletId),
            categoryId: const drift.Value('11111111-1111-4111-8111-111111111111'),
            amount: drift.Value(initialAmount),
            type: const drift.Value('transfer'),
            notes: drift.Value('Setoran ke Kantong $name (Awal)'),
            transactionDate: drift.Value(now),
            createdAt: drift.Value(now),
            updatedAt: drift.Value(now),
            isSynced: const drift.Value(false),
          ),
        );
      }
    }
  }
  @override
  Future<void> updatePocket({
    required String pocketId,
    required String name,
    required String type,
    double? targetAmount,
    required String colorHex,
    required String iconName,
    DateTime? targetDate,
    String? linkedWalletId,
    String? notes,
  }) {
    final now = DateTime.now().toUtc();
    return db.updatePocket(
      PocketsCompanion(
        id: drift.Value(pocketId),
        name: drift.Value(name),
        type: drift.Value(type),
        targetAmount: drift.Value(targetAmount),
        colorHex: drift.Value(colorHex),
        iconName: drift.Value(iconName),
        targetDate: drift.Value(targetDate),
        linkedWalletId: drift.Value(linkedWalletId),
        notes: drift.Value(notes),
        updatedAt: drift.Value(now),
        isSynced: const drift.Value(false),
      ),
    );
  }

  @override
  Future<void> deletePocket(String pocketId) => db.deletePocket(pocketId);

  @override
  Future<void> transferPocketFunds({
    required String pocketId,
    required String walletId,
    required double amount,
    required bool isDepositToPocket,
    String? notes,
  }) => db.transferPocketFunds(
    pocketId: pocketId,
    walletId: walletId,
    amount: amount,
    isDepositToPocket: isDepositToPocket,
    notes: notes,
  );

  @override
  Stream<List<ProfileEntry>> watchProfiles() => db.watchProfiles();

  @override
  Future<List<ProfileEntry>> getProfiles() => db.getProfiles();

  @override
  Future<ProfileEntry?> getActiveProfile() => db.getActiveProfile();

  @override
  Future<void> addProfile({
    required String username,
    required String fullName,
    String? email,
    String? phone,
    String? avatarPath,
    String? occupation,
    String? bio,
    String currency = 'IDR',
    double? monthlyIncomeTarget,
    bool setActive = false,
  }) async {
    final now = DateTime.now().toUtc();
    final profileId = _uuid.v4();
    if (setActive) {
      final activeList = await db.getProfiles();
      for (final p in activeList) {
        if (p.isActive) {
          await db.updateProfile(ProfilesCompanion(
            id: drift.Value(p.id),
            isActive: const drift.Value(false),
            updatedAt: drift.Value(now),
          ));
        }
      }
    }
    await db.createProfile(
      ProfilesCompanion(
        id: drift.Value(profileId),
        username: drift.Value(username),
        fullName: drift.Value(fullName),
        email: drift.Value(email),
        phone: drift.Value(phone),
        avatarPath: drift.Value(avatarPath ?? 'preset:avatar_1'),
        occupation: drift.Value(occupation),
        bio: drift.Value(bio),
        currency: drift.Value(currency),
        monthlyIncomeTarget: drift.Value(monthlyIncomeTarget),
        isActive: drift.Value(setActive),
        createdAt: drift.Value(now),
        updatedAt: drift.Value(now),
        isSynced: const drift.Value(false),
        isDeleted: const drift.Value(false),
      ),
    );
  }

  @override
  Future<void> updateProfile({
    required String profileId,
    required String username,
    required String fullName,
    String? email,
    String? phone,
    String? avatarPath,
    String? occupation,
    String? bio,
    String currency = 'IDR',
    double? monthlyIncomeTarget,
  }) {
    final now = DateTime.now().toUtc();
    return db.updateProfile(
      ProfilesCompanion(
        id: drift.Value(profileId),
        username: drift.Value(username),
        fullName: drift.Value(fullName),
        email: drift.Value(email),
        phone: drift.Value(phone),
        avatarPath: drift.Value(avatarPath),
        occupation: drift.Value(occupation),
        bio: drift.Value(bio),
        currency: drift.Value(currency),
        monthlyIncomeTarget: drift.Value(monthlyIncomeTarget),
        updatedAt: drift.Value(now),
        isSynced: const drift.Value(false),
      ),
    );
  }

  @override
  Future<void> deleteProfile(String profileId) => db.deleteProfile(profileId);

  @override
  Future<void> setActiveProfile(String profileId) => db.setActiveProfile(profileId);
}
