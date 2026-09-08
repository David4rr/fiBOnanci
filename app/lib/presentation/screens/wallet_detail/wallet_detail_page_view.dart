import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/database/app_database.dart';
import '../../theme/app_colors.dart';
import '../../widgets/transaction_detail_modal.dart';
import '../../widgets/transaction_modal.dart';
import 'wallet_detail_edit_tab.dart';
import 'wallet_detail_history_section.dart';
import 'wallet_detail_scroll_view.dart';

class WalletDetailPageView extends StatelessWidget {
  final PageController pageController;
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
  final ValueChanged<double> onScrollOffsetChanged;
  final VoidCallback onEditBalance;
  final VoidCallback onAddTransaction;
  final ValueChanged<TransactionEntry> onEditTransaction;
  final TransactionEntry? selectedTransaction;
  final VoidCallback onReturnToDetails;

  const WalletDetailPageView({
    super.key,
    required this.pageController,
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
    required this.onScrollOffsetChanged,
    required this.onEditBalance,
    required this.onAddTransaction,
    required this.onEditTransaction,
    required this.selectedTransaction,
    required this.onReturnToDetails,
  });

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: (n) {
            if (n.metrics.axis == Axis.vertical) {
              onScrollOffsetChanged(n.metrics.pixels);
            }
            return false;
          },
          child: WalletDetailScrollView(
            scrollController: scrollController,
            wallet: wallet,
            cardIndex: cardIndex >= 0 ? cardIndex : 0,
            currencyFormatter: currencyFormatter,
            cardColor: cardColor,
            allWallets: allWallets,
            transactions: transactions,
            filteredTx: filteredTx,
            searchController: searchController,
            searchQuery: searchQuery,
            selectedFilter: selectedFilter,
            onSearchChanged: onSearchChanged,
            onClearSearch: onClearSearch,
            onFilterChanged: onFilterChanged,
            onEditBalance: onEditBalance,
            onAddTransaction: onAddTransaction,
            onEditTransaction: onEditTransaction,
          ),
        ),
        WalletDetailEditTab(
          wallet: wallet,
          onReturnToDetails: onReturnToDetails,
        ),
        BottomSheet(
          onClosing: onReturnToDetails,
          enableDrag: false,
          backgroundColor: AppColors.canvasCardSurface,
          builder: (context) => TransactionModal(
            initialWalletId: wallet.id,
            isInline: true,
            onClose: onReturnToDetails,
            onSaved: onReturnToDetails,
          ),
        ),
        if (selectedTransaction != null)
          BottomSheet(
            onClosing: onReturnToDetails,
            enableDrag: false,
            backgroundColor: AppColors.canvasCardSurface,
            builder: (context) => TransactionDetailModal(
              transaction: selectedTransaction!,
              isInline: true,
              onClose: onReturnToDetails,
              onSaved: onReturnToDetails,
              onDeleted: onReturnToDetails,
            ),
          )
        else
          const SizedBox.shrink(),
      ],
    );
  }
}
