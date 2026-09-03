import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/finance_repository.dart';
import '../../domain/services/safe_to_spend_service.dart';
import 'finance_event.dart';
import 'finance_state.dart';

part 'handlers/transaction_handlers.dart';
part 'handlers/subscription_handlers.dart';
part 'handlers/wallet_handlers.dart';
part 'handlers/pocket_handlers.dart';
part 'handlers/profile_handlers.dart';

class _WalletsUpdated extends FinanceEvent {
  final List<WalletEntry> wallets;
  const _WalletsUpdated(this.wallets);
}

class _CategoriesUpdated extends FinanceEvent {
  final List<CategoryEntry> categories;
  const _CategoriesUpdated(this.categories);
}

class _TransactionsUpdated extends FinanceEvent {
  final List<TransactionEntry> transactions;
  const _TransactionsUpdated(this.transactions);
}

class _SubscriptionsUpdated extends FinanceEvent {
  final List<SubscriptionEntry> subscriptions;
  const _SubscriptionsUpdated(this.subscriptions);
}

class _PocketsUpdated extends FinanceEvent {
  final List<PocketEntry> pockets;
  const _PocketsUpdated(this.pockets);
}

class _ProfilesUpdated extends FinanceEvent {
  final List<ProfileEntry> profiles;
  const _ProfilesUpdated(this.profiles);
}

class FinanceBloc extends Bloc<FinanceEvent, FinanceState> {
  final FinanceRepository repository;

  StreamSubscription? _walletsSubscription;
  StreamSubscription? _categoriesSubscription;
  StreamSubscription? _transactionsSubscription;
  StreamSubscription? _subscriptionsSubscription;
  StreamSubscription? _pocketsSubscription;
  StreamSubscription? _profilesSubscription;

  FinanceBloc({required this.repository}) : super(FinanceState()) {
    on<LoadFinanceData>(_onLoadFinanceData);
    on<AddTransactionEvent>(handleAddTransaction);
    on<UpdateTransactionEvent>(handleUpdateTransaction);
    on<DeleteTransactionEvent>(handleDeleteTransaction);
    on<AddSubscriptionEvent>(handleAddSubscription);
    on<UpdateSubscriptionEvent>(handleUpdateSubscription);
    on<DeleteSubscriptionEvent>(handleDeleteSubscription);
    on<MarkSubscriptionPaidEvent>(handleMarkSubscriptionPaid);
    on<UpdateWalletBalanceEvent>(handleUpdateWalletBalance);
    on<AddWalletEvent>(handleAddWallet);
    on<DeleteWalletEvent>(handleDeleteWallet);
    on<BindWalletToPackageEvent>(handleBindWalletToPackage);
    on<UnbindPackageEvent>(handleUnbindPackage);
    on<AddPocketEvent>(handleAddPocket);
    on<UpdatePocketEvent>(handleUpdatePocket);
    on<DeletePocketEvent>(handleDeletePocket);
    on<TransferPocketFundsEvent>(handleTransferPocketFunds);
    on<AddProfileEvent>(handleAddProfile);
    on<UpdateProfileEvent>(handleUpdateProfile);
    on<DeleteProfileEvent>(handleDeleteProfile);
    on<SetActiveProfileEvent>(handleSetActiveProfile);
    on<SetSafeToSpendWalletsEvent>((event, emit) {
      final metrics = SafeToSpendService.calculate(
        wallets: state.wallets,
        subscriptions: state.subscriptions,
        selectedWalletIds: event.walletIds,
      );
      emit(state.copyWith(
        safeToSpendWalletIds: event.walletIds,
        clearSafeToSpendWallets: event.walletIds == null,
        metrics: metrics,
      ));
    });

    on<_WalletsUpdated>((event, emit) {
      Set<String>? safeWallets = state.safeToSpendWalletIds;
      if (safeWallets != null) {
        final activeIds = event.wallets.map((w) => w.id).toSet();
        safeWallets = safeWallets.intersection(activeIds);
      }
      final metrics = SafeToSpendService.calculate(
        wallets: event.wallets,
        subscriptions: state.subscriptions,
        selectedWalletIds: safeWallets,
      );
      emit(state.copyWith(
        wallets: event.wallets,
        safeToSpendWalletIds: safeWallets,
        metrics: metrics,
      ));
    });
    on<_CategoriesUpdated>((event, emit) => emit(state.copyWith(categories: event.categories)));
    on<_TransactionsUpdated>((event, emit) => emit(state.copyWith(transactions: event.transactions)));
    on<_SubscriptionsUpdated>((event, emit) {
      final metrics = SafeToSpendService.calculate(
        wallets: state.wallets,
        subscriptions: event.subscriptions,
        selectedWalletIds: state.safeToSpendWalletIds,
      );
      emit(state.copyWith(subscriptions: event.subscriptions, metrics: metrics));
    });
    on<_PocketsUpdated>((event, emit) => emit(state.copyWith(pockets: event.pockets)));
    on<_ProfilesUpdated>((event, emit) {
      final active = event.profiles.where((p) => p.isActive).firstOrNull ?? event.profiles.firstOrNull;
      emit(state.copyWith(profiles: event.profiles, activeProfile: active));
    });

    _initStreamListeners();
  }

  void _initStreamListeners() {
    _walletsSubscription = repository.watchWallets().listen((w) => add(_WalletsUpdated(w)));
    _categoriesSubscription = repository.watchCategories().listen((c) => add(_CategoriesUpdated(c)));
    _transactionsSubscription = repository.watchRecentTransactions(limit: 50).listen((t) => add(_TransactionsUpdated(t)));
    _subscriptionsSubscription = repository.watchActiveSubscriptions().listen((s) => add(_SubscriptionsUpdated(s)));
    _pocketsSubscription = repository.watchPockets().listen((p) => add(_PocketsUpdated(p)));
    _profilesSubscription = repository.watchProfiles().listen((pr) => add(_ProfilesUpdated(pr)));
  }

  Future<void> _onLoadFinanceData(LoadFinanceData event, Emitter<FinanceState> emit) async {
    emit(state.copyWith(status: FinanceStatus.loading));
    try {
      final wallets = await repository.getWallets();
      final categories = await repository.getCategories();
      final subscriptions = await repository.getSubscriptions();
      final transactions = await repository.getTransactions(limit: 50);
      final pockets = await repository.getPockets();
      final profiles = await repository.getProfiles();
      final activeProfile = profiles.where((p) => p.isActive).firstOrNull ?? profiles.firstOrNull;

      final metrics = SafeToSpendService.calculate(
        wallets: wallets,
        subscriptions: subscriptions,
        selectedWalletIds: state.safeToSpendWalletIds,
      );

      emit(state.copyWith(
        status: FinanceStatus.success,
        wallets: wallets,
        categories: categories,
        subscriptions: subscriptions,
        transactions: transactions,
        pockets: pockets,
        profiles: profiles,
        activeProfile: activeProfile,
        metrics: metrics,
      ));
    } catch (e) {
      emit(state.copyWith(status: FinanceStatus.failure, errorMessage: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _walletsSubscription?.cancel();
    _categoriesSubscription?.cancel();
    _transactionsSubscription?.cancel();
    _subscriptionsSubscription?.cancel();
    _pocketsSubscription?.cancel();
    _profilesSubscription?.cancel();
    return super.close();
  }
}
