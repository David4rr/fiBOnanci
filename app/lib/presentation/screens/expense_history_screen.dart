import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../data/database/app_database.dart';
import '../../domain/services/cashflow_analytics_service.dart';
import '../theme/app_colors.dart';
import 'history/daily_calendar_bar.dart';
import 'history/expense_history_deck_view.dart';
import 'history/expense_history_search_bar.dart';

export 'history/daily_calendar_bar.dart';
export 'history/expense_history_deck_view.dart';
export 'history/expense_history_search_bar.dart';

class ExpenseHistoryScreen extends StatefulWidget {
  final List<TransactionEntry> allTransactions;
  final List<WalletEntry> wallets;

  const ExpenseHistoryScreen({super.key, required this.allTransactions, required this.wallets});

  static Future<void> show(
    BuildContext context, {
    required List<TransactionEntry> allTransactions,
    required List<WalletEntry> wallets,
    Widget Function(BuildContext)? builder,
  }) {
    return Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        opaque: false, barrierDismissible: true,
        barrierColor: Colors.black.withValues(alpha: 0.65),
        transitionDuration: const Duration(milliseconds: 320),
        reverseTransitionDuration: const Duration(milliseconds: 260),
        pageBuilder: (ctx, animation, secondaryAnimation) =>
            builder?.call(ctx) ?? ExpenseHistoryScreen(allTransactions: allTransactions, wallets: wallets),
        transitionsBuilder: (ctx, animation, secondaryAnimation, child) {
          final curvedAnim = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);
          final slide = Tween<Offset>(begin: const Offset(0.0, 0.08), end: Offset.zero).animate(curvedAnim);
          final fade = Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnim);
          return SlideTransition(position: slide, child: FadeTransition(opacity: fade, child: child));
        },
      ),
    );
  }

  @override
  State<ExpenseHistoryScreen> createState() => _ExpenseHistoryScreenState();
}

class _ExpenseHistoryScreenState extends State<ExpenseHistoryScreen> with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  final _dayScrollController = ScrollController();
  String _searchQuery = '';
  String _typeFilter = 'all';
  String? _walletFilter;
  int? _selectedDayIndex;
  double _dragOffset = 0.0;
  late AnimationController _springController;
  Animation<double>? _springAnimation;

  static final _currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _springController = AnimationController.unbounded(vsync: this);
    _springController.addListener(() => setState(() => _dragOffset = _springAnimation?.value ?? 0.0));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_dayScrollController.hasClients) _dayScrollController.jumpTo(_dayScrollController.position.maxScrollExtent);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _dayScrollController.dispose();
    _springController.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails d) {
    if (d.primaryDelta != null) setState(() => _dragOffset = (_dragOffset + d.primaryDelta!).clamp(0.0, 300.0));
  }

  void _onDragEnd(DragEndDetails d) {
    final v = d.primaryVelocity ?? 0.0;
    if (_dragOffset >= 110.0 || v >= 650.0) {
      Navigator.of(context).pop();
    } else {
      final sim = SpringSimulation(const SpringDescription(mass: 1.0, stiffness: 440.0, damping: 26.0), _dragOffset, 0.0, v);
      _springAnimation = _springController.drive(Tween<double>(begin: _dragOffset, end: 0.0));
      _springController.animateWith(sim);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = CashflowAnalyticsService.filterTransactions(
      transactions: widget.allTransactions, wallets: widget.wallets,
      query: _searchQuery, typeFilter: _typeFilter, walletFilter: _walletFilter,
    );
    final dayGroups = DailyDateHelper.groupByDay(filtered);
    final sortedDays = DailyDateHelper.getAllDateKeys(dayGroups);
    final safeIndex = _selectedDayIndex != null && _selectedDayIndex! >= 0 && _selectedDayIndex! < sortedDays.length
        ? _selectedDayIndex!
        : (sortedDays.isNotEmpty ? sortedDays.length - 1 : 0);
    final currentDayKey = sortedDays.isNotEmpty ? sortedDays[safeIndex] : '';
    final currentDayTxs = sortedDays.isNotEmpty ? (dayGroups[currentDayKey] ?? const []) : <TransactionEntry>[];
    final isIncome = _typeFilter == 'income';
    final totalFiltered = filtered.where((t) => isIncome ? t.type == 'income' : (t.type == 'expense' || t.type == 'transfer')).fold(0.0, (s, t) => s + t.amount);
    final dragScale = (1.0 - (_dragOffset / 1200.0)).clamp(0.92, 1.0);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragUpdate: _onDragUpdate,
        onVerticalDragEnd: _onDragEnd,
        child: Transform.translate(
          offset: Offset(0, _dragOffset),
          child: Transform.scale(
            scale: dragScale,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.canvasBg,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16 + (_dragOffset * 0.08))),
                border: Border.all(color: AppColors.canvasBorder, width: 1),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 4),
                      child: Center(child: Container(width: 38, height: 4, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(2)))),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Riwayat\nPengeluaran', style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textWhite, height: 1.06, letterSpacing: -0.8)),
                                const SizedBox(height: 4),
                                Text('Total Terfilter: ${_currencyFormatter.format(totalFiltered)}', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textMuted)),
                              ],
                            ),
                          ),
                          IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 28, color: AppColors.textWhite)),
                        ],
                      ),
                    ),
                    ExpenseHistorySearchBar(
                      searchController: _searchController,
                      searchQuery: _searchQuery,
                      typeFilter: _typeFilter,
                      walletFilter: _walletFilter,
                      wallets: widget.wallets,
                      onSearchChanged: (q) => setState(() => _searchQuery = q.trim().toLowerCase()),
                      onClearSearch: () => setState(() => _searchQuery = ''),
                      onFilterApplied: (t, w) => setState(() {
                        _typeFilter = t; _walletFilter = w; _selectedDayIndex = null;
                      }),
                      onClearTypeFilter: () => setState(() => _typeFilter = 'all'),
                      onClearWalletFilter: () => setState(() => _walletFilter = null),
                    ),
                    const SizedBox(height: 6),
                    DailyCalendarBar(
                      scrollController: _dayScrollController,
                      sortedDays: sortedDays,
                      selectedIndex: safeIndex,
                      dayGroups: dayGroups,
                      onDaySelected: (idx) => setState(() => _selectedDayIndex = idx),
                    ),
                    const SizedBox(height: 10),
                    ExpenseHistoryDeckView(
                      isFiltering: _searchQuery.isNotEmpty || _typeFilter != 'all' || _walletFilter != null,
                      searchQuery: _searchQuery,
                      filtered: filtered,
                      sortedDays: sortedDays,
                      currentDayKey: currentDayKey,
                      currentDayTxs: currentDayTxs,
                      allTransactions: widget.allTransactions,
                      wallets: widget.wallets,
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
}
