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
  }) async {
    final now = DateTime.now().toUtc();
    final walletId = uuid.v4();
    final cleanAccountNum = accountNumber?.trim();
    final effProfileId = profileId ?? (await db.getActiveProfile())?.id ?? 'default_profile_1';
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
    if (boundPackageName != null && boundPackageName.trim().isNotEmpty) {
      await db.upsertNotificationRule(
        walletId: walletId,
        packageName: boundPackageName.trim(),
      );
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
  }) =>
      db.upsertNotificationRule(
        walletId: walletId,
        packageName: packageName,
        isEnabled: isEnabled,
        profileId: profileId,
      );

  Future<void> unbindPackage(String packageName) => db.unbindPackage(packageName);
}
