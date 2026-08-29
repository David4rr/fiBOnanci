import '../../data/database/app_database.dart';
import '../../domain/services/safe_to_spend_service.dart';

enum FinanceStatus { initial, loading, success, failure }

class FinanceState {
  final FinanceStatus status;
  final List<WalletEntry> wallets;
  final List<CategoryEntry> categories;
  final List<TransactionEntry> transactions;
  final List<SubscriptionEntry> subscriptions;
  final SafeToSpendMetrics metrics;
  final Set<String>? safeToSpendWalletIds; // null = all wallets
  final String? errorMessage;

  FinanceState({
    this.status = FinanceStatus.initial,
    this.wallets = const [],
    this.categories = const [],
    this.transactions = const [],
    this.subscriptions = const [],
    this.safeToSpendWalletIds,
    SafeToSpendMetrics? metrics,
    this.errorMessage,
  }) : metrics = metrics ??
            SafeToSpendService.calculate(
              wallets: wallets,
              subscriptions: subscriptions,
              selectedWalletIds: safeToSpendWalletIds,
            );

  FinanceState copyWith({
    FinanceStatus? status,
    List<WalletEntry>? wallets,
    List<CategoryEntry>? categories,
    List<TransactionEntry>? transactions,
    List<SubscriptionEntry>? subscriptions,
    Set<String>? safeToSpendWalletIds,
    bool clearSafeToSpendWallets = false,
    SafeToSpendMetrics? metrics,
    String? errorMessage,
  }) {
    final nextWallets = wallets ?? this.wallets;
    final nextSubs = subscriptions ?? this.subscriptions;
    final nextWalletIds = clearSafeToSpendWallets
        ? null
        : (safeToSpendWalletIds ?? this.safeToSpendWalletIds);

    return FinanceState(
      status: status ?? this.status,
      wallets: nextWallets,
      categories: categories ?? this.categories,
      transactions: transactions ?? this.transactions,
      subscriptions: nextSubs,
      safeToSpendWalletIds: nextWalletIds,
      metrics: metrics ??
          SafeToSpendService.calculate(
            wallets: nextWallets,
            subscriptions: nextSubs,
            selectedWalletIds: nextWalletIds,
          ),
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
