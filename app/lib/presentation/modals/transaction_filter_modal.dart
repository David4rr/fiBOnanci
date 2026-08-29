import 'package:flutter/material.dart';
import '../../data/database/app_database.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class TransactionFilterModal {
  static void show({
    required BuildContext context,
    required List<WalletEntry> wallets,
    required String initialType,
    required String? initialWalletId,
    required void Function(String type, String? walletId) onApply,
  }) {
    String currentType = initialType;
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
                  Text('Filter Transaksi', style: AppTypography.sectionTitle),
                  const SizedBox(height: 16),

                  Text(
                    'TIPE TRANSAKSI',
                    style: AppTypography.badgeLabel.copyWith(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildFilterChoiceChip('all', 'Semua', currentType, (val) {
                        currentType = val!;
                        setFilterState(() {});
                      }),
                      _buildFilterChoiceChip('expense', 'Pengeluaran', currentType, (val) {
                        currentType = val!;
                        setFilterState(() {});
                      }),
                      _buildFilterChoiceChip('income', 'Pemasukan', currentType, (val) {
                        currentType = val!;
                        setFilterState(() {});
                      }),
                      _buildFilterChoiceChip('transfer', 'Transfer', currentType, (val) {
                        currentType = val!;
                        setFilterState(() {});
                      }),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'REKENING',
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
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.neoChartreuse,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        onApply(currentType, currentWalletId);
                        Navigator.pop(ctx);
                      },
                      child: Text(
                        'Terapkan Filter',
                        style: AppTypography.listTitle.copyWith(
                          color: AppColors.textDarkPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static Widget _buildFilterChoiceChip(
    String? value,
    String label,
    String? currentGroup,
    ValueChanged<String?> onSelected,
  ) {
    final isSelected = value == currentGroup;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.neoChartreuse,
      backgroundColor: AppColors.canvasInputSearch,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.textDarkPrimary : AppColors.textWhite,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      onSelected: (_) => onSelected(value),
    );
  }
}
