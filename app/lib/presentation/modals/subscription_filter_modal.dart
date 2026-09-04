import 'package:flutter/material.dart';

import '../../data/database/app_database.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/common/common_widgets.dart';

/// Swiss-Editorial Filter Modal for Subscription Screen matching TransactionFilterModal on Dashboard.
class SubscriptionFilterModal {
  static void show({
    required BuildContext context,
    required List<WalletEntry> wallets,
    required String initialStatus,
    required String? initialWalletId,
    required void Function(String status, String? walletId) onApply,
  }) {
    String currentStatus = initialStatus;
    String? currentWalletId = initialWalletId;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.canvasCardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setFilterState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ModalGrabHandle(padding: EdgeInsets.only(bottom: 18)),
                  Text('Filter Tagihan', style: AppTypography.sectionTitle),
                  const SizedBox(height: 16),

                  Text(
                    'STATUS PEMBAYARAN',
                    style: AppTypography.badgeLabel.copyWith(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildFilterChoiceChip('all', 'Semua Status', currentStatus, (val) {
                        currentStatus = val!;
                        setFilterState(() {});
                      }),
                      _buildFilterChoiceChip('unpaid', 'Belum Bayar', currentStatus, (val) {
                        currentStatus = val!;
                        setFilterState(() {});
                      }),
                      _buildFilterChoiceChip('paid', 'Sudah Lunas', currentStatus, (val) {
                        currentStatus = val!;
                        setFilterState(() {});
                      }),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'REKENING PEMBAYARAN',
                    style: AppTypography.badgeLabel.copyWith(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildFilterChoiceChip(null, 'Semua Rekening', currentWalletId, (val) {
                        currentWalletId = val;
                        setFilterState(() {});
                      }),
                      for (final w in wallets)
                        _buildFilterChoiceChip(w.id, w.name, currentWalletId, (val) {
                          currentWalletId = val;
                          setFilterState(() {});
                        }),
                    ],
                  ),
                  const SizedBox(height: 24),
                  PrimaryActionButton(
                    text: 'Terapkan Filter',
                    height: 48,
                    borderRadius: 16,
                    onPressed: () {
                      Navigator.pop(ctx);
                      onApply(currentStatus, currentWalletId);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static Widget _buildFilterChoiceChip<T>(
    T value,
    String label,
    T groupValue,
    ValueChanged<T?> onSelected,
  ) {
    final isSelected = value == groupValue;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(value),
      backgroundColor: AppColors.canvasInputSearch,
      selectedColor: AppColors.neoChartreuse,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.textDarkPrimary : AppColors.textWhite,
        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
        fontSize: 12.5,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.neoChartreuse : AppColors.canvasBorder,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    );
  }
}
