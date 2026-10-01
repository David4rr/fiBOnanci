import 'package:flutter/material.dart';

import '../../../data/database/app_database.dart';
import '../../modals/all_transactions_modal.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/overlapping_deck.dart';

class DashboardHistorySection extends StatelessWidget {
  final String searchQuery;
  final bool isFiltering;
  final List<TransactionEntry> filteredTransactions;
  final List<TransactionEntry> allTransactions;
  final List<WalletEntry> wallets;

  const DashboardHistorySection({
    super.key,
    required this.searchQuery,
    required this.isFiltering,
    required this.filteredTransactions,
    required this.allTransactions,
    required this.wallets,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    searchQuery.isNotEmpty
                        ? 'Hasil Pencarian (${filteredTransactions.length})'
                        : 'Riwayat Transaksi',
                    style: AppTypography.sectionTitle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => AllTransactionsModal.show(context, allTransactions: allTransactions, wallets: wallets),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Text(
                      'Lihat Semua',
                      style: AppTypography.cardMetricLabel.copyWith(
                        color: AppColors.neoChartreuse,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Hero(
              tag: 'expense_history_card_history',
              flightShuttleBuilder: (flightContext, animation, flightDirection, fromHeroContext, toHeroContext) {
                return Material(color: Colors.transparent, child: toHeroContext.widget);
              },
              child: filteredTransactions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(isFiltering ? Icons.search_off_rounded : Icons.receipt_long_outlined, size: 42, color: AppColors.textSubtle),
                          const SizedBox(height: 10),
                          Text(isFiltering ? 'Tidak ada transaksi yang cocok' : 'Belum ada transaksi hari ini', style: AppTypography.listSubtitle),
                        ],
                      ),
                    )
                  : StackedCardDeckScrollList(
                      transactions: filteredTransactions,
                      allTransactions: allTransactions,
                      wallets: wallets,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
