import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/finance/finance_bloc.dart';
import '../../bloc/finance/finance_state.dart';
import '../../core/formatters/app_currency.dart';
import '../../data/database/app_database.dart';
import '../../core/l10n/locale_notifier.dart';
import '../../domain/services/safe_to_spend_service.dart';
import '../widgets/common/common_widgets.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class SafeToSpendModal {
  static void show(BuildContext context, List<WalletEntry> wallets) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.canvasCardSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) {
        return BlocBuilder<FinanceBloc, FinanceState>(
          builder: (context, state) {
            final l10n = AppL10n.of(context);
            final metrics = state.metrics;
            final isAll = state.safeToSpendWalletIds == null || state.safeToSpendWalletIds!.isEmpty;
            final currencyFormatter = AppCurrency.forCode(state.profile.currency);
            final statusText = switch (metrics.healthStatus) {
              FinancialHealthStatus.comfortable => l10n.healthStatusComfortable,
              FinancialHealthStatus.caution => l10n.healthStatusCaution,
              FinancialHealthStatus.deficit => l10n.healthStatusDeficit,
            };
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ModalGrabHandle(padding: EdgeInsets.only(bottom: 14)),
                  ModalHeader(
                    title: 'Smart Safe-to-Spend',
                    subtitle: l10n.stsStatusPrefix(statusText),
                    subtitleStyle: TextStyle(color: metrics.statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                    onClose: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.canvasInputSearch, borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        _buildCalcRow(
                          isAll ? l10n.stsTotalRealBalance : l10n.stsSelectedBalance,
                          metrics.operationalBalance,
                          (v) => '+${currencyFormatter.format(v)}',
                          AppColors.neoChartreuse,
                        ),
                        if (!isAll) ...[
                          const SizedBox(height: 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(l10n.stsTotalAssetsCount(wallets.length), style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                              AnimatedCountingText(
                                value: metrics.totalRealBalance,
                                formatter: currencyFormatter.format,
                                respectPrivacyMask: false,
                                style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                              ),
                            ],
                          ),
                        ],
                        Divider(color: AppColors.canvasBorder),
                        _buildCalcRow(
                          isAll ? l10n.stsPendingBills : l10n.stsSelectedBills,
                          metrics.pendingBills,
                          (v) => '-${currencyFormatter.format(v)}',
                          AppColors.neoCoral,
                        ),
                        Divider(color: AppColors.canvasBorder, height: 16),
                        _buildCalcRow(l10n.stsMonthlySafe, metrics.safeToSpendMonthly, currencyFormatter.format, metrics.statusColor, isBold: true),
                        const SizedBox(height: 8),
                        _buildCalcRow(l10n.stsDailyAllowance(metrics.daysRemainingInMonth), metrics.safeToSpendDaily, (v) => '${currencyFormatter.format(v)} ${l10n.stsPerDaySuffix}', AppColors.neoCyan),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    isAll
                        ? l10n.stsAllWalletsDesc
                        : l10n.stsSelectedWalletsDesc(metrics.selectedWalletsCount),
                    style: AppTypography.listSubtitle,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.tune, size: 12, color: AppColors.textMuted),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          l10n.stsSettingsHint,
                          style: AppTypography.listSubtitle.copyWith(color: AppColors.textMuted, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static Widget _buildCalcRow(String label, double value, String Function(double) formatter, Color color, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: AppColors.textWhite, fontSize: 13, fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          AnimatedCountingText(
            value: value,
            formatter: formatter,
            respectPrivacyMask: false,
            style: TextStyle(color: color, fontSize: 14, fontWeight: isBold ? FontWeight.bold : FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
