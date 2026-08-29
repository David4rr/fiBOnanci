import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../data/database/app_database.dart';
import '../../presentation/theme/app_colors.dart';

enum FinancialHealthStatus {
  comfortable, // >= 30% buffer (NeoChartreuse)
  caution,     // 0% - 30% buffer (Amber)
  deficit,     // <= 0% buffer (Rose/Red)
}

class SafeToSpendMetrics {
  final double totalRealBalance;
  final double pendingBills;
  final double safeToSpendMonthly;
  final double safeToSpendDaily;
  final int daysRemainingInMonth;
  final FinancialHealthStatus healthStatus;
  final Set<String> selectedWalletIds; // empty = all wallets
  final bool isAllWallets;
  final int selectedWalletsCount;

  const SafeToSpendMetrics({
    required this.totalRealBalance,
    required this.pendingBills,
    required this.safeToSpendMonthly,
    required this.safeToSpendDaily,
    required this.daysRemainingInMonth,
    required this.healthStatus,
    this.selectedWalletIds = const {},
    this.isAllWallets = true,
    this.selectedWalletsCount = 0,
  });

  Color get statusColor {
    switch (healthStatus) {
      case FinancialHealthStatus.comfortable:
        return AppColors.statusComfortable;
      case FinancialHealthStatus.caution:
        return AppColors.statusCaution;
      case FinancialHealthStatus.deficit:
        return AppColors.statusDeficit;
    }
  }

  String get statusLabel {
    switch (healthStatus) {
      case FinancialHealthStatus.comfortable:
        return 'Sangat Aman';
      case FinancialHealthStatus.caution:
        return 'Waspada';
      case FinancialHealthStatus.deficit:
        return 'Defisit Tagihan';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SafeToSpendMetrics &&
          runtimeType == other.runtimeType &&
          totalRealBalance == other.totalRealBalance &&
          pendingBills == other.pendingBills &&
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
        pendingBills,
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
  }) {
    final now = referenceDate ?? DateTime.now();

    final activeWallets = wallets.where((w) => !w.isDeleted).toList();
    final bool isAll = selectedWalletIds == null ||
        selectedWalletIds.isEmpty ||
        selectedWalletIds.length >= activeWallets.length;

    final targetWalletIds = isAll
        ? <String>{}
        : selectedWalletIds.toSet();

    // 1. Calculate Real Balance across selected or all active wallets
    double totalBalance = 0.0;
    int count = 0;
    for (final wallet in activeWallets) {
      if (isAll || targetWalletIds.contains(wallet.id)) {
        totalBalance += wallet.balance;
        count++;
      }
    }

    // 2. Calculate Pending Bills for the current month
    // A subscription is pending if active, not deleted, and due this month but not yet paid.
    // If specific wallets are selected, only bills assigned to those wallets are deducted.
    double pendingBills = 0.0;
    final currentMonthStart = DateTime(now.year, now.month, 1);

    for (final sub in subscriptions) {
      if (sub.isDeleted || sub.status != 'active') continue;

      final lastPaid = sub.lastPaidDate;
      final isPaidThisCycle = lastPaid != null && lastPaid.isAfter(currentMonthStart);

      if (!isPaidThisCycle) {
        if (isAll || targetWalletIds.contains(sub.walletId)) {
          pendingBills += sub.cost;
        }
      }
    }
    // 3. Compute Monthly Safe-to-Spend
    final safeToSpendMonthly = totalBalance - pendingBills;

    // 4. Days remaining in current month
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysRemaining = (lastDayOfMonth - now.day) + 1;
    final divisor = daysRemaining > 0 ? daysRemaining : 1;

    // 5. Compute Daily Safe-to-Spend Allowance
    final safeToSpendDaily = safeToSpendMonthly > 0 ? (safeToSpendMonthly / divisor) : 0.0;

    // 6. Evaluate Financial Health Status
    final FinancialHealthStatus status;
    if (totalBalance <= 0 || safeToSpendMonthly <= 0) {
      status = FinancialHealthStatus.deficit;
    } else {
      final ratio = safeToSpendMonthly / totalBalance;
      if (ratio >= 0.30) {
        status = FinancialHealthStatus.comfortable;
      } else {
        status = FinancialHealthStatus.caution;
      }
    }

    return SafeToSpendMetrics(
      totalRealBalance: totalBalance,
      pendingBills: pendingBills,
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
