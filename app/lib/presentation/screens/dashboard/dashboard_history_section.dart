import 'package:flutter/material.dart';

import '../../../data/database/app_database.dart';
import '../../../core/l10n/locale_notifier.dart';
import '../../modals/all_transactions_modal.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/overlapping_deck.dart';

class DashboardHistorySection extends StatefulWidget {
  final String searchQuery;
  final bool isFiltering;
  final List<TransactionEntry> filteredTransactions;
  final List<TransactionEntry> allTransactions;
  final List<WalletEntry> wallets;
  final List<CategoryEntry>? categories;
  final List<PocketEntry>? pockets;

  const DashboardHistorySection({
    super.key,
    required this.searchQuery,
    required this.isFiltering,
    required this.filteredTransactions,
    required this.allTransactions,
    required this.wallets,
    this.categories,
    this.pockets,
  });

  @override
  State<DashboardHistorySection> createState() => _DashboardHistorySectionState();
}

class _DashboardHistorySectionState extends State<DashboardHistorySection> {
  String? _expandedTxId;

  double _computeDeckHeight(int count, bool isExpanded) {
    if (count == 0) return 180.0;
    if (isExpanded) {
      return count <= 1 ? 320.0 : (count == 2 ? 500.0 : 580.0);
    }
    return count <= 1 ? 210.0 : (count == 2 ? 305.0 : 380.0);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final hasTxs = widget.filteredTransactions.isNotEmpty;
    final cardListHeight = _computeDeckHeight(widget.filteredTransactions.length, _expandedTxId != null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.searchQuery.isNotEmpty
                      ? l10n.dashboardSearchResults(widget.filteredTransactions.length)
                      : l10n.dashboardHistoryTitle,
                  style: AppTypography.sectionTitle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => AllTransactionsModal.show(context, allTransactions: widget.allTransactions, wallets: widget.wallets),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(
                    l10n.dashboardViewAll,
                    style: AppTypography.cardMetricLabel.copyWith(
                      color: AppColors.textAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          height: cardListHeight,
          child: Hero(
            tag: 'expense_history_card_history',
            flightShuttleBuilder: (flightContext, animation, flightDirection, fromHeroContext, toHeroContext) {
              return Material(color: Colors.transparent, child: toHeroContext.widget);
            },
            child: !hasTxs
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(widget.isFiltering ? Icons.search_off_rounded : Icons.receipt_long_outlined, size: 42, color: AppColors.textSubtle),
                        const SizedBox(height: 10),
                        Text(widget.isFiltering ? l10n.dashboardNoMatchingTx : l10n.dashboardNoTxToday, style: AppTypography.listSubtitle),
                      ],
                    ),
                  )
                : StackedCardDeckScrollList(
                    transactions: widget.filteredTransactions,
                    allTransactions: widget.allTransactions,
                    wallets: widget.wallets,
                    categories: widget.categories,
                    pockets: widget.pockets,
                    expandedTxId: _expandedTxId,
                    onToggleExpand: (id) => setState(() => _expandedTxId = id),
                    bottomPadding: 30.0,
                    enableInternalScroll: true,
                  ),
          ),
        ),
      ],
    );
  }
}
