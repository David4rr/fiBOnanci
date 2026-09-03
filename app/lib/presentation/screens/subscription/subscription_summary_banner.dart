import 'package:flutter/material.dart';

import '../../../data/database/app_database.dart';
import '../../modals/subscription_filter_modal.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class SubscriptionSearchBar extends StatelessWidget {
  final TextEditingController searchController;
  final String searchQuery;
  final String filter;
  final String? walletFilter;
  final List<WalletEntry> wallets;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final void Function(String status, String? walletId) onFilterApplied;
  final VoidCallback onClearStatusFilter;
  final VoidCallback onClearWalletFilter;

  const SubscriptionSearchBar({
    super.key,
    required this.searchController,
    required this.searchQuery,
    required this.filter,
    required this.walletFilter,
    required this.wallets,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onFilterApplied,
    required this.onClearStatusFilter,
    required this.onClearWalletFilter,
  });

  @override
  Widget build(BuildContext context) {
    final hasActiveFilter = filter != 'all' || walletFilter != null;

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
              borderRadius: BorderRadius.circular(23),
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
                      hintText: 'Cari tagihan, langganan, rekening...',
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
                    SubscriptionFilterModal.show(
                      context: context,
                      wallets: wallets,
                      initialStatus: filter,
                      initialWalletId: walletFilter,
                      onApply: onFilterApplied,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              children: [
                if (filter != 'all')
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Chip(
                      backgroundColor: AppColors.canvasInputSearch,
                      side: const BorderSide(color: AppColors.neoChartreuse),
                      label: Text(filter == 'unpaid' ? 'Belum Bayar' : 'Sudah Lunas', style: AppTypography.badgeLabel.copyWith(color: AppColors.neoChartreuse)),
                      onDeleted: onClearStatusFilter,
                      deleteIconColor: AppColors.neoChartreuse,
                    ),
                  ),
                if (walletFilter != null)
                  Chip(
                    backgroundColor: AppColors.canvasInputSearch,
                    side: const BorderSide(color: AppColors.neoChartreuse),
                    label: Text(
                      'Rek: ${wallets.firstWhere((w) => w.id == walletFilter, orElse: () => wallets.first).name}',
                      style: AppTypography.badgeLabel.copyWith(color: AppColors.neoChartreuse),
                    ),
                    onDeleted: onClearWalletFilter,
                    deleteIconColor: AppColors.neoChartreuse,
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
