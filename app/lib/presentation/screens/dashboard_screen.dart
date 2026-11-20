import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/finance/finance_bloc.dart';
import '../../bloc/finance/finance_state.dart';
import '../../core/formatters/app_currency.dart';
import '../../core/native_bridge/notification_bridge.dart';
import '../../domain/services/cashflow_analytics_service.dart';
import '../theme/app_colors.dart';
import '../widgets/dashboard_bento_grid.dart';
import '../widgets/notification_permission_banner.dart';
import 'dashboard/dashboard_empty_wallet_view.dart';
import 'dashboard/dashboard_header.dart';
import 'dashboard/dashboard_history_section.dart';
import 'dashboard/dashboard_search_bar.dart';
import 'subscription_screen.dart';

export 'dashboard/dashboard_empty_wallet_view.dart';
export 'dashboard/dashboard_header.dart';
export 'dashboard/dashboard_history_section.dart';
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
  String _searchQuery = '';
  String _typeFilter = 'all';
  String? _walletFilter;
  bool _isNotificationGranted = true;

  @override
  void initState() {
    super.initState();
    _checkNotificationPermission();
  }

  @override
  void didUpdateWidget(covariant DashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _checkNotificationPermission();
  }

  Future<void> _checkNotificationPermission() async {
    final granted = await NotificationBridge.isPermissionGranted();
    if (mounted) setState(() => _isNotificationGranted = granted);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onNavigateToWallets() {
    if (widget.onNavigateToWallets != null) {
      widget.onNavigateToWallets!();
    }
  }

  void _onNavigateToSubscriptions() {
    if (widget.onNavigateToSubscriptions != null) {
      widget.onNavigateToSubscriptions!();
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
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
            final todayExpense = todayTransactions
                .where((t) => t.type == 'expense' && !t.isDeleted)
                .fold<double>(0.0, (sum, t) => sum + t.amount);

            final isFiltering = _searchQuery.isNotEmpty || _typeFilter != 'all' || _walletFilter != null;
            final baseTransactions = isFiltering ? allTransactions : todayTransactions;

            final filteredTransactions = CashflowAnalyticsService.filterTransactions(
              transactions: baseTransactions,
              wallets: wallets,
              query: _searchQuery,
              typeFilter: _typeFilter,
              walletFilter: _walletFilter,
            );

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              padding: const EdgeInsets.only(bottom: 96),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DashboardHeader(
                    profileId: state.profile.id,
                    username: state.profile.username,
                    avatarPath: state.profile.avatarPath,
                    walletCount: wallets.length,
                    txCount: allTransactions.length,
                  ),
                  if (!_isNotificationGranted)
                    NotificationPermissionBanner(
                      onDismiss: () => setState(() => _isNotificationGranted = true),
                    ),
                  if (wallets.isEmpty)
                    const DashboardEmptyWalletView()
                  else ...[
                    DashboardSearchBar(
                      searchController: _searchController,
                      searchQuery: _searchQuery,
                      typeFilter: _typeFilter,
                      walletFilter: _walletFilter,
                      wallets: wallets,
                      onSearchChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                      onClearSearch: () { _searchController.clear(); setState(() => _searchQuery = ''); },
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
                      currencyFormatter: AppCurrency.forCode(state.profile.currency),
                      isBalanceHidden: state.isBalanceHidden,
                      todayExpense: todayExpense,
                      onNavigateToWallets: _onNavigateToWallets,
                      onNavigateToSubscriptions: _onNavigateToSubscriptions,
                    ),
                    DashboardHistorySection(
                      searchQuery: _searchQuery,
                      isFiltering: isFiltering,
                      filteredTransactions: filteredTransactions,
                      allTransactions: allTransactions,
                      wallets: wallets,
                      categories: state.categories,
                      pockets: state.pockets,
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
