import 'package:flutter/material.dart';

import '../../../data/database/app_database.dart';
import '../../widgets/common/common_widgets.dart';

/// Minimalist expandable search bar with morphing dropdown filters for SubscriptionScreen.
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
    return ExpandableSearchFilterBar(
      searchController: searchController,
      searchQuery: searchQuery,
      typeFilter: filter,
      walletFilter: walletFilter,
      wallets: wallets,
      hintText: 'Cari tagihan, langganan, rekening...',
      headerTitle: 'Filter Tagihan',
      primaryFilterTitle: 'STATUS PEMBAYARAN',
      primaryFilterChoices: kDefaultSubscriptionStatusChoices,
      borderRadius: 10,
      onSearchChanged: onSearchChanged,
      onClearSearch: onClearSearch,
      onFilterApplied: onFilterApplied,
      onClearTypeFilter: onClearStatusFilter,
      onClearWalletFilter: onClearWalletFilter,
    );
  }
}
