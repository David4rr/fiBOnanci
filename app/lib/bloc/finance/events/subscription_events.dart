part of '../finance_event.dart';

class AddSubscriptionEvent extends FinanceEvent {
  final String title;
  final double cost;
  final int dueDay;
  final String walletId;
  final String categoryId;
  final bool autoDeduct;
  final String billingCycle;
  final bool isInstallment;
  final int? totalCycles;
  final DateTime? deadlineDate;

  const AddSubscriptionEvent({
    required this.title,
    required this.cost,
    required this.dueDay,
    required this.walletId,
    required this.categoryId,
    this.autoDeduct = false,
    this.billingCycle = 'monthly',
    this.isInstallment = false,
    this.totalCycles,
    this.deadlineDate,
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
  final bool isInstallment;
  final int? totalCycles;
  final int paidCycles;
  final DateTime? deadlineDate;

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
    this.isInstallment = false,
    this.totalCycles,
    this.paidCycles = 0,
    this.deadlineDate,
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
