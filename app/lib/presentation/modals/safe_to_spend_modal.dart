import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/finance/finance_bloc.dart';
import '../../bloc/finance/finance_event.dart';
import '../../bloc/finance/finance_state.dart';
import '../../data/database/app_database.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class SafeToSpendModal {
  static void show(BuildContext context, List<WalletEntry> wallets) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.canvasCardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return BlocBuilder<FinanceBloc, FinanceState>(
          builder: (context, state) {
            final metrics = state.metrics;
            final selectedIds = state.safeToSpendWalletIds ?? <String>{};
            final isAll = state.safeToSpendWalletIds == null || state.safeToSpendWalletIds!.isEmpty;

            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.textSubtle,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: metrics.statusColor.withValues(alpha: 0.2),
                        ),
                        child: Icon(Icons.shield_outlined, color: metrics.statusColor, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Smart Safe-to-Spend', style: AppTypography.sectionTitle),
                            Text(
                              'Status: ${metrics.statusLabel}',
                              style: TextStyle(color: metrics.statusColor, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Spending Source Accounts Selection (Flexible Wallets)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'SUMBER REKENING PENGELUARAN',
                          style: AppTypography.badgeLabel.copyWith(color: AppColors.textMuted),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isAll ? 'Semua (${wallets.length})' : '${selectedIds.length} Dipilih',
                        style: AppTypography.badgeLabel.copyWith(color: AppColors.neoChartreuse),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      // "Semua Rekening" Chip
                      FilterChip(
                        label: Text('Semua (${wallets.length})'),
                        selected: isAll,
                        selectedColor: AppColors.neoChartreuse,
                        backgroundColor: AppColors.canvasInputSearch,
                        labelStyle: TextStyle(
                          color: isAll ? AppColors.textDarkPrimary : AppColors.textWhite,
                          fontWeight: isAll ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                        onSelected: (_) {
                          context.read<FinanceBloc>().add(const SetSafeToSpendWalletsEvent(null));
                        },
                      ),

                      // Individual Wallet Chips
                      for (final w in wallets) ...[
                        Builder(builder: (context) {
                          final isSelected = !isAll && selectedIds.contains(w.id);
                          return FilterChip(
                            label: Text(w.name),
                            selected: isSelected,
                            selectedColor: AppColors.neoChartreuse,
                            backgroundColor: AppColors.canvasInputSearch,
                            labelStyle: TextStyle(
                              color: isSelected ? AppColors.textDarkPrimary : AppColors.textWhite,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 12,
                            ),
                            onSelected: (selected) {
                              Set<String> newSet;
                              if (isAll) {
                                newSet = {w.id};
                              } else {
                                newSet = Set<String>.from(selectedIds);
                                if (selected) {
                                  newSet.add(w.id);
                                } else {
                                  newSet.remove(w.id);
                                }
                              }

                              if (newSet.isEmpty || newSet.length >= wallets.length) {
                                context.read<FinanceBloc>().add(const SetSafeToSpendWalletsEvent(null));
                              } else {
                                context.read<FinanceBloc>().add(SetSafeToSpendWalletsEvent(newSet));
                              }
                            },
                          );
                        }),
                      ],
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Calculation Breakdown
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.canvasInputSearch,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _buildCalcRow(
                          isAll ? 'Total Saldo Riil' : 'Saldo Rekening Terpilih',
                          '+Rp ${metrics.totalRealBalance.toStringAsFixed(0)}',
                          AppColors.neoChartreuse,
                        ),
                        const Divider(color: AppColors.canvasBorder),
                        _buildCalcRow(
                          isAll ? 'Sisa Tagihan Bulan Ini' : 'Tagihan Terkait Terpilih',
                          '-Rp ${metrics.pendingBills.toStringAsFixed(0)}',
                          AppColors.neoCoral,
                        ),
                        const Divider(color: AppColors.canvasBorder),
                        _buildCalcRow(
                          'Safe-to-Spend (Aman Belanja)',
                          'Rp ${metrics.safeToSpendMonthly.toStringAsFixed(0)}',
                          AppColors.neoChartreuse,
                          isBold: true,
                        ),
                        const Divider(color: AppColors.canvasBorder),
                        _buildCalcRow(
                          'Alokasi Harian (${metrics.daysRemainingInMonth} hr)',
                          'Rp ${metrics.safeToSpendDaily.toStringAsFixed(0)} / hr',
                          AppColors.neoCyan,
                        ),
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
              style: TextStyle(
                color: AppColors.textWhite,
                fontSize: 13,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            val,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
