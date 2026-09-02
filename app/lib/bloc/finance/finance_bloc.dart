import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/finance_repository.dart';
import '../../domain/services/safe_to_spend_service.dart';
import 'finance_event.dart';
import 'finance_state.dart';

// Internal stream events
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
    on<AddTransactionEvent>(_onAddTransaction);
    on<UpdateTransactionEvent>(_onUpdateTransaction);
    on<DeleteTransactionEvent>(_onDeleteTransaction);
    on<AddSubscriptionEvent>(_onAddSubscription);
    on<UpdateSubscriptionEvent>(_onUpdateSubscription);
    on<DeleteSubscriptionEvent>(_onDeleteSubscription);
    on<MarkSubscriptionPaidEvent>(_onMarkSubscriptionPaid);
    on<UpdateWalletBalanceEvent>(_onUpdateWalletBalance);
    on<AddWalletEvent>(_onAddWallet);
    on<DeleteWalletEvent>(_onDeleteWallet);
    on<BindWalletToPackageEvent>(_onBindWalletToPackage);
    on<UnbindPackageEvent>(_onUnbindPackage);
    on<AddPocketEvent>(_onAddPocket);
    on<UpdatePocketEvent>(_onUpdatePocket);
    on<DeletePocketEvent>(_onDeletePocket);
    on<TransferPocketFundsEvent>(_onTransferPocketFunds);
    on<AddProfileEvent>(_onAddProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<DeleteProfileEvent>(_onDeleteProfile);
    on<SetActiveProfileEvent>(_onSetActiveProfile);
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

    // Internal reactive stream event handlers
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
    on<_CategoriesUpdated>((event, emit) {
      emit(state.copyWith(categories: event.categories));
    });
    on<_TransactionsUpdated>((event, emit) {
      emit(state.copyWith(transactions: event.transactions));
    });

    on<_SubscriptionsUpdated>((event, emit) {
      final metrics = SafeToSpendService.calculate(
        wallets: state.wallets,
        subscriptions: event.subscriptions,
        selectedWalletIds: state.safeToSpendWalletIds,
      );
      emit(state.copyWith(subscriptions: event.subscriptions, metrics: metrics));
    });
    on<_PocketsUpdated>((event, emit) {
      emit(state.copyWith(pockets: event.pockets));
    });
    on<_ProfilesUpdated>((event, emit) {
      final active = event.profiles.where((p) => p.isActive).firstOrNull ??
          event.profiles.firstOrNull;
      emit(state.copyWith(
        profiles: event.profiles,
        activeProfile: active,
      ));
    });
    _initStreamListeners();
  }

  void _initStreamListeners() {
    _walletsSubscription = repository.watchWallets().listen((wallets) {
      add(_WalletsUpdated(wallets));
    });

    _categoriesSubscription = repository.watchCategories().listen((categories) {
      add(_CategoriesUpdated(categories));
    });

    _transactionsSubscription = repository.watchRecentTransactions(limit: 50).listen((transactions) {
      add(_TransactionsUpdated(transactions));
    });

    _subscriptionsSubscription = repository.watchActiveSubscriptions().listen((subscriptions) {
      add(_SubscriptionsUpdated(subscriptions));
    });
    _pocketsSubscription = repository.watchPockets().listen((pockets) {
      add(_PocketsUpdated(pockets));
    });
    _profilesSubscription = repository.watchProfiles().listen((profiles) {
      add(_ProfilesUpdated(profiles));
    });
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

  Future<void> _onAddTransaction(AddTransactionEvent event, Emitter<FinanceState> emit) async {
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

  Future<void> _onUpdateTransaction(UpdateTransactionEvent event, Emitter<FinanceState> emit) async {
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

  Future<void> _onDeleteTransaction(DeleteTransactionEvent event, Emitter<FinanceState> emit) async {
    try {
      await repository.deleteTransaction(event.transactionId);
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Gagal hapus transaksi: $e'));
    }
  }

  Future<void> _onAddSubscription(AddSubscriptionEvent event, Emitter<FinanceState> emit) async {
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

  Future<void> _onUpdateSubscription(UpdateSubscriptionEvent event, Emitter<FinanceState> emit) async {
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

  Future<void> _onDeleteSubscription(DeleteSubscriptionEvent event, Emitter<FinanceState> emit) async {
    try {
      await repository.deleteSubscription(event.subscriptionId);
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Gagal hapus langganan: $e'));
    }
  }

  Future<void> _onMarkSubscriptionPaid(MarkSubscriptionPaidEvent event, Emitter<FinanceState> emit) async {
    try {
      await repository.markSubscriptionAsPaid(event.subscriptionId);
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Gagal menandai lunas: $e'));
    }
  }

  Future<void> _onUpdateWalletBalance(UpdateWalletBalanceEvent event, Emitter<FinanceState> emit) async {
    try {
      await repository.updateWalletBalance(event.walletId, event.newBalance);
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Gagal update saldo: $e'));
    }
  }

  Future<void> _onAddWallet(AddWalletEvent event, Emitter<FinanceState> emit) async {
    try {
      await repository.addWallet(
        name: event.name,
        type: event.type,
        initialBalance: event.initialBalance,
        colorHex: event.colorHex,
        iconName: event.iconName,
        boundPackageName: event.boundPackageName,
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Gagal menambah rekening: $e'));
    }
  }
  Future<void> _onDeleteWallet(DeleteWalletEvent event, Emitter<FinanceState> emit) async {
    try {
      await repository.deleteWallet(event.walletId);
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Gagal menghapus rekening: $e'));
    }
  }


  Future<void> _onBindWalletToPackage(BindWalletToPackageEvent event, Emitter<FinanceState> emit) async {
    try {
      await repository.bindWalletToPackage(
        walletId: event.walletId,
        packageName: event.packageName,
        isEnabled: event.isEnabled,
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Gagal menghubungkan aplikasi: $e'));
    }
  }

  Future<void> _onUnbindPackage(UnbindPackageEvent event, Emitter<FinanceState> emit) async {
    try {
      await repository.unbindPackage(event.packageName);
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Gagal memutuskan aplikasi: $e'));
    }
  }

  Future<void> _onAddPocket(AddPocketEvent event, Emitter<FinanceState> emit) async {
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

  Future<void> _onUpdatePocket(UpdatePocketEvent event, Emitter<FinanceState> emit) async {
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

  Future<void> _onDeletePocket(DeletePocketEvent event, Emitter<FinanceState> emit) async {
    try {
      await repository.deletePocket(event.pocketId);
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Gagal menghapus kantong: $e'));
    }
  }

  Future<void> _onTransferPocketFunds(TransferPocketFundsEvent event, Emitter<FinanceState> emit) async {
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

  Future<void> _onAddProfile(AddProfileEvent event, Emitter<FinanceState> emit) async {
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

  Future<void> _onUpdateProfile(UpdateProfileEvent event, Emitter<FinanceState> emit) async {
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

  Future<void> _onDeleteProfile(DeleteProfileEvent event, Emitter<FinanceState> emit) async {
    try {
      await repository.deleteProfile(event.profileId);
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Gagal menghapus profil: $e'));
    }
  }

  Future<void> _onSetActiveProfile(SetActiveProfileEvent event, Emitter<FinanceState> emit) async {
    try {
      await repository.setActiveProfile(event.profileId);
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Gagal mengganti profil aktif: $e'));
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
