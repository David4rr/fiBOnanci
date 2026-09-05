import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/database/app_database.dart';
import '../../domain/services/cashflow_analytics_service.dart';
import '../widgets/common/common_widgets.dart';
import 'history/daily_calendar_bar.dart';
import 'history/expense_history_deck_view.dart';
import 'history/expense_history_search_bar.dart';
import 'history/expense_history_app_bar.dart';

export 'history/daily_calendar_bar.dart';
export 'history/expense_history_deck_view.dart';
export 'history/expense_history_search_bar.dart';
export 'history/expense_history_app_bar.dart';

class ExpenseHistoryScreen extends StatefulWidget {
  final List<TransactionEntry> allTransactions;
  final List<WalletEntry> wallets;
  final double initialChildSize;

  const ExpenseHistoryScreen({
    super.key,
    required this.allTransactions,
    required this.wallets,
    this.initialChildSize = 1.0,
  });

  static Future<void> show(
    BuildContext context, {
    required List<TransactionEntry> allTransactions,
    required List<WalletEntry> wallets,
    double initialChildSize = 1.0,
    Widget Function(BuildContext)? builder,
  }) {
    return Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black.withValues(alpha: 0.65),
        transitionDuration: const Duration(milliseconds: 320),
        reverseTransitionDuration: const Duration(milliseconds: 260),
        pageBuilder: (ctx, animation, secondaryAnimation) =>
            builder?.call(ctx) ??
            ExpenseHistoryScreen(
              allTransactions: allTransactions,
              wallets: wallets,
              initialChildSize: initialChildSize,
            ),
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

class _ExpenseHistoryScreenState extends State<ExpenseHistoryScreen> {
  final _sheetKey = GlobalKey<ExpandableModalSheetState>();
  final _searchController = TextEditingController();
  final _dayScrollController = ScrollController();
  String _searchQuery = '';
  String _typeFilter = 'all';
  String? _walletFilter;
  int? _selectedDayIndex;

  static final _currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_dayScrollController.hasClients) _dayScrollController.jumpTo(_dayScrollController.position.maxScrollExtent);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _dayScrollController.dispose();
    super.dispose();
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

    return ExpandableModalSheet(
      key: _sheetKey,
      initialChildSize: widget.initialChildSize,
      minChildSize: 0.40,
      maxChildSize: 1.0,
      snapSizes: const [0.85, 1.0],
      builder: (ctx, scrollController, currentSize) {
        return Column(
          children: [
            ExpenseHistoryAppBar(
              totalFiltered: totalFiltered,
              currencyFormatter: _currencyFormatter,
              onDragUpdate: (d) => _sheetKey.currentState?.handleHeaderDragUpdate(d),
              onDragEnd: (d) => _sheetKey.currentState?.handleHeaderDragEnd(d),
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
        );
      },
    );
  }
}
