import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/database/app_database.dart';
import '../../domain/services/safe_to_spend_service.dart';
import '../modals/dashboard_modals.dart';
import '../modals/safe_to_spend_modal.dart';
import '../theme/app_colors.dart';
import 'bento_folder_card.dart';

/// 2x2 Bento Folder Grid for Dashboard.
/// Displays Safe-to-Spend, Total Real Balance, Committed Bills, and Daily Pace.
class DashboardBentoGrid extends StatelessWidget {
  final SafeToSpendMetrics metrics;
  final List<WalletEntry> wallets;
  final List<SubscriptionEntry> subscriptions;
  final NumberFormat currencyFormatter;
  final VoidCallback onNavigateToWallets;
  final VoidCallback onNavigateToSubscriptions;

  const DashboardBentoGrid({
    super.key,
    required this.metrics,
    required this.wallets,
    required this.subscriptions,
    required this.currencyFormatter,
    required this.onNavigateToWallets,
    required this.onNavigateToSubscriptions,
  });

  @override
  Widget build(BuildContext context) {
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
                  title: currencyFormatter.format(metrics.safeToSpendMonthly),
                  subtitle: metrics.isAllWallets
                      ? 'Safe to Spend'
                      : 'Safe to Spend (${metrics.selectedWalletsCount} Akun)',
                  trailingIcon: const Icon(Icons.tune, color: AppColors.textDarkSecondary, size: 12),
                  onTap: () => SafeToSpendModal.show(context, wallets),
                ),
              ),
              const SizedBox(width: 14),

              // Card 2: Total Real Balance (TAP -> Switches to Wallets Tab)
              Expanded(
                child: BentoFolderCard(
                  backgroundColor: AppColors.neoMint,
                  iconData: Icons.account_balance_wallet_outlined,
                  title: currencyFormatter.format(metrics.totalRealBalance),
                  subtitle: '${wallets.length} Akun Riil',
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
                  title: currencyFormatter.format(metrics.pendingBills),
                  subtitle: '${subscriptions.length} Tagihan Bln Ini',
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
                  title: currencyFormatter.format(metrics.safeToSpendDaily),
                  subtitle: 'Alokasi/Hari (${metrics.daysRemainingInMonth}hr)',
                  trailingIcon: const Icon(Icons.info_outline, color: AppColors.textDarkSecondary, size: 13),
                  onTap: () => DailyPaceModal.show(context, metrics),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
