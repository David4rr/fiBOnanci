part of '../finance_event.dart';

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
