part of '../finance_bloc.dart';

extension SubscriptionBlocHandlers on FinanceBloc {
  Future<void> handleAddSubscription(AddSubscriptionEvent event, Emitter<FinanceState> emit) async {
    try {
      await repository.addSubscription(
        title: event.title,
        cost: event.cost,
        dueDay: event.dueDay,
        walletId: event.walletId,
        categoryId: event.categoryId,
        autoDeduct: event.autoDeduct,
        billingCycle: event.billingCycle,
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Gagal menambah langganan: $e'));
    }
  }

  Future<void> handleUpdateSubscription(UpdateSubscriptionEvent event, Emitter<FinanceState> emit) async {
    try {
      await repository.updateSubscription(
        subscriptionId: event.subscriptionId,
        title: event.title,
        cost: event.cost,
        dueDay: event.dueDay,
        walletId: event.walletId,
        categoryId: event.categoryId,
        autoDeduct: event.autoDeduct,
        billingCycle: event.billingCycle,
        status: event.status,
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Gagal update langganan: $e'));
    }
  }

  Future<void> handleDeleteSubscription(DeleteSubscriptionEvent event, Emitter<FinanceState> emit) async {
    try {
      await repository.deleteSubscription(event.subscriptionId);
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Gagal hapus langganan: $e'));
    }
  }

  Future<void> handleMarkSubscriptionPaid(MarkSubscriptionPaidEvent event, Emitter<FinanceState> emit) async {
    try {
      await repository.markSubscriptionAsPaid(event.subscriptionId);
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Gagal menandai lunas: $e'));
    }
  }
}
