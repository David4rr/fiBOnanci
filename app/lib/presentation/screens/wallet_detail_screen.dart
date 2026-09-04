import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../bloc/finance/finance_bloc.dart';
import '../../bloc/finance/finance_state.dart';
import '../../data/database/app_database.dart';
import '../theme/app_colors.dart';
import '../widgets/wallet_card.dart';
import 'wallet_detail/wallet_detail_app_bar.dart';
import 'wallet_detail/wallet_detail_history_section.dart';
import 'wallet_detail/wallet_detail_modal_route.dart';
import 'wallet_detail/wallet_detail_radial_glow.dart';
import 'wallet_detail/wallet_detail_scroll_view.dart';

export 'wallet_detail/tactile_hero_card.dart';
export 'wallet_detail/wallet_detail_actions_and_chart.dart';
export 'wallet_detail/wallet_detail_app_bar.dart';
export 'wallet_detail/wallet_detail_history_section.dart';
export 'wallet_detail/wallet_detail_modal_route.dart';
export 'wallet_detail/wallet_detail_radial_glow.dart';
export 'wallet_detail/wallet_detail_scroll_view.dart';

class WalletDetailScreen extends StatefulWidget {
  final String walletId;
  final NumberFormat currencyFormatter;

  const WalletDetailScreen({
    super.key,
    required this.walletId,
    required this.currencyFormatter,
  });

  static Future<void> show(BuildContext context, {required WalletEntry wallet}) =>
      WalletDetailModalRoute.show(context, wallet: wallet);

  static Future<void> push(BuildContext context, {required WalletEntry wallet}) =>
      WalletDetailModalRoute.show(context, wallet: wallet);

  @override
  State<WalletDetailScreen> createState() => _WalletDetailScreenState();
}

class _WalletDetailScreenState extends State<WalletDetailScreen> with SingleTickerProviderStateMixin {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  double _scrollOffset = 0.0;
  double _dragOffset = 0.0;
  late AnimationController _springController;
  Animation<double>? _springAnimation;
  WalletTxFilter _selectedFilter = WalletTxFilter.all;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _springController = AnimationController.unbounded(vsync: this);
    _springController.addListener(() => setState(() => _dragOffset = _springAnimation?.value ?? 0.0));
    _scrollController.addListener(() => setState(() => _scrollOffset = _scrollController.offset));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _springController.dispose();
    super.dispose();
  }

  void _onDragUpdate(double? delta) {
    if (delta != null) setState(() => _dragOffset = (_dragOffset + delta).clamp(0.0, 300.0));
  }

  void _onDragEnd(double velocity) {
    if (_dragOffset >= 110.0 || velocity >= 650.0) {
      Navigator.of(context).pop();
    } else {
      final sim = SpringSimulation(const SpringDescription(mass: 1.0, stiffness: 440.0, damping: 26.0), _dragOffset, 0.0, velocity);
      _springAnimation = _springController.drive(Tween<double>(begin: _dragOffset, end: 0.0));
      _springController.animateWith(sim);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FinanceBloc, FinanceState>(
      builder: (context, state) {
        final wallet = state.wallets.firstWhere((w) => w.id == widget.walletId, orElse: () => state.wallets.first);
        final cardIndex = state.wallets.indexWhere((w) => w.id == widget.walletId);
        final cardColor = getWalletColor(cardIndex >= 0 ? cardIndex : 0, wallet.colorHex);
        final walletTx = state.transactions.where((tx) => tx.walletId == wallet.id || tx.destinationWalletId == wallet.id).toList();

        final filteredTx = walletTx.where((tx) {
          if (_selectedFilter == WalletTxFilter.income && tx.type != 'income' && (tx.type != 'transfer' || tx.destinationWalletId != wallet.id)) return false;
          if (_selectedFilter == WalletTxFilter.expense && tx.type != 'expense' && (tx.type != 'transfer' || tx.walletId != wallet.id)) return false;
          if (_selectedFilter == WalletTxFilter.transfer && tx.type != 'transfer') return false;
          if (_searchQuery.isNotEmpty) {
            final notes = (tx.notes ?? '').toLowerCase();
            final amountStr = widget.currencyFormatter.format(tx.amount).toLowerCase();
            if (!notes.contains(_searchQuery) && !amountStr.contains(_searchQuery)) return false;
          }
          return true;
        }).toList();

        final double headerBalanceOpacity = (_scrollOffset / 160.0).clamp(0.0, 1.0);
        final dragScale = (1.0 - (_dragOffset / 1200.0)).clamp(0.92, 1.0);
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Transform.translate(
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
                  child: Stack(
                    children: [
                        WalletDetailRadialGlow(cardColor: cardColor),
                        Column(
                          children: [
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onVerticalDragUpdate: (d) => _onDragUpdate(d.primaryDelta),
                              onVerticalDragEnd: (d) => _onDragEnd(d.primaryVelocity ?? 0.0),
                              child: WalletDetailAppBar(
                                wallet: wallet,
                                headerBalanceOpacity: headerBalanceOpacity,
                                currencyFormatter: widget.currencyFormatter,
                              ),
                            ),
                            Expanded(
                              child: NotificationListener<ScrollNotification>(
                                onNotification: (n) {
                                  if (n is OverscrollNotification && n.overscroll < 0) {
                                    _onDragUpdate(-n.overscroll * 0.8);
                                  } else if (n is ScrollEndNotification && _dragOffset > 0) {
                                    _onDragEnd(0.0);
                                  }
                                  return false;
                                },
                                child: WalletDetailScrollView(
                                  scrollController: _scrollController,
                                  wallet: wallet,
                                  cardIndex: cardIndex >= 0 ? cardIndex : 0,
                                  currencyFormatter: widget.currencyFormatter,
                                  cardColor: cardColor,
                                  allWallets: state.wallets,
                                  transactions: state.transactions,
                                  filteredTx: filteredTx,
                                  searchController: _searchController,
                                  searchQuery: _searchQuery,
                                  selectedFilter: _selectedFilter,
                                  onSearchChanged: (q) => setState(() => _searchQuery = q.trim().toLowerCase()),
                                  onClearSearch: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                  onFilterChanged: (f) => setState(() => _selectedFilter = f),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        );
      },
    );
  }
}
