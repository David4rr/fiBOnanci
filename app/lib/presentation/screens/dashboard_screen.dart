import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../bloc/finance/finance_bloc.dart';
import '../../bloc/finance/finance_state.dart';
import '../../core/native_bridge/notification_bridge.dart';
import '../../core/notification_parser/notification_parser.dart';
import '../../data/database/app_database.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/folder_tab_card.dart';
import '../widgets/notification_review_modal.dart';
import '../widgets/overlapping_deck.dart';
import '../widgets/transaction_detail_modal.dart';

class DashboardScreen extends StatelessWidget {
  final AppDatabase db;

  const DashboardScreen({
    super.key,
    required this.db,
  });

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
        child: BlocBuilder<FinanceBloc, FinanceState>(
          builder: (context, state) {
            final wallets = state.wallets;
            final subscriptions = state.subscriptions;
            final transactions = state.transactions;
            final metrics = state.metrics;

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
                            Container(
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
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // 2. Search Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.canvasInputSearch,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.canvasBorder, width: 1),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: AppColors.textMuted, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Cari transaksi, rekening...',
                              style: AppTypography.listSubtitle,
                            ),
                          ),
                          const Icon(Icons.tune, color: AppColors.textWhite, size: 18),
                        ],
                      ),
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

                // 4. 2x2 Bento Folder Grid (Safe-to-Spend & Financial Health from BLoC RAM)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Card 1: Safe-to-Spend (Chartreuse)
                            Expanded(
                              child: FolderTabCard(
                                backgroundColor: AppColors.neoChartreuse,
                                height: 140,
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
                                        Text('Safe to Spend', style: AppTypography.cardMetricLabel),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),

                            // Card 2: Total Real Balance (Mint)
                            Expanded(
                              child: FolderTabCard(
                                backgroundColor: AppColors.neoMint,
                                height: 140,
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
                                        Text('${wallets.length} Akun Riil', style: AppTypography.cardMetricLabel),
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
                            // Card 3: Pending Bills (Coral)
                            Expanded(
                              child: FolderTabCard(
                                backgroundColor: AppColors.neoCoral,
                                height: 140,
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
                                        Text('${subscriptions.length} Tagihan Bulan Ini', style: AppTypography.cardMetricLabel),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),

                            // Card 4: Daily Allowance (Cyan)
                            Expanded(
                              child: FolderTabCard(
                                backgroundColor: AppColors.neoCyan,
                                height: 140,
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
                                        Text('Alokasi / Hari (${metrics.daysRemainingInMonth} hr)', style: AppTypography.cardMetricLabel),
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

                // 5. Section Title: Riwayat Transaksi (Overlapping Deck View)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text('Riwayat Transaksi', style: AppTypography.sectionTitle, overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(width: 8),
                        Text('Lihat Semua', style: AppTypography.listSubtitle.copyWith(color: AppColors.neoChartreuse)),
                      ],
                    ),
                  ),
                ),

                // 6. Overlapping Deck of Transactions (Instant RAM List)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: transactions.isEmpty
                        ? Container(
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              color: AppColors.canvasCardSurface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.canvasBorder),
                            ),
                            child: Center(
                              child: Text(
                                'Belum ada transaksi. Tambahkan pengeluaran atau tunggu notifikasi bank masuk otomatis!',
                                textAlign: TextAlign.center,
                                style: AppTypography.listSubtitle,
                              ),
                            ),
                          )
                        : OverlappingDeckList(
                            overlapOffset: 12,
                            children: [
                              for (final tx in transactions) ...[
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
                                    onTap: () => TransactionDetailModal.show(context, db: db, transaction: tx),
                                  );
                                }),
                              ],
                            ],
                          ),
                  ),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            );
          },
        ),
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: AppColors.textSubtle, borderRadius: BorderRadius.circular(2)),
                ),
              ),
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
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textMuted),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Notifikasi bank yang masuk saat aplikasi tidak dibuka ditampung aman di sini:',
                style: AppTypography.listSubtitle,
              ),
              const SizedBox(height: 16),
              if (pending.isEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.canvasInputSearch,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      'Tidak ada antrean notifikasi tertunda.\nSemua transaksi bank Anda sudah rapi tercatat!',
                      textAlign: TextAlign.center,
                      style: AppTypography.listSubtitle,
                    ),
                  ),
                ),
              ] else ...[
                for (final item in pending) ...[
                  Builder(builder: (context) {
                    final pkg = item['package'] as String? ?? '';
                    final title = item['title'] as String? ?? '';
                    final text = item['text'] as String? ?? '';
                    final parsed = NotificationParser.parse(packageName: pkg, title: title, body: text);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.canvasInputSearch,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.canvasBorder),
                      ),
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
                                  style: AppTypography.listAmount.copyWith(
                                    color: parsed.type == 'income' ? AppColors.neoMint : AppColors.neoCoral,
                                  ),
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
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.neoChartreuse,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: Text('Review & Simpan', style: AppTypography.listTitle.copyWith(color: AppColors.textDarkPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
                                onPressed: () async {
                                  Navigator.pop(context);
                                  await NotificationReviewModal.show(context, db: db, parsed: parsed, rawPackage: pkg);
                                },
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
                ],
              ],
            ],
          ),
        );
      },
    );
  }
}
