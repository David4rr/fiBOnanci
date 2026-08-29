import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../bloc/finance/finance_bloc.dart';
import '../../bloc/finance/finance_state.dart';
import '../../domain/services/cashflow_analytics_service.dart';
import '../../core/native_bridge/notification_bridge.dart';
import '../../data/database/app_database.dart';
import '../modals/all_transactions_modal.dart';
import '../modals/dashboard_modals.dart';
import '../modals/transaction_filter_modal.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/dashboard_bento_grid.dart';
import '../widgets/overlapping_deck.dart';
import '../widgets/transaction_detail_modal.dart';
import 'wallet_screen.dart';

class DashboardScreen extends StatefulWidget {
  final AppDatabase db;
  final VoidCallback? onNavigateToWallets;

  const DashboardScreen({
    super.key,
    required this.db,
    this.onNavigateToWallets,
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
      Navigator.push(context, MaterialPageRoute(builder: (_) => WalletScreen(db: widget.db)));
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

            final filteredTransactions = CashflowAnalyticsService.filterTransactions(
              transactions: allTransactions,
              wallets: wallets,
              query: _searchQuery,
              typeFilter: _typeFilter,
              walletFilter: _walletFilter,
            );

            return CustomScrollView(
              slivers: [
                // Top Header (Greeting, Inbox & Avatar)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Hello David', style: AppTypography.heroGreeting),
                              const SizedBox(height: 4),
                              Text('Selamat datang kembali!', style: AppTypography.listSubtitle),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => PendingInboxModal.show(context, db: widget.db),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF1E212D),
                                  border: Border.all(color: AppColors.canvasBorder, width: 1.5),
                                ),
                                child: const Center(
                                  child: Icon(Icons.inbox_outlined, color: AppColors.textWhite, size: 22),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => ProfileModal.show(context, walletCount: wallets.length, txCount: allTransactions.length),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF1E212D),
                                  border: Border.all(color: AppColors.canvasBorder, width: 1.5),
                                ),
                                child: const Center(
                                  child: Icon(Icons.person, color: AppColors.textWhite, size: 24),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Search Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.canvasInputSearch,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: _searchQuery.isNotEmpty
                              ? AppColors.neoChartreuse.withValues(alpha: 0.5)
                              : AppColors.canvasBorder,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: AppColors.textMuted, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              style: const TextStyle(color: AppColors.textWhite, fontSize: 14),
                              onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                              decoration: const InputDecoration(
                                hintText: 'Cari transaksi, rekening, merchant...',
                                hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13),
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
                                child: Icon(Icons.close, color: AppColors.textMuted, size: 18),
                              ),
                            ),
                          const SizedBox(width: 8),
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
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: (_typeFilter != 'all' || _walletFilter != null)
                                    ? AppColors.neoChartreuse.withValues(alpha: 0.2)
                                    : Colors.transparent,
                              ),
                              child: Icon(
                                Icons.tune,
                                color: (_typeFilter != 'all' || _walletFilter != null)
                                    ? AppColors.neoChartreuse
                                    : AppColors.textWhite,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Active Filter Chips
                if (_typeFilter != 'all' || _walletFilter != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      child: Row(
                        children: [
                          if (_typeFilter != 'all')
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Chip(
                                backgroundColor: AppColors.canvasInputSearch,
                                side: const BorderSide(color: AppColors.neoChartreuse),
                                label: Text(
                                  'Tipe: ${_typeFilter.toUpperCase()}',
                                  style: AppTypography.badgeLabel.copyWith(color: AppColors.neoChartreuse),
                                ),
                                onDeleted: () => setState(() => _typeFilter = 'all'),
                                deleteIconColor: AppColors.neoChartreuse,
                              ),
                            ),
                          if (_walletFilter != null)
                            Chip(
                              backgroundColor: AppColors.canvasInputSearch,
                              side: const BorderSide(color: AppColors.neoMint),
                              label: Text(
                                'Rek: ${wallets.firstWhere((w) => w.id == _walletFilter, orElse: () => wallets.first).name}',
                                style: AppTypography.badgeLabel.copyWith(color: AppColors.neoMint),
                              ),
                              onDeleted: () => setState(() => _walletFilter = null),
                              deleteIconColor: AppColors.neoMint,
                            ),
                        ],
                      ),
                    ),
                  ),

                // Notification Permission Banner
                SliverToBoxAdapter(
                  child: FutureBuilder<bool>(
                    future: NotificationBridge.isPermissionGranted(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data == false) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => NotificationBridge.openPermissionSettings(),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.neoChartreuse.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.neoChartreuse.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.notifications_active_outlined, color: AppColors.neoChartreuse, size: 20),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Akses notifikasi belum aktif. Ketuk untuk mengizinkan pencatatan otomatis dari m-banking!',
                                      style: AppTypography.listSubtitle.copyWith(color: AppColors.textWhite, fontSize: 12),
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right, color: AppColors.neoChartreuse, size: 18),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),

                // 2x2 Bento Folder Grid
                SliverToBoxAdapter(
                  child: DashboardBentoGrid(
                    metrics: metrics,
                    wallets: wallets,
                    subscriptions: subscriptions,
                    currencyFormatter: currencyFormatter,
                    onNavigateToWallets: _onNavigateToWallets,
                  ),
                ),

                // Riwayat Transaksi Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
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
                            db: widget.db,
                          ),
                          child: Text(
                            'Lihat Semua',
                            style: AppTypography.listSubtitle.copyWith(color: AppColors.neoChartreuse),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Overlapping Deck of Transactions
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: filteredTransactions.isEmpty
                        ? Container(
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              color: AppColors.canvasCardSurface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.canvasBorder),
                            ),
                            child: Center(
                              child: Text(
                                _searchQuery.isNotEmpty
                                    ? 'Tidak ada transaksi yang cocok dengan "$_searchQuery"'
                                    : 'Belum ada transaksi. Tambahkan pengeluaran atau tunggu notifikasi bank masuk otomatis!',
                                textAlign: TextAlign.center,
                                style: AppTypography.listSubtitle,
                              ),
                            ),
                          )
                        : OverlappingDeckList(
                            children: [
                              for (final tx in filteredTransactions) ...[
                                Builder(builder: (context) {
                                  final txWallet = wallets.firstWhere(
                                    (w) => w.id == tx.walletId,
                                    orElse: () => wallets.isNotEmpty ? wallets.first : WalletEntry(
                                      id: '',
                                      name: 'Rekening',
                                      type: 'bank',
                                      currency: 'IDR',
                                      balance: 0,
                                      colorHex: '#64748B',
                                      iconName: 'wallet',
                                      createdAt: DateTime.now(),
                                      updatedAt: DateTime.now(),
                                      isSynced: false,
                                      isDeleted: false,
                                    ),
                                  );

                                  return OverlappingDeckItem(
                                    title: tx.notes ?? (tx.type == 'expense' ? 'Pengeluaran' : 'Pemasukan'),
                                    category: tx.type == 'transfer'
                                        ? 'TRANSFER'
                                        : (tx.type == 'expense' ? 'PENGELUARAN' : 'PEMASUKAN'),
                                    amount: tx.amount,
                                    isExpense: tx.type == 'expense' || tx.type == 'transfer',
                                    categoryColor: tx.type == 'expense' ? AppColors.neoCoral : AppColors.neoMint,
                                    iconData: tx.type == 'expense' ? Icons.arrow_outward : Icons.arrow_downward,
                                    subtitle: '${txWallet.name} • ${DateFormat('dd MMM, HH:mm').format(tx.transactionDate)}',
                                    onTap: () => TransactionDetailModal.show(context, db: widget.db, transaction: tx),
                                  );
                                }),
                              ],
                            ],
                          ),
                  ),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: 140),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
