import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../data/database/app_database.dart';
import '../../domain/services/cashflow_analytics_service.dart';
import '../modals/all_transactions_modal.dart';
import '../modals/transaction_filter_modal.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/overlapping_deck.dart';

/// Dedicated full-screen "Expenses / Riwayat Pengeluaran" screen.
///
/// Features:
/// - Shared-element `Hero` search bar transition with lightweight smooth entry
/// - Interactive pull-to-dismiss gesture with 1:1 finger tracking and spring snap-back
/// - Modern Swiss-editorial minimalist geometry (strict non-pill, rectangular with subtle 8-10px radii)
/// - Search bar 100% consistent with Dashboard:
///   * Same 46px height, 16px horizontal padding, 10px corner radius
///   * Same search icon, hint text ("Cari transaksi, rekening, merchant..."), and typography
///   * Same integrated Icons.tune filter button with active neon indicator
///   * Same TransactionFilterModal integration and active filter chips
/// - 3-Month chronological daily calendar bar horizontally scrollable left and right
/// - Default view set to Today on the far right with auto-scroll
/// - Balanced airy spacing between Today context indicator and top card deck
/// - Lazy-rendered stacked card deck with 120 FPS fluid scroll
class ExpenseHistoryScreen extends StatefulWidget {
  final List<TransactionEntry> allTransactions;
  final List<WalletEntry> wallets;

  const ExpenseHistoryScreen({
    super.key,
    required this.allTransactions,
    required this.wallets,
  });

  /// Opens the expense history screen with a tactile interactive spring animation.
  static Future<void> show(
    BuildContext context, {
    required List<TransactionEntry> allTransactions,
    required List<WalletEntry> wallets,
  }) {
    return Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black.withValues(alpha: 0.65),
        transitionDuration: const Duration(milliseconds: 320),
        reverseTransitionDuration: const Duration(milliseconds: 260),
        pageBuilder: (ctx, animation, secondaryAnimation) {
          return AllTransactionsModal(
            allTransactions: allTransactions,
            wallets: wallets,
          );
        },
        transitionsBuilder: (ctx, animation, secondaryAnimation, child) {
          final curvedAnim = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          final slide = Tween<Offset>(
            begin: const Offset(0.0, 0.08),
            end: Offset.zero,
          ).animate(curvedAnim);
          final fade = Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(curvedAnim);

          return SlideTransition(
            position: slide,
            child: FadeTransition(
              opacity: fade,
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  State<ExpenseHistoryScreen> createState() => _ExpenseHistoryScreenState();
}

class _ExpenseHistoryScreenState extends State<ExpenseHistoryScreen>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  final _dayScrollController = ScrollController();

  String _searchQuery = '';
  String _typeFilter = 'all';
  String? _walletFilter;
  String? _expandedTxId;
  int? _selectedDayIndex;

  // Interactive pull-to-dismiss gesture state
  double _dragOffset = 0.0;
  late AnimationController _springController;
  Animation<double>? _springAnimation;

  static final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _springController = AnimationController.unbounded(vsync: this);
    _springController.addListener(() {
      setState(() {
        _dragOffset = _springAnimation?.value ?? 0.0;
      });
    });

    // Auto-scroll day tabs to the far right so Today is immediately in view
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToTodayTab();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _dayScrollController.dispose();
    _springController.dispose();
    super.dispose();
  }

  void _scrollToTodayTab() {
    if (_dayScrollController.hasClients) {
      _dayScrollController.jumpTo(_dayScrollController.position.maxScrollExtent);
    }
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (details.primaryDelta == null) return;
    setState(() {
      _dragOffset = (_dragOffset + details.primaryDelta!).clamp(0.0, 300.0);
    });
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0.0;
    if (_dragOffset >= 110.0 || velocity >= 650.0) {
      Navigator.of(context).pop();
    } else {
      // Spring snap-back to 0.0
      final simulation = SpringSimulation(
        const SpringDescription(mass: 1.0, stiffness: 440.0, damping: 26.0),
        _dragOffset,
        0.0,
        velocity,
      );
      _springAnimation = _springController.drive(Tween<double>(begin: _dragOffset, end: 0.0));
      _springController.animateWith(simulation);
    }
  }

  /// Filters transactions using CashflowAnalyticsService without any date limits (unlimited history).
  List<TransactionEntry> get _filteredTransactions {
    return CashflowAnalyticsService.filterTransactions(
      transactions: widget.allTransactions,
      wallets: widget.wallets,
      query: _searchQuery,
      typeFilter: _typeFilter,
      walletFilter: _walletFilter,
    );
  }

  /// Generates chronological daily date keys (yyyy-MM-dd) covering all transaction history up to Today.
  List<String> _getAllDateKeys(Map<String, List<TransactionEntry>> dayGroups) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayKey =
        '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final keysSet = <String>{};

    // Keep the last 7 calendar days readily available for fast recent navigation
    for (int i = 6; i >= 0; i--) {
      final d = today.subtract(Duration(days: i));
      final key =
          '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      keysSet.add(key);
    }

    // Include every date that has transactions across all historical entries without any limit
    keysSet.addAll(dayGroups.keys);
    keysSet.add(todayKey);

    final sorted = keysSet.toList()..sort((a, b) => a.compareTo(b));
    return sorted;
  }
  /// Groups transactions by date (yyyy-MM-dd) to paginate into daily tabs.
  Map<String, List<TransactionEntry>> _groupByDay(List<TransactionEntry> list) {
    final map = <String, List<TransactionEntry>>{};
    for (final tx in list) {
      final d = tx.transactionDate.toLocal();
      final key =
          '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      map.putIfAbsent(key, () => []).add(tx);
    }
    return map;
  }

  String _formatDayTabLabel(String dateKey) {
    final parts = dateKey.split('-');
    if (parts.length != 3) return dateKey;
    final date = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
    final now = DateTime.now();

    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Hari Ini';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day) {
      return 'Kemarin';
    }
    if (date.year != now.year) {
      return DateFormat('d MMM yy', 'id_ID').format(date);
    }
    return DateFormat('d MMM', 'id_ID').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredTransactions;
    final dayGroups = _groupByDay(filtered);

    // Unlimited date range: all days in history up to Today on the far right
    final sortedDays = _getAllDateKeys(dayGroups);
    // Default to the last index (Today on the right side) if not manually selected
    final safeIndex = _selectedDayIndex != null &&
            _selectedDayIndex! >= 0 &&
            _selectedDayIndex! < sortedDays.length
        ? _selectedDayIndex!
        : (sortedDays.isNotEmpty ? sortedDays.length - 1 : 0);

    final currentDayKey = sortedDays.isNotEmpty ? sortedDays[safeIndex] : '';
    final currentDayTransactions =
        sortedDays.isNotEmpty ? (dayGroups[currentDayKey] ?? const []) : <TransactionEntry>[];

    final double totalExpense = filtered
        .where((t) => t.type == 'expense' || t.type == 'transfer')
        .fold(0.0, (sum, t) => sum + t.amount);

    final isFiltering = _searchQuery.isNotEmpty || _typeFilter != 'all' || _walletFilter != null;
    final isToday = currentDayKey.isNotEmpty && _formatDayTabLabel(currentDayKey) == 'Hari Ini';

    final dragScale = (1.0 - (_dragOffset / 1200.0)).clamp(0.92, 1.0);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onVerticalDragUpdate: _onVerticalDragUpdate,
        onVerticalDragEnd: _onVerticalDragEnd,
        behavior: HitTestBehavior.opaque,
        child: Transform.translate(
          offset: Offset(0, _dragOffset),
          child: Transform.scale(
            scale: dragScale,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.canvasBg,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(16 + (_dragOffset * 0.08)),
                ),
                border: Border.all(
                  color: AppColors.canvasBorder,
                  width: 1,
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // Pull-Down Handle Bar for interactive dismissal
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 4),
                      child: Center(
                        child: Container(
                          width: 38,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),

                    // Header: Title 'Riwayat Pengeluaran' & Close Chevron
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
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
                                  'Total Terfilter: ${_currencyFormatter.format(totalExpense)}',
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
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.canvasInputSearch,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.canvasBorder,
                                  width: 1,
                                ),
                              ),
                              child: const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 28,
                                color: AppColors.textWhite,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Search Bar (100% consistent with Dashboard)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      child: Container(
                          height: 46,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.canvasInputSearch,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _searchQuery.isNotEmpty
                                  ? AppColors.neoChartreuse.withValues(alpha: 0.5)
                                  : AppColors.canvasBorder,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.search, color: AppColors.textMuted, size: 18),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  style: const TextStyle(color: AppColors.textWhite, fontSize: 13.5),
                                  onChanged: (val) {
                                    setState(() {
                                      _searchQuery = val.trim().toLowerCase();
                                      _expandedTxId = null;
                                    });
                                  },
                                  decoration: const InputDecoration(
                                    hintText: 'Cari transaksi, rekening, merchant...',
                                    hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 12.5),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                              if (_searchQuery.isNotEmpty)
                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Icon(Icons.close, color: AppColors.textMuted, size: 16),
                                  ),
                                ),
                              const SizedBox(width: 6),
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  TransactionFilterModal.show(
                                    context: context,
                                    wallets: widget.wallets,
                                    initialType: _typeFilter,
                                    initialWalletId: _walletFilter,
                                    onApply: (type, walletId) {
                                      setState(() {
                                        _typeFilter = type;
                                        _walletFilter = walletId;
                                        _selectedDayIndex = null;
                                        _expandedTxId = null;
                                      });
                                    },
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: (_typeFilter != 'all' || _walletFilter != null)
                                        ? AppColors.neoChartreuse.withValues(alpha: 0.2)
                                        : Colors.transparent,
                                  ),
                                  child: Icon(
                                    Icons.tune,
                                    color: (_typeFilter != 'all' || _walletFilter != null)
                                        ? AppColors.neoChartreuse
                                        : AppColors.textWhite,
                                    size: 17,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Active Filter Chips (100% consistent with Dashboard Screen)
                    if (_typeFilter != 'all' || _walletFilter != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: [
                              if (_typeFilter != 'all')
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.canvasInputSearch,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: AppColors.neoChartreuse, width: 1),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Tipe: ${_typeFilter.toUpperCase()}',
                                          style: AppTypography.badgeLabel.copyWith(color: AppColors.neoChartreuse),
                                        ),
                                        const SizedBox(width: 4),
                                        GestureDetector(
                                          onTap: () => setState(() => _typeFilter = 'all'),
                                          child: const Icon(Icons.close, size: 14, color: AppColors.neoChartreuse),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              if (_walletFilter != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.canvasInputSearch,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.neoChartreuse, width: 1),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Rek: ${widget.wallets.firstWhere((w) => w.id == _walletFilter, orElse: () => widget.wallets.first).name}',
                                        style: AppTypography.badgeLabel.copyWith(color: AppColors.neoChartreuse),
                                      ),
                                      const SizedBox(width: 4),
                                      GestureDetector(
                                        onTap: () => setState(() => _walletFilter = null),
                                        child: const Icon(Icons.close, size: 14, color: AppColors.neoChartreuse),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                    // Daily Tabs (Horizontally scrollable across entire history with Today on the far right)
                    if (!isFiltering && sortedDays.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 8, bottom: 4),
                        height: 38,
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: AppColors.canvasBorder, width: 1.0),
                          ),
                        ),
                        child: SingleChildScrollView(
                          controller: _dayScrollController,
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              for (int i = 0; i < sortedDays.length; i++) ...[
                                if (i > 0) const SizedBox(width: 4),
                                _buildDayTab(
                                  dayKey: sortedDays[i],
                                  index: i,
                                  safeIndex: safeIndex,
                                  count: dayGroups[sortedDays[i]]?.length ?? 0,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                    // Context Indicator Bar (Active day or Search/Filter results indicator)
                    // Generous spacing to ensure the "Today" label and transaction count have clear breathing room
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
                      child: Row(
                        mainAxisAlignment: isFiltering ? MainAxisAlignment.start : MainAxisAlignment.spaceBetween,
                        children: [
                          if (isFiltering)
                            Text(
                              _searchQuery.isNotEmpty
                                  ? 'Hasil Pencarian: ${filtered.length} Transaksi'
                                  : 'Hasil Filter: ${filtered.length} Transaksi',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.neoChartreuse,
                              ),
                            )
                          else if (sortedDays.isNotEmpty) ...[
                            Text(
                              _formatDayTabLabel(currentDayKey).toUpperCase(),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.0,
                                color: isToday ? AppColors.neoChartreuse : AppColors.textWhite,
                              ),
                            ),
                            Text(
                              '//  ${currentDayTransactions.length} TRANSAKSI',
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

                    // Stacked Cards List View (Shared component Hero transition for card history)
                    Expanded(
                      child: Hero(
                        tag: 'expense_history_card_history',
                        flightShuttleBuilder: (
                          flightContext,
                          animation,
                          flightDirection,
                          fromHeroContext,
                          toHeroContext,
                        ) {
                          final Hero toHero = toHeroContext.widget as Hero;
                          return Material(
                            color: Colors.transparent,
                            child: toHero.child,
                          );
                        },
                        child: !isFiltering && currentDayTransactions.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.receipt_long_outlined,
                                          color: AppColors.textMuted, size: 40),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Belum ada transaksi pada tanggal ini',
                                        textAlign: TextAlign.center,
                                        style: AppTypography.listSubtitle,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : (filtered.isEmpty
                                ? Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(24),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.receipt_long_outlined,
                                              color: AppColors.textMuted, size: 40),
                                          const SizedBox(height: 12),
                                          Text(
                                            isFiltering
                                                ? (_searchQuery.isNotEmpty
                                                    ? 'Tidak ada transaksi dengan kata kunci "$_searchQuery"'
                                                    : 'Tidak ada transaksi yang cocok dengan filter')
                                                : 'Belum ada transaksi di riwayat',
                                            textAlign: TextAlign.center,
                                            style: AppTypography.listSubtitle,
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : StackedCardDeckScrollList(
                                    transactions: isFiltering ? filtered : currentDayTransactions,
                                    allTransactions: widget.allTransactions,
                                    wallets: widget.wallets,
                                    expandedTxId: _expandedTxId,
                                    onToggleExpand: (id) => setState(() => _expandedTxId = id),
                                    bottomPadding: 30.0,
                                  )),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds a minimalist flat Swiss-editorial day tab (zero pills, clean bottom accent line).
  Widget _buildDayTab({
    required String dayKey,
    required int index,
    required int safeIndex,
    required int count,
  }) {
    final isSelected = index == safeIndex;
    final label = _formatDayTabLabel(dayKey);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          _selectedDayIndex = index;
          _expandedTxId = null;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.neoChartreuse.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.zero,
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.neoChartreuse : Colors.transparent,
              width: 2.0,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                color: isSelected ? AppColors.neoChartreuse : AppColors.textMuted,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              '$count',
              style: GoogleFonts.plusJakartaSans(
                color: isSelected
                    ? AppColors.neoChartreuse.withValues(alpha: 0.8)
                    : AppColors.textMuted.withValues(alpha: 0.5),
                fontSize: 10,
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
