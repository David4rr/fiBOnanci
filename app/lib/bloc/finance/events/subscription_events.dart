part of '../finance_event.dart';

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
