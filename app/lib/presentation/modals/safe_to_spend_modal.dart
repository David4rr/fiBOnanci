import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../bloc/finance/finance_bloc.dart';
import '../../bloc/finance/finance_state.dart';
import '../../data/database/app_database.dart';
import '../widgets/common/common_widgets.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'safe_to_spend_accounts_selector.dart';

export 'safe_to_spend_accounts_selector.dart';

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
            final metrics = state.metrics;
            final selectedIds = state.safeToSpendWalletIds ?? <String>{};
            final isAll = state.safeToSpendWalletIds == null || state.safeToSpendWalletIds!.isEmpty;
            final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ModalGrabHandle(padding: EdgeInsets.only(bottom: 14)),
                  ModalHeader(
                    title: 'Smart Safe-to-Spend',
                    subtitle: 'Status: ${metrics.statusLabel}',
                    subtitleStyle: TextStyle(color: metrics.statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                    onClose: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 18),
                  SafeToSpendAccountsSelector(wallets: wallets, selectedIds: selectedIds, isAll: isAll),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.canvasInputSearch, borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        _buildCalcRow(
                          isAll ? 'Total Saldo Riil' : 'Saldo Rekening Terpilih',
                          '+${currencyFormatter.format(metrics.totalRealBalance)}',
                          AppColors.neoChartreuse,
                        ),
                        const Divider(color: AppColors.canvasBorder),
                        _buildCalcRow(
                          isAll ? 'Sisa Tagihan Bulan Ini' : 'Tagihan Terkait Terpilih',
                          '-${currencyFormatter.format(metrics.pendingBills)}',
                          AppColors.neoCoral,
                        ),
                        const Divider(color: AppColors.canvasBorder, height: 16),
                        _buildCalcRow('Sisa Aman Bulan Ini', currencyFormatter.format(metrics.safeToSpendMonthly), metrics.statusColor, isBold: true),
                        const SizedBox(height: 8),
                        _buildCalcRow('Alokasi Harian (${metrics.daysRemainingInMonth} hr)', '${currencyFormatter.format(metrics.safeToSpendDaily)} / hr', AppColors.neoCyan),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    isAll
                        ? 'Dihitung dari seluruh rekening Anda. Uang ini aman dibelanjakan tanpa khawatir tagihan bulanan gagal bayar.'
                        : 'Dihitung hanya dari rekening pengeluaran yang Anda pilih (${metrics.selectedWalletsCount} rekening). Tagihan dan saldo rekening tabungan lain tidak dicampur.',
                    style: AppTypography.listSubtitle,
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

  static Widget _buildCalcRow(String label, String val, Color color, {bool isBold = false}) {
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
          Text(val, style: TextStyle(color: color, fontSize: 14, fontWeight: isBold ? FontWeight.bold : FontWeight.w600, fontFeatures: const [FontFeature.tabularFigures()])),
        ],
      ),
    );
  }
}
