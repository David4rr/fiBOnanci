part of '../finance_event.dart';

class AddCategoryEvent extends FinanceEvent {
  final String name;
  final String type;
  final String iconName;
  final String colorHex;

  const AddCategoryEvent({
    required this.name,
    required this.type,
    this.iconName = 'category',
    this.colorHex = '#D4F442',
  });
}

class DeleteCategoryEvent extends FinanceEvent {
  final String categoryId;

  const DeleteCategoryEvent(this.categoryId);
}

class SetBudgetCycleDayEvent extends FinanceEvent {
  final int cycleDay;

  const SetBudgetCycleDayEvent(this.cycleDay);
}

class ToggleBalanceVisibilityEvent extends FinanceEvent {
  final bool? hidden;

  const ToggleBalanceVisibilityEvent([this.hidden]);
}

class ClearProfileTransactionsEvent extends FinanceEvent {
  final String? profileId;

  const ClearProfileTransactionsEvent([this.profileId]);
}

class SetExchangeRateEvent extends FinanceEvent {
  final String currencyCode;
  final double rateToIdr;

  const SetExchangeRateEvent(this.currencyCode, this.rateToIdr);
}

class SyncExchangeRatesEvent extends FinanceEvent {
  const SyncExchangeRatesEvent();
}
