import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../data/database/app_database.dart';
import '../../domain/services/cashflow_analytics_service.dart';
import '../theme/app_colors.dart';
import 'transaction_detail_modal.dart';

/// Individual pastel expense card item matching the Swiss-editorial reference.
class OverlappingDeckItem extends StatelessWidget {
  final String title;
  final String category;
  final double amount;
  final Color categoryColor;
  final IconData iconData;
  final String? subtitle;
  final bool isExpense;
  final bool isExpanded;
  final DateTime? transactionDate;
  final List<double>? weeklySpending;
  final VoidCallback? onTap;
  final VoidCallback? onManage;

  const OverlappingDeckItem({
    super.key,
    required this.title,
    required this.category,
    required this.amount,
    required this.categoryColor,
    required this.iconData,
    this.subtitle,
    this.isExpense = true,
    this.isExpanded = false,
    this.transactionDate,
    this.weeklySpending,
    this.onTap,
    this.onManage,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: isExpense ? '-Rp ' : '+Rp ',
      decimalDigits: 0,
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        height: isExpanded ? 295.0 : 190.0,
        clipBehavior: Clip.antiAlias,
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
        decoration: BoxDecoration(
          color: categoryColor,
          borderRadius: BorderRadius.circular(26),
          border: isExpanded ? Border.all(color: const Color(0xFF0C0D11).withValues(alpha: 0.35), width: 2) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isExpanded ? 0.45 : 0.35),
              blurRadius: isExpanded ? 20 : 14,
              offset: Offset(0, isExpanded ? -6 : -4),
              spreadRadius: isExpanded ? 2 : 1,
            ),
          ],
        ),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Row: Icon Circle Avatar & Tabular Amount
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF0C0D11).withValues(alpha: 0.12),
                    ),
                    child: Center(
                      child: Icon(iconData, color: const Color(0xFF0C0D11), size: 20),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    currencyFormatter.format(amount.abs()),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0C0D11),
                      letterSpacing: -0.6,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Middle: Category Eyebrow
              Text(
                category.toUpperCase(),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0C0D11).withValues(alpha: 0.65),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),

              // Title: Merchant / Note
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0C0D11),
                  letterSpacing: -0.4,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              // Expanded Insight: 7-Day Bar Chart & Detail Action
              if (isExpanded) ...[
                const SizedBox(height: 14),
                Container(
                  height: 1,
                  color: const Color(0xFF0C0D11).withValues(alpha: 0.14),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Tren ${category.toLowerCase()} (Sen–Min)',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0C0D11).withValues(alpha: 0.65),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (weeklySpending != null)
                      Text(
                        currencyFormatter.format(weeklySpending!.reduce((a, b) => a + b)),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0C0D11).withValues(alpha: 0.8),
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: _buildMini7DayBarChart(transactionDate ?? DateTime.now(), weeklySpending),
                    ),
                    if (onManage != null) ...[
                      const SizedBox(width: 14),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: onManage,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0C0D11),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Kelola',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: categoryColor,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(Icons.arrow_forward_rounded, size: 15, color: categoryColor),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0C0D11).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.account_balance_wallet_outlined, size: 14, color: Color(0xFF0C0D11)),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            subtitle!,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0C0D11).withValues(alpha: 0.85),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMini7DayBarChart(DateTime txDate, List<double>? weeklySpending) {
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    final int activeDayIndex = (txDate.weekday - 1).clamp(0, 6);

    // Real data for the 7 days of the week [Monday..Sunday]
    final data = (weeklySpending != null && weeklySpending.length == 7)
        ? weeklySpending
        : List.filled(7, 0.0);

    final double maxSpend = data.reduce(math.max);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (int d = 0; d < 7; d++) ...[
          Builder(builder: (context) {
            final double spend = data[d];
            final bool isTodayOrActive = d == activeDayIndex;

            // Height calculated dynamically from real spend (minimum 6dp, max 48dp)
            final double barHeight = maxSpend > 0
                ? (spend > 0 ? (spend / maxSpend * 40.0 + 8.0).clamp(8.0, 48.0) : 6.0)
                : (isTodayOrActive ? 24.0 : 6.0);

            return Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: barHeight,
                    margin: const EdgeInsets.symmetric(horizontal: 2.5),
                    decoration: BoxDecoration(
                      color: isTodayOrActive
                          ? const Color(0xFF0C0D11)
                          : (spend > 0
                              ? const Color(0xFF0C0D11).withValues(alpha: 0.55)
                              : const Color(0xFF0C0D11).withValues(alpha: 0.18)),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    days[d],
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9,
                      fontWeight: isTodayOrActive ? FontWeight.w800 : FontWeight.w600,
                      color: const Color(0xFF0C0D11).withValues(alpha: isTodayOrActive ? 0.95 : 0.45),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }
}

/// Vertically stacked deck of cards overlapping by negative vertical step
class OverlappingDeckList extends StatelessWidget {
  final List<Widget> children;
  final double overlapOffset;
  final double stepOffset;
  final double cardHeight;

  const OverlappingDeckList({
    super.key,
    required this.children,
    this.overlapOffset = 70.0,
    this.stepOffset = 95.0,
    this.cardHeight = 200.0,
  });

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return const SizedBox.shrink();
    }

    final totalHeight = (children.length - 1) * stepOffset + cardHeight;

    return SizedBox(
      height: totalHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (int i = 0; i < children.length; i++)
            Positioned(
              top: i * stepOffset,
              left: 0,
              right: 0,
              child: children[i],
            ),
        ],
      ),
    );
  }
}

/// Interactive scrollable stacked card deck matching the Apple Wallet / Passbook physics in the reference.
class StackedCardDeckScrollList extends StatefulWidget {
  final List<TransactionEntry> transactions;
  final List<TransactionEntry>? allTransactions;
  final List<WalletEntry> wallets;
  final AppDatabase db;
  final String? expandedTxId;
  final ValueChanged<String?>? onToggleExpand;
  final double bottomPadding;

  const StackedCardDeckScrollList({
    super.key,
    required this.transactions,
    this.allTransactions,
    required this.wallets,
    required this.db,
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

                    // Compute real 7-day spending for the week of this transaction, scoped to its category
                    final weeklySpending = CashflowAnalyticsService.computeWeeklySpending(
                      sourceTransactions,
                      referenceDate: tx.transactionDate,
                      categoryId: tx.categoryId,
                    );

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
                        onManage: () => TransactionDetailModal.show(context, db: widget.db, transaction: tx),
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

