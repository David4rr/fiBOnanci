part of '../finance_repository.dart';

mixin DriftWalletRepository on DriftRepoBase {
  Stream<List<WalletEntry>> watchWallets() => db.watchActiveWallets();

  Stream<List<CategoryEntry>> watchCategories() => db.watchActiveCategories();

  Future<List<WalletEntry>> getWallets() =>
      (db.select(db.wallets)..where((t) => t.isDeleted.equals(false))).get();

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
  }) async {
    final now = DateTime.now().toUtc();
    final walletId = uuid.v4();
    final cleanAccountNum = accountNumber?.trim();
    await db.into(db.wallets).insert(
      WalletsCompanion(
        id: drift.Value(walletId),
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

  Stream<List<NotificationRuleEntry>> watchNotificationRules() => db.watchNotificationRules();

  Future<List<NotificationRuleEntry>> getNotificationRules() =>
      (db.select(db.notificationRules)..where((t) => t.isDeleted.equals(false))).get();

  Future<List<NotificationRuleEntry>> getNotificationRulesForWallet(String walletId) =>
      db.getNotificationRulesForWallet(walletId);

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

  Future<void> unbindPackage(String packageName) => db.unbindPackage(packageName);
}
