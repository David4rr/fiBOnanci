import 'package:flutter/material.dart';

import '../../../data/database/app_database.dart';
import '../../widgets/common/common_widgets.dart';
import 'daily_calendar_bar.dart';
import 'expense_history_deck_view.dart';
import 'expense_history_search_bar.dart';

class ExpenseHistoryDeckTab extends StatelessWidget {
  final TextEditingController searchController;
  final String searchQuery;
  final String typeFilter;
  final String? walletFilter;
  final List<WalletEntry> wallets;
  final List<TransactionEntry> allTransactions;
  final List<TransactionEntry> filtered;
  final List<String> sortedDays;
  final int selectedDayIndex;
  final String currentDayKey;
  final List<TransactionEntry> currentDayTxs;
  final Map<String, List<TransactionEntry>> dayGroups;
  final ScrollController dayScrollController;
  final bool isFiltering;
  final List<CategoryEntry>? categories;
  final List<PocketEntry>? pockets;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final void Function(String type, String? walletId) onFilterApplied;
  final VoidCallback onClearTypeFilter;
  final VoidCallback onClearWalletFilter;
  final ValueChanged<int> onDaySelected;
  final ValueChanged<TransactionEntry> onManageTransaction;
  final GlobalKey<ExpandableModalSheetState>? sheetKey;

  const ExpenseHistoryDeckTab({
    super.key,
    required this.searchController,
    required this.searchQuery,
    required this.typeFilter,
    required this.walletFilter,
    required this.wallets,
    required this.allTransactions,
    required this.filtered,
    required this.sortedDays,
    required this.selectedDayIndex,
    required this.currentDayKey,
    required this.currentDayTxs,
    required this.dayGroups,
    required this.dayScrollController,
    required this.isFiltering,
    this.categories,
    this.pockets,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onFilterApplied,
    required this.onClearTypeFilter,
    required this.onClearWalletFilter,
    required this.onDaySelected,
    required this.onManageTransaction,
    this.sheetKey,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ExpenseHistorySearchBar(
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
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) => SizeTransition(
            sizeFactor: animation,
            axisAlignment: -1.0,
            child: FadeTransition(opacity: animation, child: child),
          ),
          child: isFiltering
              ? const SizedBox.shrink(key: ValueKey('calendar_collapsed'))
              : Padding(
                  key: const ValueKey('calendar_expanded'),
                  padding: const EdgeInsets.only(top: 6, bottom: 10),
                  child: DailyCalendarBar(
                    scrollController: dayScrollController,
                    sortedDays: sortedDays,
                    selectedIndex: selectedDayIndex,
                    dayGroups: dayGroups,
                    onDaySelected: onDaySelected,
                  ),
                ),
        ),
        ExpenseHistoryDeckView(
          isFiltering: isFiltering,
          searchQuery: searchQuery,
          filtered: filtered,
          sortedDays: sortedDays,
          currentDayKey: currentDayKey,
          currentDayTxs: currentDayTxs,
          allTransactions: allTransactions,
          wallets: wallets,
          categories: categories,
          pockets: pockets,
          onManageTransaction: onManageTransaction,
          onDownwardDrag: (d) => sheetKey?.currentState?.handleHeaderDragUpdate(d),
          onDownwardDragEnd: (d) => sheetKey?.currentState?.handleHeaderDragEnd(d),
        ),
      ],
    );
  }
}
