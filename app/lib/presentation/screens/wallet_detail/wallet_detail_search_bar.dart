import 'package:flutter/material.dart';

import '../../widgets/common/expandable_search_filter_bar.dart';
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
    return ExpandableSearchFilterBar(
      searchController: searchController,
      searchQuery: searchQuery,
      typeFilter: selectedFilter == WalletTxFilter.all ? 'all' : selectedFilter.name,
      showWalletFilter: false,
      padding: EdgeInsets.zero,
      borderRadius: 23,
      showActiveChipsBelow: false,
      onSearchChanged: onSearchChanged,
      onClearSearch: onClearSearch,
      onFilterApplied: (type, _) {
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
  }
}
