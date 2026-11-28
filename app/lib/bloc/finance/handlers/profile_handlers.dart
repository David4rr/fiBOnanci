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
      final pId = (event.profileId.isNotEmpty && event.profileId != 'default_fallback')
          ? event.profileId
          : (state.activeProfile?.id ?? 'default_profile_1');
      await repository.updateProfile(
        profileId: pId,
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
      _profileCycleDays.remove(event.profileId);
      _profileStsWallets.remove(event.profileId);
      ProfilePreferencesStorage.removeProfile(event.profileId);
      await repository.deleteProfile(event.profileId);
      final profiles = await repository.getProfiles();
      final active = profiles.where((p) => p.isActive).firstOrNull ?? profiles.firstOrNull;
      final pId = active?.id ?? 'default_profile_1';
      _initStreamListeners(pId);
      final wallets = await repository.getWallets(profileId: pId);
      final transactions = await repository.getTransactions(profileId: pId, limit: 50);
      final subscriptions = await repository.getSubscriptions(profileId: pId);
      final pockets = await repository.getPockets(profileId: pId);
      final cycleDay = _profileCycleDays[pId] ?? ProfilePreferencesStorage.getBudgetCycleDay(pId);
      final stsWallets = _profileStsWallets[pId] ?? ProfilePreferencesStorage.getSafeToSpendWallets(pId);
      final metrics = SafeToSpendService.calculate(wallets: wallets, subscriptions: subscriptions, selectedWalletIds: stsWallets, cycleDay: cycleDay);
      emit(state.copyWith(
        activeProfile: active, profiles: profiles, wallets: wallets,
        transactions: transactions, subscriptions: subscriptions, pockets: pockets,
        budgetCycleDay: cycleDay, safeToSpendWalletIds: stsWallets, clearSafeToSpendWallets: stsWallets == null, metrics: metrics,
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
      final cycleDay = _profileCycleDays[event.profileId] ?? ProfilePreferencesStorage.getBudgetCycleDay(event.profileId);
      final stsWallets = _profileStsWallets[event.profileId] ?? ProfilePreferencesStorage.getSafeToSpendWallets(event.profileId);
      final metrics = SafeToSpendService.calculate(wallets: wallets, subscriptions: subscriptions, selectedWalletIds: stsWallets, cycleDay: cycleDay);
      final profiles = await repository.getProfiles();
      final active = profiles.where((p) => p.id == event.profileId).firstOrNull ?? state.activeProfile;
      emit(state.copyWith(
        activeProfile: active, profiles: profiles, wallets: wallets,
        transactions: transactions, subscriptions: subscriptions, pockets: pockets,
        budgetCycleDay: cycleDay, safeToSpendWalletIds: stsWallets, clearSafeToSpendWallets: stsWallets == null, metrics: metrics,
      ));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Gagal mengganti profil aktif: $e'));
    }
  }

  Future<void> handleOnboardNewProfile(
    OnboardNewProfileEvent event,
    Emitter<FinanceState> emit,
  ) async {
    try {
      final newProfileId = await repository.addProfile(
        username: event.username,
        fullName: event.fullName,
        occupation: event.occupation,
        monthlyIncomeTarget: event.monthlyIncomeTarget,
        avatarPath: event.avatarPath,
        currency: event.currency,
        setActive: true,
      );
      await repository.addWallet(
        name: event.walletName,
        type: event.walletType,
        initialBalance: event.initialBalance,
        colorHex: event.colorHex,
        iconName: event.iconName,
        profileId: newProfileId,
        createInitialTransaction: event.createInitialTransaction,
      );
      _initStreamListeners(newProfileId);
      final profiles = await repository.getProfiles();
      final active = profiles.where((p) => p.id == newProfileId).firstOrNull;
      final wallets = await repository.getWallets(profileId: newProfileId);
      final transactions = await repository.getTransactions(profileId: newProfileId, limit: 5000);
      final subscriptions = await repository.getSubscriptions(profileId: newProfileId);
      final pockets = await repository.getPockets(profileId: newProfileId);
      final metrics = SafeToSpendService.calculate(wallets: wallets, subscriptions: subscriptions);
      emit(state.copyWith(
        activeProfile: active,
        profiles: profiles,
        wallets: wallets,
        transactions: transactions,
        subscriptions: subscriptions,
        pockets: pockets,
        budgetCycleDay: 1,
        clearSafeToSpendWallets: true,
        metrics: metrics,
      ));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Gagal membuat profil baru: $e'));
    }
  }
}
