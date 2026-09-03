import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../modals/transaction_filter_modal.dart';
import '../../theme/app_colors.dart';
import 'wallet_detail_history_section.dart';

class WalletDetailSearchBar extends StatelessWidget {
  final TextEditingController searchController;
  final String searchQuery;
  final WalletTxFilter selectedFilter;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final ValueChanged<WalletTxFilter> onFilterChanged;

  const WalletDetailSearchBar({
    super.key,
    required this.searchController,
    required this.searchQuery,
    required this.selectedFilter,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.canvasInputSearch,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: searchQuery.isNotEmpty ? AppColors.neoChartreuse.withValues(alpha: 0.5) : AppColors.canvasBorder),
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
              onTap: onClearSearch,
              child: const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.close, color: AppColors.textMuted, size: 16)),
            ),
          const SizedBox(width: 6),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              HapticFeedback.selectionClick();
              TransactionFilterModal.show(
                context: context,
                wallets: const [],
                showWalletFilter: false,
                initialType: selectedFilter == WalletTxFilter.all ? 'all' : selectedFilter.name,
                initialWalletId: null,
                onApply: (type, _) {
                  switch (type) {
                    case 'income':
                      onFilterChanged(WalletTxFilter.income);
                      break;
                    case 'expense':
                      onFilterChanged(WalletTxFilter.expense);
                      break;
                    case 'transfer':
                      onFilterChanged(WalletTxFilter.transfer);
                      break;
                    default:
                      onFilterChanged(WalletTxFilter.all);
                  }
                },
              );
            },
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: selectedFilter != WalletTxFilter.all ? AppColors.neoChartreuse.withValues(alpha: 0.2) : Colors.transparent,
              ),
              child: Icon(Icons.tune, color: selectedFilter != WalletTxFilter.all ? AppColors.neoChartreuse : AppColors.textWhite, size: 17),
            ),
          ),
        ],
      ),
    );
  }
}
