import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../data/database/app_database.dart';
import '../../presentation/theme/app_colors.dart';
import 'subscription_schedule_service.dart';

enum FinancialHealthStatus {
  comfortable, // >= 30% buffer (NeoChartreuse)
  caution,     // 0% - 30% buffer (Amber)
  deficit,     // <= 0% buffer (Rose/Red)
}

class SafeToSpendMetrics {
  final double totalRealBalance; // Grand total assets across all active wallets
  final double operationalBalance; // Total balance across selected operational wallets
  final double pendingBills;
  final int pendingBillsCount;
  final double safeToSpendMonthly;
  final double safeToSpendDaily;
  final int daysRemainingInMonth;
  final FinancialHealthStatus healthStatus;
  final Set<String> selectedWalletIds; // empty = all wallets
  final bool isAllWallets;
  final int selectedWalletsCount;

  const SafeToSpendMetrics({
    required this.totalRealBalance,
    double? operationalBalance,
    required this.pendingBills,
    this.pendingBillsCount = 0,
    required this.safeToSpendMonthly,
    required this.safeToSpendDaily,
    required this.daysRemainingInMonth,
    required this.healthStatus,
    this.selectedWalletIds = const {},
    this.isAllWallets = true,
    this.selectedWalletsCount = 0,
  }) : operationalBalance = operationalBalance ?? totalRealBalance;

  Color get statusColor => switch (healthStatus) {
    FinancialHealthStatus.comfortable => AppColors.statusComfortable,
    FinancialHealthStatus.caution => AppColors.statusCaution,
    FinancialHealthStatus.deficit => AppColors.statusDeficit,
  };

  String get statusLabel => switch (healthStatus) {
    FinancialHealthStatus.comfortable => 'Sangat Aman',
    FinancialHealthStatus.caution => 'Waspada',
    FinancialHealthStatus.deficit => 'Defisit Tagihan',
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SafeToSpendMetrics &&
          runtimeType == other.runtimeType &&
          totalRealBalance == other.totalRealBalance &&
          operationalBalance == other.operationalBalance &&
          pendingBills == other.pendingBills &&
          pendingBillsCount == other.pendingBillsCount &&
          safeToSpendMonthly == other.safeToSpendMonthly &&
          safeToSpendDaily == other.safeToSpendDaily &&
          daysRemainingInMonth == other.daysRemainingInMonth &&
          healthStatus == other.healthStatus &&
          isAllWallets == other.isAllWallets &&
          selectedWalletsCount == other.selectedWalletsCount &&
          setEquals(selectedWalletIds, other.selectedWalletIds);

  @override
  int get hashCode => Object.hash(
        totalRealBalance,
        operationalBalance,
        pendingBills,
        pendingBillsCount,
        safeToSpendMonthly,
        safeToSpendDaily,
        daysRemainingInMonth,
        healthStatus,
        isAllWallets,
        selectedWalletsCount,
      );
}

class SafeToSpendService {
  /// Pure deterministic calculation of Safe-to-Spend metrics
  static SafeToSpendMetrics calculate({
    required List<WalletEntry> wallets,
    required List<SubscriptionEntry> subscriptions,
    Set<String>? selectedWalletIds,
    DateTime? referenceDate,
    int cycleDay = 1,
  }) {
    final now = referenceDate ?? DateTime.now();

    final activeWallets = wallets.where((w) => !w.isDeleted).toList();
    final bool isAll = selectedWalletIds == null ||
        selectedWalletIds.isEmpty ||
        selectedWalletIds.length >= activeWallets.length;

    final targetWalletIds = isAll ? <String>{} : selectedWalletIds.toSet();

    // 1. Calculate Grand Total Assets (all active wallets) and Operational Balance (selected wallets)
    double grandTotalBalance = 0.0;
    double operationalBalance = 0.0;
    int count = 0;
    for (final wallet in activeWallets) {
      grandTotalBalance += wallet.balance;
      if (isAll || targetWalletIds.contains(wallet.id)) {
        operationalBalance += wallet.balance;
        count++;
      }
    }

    // 2. Calculate Pending Bills for the active budget cycle using explicit nextDueDate
    double pendingBills = 0.0;
    int pendingBillsCount = 0;

    for (final sub in subscriptions) {
      if (!SubscriptionScheduleService.isPendingInCycle(sub, referenceDate: now, cycleDay: cycleDay)) {
        continue;
      }
      if (isAll || targetWalletIds.contains(sub.walletId)) {
        pendingBills += sub.cost;
        pendingBillsCount++;
      }
    }
    // 3. Compute Monthly Safe-to-Spend
    final safeToSpendMonthly = operationalBalance - pendingBills;

    // 4. Days remaining in current budget cycle
    final int daysRemaining;
    if (cycleDay <= 1) {
      final lastDayOfMonth = DateTime(now.year, now.month + 1, 0).day;
      daysRemaining = (lastDayOfMonth - now.day) + 1;
    } else {
      final today = DateTime(now.year, now.month, now.day);
      final curMax = DateTime(now.year, now.month + 1, 0).day;
      final curCut = cycleDay > curMax ? curMax : cycleDay;
      final nxtMax = DateTime(now.year, now.month + 2, 0).day;
      final nxtCut = cycleDay > nxtMax ? nxtMax : cycleDay;
      final nextCutoff = now.day < curCut ? DateTime(now.year, now.month, curCut) : DateTime(now.year, now.month + 1, nxtCut);
      daysRemaining = nextCutoff.difference(today).inDays;
    }
    final divisor = daysRemaining > 0 ? daysRemaining : 1;

    // 5. Compute Daily Safe-to-Spend Allowance
    final safeToSpendDaily = safeToSpendMonthly > 0 ? (safeToSpendMonthly / divisor) : 0.0;

    // 6. Evaluate Financial Health Status based on operational balance
    final FinancialHealthStatus status;
    if (operationalBalance <= 0 || safeToSpendMonthly <= 0) {
      status = FinancialHealthStatus.deficit;
    } else {
      final ratio = safeToSpendMonthly / operationalBalance;
      if (ratio >= 0.30) {
        status = FinancialHealthStatus.comfortable;
      } else {
        status = FinancialHealthStatus.caution;
      }
    }

    return SafeToSpendMetrics(
      totalRealBalance: grandTotalBalance,
      operationalBalance: operationalBalance,
      pendingBills: pendingBills,
      pendingBillsCount: pendingBillsCount,
      safeToSpendMonthly: safeToSpendMonthly,
      safeToSpendDaily: safeToSpendDaily,
      daysRemainingInMonth: daysRemaining,
      healthStatus: status,
      selectedWalletIds: targetWalletIds,
      isAllWallets: isAll,
      selectedWalletsCount: isAll ? activeWallets.length : count,
    );
  }
}
