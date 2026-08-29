import 'package:flutter/foundation.dart';
import '../../data/database/app_database.dart';
import '../../domain/services/cashflow_analytics_service.dart';
import '../../domain/services/safe_to_spend_service.dart';
enum FinanceStatus { initial, loading, success, failure }

class FinanceState {
  final FinanceStatus status;
  final List<WalletEntry> wallets;
  final List<CategoryEntry> categories;
  final List<TransactionEntry> transactions;
  final List<SubscriptionEntry> subscriptions;
  final SafeToSpendMetrics metrics;
  final MonthlyCashflow monthlyCashflow;
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
    MonthlyCashflow? monthlyCashflow,
    this.errorMessage,
  })  : metrics = metrics ??
            SafeToSpendService.calculate(
              wallets: wallets,
              subscriptions: subscriptions,
              selectedWalletIds: safeToSpendWalletIds,
            ),
        monthlyCashflow = monthlyCashflow ??
            CashflowAnalyticsService.calculateMonthlyCashflow(transactions);

  FinanceState copyWith({
    FinanceStatus? status,
    List<WalletEntry>? wallets,
    List<CategoryEntry>? categories,
    List<TransactionEntry>? transactions,
    List<SubscriptionEntry>? subscriptions,
    Set<String>? safeToSpendWalletIds,
    bool clearSafeToSpendWallets = false,
    SafeToSpendMetrics? metrics,
    MonthlyCashflow? monthlyCashflow,
    String? errorMessage,
  }) {
    final nextWallets = wallets ?? this.wallets;
    final nextSubs = subscriptions ?? this.subscriptions;
    final nextTx = transactions ?? this.transactions;
    final nextWalletIds = clearSafeToSpendWallets
        ? null
        : (safeToSpendWalletIds ?? this.safeToSpendWalletIds);

    return FinanceState(
      status: status ?? this.status,
      wallets: nextWallets,
      categories: categories ?? this.categories,
      transactions: nextTx,
      subscriptions: nextSubs,
      safeToSpendWalletIds: nextWalletIds,
      metrics: metrics ??
          SafeToSpendService.calculate(
            wallets: nextWallets,
            subscriptions: nextSubs,
            selectedWalletIds: nextWalletIds,
          ),
      monthlyCashflow: monthlyCashflow ??
          CashflowAnalyticsService.calculateMonthlyCashflow(nextTx),
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FinanceState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          errorMessage == other.errorMessage &&
          metrics == other.metrics &&
          monthlyCashflow == other.monthlyCashflow &&
          setEquals(safeToSpendWalletIds, other.safeToSpendWalletIds) &&
          listEquals(wallets, other.wallets) &&
          listEquals(categories, other.categories) &&
          listEquals(transactions, other.transactions) &&
          listEquals(subscriptions, other.subscriptions);

  @override
  int get hashCode => Object.hash(
        status,
        errorMessage,
        metrics,
        wallets.length,
        transactions.length,
        subscriptions.length,
      );
}
