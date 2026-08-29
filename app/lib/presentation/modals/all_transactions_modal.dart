import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../data/database/app_database.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/overlapping_deck.dart';
import '../widgets/transaction_detail_modal.dart';

/// Full-screen Swiss-editorial "Expenses / Riwayat Transaksi" modal matching the reference design.
///
/// Features:
/// - Full-screen layout with 'Expenses' header and top-right dismiss chevron.
/// - Dynamic category-based pastel cards (Orange, Sage Green, Warm Sand, Teal, Lavender).
/// - Tap to expand mini 7-day spend bar chart breakdown and manage options.
/// - Integrated search and category filtering.
class AllTransactionsModal extends StatefulWidget {
  final List<TransactionEntry> allTransactions;
  final List<WalletEntry> wallets;
  final AppDatabase db;

  const AllTransactionsModal({
    super.key,
    required this.allTransactions,
    required this.wallets,
    required this.db,
  });

  static void show(
    BuildContext context, {
    required List<TransactionEntry> allTransactions,
    required List<WalletEntry> wallets,
    required AppDatabase db,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AllTransactionsModal(
        allTransactions: allTransactions,
        wallets: wallets,
        db: db,
      ),
    );
  }

  @override
  State<AllTransactionsModal> createState() => _AllTransactionsModalState();
}

class _AllTransactionsModalState extends State<AllTransactionsModal> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _typeFilter = 'all';
  String? _expandedTxId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TransactionEntry> get _filteredTransactions {
    return widget.allTransactions.where((tx) {
      if (_typeFilter != 'all' && tx.type != _typeFilter) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final notes = (tx.notes ?? '').toLowerCase();
        final type = tx.type.toLowerCase();
        final wallet = widget.wallets.firstWhere(
          (w) => w.id == tx.walletId,
          orElse: () => widget.wallets.first,
        );
        final walletName = wallet.name.toLowerCase();
        return notes.contains(query) || type.contains(query) || walletName.contains(query);
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final filtered = _filteredTransactions;

    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final double totalExpense = filtered
        .where((t) => t.type == 'expense' || t.type == 'transfer')
        .fold(0.0, (sum, t) => sum + t.amount);

    return Container(
      height: screenHeight,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.canvasBg,
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header: Title 'Expenses' & Close Chevron
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Riwayat\nPengeluaran',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textWhite,
                            height: 1.06,
                            letterSpacing: -0.8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Total Terfilter: ${currencyFormatter.format(totalExpense)}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.topRight,
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 36,
                        color: AppColors.textWhite,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar & Filter Chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                children: [
                  Container(
                    height: 46,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: AppColors.canvasInputSearch,
                      borderRadius: BorderRadius.circular(23),
                      border: Border.all(color: AppColors.canvasBorder),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: AppColors.textMuted, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(color: AppColors.textWhite, fontSize: 13),
                            onChanged: (val) => setState(() => _searchQuery = val.trim()),
                            decoration: const InputDecoration(
                              hintText: 'Cari riwayat transaksi...',
                              hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 12),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        if (_searchQuery.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                            child: const Icon(Icons.close, color: AppColors.textMuted, size: 16),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildFilterChip('Semua (${widget.allTransactions.length})', 'all'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Pengeluaran', 'expense'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Pemasukan', 'income'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Transfer', 'transfer'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Stacked Cards List View
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.receipt_long_outlined, color: AppColors.textMuted, size: 40),
                            const SizedBox(height: 12),
                            Text(
                              _searchQuery.isNotEmpty
                                  ? 'Tidak ada transaksi dengan kata kunci "$_searchQuery"'
                                  : 'Belum ada transaksi di riwayat',
                              textAlign: TextAlign.center,
                              style: AppTypography.listSubtitle,
                            ),
                          ],
                        ),
                      ),
                    )
                  : StackedCardDeckScrollList(
                      transactions: filtered,
                      allTransactions: widget.allTransactions,
                      wallets: widget.wallets,
                      db: widget.db,
                      expandedTxId: _expandedTxId,
                      onToggleExpand: (id) => setState(() => _expandedTxId = id),
                      bottomPadding: 30.0,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _typeFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _typeFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.neoChartreuse : AppColors.canvasCardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.neoChartreuse : AppColors.canvasBorder,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.textDarkPrimary : AppColors.textWhite,
          ),
        ),
      ),
    );
  }
}
