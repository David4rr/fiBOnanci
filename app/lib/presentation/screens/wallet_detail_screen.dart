import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../bloc/finance/finance_bloc.dart';
import '../../bloc/finance/finance_state.dart';
import '../../data/database/app_database.dart';
import '../widgets/wallet_card.dart';
import '../widgets/common/common_widgets.dart';
import 'wallet_detail/wallet_detail_app_bar.dart';
import 'wallet_detail/wallet_detail_history_section.dart';
import 'wallet_detail/wallet_detail_modal_route.dart';
import 'wallet_detail/wallet_detail_page_view.dart';
import 'wallet_detail/wallet_detail_radial_glow.dart';
export 'wallet_detail/tactile_hero_card.dart';
export 'wallet_detail/wallet_detail_actions_and_chart.dart';
export 'wallet_detail/wallet_detail_app_bar.dart';
export 'wallet_detail/wallet_detail_edit_tab.dart';
export 'wallet_detail/wallet_detail_history_section.dart';
export 'wallet_detail/wallet_detail_modal_route.dart';
export 'wallet_detail/wallet_detail_page_view.dart';
export 'wallet_detail/wallet_detail_radial_glow.dart';
export 'wallet_detail/wallet_detail_scroll_view.dart';

class WalletDetailScreen extends StatefulWidget {
  final String walletId;
  final NumberFormat currencyFormatter;
  final double initialChildSize;

  const WalletDetailScreen({
    super.key,
    required this.walletId,
    required this.currencyFormatter,
    this.initialChildSize = 1.0,
  });

  static Future<void> show(BuildContext context, {required WalletEntry wallet, double initialChildSize = 1.0}) =>
      WalletDetailModalRoute.show(context, wallet: wallet, initialChildSize: initialChildSize);

  static Future<void> push(BuildContext context, {required WalletEntry wallet, double initialChildSize = 1.0}) =>
      WalletDetailModalRoute.show(context, wallet: wallet, initialChildSize: initialChildSize);
  @override
  State<WalletDetailScreen> createState() => _WalletDetailScreenState();
}

class _WalletDetailScreenState extends State<WalletDetailScreen> {
  final _sheetKey = GlobalKey<ExpandableModalSheetState>();
  final _searchController = TextEditingController();
  late final PageController _pageController;
  double _scrollOffset = 0.0;
  WalletTxFilter _selectedFilter = WalletTxFilter.all;
  String _searchQuery = '';
  int _currentTab = 0;
  TransactionEntry? _selectedTransaction;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _goToEditTab() {
    setState(() => _currentTab = 1);
    _pageController.animateToPage(1, duration: const Duration(milliseconds: 320), curve: Curves.easeInOutCubic);
  }

  void _goToAddTxTab() {
    setState(() => _currentTab = 2);
    _pageController.animateToPage(2, duration: const Duration(milliseconds: 320), curve: Curves.easeInOutCubic);
  }

  void _goToEditTxTab(TransactionEntry tx) {
    setState(() {
      _selectedTransaction = tx;
      _currentTab = 3;
    });
    _pageController.animateToPage(3, duration: const Duration(milliseconds: 320), curve: Curves.easeInOutCubic);
  }

  void _goToDetailsTab() {
    setState(() => _currentTab = 0);
    _pageController.animateToPage(0, duration: const Duration(milliseconds: 320), curve: Curves.easeInOutCubic);
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

        return ExpandableModalSheet(
          key: _sheetKey,
          initialChildSize: widget.initialChildSize,
          minChildSize: 0.40,
          maxChildSize: 1.0,
          snapSizes: const [0.85, 1.0],
          builder: (ctx, scrollController, currentSize) {
            return Stack(
              children: [
                WalletDetailRadialGlow(cardColor: cardColor),
                Column(
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onVerticalDragUpdate: (d) => _sheetKey.currentState?.handleHeaderDragUpdate(d),
                      onVerticalDragEnd: (d) => _sheetKey.currentState?.handleHeaderDragEnd(d),
                      child: WalletDetailAppBar(
                        wallet: wallet,
                        headerBalanceOpacity: headerBalanceOpacity,
                        currencyFormatter: widget.currencyFormatter,
                        isEditing: _currentTab != 0,
                        onReturnToDetails: _goToDetailsTab,
                        customTitle: _currentTab == 1
                            ? 'Penyesuaian Saldo: ${wallet.name}'
                            : (_currentTab == 2 ? 'Catat Transaksi' : (_currentTab == 3 ? 'Edit Transaksi' : null)),
                        customSubtitle: _currentTab == 1
                            ? 'Ubah saldo awal & preferensi rekening'
                            : (_currentTab == 2 ? 'Rekening: ${wallet.name}' : (_currentTab == 3 ? (_selectedTransaction?.notes?.isNotEmpty == true ? _selectedTransaction!.notes! : 'Ubah rincian mutasi transaksi') : null)),
                      ),
                    ),
                    Expanded(
                      child: WalletDetailPageView(
                        pageController: _pageController,
                        scrollController: scrollController,
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
                        onScrollOffsetChanged: (off) {
                          if ((off - _scrollOffset).abs() > 2) {
                            setState(() => _scrollOffset = off);
                          }
                        },
                        onEditBalance: _goToEditTab,
                        onAddTransaction: _goToAddTxTab,
                        onEditTransaction: _goToEditTxTab,
                        selectedTransaction: _selectedTransaction,
                        onReturnToDetails: _goToDetailsTab,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
}
