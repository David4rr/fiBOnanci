part of '../finance_repository.dart';

mixin DriftWalletRepository on DriftRepoBase {
  Stream<List<WalletEntry>> watchWallets({String? profileId}) =>
      db.watchActiveWallets(profileId: profileId);

  Stream<List<CategoryEntry>> watchCategories() => db.watchActiveCategories();

  Future<List<WalletEntry>> getWallets({String? profileId}) {
    final q = db.select(db.wallets)
      ..where((t) => t.isDeleted.equals(false) & db.profileFilter(t.profileId, profileId));
    return q.get();
  }

  Future<List<CategoryEntry>> getCategories() =>
      (db.select(db.categories)..where((t) => t.isDeleted.equals(false))).get();

  Future<void> updateWalletBalance(String walletId, double newBalance, {String? accountNumber}) {
    return db.updateWalletBalance(
      walletId,
      newBalance,
      accountNumber: accountNumber != null
          ? drift.Value(accountNumber.trim().isNotEmpty ? accountNumber.trim() : null)
          : const drift.Value.absent(),
    );
  }

  Future<void> addWallet({
    required String name,
    required String type,
    String? accountNumber,
    required double initialBalance,
    required String colorHex,
    required String iconName,
    String? boundPackageName,
    String? profileId,
    bool createInitialTransaction = false,
  }) async {
    final now = DateTime.now().toUtc();
    final walletId = uuid.v4();
    final cleanAccountNum = accountNumber?.trim();
    final effProfileId = (profileId != null && profileId.isNotEmpty && profileId != 'default_fallback')
        ? profileId
        : (await db.getActiveProfile())?.id ?? 'default_profile_1';
    await db.into(db.wallets).insert(
      WalletsCompanion(
        id: drift.Value(walletId),
        profileId: drift.Value(effProfileId),
        name: drift.Value(name),
        type: drift.Value(type),
        accountNumber: drift.Value(cleanAccountNum != null && cleanAccountNum.isNotEmpty ? cleanAccountNum : null),
        balance: drift.Value(initialBalance),
        colorHex: drift.Value(colorHex),
        iconName: drift.Value(iconName),
        createdAt: drift.Value(now),
        updatedAt: drift.Value(now),
      ),
    );
    if (createInitialTransaction && initialBalance > 0) {
      final cat = await (db.select(db.categories)
            ..where((t) => t.name.equals('Saldo Awal') | t.name.equals('Pemasukan') | t.type.equals('income'))
            ..limit(1))
          .getSingleOrNull();
      final catId = cat?.id ?? '11111111-1111-4111-8111-111111111108';
      await db.into(db.transactions).insert(
        TransactionsCompanion(
          id: drift.Value(uuid.v4()),
          walletId: drift.Value(walletId),
          profileId: drift.Value(effProfileId),
          amount: drift.Value(initialBalance),
          type: const drift.Value('income'),
          categoryId: drift.Value(catId),
          notes: const drift.Value('Saldo Awal'),
          transactionDate: drift.Value(now),
          createdAt: drift.Value(now),
          updatedAt: drift.Value(now),
          isSynced: const drift.Value(false),
          isDeleted: const drift.Value(false),
        ),
      );
    }
    if (boundPackageName != null && boundPackageName.trim().isNotEmpty) {
      await db.upsertNotificationRule(
        walletId: walletId,
        packageName: boundPackageName.trim(),
      );
      await NotificationBridge.syncAllowedPackages(db);
    }
  }

  Future<void> deleteWallet(String walletId) async {
    await db.deleteWallet(walletId);
    await NotificationBridge.syncAllowedPackages(db);
  }

  Stream<List<NotificationRuleEntry>> watchNotificationRules({String? profileId}) =>
      db.watchNotificationRules(profileId: profileId);

  Future<List<NotificationRuleEntry>> getNotificationRules({String? profileId}) {
    final q = db.select(db.notificationRules)
      ..where((t) => t.isDeleted.equals(false) & db.profileFilter(t.profileId, profileId));
    return q.get();
  }

  Future<List<NotificationRuleEntry>> getNotificationRulesForWallet(String walletId) =>
      db.getNotificationRulesForWallet(walletId);

  Future<void> bindWalletToPackage({
    required String walletId,
    required String packageName,
    bool isEnabled = true,
    String? profileId,
  }) async {
    await db.upsertNotificationRule(
      walletId: walletId,
      packageName: packageName,
      isEnabled: isEnabled,
      profileId: profileId,
    );
    await NotificationBridge.syncAllowedPackages(db);
  }

  Future<void> unbindPackage(String packageName) async {
    await db.unbindPackage(packageName);
    await NotificationBridge.syncAllowedPackages(db);
  }
}
