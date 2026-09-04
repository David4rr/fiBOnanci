import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../data/database/app_database.dart';
import '../../widgets/common/search_filter_chip.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import 'wallet_detail_search_bar.dart';
import 'wallet_detail_transaction_tile.dart';

export 'wallet_detail_search_bar.dart';

enum WalletTxFilter { all, income, expense, transfer }

class WalletDetailHistorySection extends StatelessWidget {
  final WalletEntry wallet;
  final List<TransactionEntry> filteredTx;
  final TextEditingController searchController;
  final String searchQuery;
  final WalletTxFilter selectedFilter;
  final NumberFormat currencyFormatter;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final ValueChanged<WalletTxFilter> onFilterChanged;

  const WalletDetailHistorySection({
    super.key,
    required this.wallet,
    required this.filteredTx,
    required this.searchController,
    required this.searchQuery,
    required this.selectedFilter,
    required this.currencyFormatter,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onFilterChanged,
  });

  String _getFilterTypeLabel(WalletTxFilter filter) {
    switch (filter) {
      case WalletTxFilter.income: return 'Masuk';
      case WalletTxFilter.expense: return 'Keluar';
      case WalletTxFilter.transfer: return 'Transfer';
      case WalletTxFilter.all: return 'Semua';
    }
  }

  Widget _buildFilterChip(String label, WalletTxFilter filter) {
    final isSelected = selectedFilter == filter;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onFilterChanged(filter);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6.5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.neoChartreuse : AppColors.canvasInputSearch,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppColors.neoChartreuse : AppColors.canvasBorder),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: isSelected ? AppColors.textDarkPrimary : AppColors.textWhite,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: WalletDetailSearchBar(
              searchController: searchController,
              searchQuery: searchQuery,
              selectedFilter: selectedFilter,
              onSearchChanged: onSearchChanged,
              onClearSearch: onClearSearch,
              onFilterChanged: onFilterChanged,
            ),
          ),
        ),
        if (selectedFilter != WalletTxFilter.all)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
              child: Row(
                children: [
                  SearchFilterChip(
                    label: 'Tipe: ${_getFilterTypeLabel(selectedFilter).toUpperCase()}',
                    onClear: () => onFilterChanged(WalletTxFilter.all),
                  ),
                ],
              ),
            ),
          ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Semua', WalletTxFilter.all),
                  const SizedBox(width: 8),
                  _buildFilterChip('Masuk', WalletTxFilter.income),
                  const SizedBox(width: 8),
                  _buildFilterChip('Keluar', WalletTxFilter.expense),
                  const SizedBox(width: 8),
                  _buildFilterChip('Transfer', WalletTxFilter.transfer),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    searchQuery.isNotEmpty ? 'Hasil Pencarian (${filteredTx.length})' : 'Riwayat Transaksi',
                    style: AppTypography.sectionTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text('${filteredTx.length} transaksi', style: AppTypography.listSubtitle.copyWith(fontSize: 12)),
              ],
            ),
          ),
        ),
        if (filteredTx.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: AppColors.canvasCardSurface, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.canvasBorder)),
                child: Column(
                  children: [
                    Icon(searchQuery.isNotEmpty ? Icons.search_off_rounded : Icons.receipt_long_outlined, size: 36, color: AppColors.textSubtle),
                    const SizedBox(height: 10),
                    Text(searchQuery.isNotEmpty ? 'Tidak ada transaksi yang cocok' : 'Belum ada mutasi transaksi', style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textWhite)),
                  ],
                ),
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => WalletDetailTransactionTile(tx: filteredTx[index], walletId: wallet.id, currencyFormatter: currencyFormatter),
              childCount: filteredTx.length,
            ),
          ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 48),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(color: AppColors.canvasCardSurface, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.canvasBorder, width: 0.8)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 6, height: 6, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.neoMint)),
                    const SizedBox(width: 8),
                    Text('Offline & Terenkripsi', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
