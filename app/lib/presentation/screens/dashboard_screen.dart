import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../bloc/finance/finance_bloc.dart';
import '../../bloc/finance/finance_event.dart';
import '../../bloc/finance/finance_state.dart';
import '../../core/native_bridge/notification_bridge.dart';
import '../../core/notification_parser/notification_parser.dart';
import '../../data/database/app_database.dart';
import '../../domain/services/safe_to_spend_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/folder_tab_card.dart';
import '../widgets/notification_review_modal.dart';
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
  String _typeFilter = 'all'; // 'all', 'expense', 'income', 'transfer'
  String? _walletFilter; // null = all wallets

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

            // Live search and filter pipeline
            final filteredTransactions = allTransactions.where((tx) {
              if (_searchQuery.isNotEmpty) {
                final notes = (tx.notes ?? '').toLowerCase();
                final type = tx.type.toLowerCase();
                final amt = tx.amount.toString();
                final wallet = wallets.firstWhere(
                  (w) => w.id == tx.walletId,
                  orElse: () => wallets.isNotEmpty ? wallets.first : WalletEntry(
                    id: '',
                    name: '',
                    type: '',
                    currency: '',
                    balance: 0,
                    colorHex: '#64748B',
                    iconName: '',
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                    isSynced: false,
                    isDeleted: false,
                  ),
                );
                final walletName = wallet.name.toLowerCase();

                final match = notes.contains(_searchQuery) ||
                    type.contains(_searchQuery) ||
                    amt.contains(_searchQuery) ||
                    walletName.contains(_searchQuery);
                if (!match) return false;
              }

              if (_typeFilter != 'all' && tx.type != _typeFilter) {
                return false;
              }

              if (_walletFilter != null && tx.walletId != _walletFilter) {
                return false;
              }

              return true;
            }).toList();

            return CustomScrollView(
              slivers: [
                // 1. Top Header (Greeting, Inbox & Avatar)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Hello David', style: AppTypography.heroGreeting, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 2),
                              Text('Selamat datang kembali!', style: AppTypography.listSubtitle, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.inbox_outlined, color: AppColors.neoChartreuse, size: 26),
                              tooltip: 'Kotak Masuk Notifikasi',
                              onPressed: () => _showPendingInboxModal(context),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => _showProfileModal(context, wallets.length, allTransactions.length),
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

                // 2. Interactive Search Bar (Functional Search & Filter)
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
                          color: _searchQuery.isNotEmpty ? AppColors.neoChartreuse.withOpacity(0.5) : AppColors.canvasBorder,
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
                            onTap: () => _showFilterModal(context, wallets),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: (_typeFilter != 'all' || _walletFilter != null)
                                    ? AppColors.neoChartreuse.withOpacity(0.2)
                                    : Colors.transparent,
                              ),
                              child: Icon(
                                Icons.tune,
                                color: (_typeFilter != 'all' || _walletFilter != null) ? AppColors.neoChartreuse : AppColors.textWhite,
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
                                label: Text('Tipe: ${_typeFilter.toUpperCase()}', style: AppTypography.badgeLabel.copyWith(color: AppColors.neoChartreuse)),
                                onDeleted: () => setState(() => _typeFilter = 'all'),
                                deleteIconColor: AppColors.neoChartreuse,
                              ),
                            ),
                          if (_walletFilter != null)
                            Chip(
                              backgroundColor: AppColors.canvasInputSearch,
                              side: const BorderSide(color: AppColors.neoMint),
                              label: Text('Rekening: ${wallets.firstWhere((w) => w.id == _walletFilter, orElse: () => wallets.first).name}', style: AppTypography.badgeLabel.copyWith(color: AppColors.neoMint)),
                              onDeleted: () => setState(() => _walletFilter = null),
                              deleteIconColor: AppColors.neoMint,
                            ),
                        ],
                      ),
                    ),
                  ),

                // 3. Notification Permission Prompt Banner (if needed)
                SliverToBoxAdapter(
                  child: FutureBuilder<bool>(
                    future: NotificationBridge.isPermissionGranted(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data == false) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => NotificationBridge.openPermissionSettings(),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.neoChartreuse.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.neoChartreuse.withOpacity(0.35)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.notifications_active, color: AppColors.neoChartreuse, size: 22),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Aktifkan Izin Notifikasi Bank',
                                          style: AppTypography.listTitle.copyWith(fontSize: 14, color: AppColors.neoChartreuse),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Ketuk di sini agar SeaBank, BCA, blu, dll. otomatis tercatat saat notif masuk.',
                                          style: AppTypography.listSubtitle.copyWith(fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward_ios, color: AppColors.neoChartreuse, size: 14),
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

                // 4. 2x2 Bento Folder Grid (ALL CARDS WITH ONTAP ACTION)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Card 1: Safe-to-Spend (TAP -> Opens Formula Breakdown)
                            Expanded(
                              child: FolderTabCard(
                                backgroundColor: AppColors.neoChartreuse,
                                height: 140,
                                onTap: () => _showSafeToSpendModal(context, wallets),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: 34,
                                      height: 34,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.cardIconBadgeBg,
                                      ),
                                      child: const Center(
                                        child: Icon(Icons.shield_outlined, color: AppColors.textDarkPrimary, size: 18),
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          currencyFormatter.format(metrics.safeToSpendMonthly),
                                          style: AppTypography.cardMetricValue,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                metrics.isAllWallets ? 'Safe to Spend' : 'Safe to Spend (${metrics.selectedWalletsCount} Akun)',
                                                style: AppTypography.cardMetricLabel,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            const Icon(Icons.tune, color: AppColors.textDarkSecondary, size: 12),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),

                            // Card 2: Total Real Balance (TAP -> Opens Wallets List)
                            Expanded(
                              child: FolderTabCard(
                                backgroundColor: AppColors.neoMint,
                                height: 140,
                                onTap: () {
                                  if (widget.onNavigateToWallets != null) {
                                    widget.onNavigateToWallets!();
                                  } else {
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => WalletScreen(db: widget.db)));
                                  }
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: 34,
                                      height: 34,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.cardIconBadgeBg,
                                      ),
                                      child: const Center(
                                        child: Icon(Icons.account_balance_wallet_outlined, color: AppColors.textDarkPrimary, size: 18),
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          currencyFormatter.format(metrics.totalRealBalance),
                                          style: AppTypography.cardMetricValue,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            Expanded(child: Text('${wallets.length} Akun Riil', style: AppTypography.cardMetricLabel, overflow: TextOverflow.ellipsis)),
                                            const SizedBox(width: 4),
                                            const Icon(Icons.chevron_right, color: AppColors.textDarkSecondary, size: 14),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            // Card 3: Pending Bills (TAP -> Opens Upcoming Bills List)
                            Expanded(
                              child: FolderTabCard(
                                backgroundColor: AppColors.neoCoral,
                                height: 140,
                                onTap: () => _showBillsListModal(context, subscriptions),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: 34,
                                      height: 34,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.cardIconBadgeBg,
                                      ),
                                      child: const Center(
                                        child: Icon(Icons.receipt_long_outlined, color: AppColors.textDarkPrimary, size: 18),
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          currencyFormatter.format(metrics.pendingBills),
                                          style: AppTypography.cardMetricValue,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            Expanded(child: Text('${subscriptions.length} Tagihan Bln Ini', style: AppTypography.cardMetricLabel, overflow: TextOverflow.ellipsis)),
                                            const SizedBox(width: 4),
                                            const Icon(Icons.chevron_right, color: AppColors.textDarkSecondary, size: 14),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),

                            // Card 4: Daily Allowance (TAP -> Opens Daily Pace Calculator)
                            Expanded(
                              child: FolderTabCard(
                                backgroundColor: AppColors.neoCyan,
                                height: 140,
                                onTap: () => _showDailyPaceModal(context, metrics),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: 34,
                                      height: 34,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.cardIconBadgeBg,
                                      ),
                                      child: const Center(
                                        child: Icon(Icons.today_outlined, color: AppColors.textDarkPrimary, size: 18),
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          currencyFormatter.format(metrics.safeToSpendDaily),
                                          style: AppTypography.cardMetricValue,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            Expanded(child: Text('Alokasi/Hari (${metrics.daysRemainingInMonth}hr)', style: AppTypography.cardMetricLabel, overflow: TextOverflow.ellipsis)),
                                            const SizedBox(width: 4),
                                            const Icon(Icons.info_outline, color: AppColors.textDarkSecondary, size: 13),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // 5. Section Title: Riwayat Transaksi (INTERACTIVE "Lihat Semua")
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _searchQuery.isNotEmpty ? 'Hasil Pencarian (${filteredTransactions.length})' : 'Riwayat Transaksi',
                            style: AppTypography.sectionTitle,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => _showAllTransactionsModal(context, allTransactions, wallets),
                          child: Text('Lihat Semua', style: AppTypography.listSubtitle.copyWith(color: AppColors.neoChartreuse)),
                        ),
                      ],
                    ),
                  ),
                ),

                // 6. Overlapping Deck of Transactions (Instant Filtered RAM List)
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
                            overlapOffset: 12,
                            children: [
                              for (final tx in filteredTransactions) ...[
                                Builder(builder: (context) {
                                  final txWallet = wallets.firstWhere(
                                    (w) => w.id == tx.walletId,
                                    orElse: () => wallets.isNotEmpty
                                        ? wallets.first
                                        : WalletEntry(
                                            id: '',
                                            name: 'Rekening',
                                            type: '',
                                            currency: '',
                                            balance: 0,
                                            colorHex: '#64748B',
                                            iconName: '',
                                            createdAt: DateTime.now(),
                                            updatedAt: DateTime.now(),
                                            isSynced: false,
                                            isDeleted: false,
                                          ),
                                  );
                                  return OverlappingDeckItem(
                                    title: tx.notes ?? (tx.type == 'expense' ? 'Pengeluaran' : 'Pemasukan'),
                                    category: tx.type == 'transfer' ? 'TRANSFER' : (tx.type == 'expense' ? 'PENGELUARAN' : 'PEMASUKAN'),
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

  // ===========================================================================
  // INTERACTIVE MODALS & FUNCTIONAL HANDLERS
  // ===========================================================================

  void _showFilterModal(BuildContext context, List<WalletEntry> wallets) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.canvasCardSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setFilterState) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.textSubtle, borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 18),
                Text('Filter Transaksi', style: AppTypography.sectionTitle),
                const SizedBox(height: 16),

                Text('TIPE TRANSAKSI', style: AppTypography.badgeLabel.copyWith(color: AppColors.textMuted)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildFilterChoiceChip('all', 'Semua', _typeFilter, (val) {
                      setState(() => _typeFilter = val!);
                      setFilterState(() {});
                    }),
                    _buildFilterChoiceChip('expense', 'Pengeluaran', _typeFilter, (val) {
                      setState(() => _typeFilter = val!);
                      setFilterState(() {});
                    }),
                    _buildFilterChoiceChip('income', 'Pemasukan', _typeFilter, (val) {
                      setState(() => _typeFilter = val!);
                      setFilterState(() {});
                    }),
                    _buildFilterChoiceChip('transfer', 'Transfer', _typeFilter, (val) {
                      setState(() => _typeFilter = val!);
                      setFilterState(() {});
                    }),
                  ],
                ),
                const SizedBox(height: 16),

                Text('REKENING', style: AppTypography.badgeLabel.copyWith(color: AppColors.textMuted)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildFilterChoiceChip(null, 'Semua Rekening', _walletFilter, (val) {
                      setState(() => _walletFilter = val);
                      setFilterState(() {});
                    }),
                    for (final w in wallets)
                      _buildFilterChoiceChip(w.id, w.name, _walletFilter, (val) {
                        setState(() => _walletFilter = val);
                        setFilterState(() {});
                      }),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.neoChartreuse, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                    onPressed: () => Navigator.pop(ctx),
                    child: Text('Terapkan Filter', style: AppTypography.listTitle.copyWith(color: AppColors.textDarkPrimary, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  Widget _buildFilterChoiceChip(String? value, String label, String? currentGroup, ValueChanged<String?> onSelected) {
    final isSelected = value == currentGroup;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.neoChartreuse,
      backgroundColor: AppColors.canvasInputSearch,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.textDarkPrimary : AppColors.textWhite,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      onSelected: (_) => onSelected(value),
    );
  }

  void _showSafeToSpendModal(BuildContext context, List<WalletEntry> wallets) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.canvasCardSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) {
        return BlocBuilder<FinanceBloc, FinanceState>(
          builder: (context, state) {
            final metrics = state.metrics;
            final selectedIds = state.safeToSpendWalletIds ?? <String>{};
            final isAll = state.safeToSpendWalletIds == null || state.safeToSpendWalletIds!.isEmpty;

            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.textSubtle, borderRadius: BorderRadius.circular(2)))),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(shape: BoxShape.circle, color: metrics.statusColor.withOpacity(0.2)),
                        child: Icon(Icons.shield_outlined, color: metrics.statusColor, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Smart Safe-to-Spend', style: AppTypography.sectionTitle),
                            Text('Status: ${metrics.statusLabel}', style: TextStyle(color: metrics.statusColor, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // ── Spending Source Accounts Selection (Flexible Wallets) ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'SUMBER REKENING PENGELUARAN',
                          style: AppTypography.badgeLabel.copyWith(color: AppColors.textMuted),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isAll ? 'Semua (${wallets.length})' : '${selectedIds.length} Dipilih',
                        style: AppTypography.badgeLabel.copyWith(color: AppColors.neoChartreuse),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      // "Semua Rekening" Chip
                      FilterChip(
                        label: Text('Semua (${wallets.length})'),
                        selected: isAll,
                        selectedColor: AppColors.neoChartreuse,
                        backgroundColor: AppColors.canvasInputSearch,
                        labelStyle: TextStyle(
                          color: isAll ? AppColors.textDarkPrimary : AppColors.textWhite,
                          fontWeight: isAll ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                        onSelected: (_) {
                          context.read<FinanceBloc>().add(const SetSafeToSpendWalletsEvent(null));
                        },
                      ),

                      // Individual Wallet Chips
                      for (final w in wallets) ...[
                        Builder(builder: (context) {
                          final isSelected = !isAll && selectedIds.contains(w.id);
                          return FilterChip(
                            label: Text(w.name),
                            selected: isSelected,
                            selectedColor: AppColors.neoMint,
                            backgroundColor: AppColors.canvasInputSearch,
                            labelStyle: TextStyle(
                              color: isSelected ? AppColors.textDarkPrimary : AppColors.textWhite,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 12,
                            ),
                            onSelected: (selected) {
                              Set<String> newSet;
                              if (isAll) {
                                newSet = {w.id};
                              } else {
                                newSet = Set<String>.from(selectedIds);
                                if (selected) {
                                  newSet.add(w.id);
                                } else {
                                  newSet.remove(w.id);
                                }
                              }

                              if (newSet.isEmpty || newSet.length >= wallets.length) {
                                context.read<FinanceBloc>().add(const SetSafeToSpendWalletsEvent(null));
                              } else {
                                context.read<FinanceBloc>().add(SetSafeToSpendWalletsEvent(newSet));
                              }
                            },
                          );
                        }),
                      ],
                    ],
                  ),
                  const SizedBox(height: 18),

                  // ── Calculation Breakdown ──
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.canvasInputSearch, borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        _buildCalcRow(
                          isAll ? 'Total Saldo Riil' : 'Saldo Rekening Terpilih',
                          '+Rp ${metrics.totalRealBalance.toStringAsFixed(0)}',
                          AppColors.neoMint,
                        ),
                        const Divider(color: AppColors.canvasBorder),
                        _buildCalcRow(
                          isAll ? 'Sisa Tagihan Bulan Ini' : 'Tagihan Terkait Terpilih',
                          '-Rp ${metrics.pendingBills.toStringAsFixed(0)}',
                          AppColors.neoCoral,
                        ),
                        const Divider(color: AppColors.canvasBorder),
                        _buildCalcRow(
                          'Safe-to-Spend (Aman Belanja)',
                          'Rp ${metrics.safeToSpendMonthly.toStringAsFixed(0)}',
                          AppColors.neoChartreuse,
                          isBold: true,
                        ),
                        const Divider(color: AppColors.canvasBorder),
                        _buildCalcRow(
                          'Alokasi Harian (${metrics.daysRemainingInMonth} hr)',
                          'Rp ${metrics.safeToSpendDaily.toStringAsFixed(0)} / hr',
                          AppColors.neoCyan,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    isAll
                        ? 'Dihitung dari seluruh rekening Anda. Uang ini aman dibelanjakan tanpa khawatir tagihan bulanan gagal bayar.'
                        : 'Dihitung hanya dari rekening pengeluaran yang Anda pilih (${metrics.selectedWalletsCount} rekening). Tagihan dan saldo rekening tabungan lain tidak dicampur.',
                    style: AppTypography.listSubtitle,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showWalletsListModal(BuildContext context, List<WalletEntry> wallets) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.canvasCardSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.textSubtle, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 18),
              Text('Rincian Saldo Rekening', style: AppTypography.sectionTitle),
              const SizedBox(height: 14),
              for (final w in wallets)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Container(width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, color: Color(int.parse(w.colorHex.replaceFirst('#', '0xFF'))))),
                      const SizedBox(width: 12),
                      Text(w.name, style: AppTypography.listTitle),
                      const Spacer(),
                      Text('Rp ${w.balance.toStringAsFixed(0)}', style: AppTypography.listAmount),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showBillsListModal(BuildContext context, List<SubscriptionEntry> subscriptions) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.canvasCardSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.textSubtle, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 18),
              Text('Tagihan Rutin Bulan Ini', style: AppTypography.sectionTitle),
              const SizedBox(height: 14),
              if (subscriptions.isEmpty)
                Text('Tidak ada tagihan aktif.', style: AppTypography.listSubtitle)
              else
                for (final sub in subscriptions)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(sub.title, style: AppTypography.listTitle),
                            Text('Jatuh tempo tgl ${sub.dueDay}', style: AppTypography.listSubtitle),
                          ],
                        ),
                        Text('Rp ${sub.cost.toStringAsFixed(0)}', style: AppTypography.listAmount.copyWith(color: AppColors.neoCoral)),
                      ],
                    ),
                  ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showDailyPaceModal(BuildContext context, SafeToSpendMetrics metrics) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.canvasCardSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.textSubtle, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 18),
              Text('Alokasi Harian (Daily Pace)', style: AppTypography.sectionTitle),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.canvasInputSearch, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    _buildCalcRow('Sisa Hari Bulan Ini', '${metrics.daysRemainingInMonth} Hari', AppColors.textWhite),
                    const Divider(color: AppColors.canvasBorder),
                    _buildCalcRow('Batas Aman Belanja / Hari', 'Rp ${metrics.safeToSpendDaily.toStringAsFixed(0)}', AppColors.neoCyan, isBold: true),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Menjaga belanja rata-rata harian Anda di bawah angka ini akan menjamin keuangan tetap surplus hingga akhir bulan.',
                style: AppTypography.listSubtitle,
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showAllTransactionsModal(BuildContext context, List<TransactionEntry> allTransactions, List<WalletEntry> wallets) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.canvasCardSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.textSubtle, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 18),
              Text('Semua Riwayat Transaksi (${allTransactions.length})', style: AppTypography.sectionTitle),
              const SizedBox(height: 14),
              Expanded(
                child: allTransactions.isEmpty
                    ? Center(child: Text('Belum ada transaksi', style: AppTypography.listSubtitle))
                    : ListView.builder(
                        itemCount: allTransactions.length,
                        itemBuilder: (ctx, i) {
                          final tx = allTransactions[i];
                          final w = wallets.firstWhere((wallet) => wallet.id == tx.walletId, orElse: () => wallets.first);
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: tx.type == 'expense' ? AppColors.neoCoral.withOpacity(0.2) : AppColors.neoMint.withOpacity(0.2),
                              child: Icon(tx.type == 'expense' ? Icons.arrow_outward : Icons.arrow_downward, color: tx.type == 'expense' ? AppColors.neoCoral : AppColors.neoMint),
                            ),
                            title: Text(tx.notes ?? tx.type.toUpperCase(), style: AppTypography.listTitle),
                            subtitle: Text('${w.name} • ${DateFormat('dd MMM yyyy, HH:mm').format(tx.transactionDate)}', style: AppTypography.listSubtitle),
                            trailing: Text(
                              '${tx.type == 'income' ? '+' : '-'}Rp ${tx.amount.toStringAsFixed(0)}',
                              style: AppTypography.listAmount.copyWith(color: tx.type == 'income' ? AppColors.neoMint : AppColors.textWhite),
                            ),
                            onTap: () {
                              Navigator.pop(ctx);
                              TransactionDetailModal.show(context, db: widget.db, transaction: tx);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showProfileModal(BuildContext context, int walletCount, int txCount) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.canvasCardSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.textSubtle, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(width: 52, height: 52, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF1E212D)), child: const Icon(Icons.person, color: AppColors.textWhite, size: 28)),
                  const SizedBox(width: 14),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('David Arrozaqi', style: AppTypography.heroGreeting.copyWith(fontSize: 20)),
                    Text('Akun Lokal Offline-First', style: AppTypography.listSubtitle),
                  ]),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.canvasInputSearch, borderRadius: BorderRadius.circular(16)),
                child: Column(children: [
                  _buildCalcRow('Total Rekening Terhubung', '$walletCount Akun', AppColors.textWhite),
                  const Divider(color: AppColors.canvasBorder),
                  _buildCalcRow('Total Transaksi Tercatat', '$txCount Transaksi', AppColors.textWhite),
                  const Divider(color: AppColors.canvasBorder),
                  _buildCalcRow('Status Database', 'SQLite Aktif (Offline)', AppColors.neoMint),
                ]),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCalcRow(String label, String val, Color color, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: AppColors.textWhite, fontSize: 13, fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(val, style: TextStyle(color: color, fontSize: 14, fontWeight: isBold ? FontWeight.bold : FontWeight.w600, fontFeatures: const [FontFeature.tabularFigures()])),
        ],
      ),
    );
  }

  void _showPendingInboxModal(BuildContext context) async {
    final pending = await NotificationBridge.getPendingRawNotifications();
    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.canvasCardSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.textSubtle, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.inbox_outlined, color: AppColors.neoChartreuse, size: 22),
                      const SizedBox(width: 8),
                      Text('Kotak Masuk Notifikasi', style: AppTypography.sectionTitle),
                    ],
                  ),
                  IconButton(icon: const Icon(Icons.close, color: AppColors.textMuted), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 6),
              Text('Notifikasi bank yang masuk saat aplikasi tidak dibuka ditampung aman di sini:', style: AppTypography.listSubtitle),
              const SizedBox(height: 16),
              if (pending.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: AppColors.canvasInputSearch, borderRadius: BorderRadius.circular(16)),
                  child: Center(
                    child: Text('Tidak ada antrean notifikasi tertunda.\nSemua transaksi bank Anda sudah rapi tercatat!', textAlign: TextAlign.center, style: AppTypography.listSubtitle),
                  ),
                )
              else
                for (final item in pending)
                  Builder(builder: (c) {
                    final pkg = item['package'] as String? ?? '';
                    final title = item['title'] as String? ?? '';
                    final text = item['text'] as String? ?? '';
                    final parsed = NotificationParser.parse(packageName: pkg, title: title, body: text);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AppColors.canvasInputSearch, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.canvasBorder)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(pkg.contains('seabank') ? 'SeaBank' : (pkg.contains('shopee') ? 'ShopeePay' : title), style: AppTypography.listTitle),
                              if (parsed != null)
                                Text(
                                  parsed.type == 'income' ? '+Rp ${parsed.amount.toStringAsFixed(0)}' : '-Rp ${parsed.amount.toStringAsFixed(0)}',
                                  style: AppTypography.listAmount.copyWith(color: parsed.type == 'income' ? AppColors.neoMint : AppColors.neoCoral),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(text, style: AppTypography.listSubtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 12),
                          if (parsed != null)
                            SizedBox(
                              width: double.infinity,
                              height: 40,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.neoChartreuse, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                child: Text('Review & Simpan', style: AppTypography.listTitle.copyWith(color: AppColors.textDarkPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
                                onPressed: () async {
                                  Navigator.pop(ctx);
                                  await NotificationReviewModal.show(context, db: widget.db, parsed: parsed, rawPackage: pkg);
                                },
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
            ],
          ),
        );
      },
    );
  }
}
