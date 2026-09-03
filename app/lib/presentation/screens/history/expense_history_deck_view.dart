import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/database/app_database.dart';
import '../../theme/app_colors.dart';
import '../../widgets/overlapping_deck.dart';
import 'daily_calendar_bar.dart';

class ExpenseHistoryDeckView extends StatelessWidget {
  final bool isFiltering;
  final String searchQuery;
  final List<TransactionEntry> filtered;
  final List<String> sortedDays;
  final String currentDayKey;
  final List<TransactionEntry> currentDayTxs;
  final List<TransactionEntry> allTransactions;
  final List<WalletEntry> wallets;

  const ExpenseHistoryDeckView({
    super.key,
    required this.isFiltering,
    required this.searchQuery,
    required this.filtered,
    required this.sortedDays,
    required this.currentDayKey,
    required this.currentDayTxs,
    required this.allTransactions,
    required this.wallets,
  });

  @override
  Widget build(BuildContext context) {
    final isToday = currentDayKey.isNotEmpty && DailyDateHelper.formatDayTabLabel(currentDayKey) == 'Hari Ini';
    final listToDisplay = isFiltering ? filtered : currentDayTxs;

    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (isFiltering)
                  Text(
                    searchQuery.isNotEmpty ? 'Hasil Pencarian: ${filtered.length} Transaksi' : 'Hasil Filter: ${filtered.length} Transaksi',
                    style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.neoChartreuse),
                  )
                else if (sortedDays.isNotEmpty) ...[
                  Text(
                    DailyDateHelper.formatDayTabLabel(currentDayKey).toUpperCase(),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                      color: isToday ? AppColors.neoChartreuse : AppColors.textWhite,
                    ),
                  ),
                  Text(
                    '//  ${currentDayTxs.length} TRANSAKSI',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: isToday ? AppColors.neoChartreuse : AppColors.textMuted,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Hero(
              tag: 'expense_history_card_history',
              flightShuttleBuilder: (flightContext, animation, flightDirection, fromHeroContext, toHeroContext) {
                return Material(color: Colors.transparent, child: toHeroContext.widget);
              },
              child: listToDisplay.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long_outlined, size: 48, color: AppColors.textSubtle),
                          const SizedBox(height: 12),
                          Text('Tidak Ada Transaksi di Tanggal Ini', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textWhite)),
                        ],
                      ),
                    )
                  : StackedCardDeckScrollList(
                      transactions: listToDisplay,
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
