part of '../finance_event.dart';

class UpdateWalletBalanceEvent extends FinanceEvent {
  final String walletId;
  final double newBalance;
  final String? accountNumber;

  const UpdateWalletBalanceEvent({
    required this.walletId,
    required this.newBalance,
    this.accountNumber,
  });
}

class AddWalletEvent extends FinanceEvent {
  final String name;
  final String type;
  final String? accountNumber;
  final double initialBalance;
  final String colorHex;
  final String iconName;
  final String? boundPackageName;

  const AddWalletEvent({
    required this.name,
    required this.type,
    this.accountNumber,
    required this.initialBalance,
    required this.colorHex,
    required this.iconName,
    this.boundPackageName,
  });
}

class DeleteWalletEvent extends FinanceEvent {
  final String walletId;

  const DeleteWalletEvent(this.walletId);
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
