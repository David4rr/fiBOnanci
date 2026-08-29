import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/database/app_database.dart';
import '../../domain/services/safe_to_spend_service.dart';
import '../modals/dashboard_modals.dart';
import '../modals/budgeting_insights_modal.dart';
import '../modals/safe_to_spend_modal.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'folder_tab_card.dart';

/// 2x2 Bento Folder Grid for Dashboard.
/// Displays Safe-to-Spend, Total Real Balance, Committed Bills, and Daily Pace.
class DashboardBentoGrid extends StatelessWidget {
  final SafeToSpendMetrics metrics;
  final List<WalletEntry> wallets;
  final List<SubscriptionEntry> subscriptions;
  final NumberFormat currencyFormatter;
  final VoidCallback onNavigateToWallets;

  const DashboardBentoGrid({
    super.key,
    required this.metrics,
    required this.wallets,
    required this.subscriptions,
    required this.currencyFormatter,
    required this.onNavigateToWallets,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        children: [
          Row(
            children: [
              // Card 1: Safe-to-Spend (TAP -> Opens Formula Breakdown)
              Expanded(
                child: FolderTabCard(
                  backgroundColor: AppColors.neoChartreuse,
                  height: 140,
                  onTap: () => SafeToSpendModal.show(context, wallets),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.cardIconBadgeBg,
                        ),
                        child: const Center(
                          child: Icon(Icons.shield_outlined, color: AppColors.textDarkPrimary, size: 18),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currencyFormatter.format(metrics.safeToSpendMonthly),
                            style: AppTypography.cardMetricValue,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  metrics.isAllWallets ? 'Safe to Spend' : 'Safe to Spend (${metrics.selectedWalletsCount} Akun)',
                                  style: AppTypography.cardMetricLabel,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.tune, color: AppColors.textDarkSecondary, size: 12),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Card 2: Total Real Balance (TAP -> Switches to Wallets Tab)
              Expanded(
                child: FolderTabCard(
                  backgroundColor: AppColors.neoMint,
                  height: 140,
                  onTap: onNavigateToWallets,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.cardIconBadgeBg,
                        ),
                        child: const Center(
                          child: Icon(Icons.account_balance_wallet_outlined, color: AppColors.textDarkPrimary, size: 18),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currencyFormatter.format(metrics.totalRealBalance),
                            style: AppTypography.cardMetricValue,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Expanded(child: Text('${wallets.length} Akun Riil', style: AppTypography.cardMetricLabel, overflow: TextOverflow.ellipsis)),
                              const SizedBox(width: 4),
                              const Icon(Icons.chevron_right, color: AppColors.textDarkSecondary, size: 14),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              // Card 3: Pending Bills (TAP -> Opens Upcoming Bills List)
              Expanded(
                child: FolderTabCard(
                  backgroundColor: AppColors.neoCoral,
                  height: 140,
                  onTap: () => BudgetingInsightsModal.show(
                    context,
                    subscriptions: subscriptions,
                    wallets: wallets,
                    metrics: metrics,
                    currencyFormatter: currencyFormatter,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.cardIconBadgeBg,
                        ),
                        child: const Center(
                          child: Icon(Icons.receipt_long_outlined, color: AppColors.textDarkPrimary, size: 18),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currencyFormatter.format(metrics.pendingBills),
                            style: AppTypography.cardMetricValue,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Expanded(child: Text('${subscriptions.length} Tagihan Bln Ini', style: AppTypography.cardMetricLabel, overflow: TextOverflow.ellipsis)),
                              const SizedBox(width: 4),
                              const Icon(Icons.chevron_right, color: AppColors.textDarkSecondary, size: 14),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Card 4: Daily Allowance (TAP -> Opens Daily Pace Calculator)
              Expanded(
                child: FolderTabCard(
                  backgroundColor: AppColors.neoCyan,
                  height: 140,
                  onTap: () => DailyPaceModal.show(context, metrics),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.cardIconBadgeBg,
                        ),
                        child: const Center(
                          child: Icon(Icons.pie_chart_outline, color: AppColors.textDarkPrimary, size: 18),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currencyFormatter.format(metrics.safeToSpendDaily),
                            style: AppTypography.cardMetricValue,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Expanded(child: Text('Alokasi/Hari (${metrics.daysRemainingInMonth}hr)', style: AppTypography.cardMetricLabel, overflow: TextOverflow.ellipsis)),
                              const SizedBox(width: 4),
                              const Icon(Icons.info_outline, color: AppColors.textDarkSecondary, size: 13),
                            ],
                          ),
                        ],
                      ),
                    ],
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
