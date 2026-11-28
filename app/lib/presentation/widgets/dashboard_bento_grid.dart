import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/database/app_database.dart';
import '../../domain/services/cashflow_calendar_service.dart';
import '../../domain/services/daily_pacing_nudge_service.dart';
import '../../domain/services/safe_to_spend_service.dart';
import '../../core/l10n/locale_notifier.dart';
import '../modals/dashboard_modals.dart';
import '../modals/safe_to_spend_modal.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'bento_folder_card.dart';
import 'common/common_widgets.dart';

/// 2x2 Bento Folder Grid for Dashboard.
/// Displays Safe-to-Spend, Total Real Balance, Committed Bills, and Daily Pace.
class DashboardBentoGrid extends StatelessWidget {
  final SafeToSpendMetrics metrics;
  final List<WalletEntry> wallets;
  final List<SubscriptionEntry> subscriptions;
  final NumberFormat currencyFormatter;
  final VoidCallback onNavigateToWallets;
  final VoidCallback onNavigateToSubscriptions;
  final bool isBalanceHidden;
  final double todayExpense;
  final int streak;
  final DateTime? referenceDate;
  final List<TransactionEntry>? transactions;

  const DashboardBentoGrid({
    super.key,
    required this.metrics,
    required this.wallets,
    required this.subscriptions,
    required this.currencyFormatter,
    required this.onNavigateToWallets,
    required this.onNavigateToSubscriptions,
    this.isBalanceHidden = false,
    this.todayExpense = 0.0,
    this.streak = 0,
    this.referenceDate,
    this.transactions,
  });

  String _fmt(double amount) => currencyFormatter.format(amount);

  Widget _countingMetric(double value) {
    return AnimatedCountingText(
      value: value,
      formatter: _fmt,
      animateOnMount: false,
      respectPrivacyMask: false,
      duration: const Duration(milliseconds: 380),
      style: AppTypography.cardMetricValue.copyWith(color: AppColors.textDarkPrimary),
    );
  }

  int _resolveStreak() {
    if (streak > 0) return streak;
    if (transactions == null || transactions!.isEmpty) return 0;
    return CashflowCalendarService.calculateCurrentStreak(
      transactions: transactions!,
      dailySafePace: metrics.safeToSpendDaily,
      referenceDate: referenceDate,
    );
  }

  String _dailyPaceSubtitle(BuildContext context) {
    return DailyPacingNudgeService.getCompactSubtitle(
      metrics: metrics,
      todayExpense: todayExpense,
      referenceDate: referenceDate,
      streak: _resolveStreak(),
      localeCode: AppL10n.of(context).localeName,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
      child: Column(
        children: [
          Row(
            children: [
              // Card 1: Safe-to-Spend (TAP -> Opens Formula Breakdown)
              Expanded(
                child: BentoFolderCard(
                  backgroundColor: AppColors.neoChartreuse,
                  iconData: Icons.shield_outlined,
                  title: _fmt(metrics.safeToSpendMonthly),
                  titleWidget: _countingMetric(metrics.safeToSpendMonthly),
                  isBalanceHidden: isBalanceHidden,
                  subtitle: metrics.isAllWallets
                      ? 'Safe to Spend'
                      : l10n.dashboardSafeToSpendFiltered(metrics.selectedWalletsCount),
                  trailingIcon: const Icon(Icons.info_outline, color: AppColors.textDarkSecondary, size: 13),
                  onTap: () => SafeToSpendModal.show(context, wallets),
                ),
              ),
              const SizedBox(width: 14),

              // Card 2: Total Real Balance / Total Aset (TAP -> Switches to Wallets Tab)
              Expanded(
                child: BentoFolderCard(
                  backgroundColor: AppColors.neoMint,
                  iconData: Icons.account_balance_wallet_outlined,
                  title: _fmt(metrics.totalRealBalance),
                  titleWidget: _countingMetric(metrics.totalRealBalance),
                  isBalanceHidden: isBalanceHidden,
                  subtitle: l10n.dashboardRealAccounts(wallets.length),
                  trailingIcon: const Icon(Icons.chevron_right, color: AppColors.textDarkSecondary, size: 14),
                  onTap: onNavigateToWallets,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              // Card 3: Pending Bills (TAP -> Navigates to Billing & Subscriptions Tab)
              Expanded(
                child: BentoFolderCard(
                  backgroundColor: AppColors.neoCoral,
                  iconData: Icons.receipt_long_outlined,
                  title: _fmt(metrics.pendingBills),
                  titleWidget: _countingMetric(metrics.pendingBills),
                  isBalanceHidden: isBalanceHidden,
                  subtitle: l10n.dashboardBillsThisMonth(metrics.pendingBillsCount),
                  trailingIcon: const Icon(Icons.chevron_right, color: AppColors.textDarkSecondary, size: 14),
                  onTap: onNavigateToSubscriptions,
                ),
              ),
              const SizedBox(width: 14),

              // Card 4: Daily Allowance (TAP -> Opens Daily Pace Calculator)
              Expanded(
                child: BentoFolderCard(
                  backgroundColor: AppColors.neoCyan,
                  iconData: Icons.pie_chart_outline,
                  title: _fmt(metrics.safeToSpendDaily),
                  titleWidget: _countingMetric(metrics.safeToSpendDaily),
                  isBalanceHidden: isBalanceHidden,
                  subtitle: _dailyPaceSubtitle(context),
                  subtitleMaxLines: 2,
                  trailingIcon: const Icon(Icons.info_outline, color: AppColors.textDarkSecondary, size: 13),
                  onTap: () => DailyPaceModal.show(
                    context,
                    metrics,
                    todayExpense: todayExpense,
                    referenceDate: referenceDate,
                    streak: _resolveStreak(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
