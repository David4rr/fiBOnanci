import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/database/app_database.dart';
import 'tactile_hero_card.dart';
import 'wallet_detail_actions_and_chart.dart';
import 'wallet_detail_history_section.dart';

class WalletDetailScrollView extends StatelessWidget {
  final ScrollController scrollController;
  final WalletEntry wallet;
  final int cardIndex;
  final NumberFormat currencyFormatter;
  final Color cardColor;
  final List<WalletEntry> allWallets;
  final List<TransactionEntry> transactions;
  final List<TransactionEntry> filteredTx;
  final TextEditingController searchController;
  final String searchQuery;
  final WalletTxFilter selectedFilter;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final ValueChanged<WalletTxFilter> onFilterChanged;

  const WalletDetailScrollView({
    super.key,
    required this.scrollController,
    required this.wallet,
    required this.cardIndex,
    required this.currencyFormatter,
    required this.cardColor,
    required this.allWallets,
    required this.transactions,
    required this.filteredTx,
    required this.searchController,
    required this.searchQuery,
    required this.selectedFilter,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: scrollController,
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
            child: Center(
              child: TactileHeroCard(
                wallet: wallet,
                cardIndex: cardIndex >= 0 ? cardIndex : 0,
                fmt: currencyFormatter,
                cardColor: cardColor,
                allWallets: allWallets,
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        SliverToBoxAdapter(
          child: WalletDetailActionsAndChart(
            wallet: wallet,
            cardColor: cardColor,
            transactions: transactions,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 14)),
        WalletDetailHistorySection(
          wallet: wallet,
          filteredTx: filteredTx,
          searchController: searchController,
          searchQuery: searchQuery,
          selectedFilter: selectedFilter,
          currencyFormatter: currencyFormatter,
          onSearchChanged: onSearchChanged,
          onClearSearch: onClearSearch,
          onFilterChanged: onFilterChanged,
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }
}
