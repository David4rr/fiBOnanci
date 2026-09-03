import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/database/app_database.dart';
import '../../domain/services/cashflow_analytics_service.dart';
import '../theme/app_colors.dart';
import 'transaction_detail_modal.dart';

export 'overlapping_deck_item.dart';
import 'overlapping_deck_item.dart';

/// Interactive scrollable stacked card deck matching the Apple Wallet / Passbook physics in the reference.
class StackedCardDeckScrollList extends StatefulWidget {
  final List<TransactionEntry> transactions;
  final List<TransactionEntry>? allTransactions;
  final List<WalletEntry> wallets;
  final String? expandedTxId;
  final ValueChanged<String?>? onToggleExpand;
  final double bottomPadding;

  const StackedCardDeckScrollList({
    super.key,
    required this.transactions,
    this.allTransactions,
    required this.wallets,
    this.expandedTxId,
    this.onToggleExpand,
    this.bottomPadding = 110.0,
  });

  @override
  State<StackedCardDeckScrollList> createState() => _StackedCardDeckScrollListState();
}

class _StackedCardDeckScrollListState extends State<StackedCardDeckScrollList> with SingleTickerProviderStateMixin {
  double _scrollOffset = 0.0;
  String? _internalExpandedId;
  late AnimationController _flingController;
  Animation<double>? _flingAnimation;

  // Stacking metrics
  static const double _cardStep = 85.0;
  static const double _collapsedCardHeight = 190.0;
  static const double _expandedCardHeight = 295.0;
  static const double _expandDisplacement = 190.0;
  static const double _dockStep = 14.0;
  static const int _maxDockedHeaders = 4;

  @override
  void initState() {
    super.initState();
    _internalExpandedId = widget.expandedTxId;
    _flingController = AnimationController(vsync: this);
    _flingController.addListener(() {
      if (_flingAnimation != null) {
        setState(() {
          _scrollOffset = _flingAnimation!.value;
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant StackedCardDeckScrollList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.expandedTxId != oldWidget.expandedTxId) {
      _internalExpandedId = widget.expandedTxId;
    }
  }

  @override
  void dispose() {
    _flingController.dispose();
    super.dispose();
  }

  double _getMaxScroll(int count, String? expandedId, double viewportHeight) {
    if (count <= 1) return 0.0;
    final totalNatural = (count - 1) * _cardStep + (expandedId != null ? _expandDisplacement : 0.0) + (expandedId != null ? _expandedCardHeight : _collapsedCardHeight);
    final availableHeight = viewportHeight - widget.bottomPadding;
    return math.max(0.0, totalNatural - availableHeight);
  }

  void _onDragUpdate(DragUpdateDetails details, double maxScroll) {
    if (_flingController.isAnimating) _flingController.stop();
    setState(() {
      _scrollOffset = (_scrollOffset - details.primaryDelta!).clamp(0.0, maxScroll);
    });
  }

  void _onDragEnd(DragEndDetails details, double maxScroll) {
    final velocity = details.primaryVelocity ?? 0.0;
    if (velocity.abs() > 100) {
      final double target = (_scrollOffset - velocity * 0.22).clamp(0.0, maxScroll);
      _flingAnimation = Tween<double>(begin: _scrollOffset, end: target).animate(
        CurvedAnimation(parent: _flingController, curve: Curves.easeOutCubic),
      );
      _flingController.duration = const Duration(milliseconds: 320);
      _flingController.forward(from: 0.0);
    }
  }

  double _getNaturalTop(int index, String? expandedId, List<TransactionEntry> list) {
    double y = 0.0;
    for (int j = 0; j < index; j++) {
      final isPrevExpanded = list[j].id == expandedId;
      y += isPrevExpanded ? _cardStep + _expandDisplacement : _cardStep;
    }
    return y;
  }

  @override
  Widget build(BuildContext context) {
    final list = widget.transactions;
    if (list.isEmpty) {
      return const SizedBox.shrink();
    }

    final String? currentExpandedId = widget.onToggleExpand != null ? widget.expandedTxId : _internalExpandedId;
    final sourceTransactions = widget.allTransactions ?? widget.transactions;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxScroll = _getMaxScroll(list.length, currentExpandedId, constraints.maxHeight);

        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onVerticalDragUpdate: (details) => _onDragUpdate(details, maxScroll),
          onVerticalDragEnd: (details) => _onDragEnd(details, maxScroll),
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, widget.bottomPadding),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                for (int i = 0; i < list.length; i++) ...[
                  Builder(builder: (context) {
                    final tx = list[i];
                    final isExpanded = currentExpandedId == tx.id;
                    final wallet = widget.wallets.firstWhere(
                      (w) => w.id == tx.walletId,
                      orElse: () => widget.wallets.first,
                    );

                    final cardColor = getExpenseCategoryColor(tx.type, tx.notes, tx.type, i);
                    final iconData = getExpenseCategoryIcon(tx.type, tx.notes);

                    // Compute real 7-day spending/income only when expanded (huge performance win)
                    final weeklySpending = isExpanded
                        ? CashflowAnalyticsService.computeWeeklySpending(
                            sourceTransactions,
                            referenceDate: tx.transactionDate,
                            categoryId: tx.categoryId,
                            type: tx.type,
                          )
                        : null;
                    // Natural unconstrained Y
                    final double naturalTop = _getNaturalTop(i, currentExpandedId, list);
                    final double screenY = naturalTop - _scrollOffset;

                    // Clamped docking Y at top header
                    final double dockY = math.min(i, _maxDockedHeaders) * _dockStep;
                    final double computedTop = math.max(screenY, dockY);

                    return AnimatedPositioned(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutCubic,
                      top: computedTop,
                      left: 0,
                      right: 0,
                      child: OverlappingDeckItem(
                        title: tx.notes?.isNotEmpty == true ? tx.notes! : (tx.type == 'expense' ? 'Pengeluaran' : 'Pemasukan'),
                        category: tx.type == 'transfer'
                            ? 'TRANSFER'
                            : (tx.type == 'expense' ? 'PENGELUARAN' : 'PEMASUKAN'),
                        amount: tx.amount,
                        isExpense: tx.type == 'expense' || tx.type == 'transfer',
                        categoryColor: cardColor,
                        iconData: iconData,
                        isExpanded: isExpanded,
                        transactionDate: tx.transactionDate,
                        weeklySpending: weeklySpending,
                        subtitle: '${wallet.name} • ${DateFormat('dd MMM yyyy, HH:mm').format(tx.transactionDate)}',
                        onTap: () {
                          final newId = isExpanded ? null : tx.id;
                          if (widget.onToggleExpand != null) {
                            widget.onToggleExpand!(newId);
                          } else {
                            setState(() {
                              _internalExpandedId = newId;
                            });
                          }
                        },
                        onManage: () => TransactionDetailModal.show(context, transaction: tx),
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Dynamic category color helper
Color getExpenseCategoryColor(String? category, String? title, String? type, int index) {
  final str = '${category ?? ''} ${title ?? ''}'.toLowerCase();
  if (str.contains('makan') || str.contains('food') || str.contains('resto') || str.contains('taco') || str.contains('mcd') || str.contains('kfc') || str.contains('kopi') || str.contains('cafe')) {
    return const Color(0xFFCBB776); // Warm Ochre / Sand
  }
  if (str.contains('spotify') || str.contains('musik') || str.contains('music') || str.contains('hiburan') || str.contains('entertain') || str.contains('game')) {
    return const Color(0xFF7E9D75); // Sage Olive Green
  }
  if (str.contains('amazon') || str.contains('belanja') || str.contains('product') || str.contains('shop') || str.contains('shopee') || str.contains('tokopedia')) {
    return const Color(0xFFFF7052); // Bold Neo-Orange
  }
  if (str.contains('transport') || str.contains('grab') || str.contains('gojek') || str.contains('uber') || str.contains('bensin') || str.contains('parkir')) {
    return const Color(0xFF2EBFA5); // Neo-Teal
  }
  if (str.contains('tagihan') || str.contains('bill') || str.contains('listrik') || str.contains('internet') || str.contains('pulsa') || str.contains('pln')) {
    return const Color(0xFFA78BFA); // Neo-Lavender
  }
  if (type == 'income') {
    return AppColors.neoMint;
  }

  const fallbackPalette = [
    Color(0xFFFF7052), // Orange
    Color(0xFF7E9D75), // Sage Green
    Color(0xFFCBB776), // Sand Ochre
    Color(0xFF2EBFA5), // Teal
    Color(0xFFA78BFA), // Lavender
    Color(0xFFD4F442), // Neo-Chartreuse
  ];
  return fallbackPalette[index % fallbackPalette.length];
}

/// Dynamic category icon helper
IconData getExpenseCategoryIcon(String? category, String? title) {
  final str = '${category ?? ''} ${title ?? ''}'.toLowerCase();
  if (str.contains('makan') || str.contains('food') || str.contains('resto') || str.contains('taco') || str.contains('mcd') || str.contains('kfc') || str.contains('kopi') || str.contains('cafe')) {
    return Icons.restaurant_rounded;
  }
  if (str.contains('spotify') || str.contains('musik') || str.contains('music')) {
    return Icons.music_note_rounded;
  }
  if (str.contains('netflix') || str.contains('film') || str.contains('movie') || str.contains('hiburan') || str.contains('game')) {
    return Icons.play_arrow_rounded;
  }
  if (str.contains('amazon') || str.contains('belanja') || str.contains('shop') || str.contains('shopee') || str.contains('tokopedia') || str.contains('product')) {
    return Icons.shopping_bag_rounded;
  }
  if (str.contains('transport') || str.contains('grab') || str.contains('gojek') || str.contains('uber') || str.contains('bensin')) {
    return Icons.directions_car_rounded;
  }
  if (str.contains('transfer')) {
    return Icons.swap_horiz_rounded;
  }
  return Icons.receipt_long_rounded;
}

