part of '../finance_bloc.dart';

extension PocketBlocHandlers on FinanceBloc {
  Future<void> handleAddPocket(AddPocketEvent event, Emitter<FinanceState> emit) async {
    try {
      await repository.addPocket(
        name: event.name,
        type: event.type,
        targetAmount: event.targetAmount,
        initialAmount: event.initialAmount,
        colorHex: event.colorHex,
        iconName: event.iconName,
        targetDate: event.targetDate,
        linkedWalletId: event.linkedWalletId,
        notes: event.notes,
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Gagal menambah kantong: $e'));
    }
  }

  Future<void> handleUpdatePocket(UpdatePocketEvent event, Emitter<FinanceState> emit) async {
    try {
      await repository.updatePocket(
        pocketId: event.pocketId,
        name: event.name,
        type: event.type,
        targetAmount: event.targetAmount,
        colorHex: event.colorHex,
        iconName: event.iconName,
        targetDate: event.targetDate,
        linkedWalletId: event.linkedWalletId,
        notes: event.notes,
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Gagal memperbarui kantong: $e'));
    }
  }

  Future<void> handleDeletePocket(DeletePocketEvent event, Emitter<FinanceState> emit) async {
    try {
      await repository.deletePocket(event.pocketId);
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Gagal menghapus kantong: $e'));
    }
  }

  Future<void> handleTransferPocketFunds(TransferPocketFundsEvent event, Emitter<FinanceState> emit) async {
    try {
      await repository.transferPocketFunds(
        pocketId: event.pocketId,
        walletId: event.walletId,
        amount: event.amount,
        isDepositToPocket: event.isDepositToPocket,
        notes: event.notes,
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Gagal memindahkan dana kantong: $e'));
    }
  }
}
