import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../bloc/finance/finance_bloc.dart';
import '../../bloc/finance/finance_state.dart';
import '../../data/database/app_database.dart';
import '../theme/app_colors.dart';
import '../widgets/wallet_card.dart';
import 'wallet_detail/tactile_hero_card.dart';
import 'wallet_detail/wallet_detail_actions_and_chart.dart';
import 'wallet_detail/wallet_detail_app_bar.dart';
import 'wallet_detail/wallet_detail_history_section.dart';

export 'wallet_detail/tactile_hero_card.dart';
export 'wallet_detail/wallet_detail_actions_and_chart.dart';
export 'wallet_detail/wallet_detail_app_bar.dart';
export 'wallet_detail/wallet_detail_history_section.dart';

class WalletDetailScreen extends StatefulWidget {
  final String walletId;
  final NumberFormat currencyFormatter;

  const WalletDetailScreen({
    super.key,
    required this.walletId,
    required this.currencyFormatter,
  });

  static Future<void> push(
    BuildContext context, {
    required WalletEntry wallet,
  }) {
    final financeBloc = context.read<FinanceBloc>();
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        opaque: true,
        transitionDuration: const Duration(milliseconds: 360),
        reverseTransitionDuration: const Duration(milliseconds: 320),
        pageBuilder: (ctx, animation, secondaryAnimation) {
          return BlocProvider.value(
            value: financeBloc,
            child: WalletDetailScreen(
              walletId: wallet.id,
              currencyFormatter: currencyFormatter,
            ),
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: const Interval(0.0, 0.7, curve: Curves.easeOut)),
            child: child,
          );
        },
      ),
    );
  }

  @override
  State<WalletDetailScreen> createState() => _WalletDetailScreenState();
}

class _WalletDetailScreenState extends State<WalletDetailScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  double _scrollOffset = 0.0;
  WalletTxFilter _selectedFilter = WalletTxFilter.all;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() => _scrollOffset = _scrollController.offset);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
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
          if (_selectedFilter == WalletTxFilter.income && tx.type != 'income' && tx.destinationWalletId != wallet.id) return false;
          if (_selectedFilter == WalletTxFilter.expense && tx.type != 'expense' && tx.walletId != wallet.id) return false;
          if (_selectedFilter == WalletTxFilter.transfer && tx.type != 'transfer') return false;
          if (_searchQuery.isNotEmpty) {
            final notes = (tx.notes ?? '').toLowerCase();
            final amountStr = widget.currencyFormatter.format(tx.amount).toLowerCase();
            if (!notes.contains(_searchQuery) && !amountStr.contains(_searchQuery)) return false;
          }
          return true;
        }).toList();

        final double headerBalanceOpacity = (_scrollOffset / 160.0).clamp(0.0, 1.0);

        return Scaffold(
          backgroundColor: AppColors.canvasBg,
          body: Stack(
            children: [
              Positioned(
                top: -90, left: -60, right: -60, height: 420,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.topCenter, radius: 0.85,
                        colors: [cardColor.withValues(alpha: 0.22), cardColor.withValues(alpha: 0.06), Colors.transparent],
                        stops: const [0.0, 0.40, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  slivers: [
                    SliverToBoxAdapter(child: SizedBox(height: MediaQuery.paddingOf(context).top + 68)),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                        child: Center(
                          child: TactileHeroCard(
                            wallet: wallet,
                            cardIndex: cardIndex >= 0 ? cardIndex : 0,
                            fmt: widget.currencyFormatter,
                            cardColor: cardColor,
                            allWallets: state.wallets,
                          ),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 20)),
                    SliverToBoxAdapter(
                      child: WalletDetailActionsAndChart(
                        wallet: wallet,
                        cardColor: cardColor,
                        transactions: state.transactions,
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 14)),
                    WalletDetailHistorySection(
                      wallet: wallet,
                      filteredTx: filteredTx,
                      searchController: _searchController,
                      searchQuery: _searchQuery,
                      selectedFilter: _selectedFilter,
                      currencyFormatter: widget.currencyFormatter,
                      onSearchChanged: (q) => setState(() => _searchQuery = q.trim().toLowerCase()),
                      onClearSearch: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                      onFilterChanged: (f) => setState(() => _selectedFilter = f),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0, left: 0, right: 0,
                child: WalletDetailAppBar(
                  wallet: wallet,
                  headerBalanceOpacity: headerBalanceOpacity,
                  currencyFormatter: widget.currencyFormatter,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
