import 'package:flutter/foundation.dart';
import '../../data/database/app_database.dart';
import '../../domain/services/cashflow_analytics_service.dart';
import '../../domain/services/safe_to_spend_service.dart';
import '../../domain/services/financial_health_service.dart';
enum FinanceStatus { initial, loading, success, failure }

class FinanceState {
  final FinanceStatus status;
  final List<WalletEntry> wallets;
  final List<CategoryEntry> categories;
  final List<TransactionEntry> transactions;
  final List<SubscriptionEntry> subscriptions;
  final List<PocketEntry> pockets;
  final List<ProfileEntry> profiles;
  final ProfileEntry? activeProfile;
  final SafeToSpendMetrics metrics;
  final MonthlyCashflow monthlyCashflow;
  final FinancialHealthReport healthReport;
  final Set<String>? safeToSpendWalletIds; // null = all wallets
  final String? errorMessage;

  FinanceState({
    this.status = FinanceStatus.initial,
    this.wallets = const [],
    this.categories = const [],
    this.transactions = const [],
    this.subscriptions = const [],
    this.pockets = const [],
    this.profiles = const [],
    this.activeProfile,
    this.safeToSpendWalletIds,
    SafeToSpendMetrics? metrics,
    MonthlyCashflow? monthlyCashflow,
    FinancialHealthReport? healthReport,
    this.errorMessage,
  })  : metrics = metrics ??
            SafeToSpendService.calculate(
              wallets: wallets,
              subscriptions: subscriptions,
              selectedWalletIds: safeToSpendWalletIds,
            ),
        monthlyCashflow = monthlyCashflow ??
            CashflowAnalyticsService.calculateMonthlyCashflow(transactions),
        healthReport = healthReport ??
            FinancialHealthService.evaluate(
              wallets: wallets,
              pockets: pockets,
              subscriptions: subscriptions,
              monthlyCashflow: monthlyCashflow ??
                  CashflowAnalyticsService.calculateMonthlyCashflow(transactions),
              safeToSpend: metrics ??
                  SafeToSpendService.calculate(
                    wallets: wallets,
                    subscriptions: subscriptions,
                    selectedWalletIds: safeToSpendWalletIds,
                  ),
            );

  static final ProfileEntry _defaultFallback = ProfileEntry(
    id: 'default_fallback',
    username: 'David',
    fullName: 'David Arrozaqi',
    email: 'david@fibonanci.app',
    phone: '+62 812-3456-7890',
    avatarPath: 'preset:avatar_1',
    occupation: 'Software Engineer',
    bio: 'Living lean, building offline financial freedom.',
    currency: 'IDR',
    monthlyIncomeTarget: 15000000.0,
    isActive: true,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    isSynced: false,
    isDeleted: false,
  );

  ProfileEntry get profile =>
      activeProfile ??
      (profiles.where((p) => p.isActive).firstOrNull ??
          (profiles.isNotEmpty ? profiles.first : _defaultFallback));

  FinanceState copyWith({
    FinanceStatus? status,
    List<WalletEntry>? wallets,
    List<CategoryEntry>? categories,
    List<TransactionEntry>? transactions,
    List<SubscriptionEntry>? subscriptions,
    List<PocketEntry>? pockets,
    List<ProfileEntry>? profiles,
    ProfileEntry? activeProfile,
    bool clearActiveProfile = false,
    Set<String>? safeToSpendWalletIds,
    bool clearSafeToSpendWallets = false,
    SafeToSpendMetrics? metrics,
    MonthlyCashflow? monthlyCashflow,
    FinancialHealthReport? healthReport,
    String? errorMessage,
  }) {
    final nextWallets = wallets ?? this.wallets;
    final nextSubs = subscriptions ?? this.subscriptions;
    final nextTx = transactions ?? this.transactions;
    final nextPockets = pockets ?? this.pockets;
    final nextProfiles = profiles ?? this.profiles;
    final nextActiveProfile = clearActiveProfile
        ? null
        : (activeProfile ?? this.activeProfile);
    final nextWalletIds = clearSafeToSpendWallets
        ? null
        : (safeToSpendWalletIds ?? this.safeToSpendWalletIds);

    return FinanceState(
      status: status ?? this.status,
      wallets: nextWallets,
      categories: categories ?? this.categories,
      transactions: nextTx,
      subscriptions: nextSubs,
      pockets: nextPockets,
      profiles: nextProfiles,
      activeProfile: nextActiveProfile,
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
      healthReport: healthReport ??
          FinancialHealthService.evaluate(
            wallets: nextWallets,
            pockets: nextPockets,
            subscriptions: nextSubs,
            monthlyCashflow: monthlyCashflow ??
                CashflowAnalyticsService.calculateMonthlyCashflow(nextTx),
            safeToSpend: metrics ??
                SafeToSpendService.calculate(
                  wallets: nextWallets,
                  subscriptions: nextSubs,
                  selectedWalletIds: nextWalletIds,
                ),
          ),
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
          listEquals(subscriptions, other.subscriptions) &&
          listEquals(pockets, other.pockets) &&
          listEquals(profiles, other.profiles) &&
          activeProfile?.id == other.activeProfile?.id &&
          healthReport.overallScore == other.healthReport.overallScore;

  @override
  int get hashCode => Object.hash(
        status,
        errorMessage,
        metrics,
        wallets.length,
        transactions.length,
        subscriptions.length,
        pockets.length,
        profiles.length,
        activeProfile?.id,
        healthReport.overallScore,
      );
}
