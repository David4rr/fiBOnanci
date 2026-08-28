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
  final String? errorMessage;

  FinanceState({
    this.status = FinanceStatus.initial,
    this.wallets = const [],
    this.categories = const [],
    this.transactions = const [],
    this.subscriptions = const [],
    SafeToSpendMetrics? metrics,
    this.errorMessage,
  }) : metrics = metrics ??
            SafeToSpendService.calculate(
              wallets: wallets,
              subscriptions: subscriptions,
            );

  FinanceState copyWith({
    FinanceStatus? status,
    List<WalletEntry>? wallets,
    List<CategoryEntry>? categories,
    List<TransactionEntry>? transactions,
    List<SubscriptionEntry>? subscriptions,
    SafeToSpendMetrics? metrics,
    String? errorMessage,
  }) {
    final nextWallets = wallets ?? this.wallets;
    final nextSubs = subscriptions ?? this.subscriptions;

    return FinanceState(
      status: status ?? this.status,
      wallets: nextWallets,
      categories: categories ?? this.categories,
      transactions: transactions ?? this.transactions,
      subscriptions: nextSubs,
      metrics: metrics ??
          SafeToSpendService.calculate(
            wallets: nextWallets,
            subscriptions: nextSubs,
          ),
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
