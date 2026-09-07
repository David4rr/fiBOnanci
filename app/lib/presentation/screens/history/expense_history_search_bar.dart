import 'package:flutter/material.dart';

import '../../../data/database/app_database.dart';
import '../../widgets/common/expandable_search_filter_bar.dart';

class ExpenseHistorySearchBar extends StatelessWidget {
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

  const ExpenseHistorySearchBar({
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
    return ExpandableSearchFilterBar(
      searchController: searchController,
      searchQuery: searchQuery,
      typeFilter: typeFilter,
      walletFilter: walletFilter,
      wallets: wallets,
      onSearchChanged: onSearchChanged,
      onClearSearch: onClearSearch,
      onFilterApplied: onFilterApplied,
      onClearTypeFilter: onClearTypeFilter,
      onClearWalletFilter: onClearWalletFilter,
    );
  }
}
