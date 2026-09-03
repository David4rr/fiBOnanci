import 'package:flutter/material.dart';
import '../../../data/database/app_database.dart';
import '../../modals/transaction_filter_modal.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class DashboardSearchBar extends StatelessWidget {
  final TextEditingController searchController;
  final String searchQuery;
  final String typeFilter;
  final String? walletFilter;
  final List<WalletEntry> wallets;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final void Function(String type, String? walletId) onFilterApplied;
  final VoidCallback onClearTypeFilter;
  final VoidCallback onClearWalletFilter;

  const DashboardSearchBar({
    super.key,
    required this.searchController,
    required this.searchQuery,
    required this.typeFilter,
    required this.walletFilter,
    required this.wallets,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onFilterApplied,
    required this.onClearTypeFilter,
    required this.onClearWalletFilter,
  });

  @override
  Widget build(BuildContext context) {
    final hasActiveFilter = typeFilter != 'all' || walletFilter != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.canvasInputSearch,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: searchQuery.isNotEmpty ? AppColors.neoChartreuse.withValues(alpha: 0.5) : AppColors.canvasBorder,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: AppColors.textMuted, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: searchController,
                    style: const TextStyle(color: AppColors.textWhite, fontSize: 13.5),
                    onChanged: onSearchChanged,
                    decoration: const InputDecoration(
                      hintText: 'Cari transaksi, rekening, merchant...',
                      hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 12.5),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                if (searchQuery.isNotEmpty)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onClearSearch,
                    child: const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.close, color: AppColors.textMuted, size: 16)),
                  ),
                const SizedBox(width: 6),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    TransactionFilterModal.show(
                      context: context,
                      wallets: wallets,
                      initialType: typeFilter,
                      initialWalletId: walletFilter,
                      onApply: onFilterApplied,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: hasActiveFilter ? AppColors.neoChartreuse.withValues(alpha: 0.2) : Colors.transparent,
                    ),
                    child: Icon(Icons.tune, color: hasActiveFilter ? AppColors.neoChartreuse : AppColors.textWhite, size: 17),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (hasActiveFilter)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
            child: Row(
              children: [
                if (typeFilter != 'all')
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.canvasInputSearch, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.neoChartreuse, width: 1)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Tipe: ${typeFilter.toUpperCase()}', style: AppTypography.badgeLabel.copyWith(color: AppColors.neoChartreuse)),
                          const SizedBox(width: 4),
                          GestureDetector(onTap: onClearTypeFilter, child: const Icon(Icons.close, size: 14, color: AppColors.neoChartreuse)),
                        ],
                      ),
                    ),
                  ),
                if (walletFilter != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.canvasInputSearch, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.neoChartreuse, width: 1)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Rek: ${wallets.firstWhere((w) => w.id == walletFilter, orElse: () => wallets.first).name}',
                          style: AppTypography.badgeLabel.copyWith(color: AppColors.neoChartreuse),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(onTap: onClearWalletFilter, child: const Icon(Icons.close, size: 14, color: AppColors.neoChartreuse)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
