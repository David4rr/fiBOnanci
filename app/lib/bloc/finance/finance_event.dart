abstract class FinanceEvent {
  const FinanceEvent();
}

class LoadFinanceData extends FinanceEvent {
  const LoadFinanceData();
}

class AddTransactionEvent extends FinanceEvent {
  final String walletId;
  final String categoryId;
  final double amount;
  final String type;
  final String? destinationWalletId;
  final String? notes;
  final DateTime? transactionDate;
  final String source;
  final String? externalRef;

  const AddTransactionEvent({
    required this.walletId,
    required this.categoryId,
    required this.amount,
    required this.type,
    this.destinationWalletId,
    this.notes,
    this.transactionDate,
    this.source = 'manual',
    this.externalRef,
  });
}

class UpdateTransactionEvent extends FinanceEvent {
  final String transactionId;
  final String newWalletId;
  final double newAmount;
  final String newType;
  final String newCategoryId;
  final String? newDestinationWalletId;
  final String? newNotes;

  const UpdateTransactionEvent({
    required this.transactionId,
    required this.newWalletId,
    required this.newAmount,
    required this.newType,
    required this.newCategoryId,
    this.newDestinationWalletId,
    this.newNotes,
  });
}

class DeleteTransactionEvent extends FinanceEvent {
  final String transactionId;

  const DeleteTransactionEvent(this.transactionId);
}

class AddSubscriptionEvent extends FinanceEvent {
  final String title;
  final double cost;
  final int dueDay;
  final String walletId;
  final String categoryId;
  final bool autoDeduct;
  final String billingCycle;

  const AddSubscriptionEvent({
    required this.title,
    required this.cost,
    required this.dueDay,
    required this.walletId,
    required this.categoryId,
    this.autoDeduct = false,
    this.billingCycle = 'monthly',
  });
}

class UpdateSubscriptionEvent extends FinanceEvent {
  final String subscriptionId;
  final String title;
  final double cost;
  final int dueDay;
  final String walletId;
  final String categoryId;
  final bool autoDeduct;
  final String billingCycle;
  final String status;

  const UpdateSubscriptionEvent({
    required this.subscriptionId,
    required this.title,
    required this.cost,
    required this.dueDay,
    required this.walletId,
    required this.categoryId,
    this.autoDeduct = false,
    this.billingCycle = 'monthly',
    this.status = 'active',
  });
}

class DeleteSubscriptionEvent extends FinanceEvent {
  final String subscriptionId;

  const DeleteSubscriptionEvent(this.subscriptionId);
}

class MarkSubscriptionPaidEvent extends FinanceEvent {
  final String subscriptionId;

  const MarkSubscriptionPaidEvent(this.subscriptionId);
}

class UpdateWalletBalanceEvent extends FinanceEvent {
  final String walletId;
  final double newBalance;

  const UpdateWalletBalanceEvent({
    required this.walletId,
    required this.newBalance,
  });
}

class AddWalletEvent extends FinanceEvent {
  final String name;
  final String type;
  final double initialBalance;
  final String colorHex;
  final String iconName;
  final String? boundPackageName;

  const AddWalletEvent({
    required this.name,
    required this.type,
    required this.initialBalance,
    required this.colorHex,
    required this.iconName,
    this.boundPackageName,
  });
}

class BindWalletToPackageEvent extends FinanceEvent {
  final String walletId;
  final String packageName;
  final bool isEnabled;

  const BindWalletToPackageEvent({
    required this.walletId,
    required this.packageName,
    this.isEnabled = true,
  });
}

class UnbindPackageEvent extends FinanceEvent {
  final String packageName;

  const UnbindPackageEvent(this.packageName);
}

class SetSafeToSpendWalletsEvent extends FinanceEvent {
  final Set<String>? walletIds; // null = all wallets

  const SetSafeToSpendWalletsEvent(this.walletIds);
}

class AddPocketEvent extends FinanceEvent {
  final String name;
  final String type;
  final double? targetAmount;
  final double initialAmount;
  final String colorHex;
  final String iconName;
  final DateTime? targetDate;
  final String? linkedWalletId;
  final String? notes;

  const AddPocketEvent({
    required this.name,
    required this.type,
    this.targetAmount,
    this.initialAmount = 0.0,
    required this.colorHex,
    required this.iconName,
    this.targetDate,
    this.linkedWalletId,
    this.notes,
  });
}

class UpdatePocketEvent extends FinanceEvent {
  final String pocketId;
  final String name;
  final String type;
  final double? targetAmount;
  final String colorHex;
  final String iconName;
  final DateTime? targetDate;
  final String? linkedWalletId;
  final String? notes;

  const UpdatePocketEvent({
    required this.pocketId,
    required this.name,
    required this.type,
    this.targetAmount,
    required this.colorHex,
    required this.iconName,
    this.targetDate,
    this.linkedWalletId,
    this.notes,
  });
}

class DeletePocketEvent extends FinanceEvent {
  final String pocketId;

  const DeletePocketEvent(this.pocketId);
}

class TransferPocketFundsEvent extends FinanceEvent {
  final String pocketId;
  final String walletId;
  final double amount;
  final bool isDepositToPocket;
  final String? notes;

  const TransferPocketFundsEvent({
    required this.pocketId,
    required this.walletId,
    required this.amount,
    required this.isDepositToPocket,
    this.notes,
  });
}

class AddProfileEvent extends FinanceEvent {
  final String username;
  final String fullName;
  final String? email;
  final String? phone;
  final String? avatarPath;
  final String? occupation;
  final String? bio;
  final String currency;
  final double? monthlyIncomeTarget;
  final bool setActive;

  const AddProfileEvent({
    required this.username,
    required this.fullName,
    this.email,
    this.phone,
    this.avatarPath,
    this.occupation,
    this.bio,
    this.currency = 'IDR',
    this.monthlyIncomeTarget,
    this.setActive = false,
  });
}

class UpdateProfileEvent extends FinanceEvent {
  final String profileId;
  final String username;
  final String fullName;
  final String? email;
  final String? phone;
  final String? avatarPath;
  final String? occupation;
  final String? bio;
  final String currency;
  final double? monthlyIncomeTarget;

  const UpdateProfileEvent({
    required this.profileId,
    required this.username,
    required this.fullName,
    this.email,
    this.phone,
    this.avatarPath,
    this.occupation,
    this.bio,
    this.currency = 'IDR',
    this.monthlyIncomeTarget,
  });
}

class DeleteProfileEvent extends FinanceEvent {
  final String profileId;

  const DeleteProfileEvent(this.profileId);
}

class SetActiveProfileEvent extends FinanceEvent {
  final String profileId;

  const SetActiveProfileEvent(this.profileId);
}
