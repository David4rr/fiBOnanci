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

  Future<void> updateWalletBalance(String walletId, double newBalance, {String? accountNumber});

  Future<void> addWallet({
    required String name,
    required String type,
    String? accountNumber,
    required double initialBalance,
    required String colorHex,
    required String iconName,
    String? boundPackageName,
  });
  Future<void> deleteWallet(String walletId);

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
