import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/database/app_database.dart';
import '../../domain/services/cashflow_analytics_service.dart';
import 'expense_category_helpers.dart';
import 'overlapping_deck_item.dart';
import 'transaction_detail_modal.dart';

export 'expense_category_helpers.dart';
export 'overlapping_deck_item.dart';

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
    final totalNatural = (count - 1) * _cardStep +
        (expandedId != null ? _expandDisplacement : 0.0) +
        (expandedId != null ? _expandedCardHeight : _collapsedCardHeight);
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
    if (list.isEmpty) return const SizedBox.shrink();

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

                    final weeklySpending = isExpanded
                        ? CashflowAnalyticsService.computeWeeklySpending(
                            sourceTransactions,
                            referenceDate: tx.transactionDate,
                            categoryId: tx.categoryId,
                            type: tx.type,
                          )
                        : null;
                    final double naturalTop = _getNaturalTop(i, currentExpandedId, list);
                    final double screenY = naturalTop - _scrollOffset;
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
                        category: tx.type == 'transfer' ? 'TRANSFER' : (tx.type == 'expense' ? 'PENGELUARAN' : 'PEMASUKAN'),
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
                            setState(() => _internalExpandedId = newId);
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
