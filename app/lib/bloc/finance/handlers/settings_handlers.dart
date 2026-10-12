part of '../finance_bloc.dart';

extension SettingsBlocHandlers on FinanceBloc {
  void handleSetSafeToSpendWallets(
    SetSafeToSpendWalletsEvent event,
    Emitter<FinanceState> emit,
  ) {
    _profileStsWallets[state.profile.id] = event.walletIds;
    final metrics = SafeToSpendService.calculate(
      wallets: state.wallets,
      subscriptions: state.subscriptions,
      selectedWalletIds: event.walletIds,
      cycleDay: state.budgetCycleDay,
    );
    emit(state.copyWith(
      safeToSpendWalletIds: event.walletIds,
      clearSafeToSpendWallets: event.walletIds == null,
      metrics: metrics,
    ));
  }

  void handleSetBudgetCycleDay(
    SetBudgetCycleDayEvent event,
    Emitter<FinanceState> emit,
  ) {
    final clamped = event.cycleDay.clamp(1, 31);
    _profileCycleDays[state.profile.id] = clamped;
    final metrics = SafeToSpendService.calculate(
      wallets: state.wallets,
      subscriptions: state.subscriptions,
      selectedWalletIds: state.safeToSpendWalletIds,
      cycleDay: clamped,
    );
    emit(state.copyWith(budgetCycleDay: clamped, metrics: metrics));
  }

  void handleToggleBalanceVisibility(
    ToggleBalanceVisibilityEvent event,
    Emitter<FinanceState> emit,
  ) {
    final nextHidden = event.hidden ?? !state.isBalanceHidden;
    emit(state.copyWith(isBalanceHidden: nextHidden));
  }

  void handleSetHighRefreshRate(SetHighRefreshRateEvent event, Emitter<FinanceState> emit) {
    NotificationBridge.setHighRefreshRate(event.enabled);
    emit(state.copyWith(isHighRefreshRate: event.enabled));
  }

  void handleSetExchangeRate(
    SetExchangeRateEvent event,
    Emitter<FinanceState> emit,
  ) {
    if (event.rateToIdr <= 0) return;
    AppCurrency.setRate(event.currencyCode, event.rateToIdr);
    emit(state.copyWith(exchangeRateVersion: state.exchangeRateVersion + 1));
  }

  Future<void> handleSyncExchangeRates(
    SyncExchangeRatesEvent event,
    Emitter<FinanceState> emit,
  ) async {
    final ok = await AppCurrency.syncLiveRates();
    if (ok) emit(state.copyWith(exchangeRateVersion: state.exchangeRateVersion + 1));
  }

  Future<void> handleAddCategory(
    AddCategoryEvent event,
    Emitter<FinanceState> emit,
  ) async {
    try {
      await repository.addCategory(
        name: event.name,
        type: event.type,
        iconName: event.iconName,
        colorHex: event.colorHex,
      );
      final categories = await repository.getCategories();
      emit(state.copyWith(categories: categories));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Gagal menambah kategori: $e'));
    }
  }

  Future<void> handleDeleteCategory(
    DeleteCategoryEvent event,
    Emitter<FinanceState> emit,
  ) async {
    try {
      await repository.deleteCategory(event.categoryId);
      final categories = await repository.getCategories();
      emit(state.copyWith(categories: categories));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Gagal menghapus kategori: $e'));
    }
  }

  Future<void> handleClearProfileTransactions(
    ClearProfileTransactionsEvent event,
    Emitter<FinanceState> emit,
  ) async {
    try {
      final targetProfileId = event.profileId ?? state.profile.id;
      await repository.clearProfileTransactions(targetProfileId);
      final wallets = await repository.getWallets(profileId: targetProfileId);
      final transactions = await repository.getTransactions(profileId: targetProfileId, limit: 50);
      final metrics = SafeToSpendService.calculate(
        wallets: wallets,
        subscriptions: state.subscriptions,
        selectedWalletIds: state.safeToSpendWalletIds,
        cycleDay: state.budgetCycleDay,
      );
      emit(state.copyWith(
        wallets: wallets,
        transactions: transactions,
        metrics: metrics,
      ));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Gagal membersihkan transaksi: $e'));
    }
  }
}
