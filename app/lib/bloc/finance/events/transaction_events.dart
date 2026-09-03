part of '../finance_event.dart';

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
