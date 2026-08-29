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

  const AddWalletEvent({
    required this.name,
    required this.type,
    required this.initialBalance,
    required this.colorHex,
    required this.iconName,
  });
}

class SetSafeToSpendWalletsEvent extends FinanceEvent {
  final Set<String>? walletIds; // null = all wallets

  const SetSafeToSpendWalletsEvent(this.walletIds);
}
