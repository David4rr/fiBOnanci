part of '../finance_bloc.dart';

extension TransactionBlocHandlers on FinanceBloc {
  Future<void> handleAddTransaction(AddTransactionEvent event, Emitter<FinanceState> emit) async {
    try {
      await repository.addTransaction(
        walletId: event.walletId,
        categoryId: event.categoryId,
        amount: event.amount,
        type: event.type,
        destinationWalletId: event.destinationWalletId,
        notes: event.notes,
        transactionDate: event.transactionDate,
        source: event.source,
        externalRef: event.externalRef,
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Gagal menambah transaksi: $e'));
    }
  }

  Future<void> handleUpdateTransaction(UpdateTransactionEvent event, Emitter<FinanceState> emit) async {
    try {
      await repository.updateTransaction(
        transactionId: event.transactionId,
        newWalletId: event.newWalletId,
        newAmount: event.newAmount,
        newType: event.newType,
        newCategoryId: event.newCategoryId,
        newDestinationWalletId: event.newDestinationWalletId,
        newNotes: event.newNotes,
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Gagal update transaksi: $e'));
    }
  }

  Future<void> handleDeleteTransaction(DeleteTransactionEvent event, Emitter<FinanceState> emit) async {
    try {
      await repository.deleteTransaction(event.transactionId);
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Gagal hapus transaksi: $e'));
    }
  }
}
