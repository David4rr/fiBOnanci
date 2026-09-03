import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../bloc/finance/finance_bloc.dart';
import '../../bloc/finance/finance_state.dart';
import '../../domain/services/cashflow_analytics_service.dart';
import '../modals/all_transactions_modal.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/dashboard_bento_grid.dart';
import '../widgets/overlapping_deck.dart';
import '../widgets/subscription_modal.dart';
import 'dashboard/dashboard_header.dart';
import 'dashboard/dashboard_search_bar.dart';
import 'subscription_screen.dart';
import 'wallet_screen.dart';

export 'dashboard/dashboard_header.dart';
export 'dashboard/dashboard_search_bar.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback? onNavigateToWallets;
  final VoidCallback? onNavigateToSubscriptions;

  const DashboardScreen({
    super.key,
    this.onNavigateToWallets,
    this.onNavigateToSubscriptions,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _searchController = TextEditingController();
  static final _currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  String _searchQuery = '';
  String _typeFilter = 'all';
  String? _walletFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onNavigateToWallets() {
    if (widget.onNavigateToWallets != null) {
      widget.onNavigateToWallets!();
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletScreen()));
    }
  }

  void _onNavigateToSubscriptions() {
    if (widget.onNavigateToSubscriptions != null) {
      widget.onNavigateToSubscriptions!();
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SubscriptionScreen(onAddSubscription: () => AddSubscriptionModal.show(context))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasBg,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<FinanceBloc, FinanceState>(
          builder: (context, state) {
            final wallets = state.wallets;
            final subscriptions = state.subscriptions;
            final allTransactions = state.transactions;
            final metrics = state.metrics;

            final now = DateTime.now();
            final todayTransactions = allTransactions.where((t) {
              final d = t.transactionDate.toLocal();
              final n = now.toLocal();
              return d.year == n.year && d.month == n.month && d.day == n.day;
            }).toList();

            final isFiltering = _searchQuery.isNotEmpty || _typeFilter != 'all' || _walletFilter != null;
            final baseTransactions = isFiltering ? allTransactions : todayTransactions;

            final filteredTransactions = CashflowAnalyticsService.filterTransactions(
              transactions: baseTransactions,
              wallets: wallets,
              query: _searchQuery,
              typeFilter: _typeFilter,
              walletFilter: _walletFilter,
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DashboardHeader(
                  username: state.profile.username,
                  avatarPath: state.profile.avatarPath,
                  walletCount: wallets.length,
                  txCount: allTransactions.length,
                ),
                DashboardSearchBar(
                  searchController: _searchController,
                  searchQuery: _searchQuery,
                  typeFilter: _typeFilter,
                  walletFilter: _walletFilter,
                  wallets: wallets,
                  onSearchChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                  onClearSearch: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                  onFilterApplied: (type, walletId) => setState(() {
                    _typeFilter = type;
                    _walletFilter = walletId;
                  }),
                  onClearTypeFilter: () => setState(() => _typeFilter = 'all'),
                  onClearWalletFilter: () => setState(() => _walletFilter = null),
                ),
                DashboardBentoGrid(
                  metrics: metrics,
                  wallets: wallets,
                  subscriptions: subscriptions,
                  currencyFormatter: _currencyFormatter,
                  onNavigateToWallets: _onNavigateToWallets,
                  onNavigateToSubscriptions: _onNavigateToSubscriptions,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _searchQuery.isNotEmpty
                              ? 'Hasil Pencarian (${filteredTransactions.length})'
                              : 'Riwayat Transaksi',
                          style: AppTypography.sectionTitle,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => AllTransactionsModal.show(context, allTransactions: allTransactions, wallets: wallets),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          child: Text(
                            'Lihat Semua',
                            style: AppTypography.cardMetricLabel.copyWith(
                              color: AppColors.neoChartreuse,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Hero(
                    tag: 'expense_history_card_history',
                    flightShuttleBuilder: (flightContext, animation, flightDirection, fromHeroContext, toHeroContext) {
                      return Material(color: Colors.transparent, child: toHeroContext.widget);
                    },
                    child: filteredTransactions.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(isFiltering ? Icons.search_off_rounded : Icons.receipt_long_outlined, size: 42, color: AppColors.textSubtle),
                                const SizedBox(height: 10),
                                Text(isFiltering ? 'Tidak ada transaksi yang cocok' : 'Belum ada transaksi hari ini', style: AppTypography.listSubtitle),
                              ],
                            ),
                          )
                        : StackedCardDeckScrollList(
                            transactions: filteredTransactions,
                            allTransactions: allTransactions,
                            wallets: wallets,
                          ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
