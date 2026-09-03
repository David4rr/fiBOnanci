import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../bloc/finance/finance_bloc.dart';
import '../../bloc/finance/finance_state.dart';
import '../../domain/services/cashflow_analytics_service.dart';
import '../../core/native_bridge/notification_bridge.dart';
import '../modals/all_transactions_modal.dart';
import '../modals/dashboard_modals.dart';
import '../modals/pending_inbox_modal.dart';
import '../modals/transaction_filter_modal.dart';
import '../modals/profile_modal.dart';
import '../widgets/profile_avatar.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/dashboard_bento_grid.dart';
import '../widgets/overlapping_deck.dart';
import '../widgets/subscription_modal.dart';
import 'subscription_screen.dart';
import 'wallet_screen.dart';

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
        MaterialPageRoute(
          builder: (_) => SubscriptionScreen(
            onAddSubscription: () => AddSubscriptionModal.show(context),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

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
                // Top Header (Greeting, Inbox & Avatar)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Hello ${state.profile.username}', style: AppTypography.heroGreeting),
                            const SizedBox(height: 2),
                            Text('Selamat datang kembali!', style: AppTypography.listSubtitle),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => PendingInboxModal.show(context),
                            child: ValueListenableBuilder<int>(
                              valueListenable: NotificationBridge.pendingCountNotifier,
                              builder: (context, pendingCount, child) {
                                return Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(0xFF1E212D),
                                        border: Border.all(color: AppColors.canvasBorder, width: 1.5),
                                      ),
                                      child: const Center(
                                        child: Icon(Icons.inbox_outlined, color: AppColors.textWhite, size: 20),
                                      ),
                                    ),
                                    if (pendingCount > 0)
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: Container(
                                          width: 10,
                                          height: 10,
                                          decoration: BoxDecoration(
                                            color: AppColors.neoChartreuse,
                                            shape: BoxShape.circle,
                                            border: Border.all(color: AppColors.canvasBg, width: 1.5),
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => ProfileModal.show(
                              context,
                              walletCount: wallets.length,
                              txCount: allTransactions.length,
                            ),
                            child: ProfileAvatar(
                              avatarPath: state.profile.avatarPath,
                              name: state.profile.username,
                              size: 42,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Search Bar (Consistent rectangular Swiss-minimalist styling)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Container(
                      height: 46,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.canvasInputSearch,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _searchQuery.isNotEmpty
                              ? AppColors.neoChartreuse.withValues(alpha: 0.5)
                              : AppColors.canvasBorder,
                          width: 1,
                        ),
                      ),
                      child: Row(
                      children: [
                        const Icon(Icons.search, color: AppColors.textMuted, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(color: AppColors.textWhite, fontSize: 13.5),
                            onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                            decoration: const InputDecoration(
                              hintText: 'Cari transaksi, rekening, merchant...',
                              hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 12.5),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        if (_searchQuery.isNotEmpty)
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(Icons.close, color: AppColors.textMuted, size: 16),
                            ),
                          ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            TransactionFilterModal.show(
                              context: context,
                              wallets: wallets,
                              initialType: _typeFilter,
                              initialWalletId: _walletFilter,
                              onApply: (type, walletId) {
                                setState(() {
                                  _typeFilter = type;
                                  _walletFilter = walletId;
                                });
                              },
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: (_typeFilter != 'all' || _walletFilter != null)
                                  ? AppColors.neoChartreuse.withValues(alpha: 0.2)
                                  : Colors.transparent,
                            ),
                            child: Icon(
                              Icons.tune,
                              color: (_typeFilter != 'all' || _walletFilter != null)
                                  ? AppColors.neoChartreuse
                                  : AppColors.textWhite,
                              size: 17,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Active Filter Chips
                if (_typeFilter != 'all' || _walletFilter != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                    child: Row(
                      children: [
                        if (_typeFilter != 'all')
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.canvasInputSearch,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.neoChartreuse, width: 1),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Tipe: ${_typeFilter.toUpperCase()}',
                                    style: AppTypography.badgeLabel.copyWith(color: AppColors.neoChartreuse),
                                  ),
                                  const SizedBox(width: 4),
                                  GestureDetector(
                                    onTap: () => setState(() => _typeFilter = 'all'),
                                    child: const Icon(Icons.close, size: 14, color: AppColors.neoChartreuse),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (_walletFilter != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.canvasInputSearch,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.neoChartreuse, width: 1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Rek: ${wallets.firstWhere((w) => w.id == _walletFilter, orElse: () => wallets.first).name}',
                                  style: AppTypography.badgeLabel.copyWith(color: AppColors.neoChartreuse),
                                ),
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: () => setState(() => _walletFilter = null),
                                  child: const Icon(Icons.close, size: 14, color: AppColors.neoChartreuse),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                // 2x2 Bento Folder Grid
                DashboardBentoGrid(
                  metrics: metrics,
                  wallets: wallets,
                  subscriptions: subscriptions,
                  currencyFormatter: currencyFormatter,
                  onNavigateToWallets: _onNavigateToWallets,
                  onNavigateToSubscriptions: _onNavigateToSubscriptions,
                ),

                // Riwayat Transaksi Header
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
                        onTap: () => AllTransactionsModal.show(
                          context,
                          allTransactions: allTransactions,
                          wallets: wallets,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.neoChartreuse.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.neoChartreuse.withValues(alpha: 0.4),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Lihat Semua',
                                style: AppTypography.listSubtitle.copyWith(
                                  color: AppColors.neoChartreuse,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                size: 13,
                                color: AppColors.neoChartreuse,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Overlapping Deck of Transactions (Shared component Hero animation for card history)
                Expanded(
                  child: Hero(
                    tag: 'expense_history_card_history',
                    flightShuttleBuilder: (
                      flightContext,
                      animation,
                      flightDirection,
                      fromHeroContext,
                      toHeroContext,
                    ) {
                      final Hero toHero = toHeroContext.widget as Hero;
                      return Material(
                        color: Colors.transparent,
                        child: toHero.child,
                      );
                    },
                    child: filteredTransactions.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: AppColors.canvasCardSurface,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppColors.canvasBorder),
                                ),
                                child: Text(
                                  _searchQuery.isNotEmpty
                                      ? 'Tidak ada transaksi yang cocok dengan "$_searchQuery"'
                                      : 'Belum ada transaksi. Tambahkan pengeluaran atau tunggu notifikasi bank masuk otomatis!',
                                  textAlign: TextAlign.center,
                                  style: AppTypography.listSubtitle,
                                ),
                              ),
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
