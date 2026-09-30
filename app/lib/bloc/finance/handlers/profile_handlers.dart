part of '../finance_bloc.dart';

extension ProfileBlocHandlers on FinanceBloc {
  Future<void> handleAddProfile(AddProfileEvent event, Emitter<FinanceState> emit) async {
    try {
      await repository.addProfile(
        username: event.username,
        fullName: event.fullName,
        email: event.email,
        phone: event.phone,
        avatarPath: event.avatarPath,
        occupation: event.occupation,
        bio: event.bio,
        currency: event.currency,
        monthlyIncomeTarget: event.monthlyIncomeTarget,
        setActive: event.setActive,
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Gagal menambah profil: $e'));
    }
  }

  Future<void> handleUpdateProfile(UpdateProfileEvent event, Emitter<FinanceState> emit) async {
    try {
      await repository.updateProfile(
        profileId: event.profileId,
        username: event.username,
        fullName: event.fullName,
        email: event.email,
        phone: event.phone,
        avatarPath: event.avatarPath,
        occupation: event.occupation,
        bio: event.bio,
        currency: event.currency,
        monthlyIncomeTarget: event.monthlyIncomeTarget,
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Gagal memperbarui profil: $e'));
    }
  }

  Future<void> handleDeleteProfile(DeleteProfileEvent event, Emitter<FinanceState> emit) async {
    try {
      await repository.deleteProfile(event.profileId);
      final profiles = await repository.getProfiles();
      final active = profiles.where((p) => p.isActive).firstOrNull ?? profiles.firstOrNull;
      final pId = active?.id;
      _initStreamListeners(pId);
      final wallets = await repository.getWallets(profileId: pId);
      final transactions = await repository.getTransactions(profileId: pId, limit: 50);
      final subscriptions = await repository.getSubscriptions(profileId: pId);
      final pockets = await repository.getPockets(profileId: pId);
      final metrics = SafeToSpendService.calculate(wallets: wallets, subscriptions: subscriptions);
      emit(state.copyWith(
        activeProfile: active, profiles: profiles, wallets: wallets,
        transactions: transactions, subscriptions: subscriptions, pockets: pockets, metrics: metrics,
      ));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Gagal menghapus profil: $e'));
    }
  }

  Future<void> handleSetActiveProfile(SetActiveProfileEvent event, Emitter<FinanceState> emit) async {
    try {
      await repository.setActiveProfile(event.profileId);
      _initStreamListeners(event.profileId);
      final wallets = await repository.getWallets(profileId: event.profileId);
      final transactions = await repository.getTransactions(profileId: event.profileId, limit: 50);
      final subscriptions = await repository.getSubscriptions(profileId: event.profileId);
      final pockets = await repository.getPockets(profileId: event.profileId);
      final metrics = SafeToSpendService.calculate(wallets: wallets, subscriptions: subscriptions);
      final profiles = await repository.getProfiles();
      final active = profiles.where((p) => p.id == event.profileId).firstOrNull ?? state.activeProfile;
      emit(state.copyWith(
        activeProfile: active, profiles: profiles, wallets: wallets,
        transactions: transactions, subscriptions: subscriptions, pockets: pockets, metrics: metrics,
      ));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Gagal mengganti profil aktif: $e'));
    }
  }
}
