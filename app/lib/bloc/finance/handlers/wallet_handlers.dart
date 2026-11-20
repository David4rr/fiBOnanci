part of '../finance_bloc.dart';

extension WalletBlocHandlers on FinanceBloc {
  Future<void> handleUpdateWalletBalance(UpdateWalletBalanceEvent event, Emitter<FinanceState> emit) async {
    try {
      await repository.updateWalletBalance(
        event.walletId,
        event.newBalance,
        accountNumber: event.accountNumber,
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Gagal update saldo: $e'));
    }
  }

  Future<void> handleAddWallet(AddWalletEvent event, Emitter<FinanceState> emit) async {
    try {
      final pId = (state.activeProfile?.id != null && state.activeProfile!.id.isNotEmpty && state.activeProfile!.id != 'default_fallback')
          ? state.activeProfile!.id
          : (state.profiles.where((p) => p.isActive).firstOrNull?.id ?? 'default_profile_1');
      await repository.addWallet(
        name: event.name,
        type: event.type,
        accountNumber: event.accountNumber,
        initialBalance: event.initialBalance,
        colorHex: event.colorHex,
        iconName: event.iconName,
        boundPackageName: event.boundPackageName,
        profileId: pId,
        createInitialTransaction: event.createInitialTransaction,
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Gagal menambah rekening: $e'));
    }
  }

  Future<void> handleDeleteWallet(DeleteWalletEvent event, Emitter<FinanceState> emit) async {
    try {
      await repository.deleteWallet(event.walletId);
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Gagal menghapus rekening: $e'));
    }
  }

  Future<void> handleBindWalletToPackage(BindWalletToPackageEvent event, Emitter<FinanceState> emit) async {
    try {
      await repository.bindWalletToPackage(
        walletId: event.walletId,
        packageName: event.packageName,
        isEnabled: event.isEnabled,
        profileId: state.profile.id,
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Gagal menghubungkan aplikasi: $e'));
    }
  }

  Future<void> handleUnbindPackage(UnbindPackageEvent event, Emitter<FinanceState> emit) async {
    try {
      await repository.unbindPackage(event.packageName);
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Gagal memutuskan aplikasi: $e'));
    }
  }
}
