import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../bloc/finance/finance_bloc.dart';
import '../../bloc/finance/finance_event.dart';
import '../../bloc/finance/finance_state.dart';
import '../../data/database/app_database.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/subscription_stacked_deck.dart';
import '../modals/subscription_filter_modal.dart';
import '../widgets/subscription_modal.dart';

class SubscriptionScreen extends StatefulWidget {
  final VoidCallback? onAddSubscription;

  const SubscriptionScreen({
    super.key,
    this.onAddSubscription,
  });

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  String _filter = 'all'; // 'all', 'unpaid', 'paid'
  String? _walletFilter;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: AppColors.canvasBg,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<FinanceBloc, FinanceState>(
          builder: (context, state) {
            final subscriptions = state.subscriptions;
            final wallets = state.wallets;


            // Filter logic
            final filtered = subscriptions.where((sub) {
              final isPaid = sub.lastPaidDate != null &&
                  sub.lastPaidDate!.year == now.year &&
                  sub.lastPaidDate!.month == now.month;

              if (_filter == 'unpaid' && isPaid) return false;
              if (_filter == 'paid' && !isPaid) return false;
              if (_walletFilter != null && sub.walletId != _walletFilter) return false;

              if (_searchQuery.isNotEmpty) {
                final matchTitle = sub.title.toLowerCase().contains(_searchQuery.toLowerCase());
                final wallet = wallets.firstWhere((w) => w.id == sub.walletId, orElse: () => wallets.first);
                final matchWallet = wallet.name.toLowerCase().contains(_searchQuery.toLowerCase());
                return matchTitle || matchWallet;
              }
              return true;
            }).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Clean Swiss-Editorial Header (No redundant plus button)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tagihan & Langganan',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textWhite,
                          letterSpacing: -0.6,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${subscriptions.length} Kartu Terdaftar • Diurutkan jatuh tempo',
                        style: AppTypography.listSubtitle,
                      ),
                    ],
                  ),
                ),

                if (subscriptions.isEmpty)
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 68,
                              height: 68,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF13151D),
                                border: Border.all(color: AppColors.canvasBorder, width: 1.5),
                              ),
                              child: const Icon(Icons.receipt_long_outlined, color: AppColors.neoCoral, size: 32),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'Belum Ada Tagihan Rutin',
                              style: AppTypography.heroGreeting.copyWith(fontSize: 20),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Daftarkan langganan (Netflix, Spotify, Kost, Indihome, dll) untuk kalkulasi Safe-to-Spend otomatis.',
                              textAlign: TextAlign.center,
                              style: AppTypography.listSubtitle,
                            ),
                            const SizedBox(height: 24),
                            GestureDetector(
                              onTap: () => AddSubscriptionModal.show(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.neoChartreuse,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Text(
                                  '+ Tambah Tagihan Pertama',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textDarkPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else ...[
                // Search Bar (Styled Identical to Home / Dashboard Screen with tune filter button)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Container(
                    height: 46,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.canvasInputSearch,
                      borderRadius: BorderRadius.circular(23),
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
                              hintText: 'Cari tagihan, langganan, rekening...',
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
                            SubscriptionFilterModal.show(
                              context: context,
                              wallets: wallets,
                              initialStatus: _filter,
                              initialWalletId: _walletFilter,
                              onApply: (status, walletId) {
                                setState(() {
                                  _filter = status;
                                  _walletFilter = walletId;
                                });
                              },
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: (_filter != 'all' || _walletFilter != null)
                                  ? AppColors.neoChartreuse.withValues(alpha: 0.2)
                                  : Colors.transparent,
                            ),
                            child: Icon(
                              Icons.tune,
                              color: (_filter != 'all' || _walletFilter != null)
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

                // Active Filter Chips (Identical to Home)
                if (_filter != 'all' || _walletFilter != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: Row(
                      children: [
                        if (_filter != 'all')
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Chip(
                              backgroundColor: AppColors.canvasInputSearch,
                              side: const BorderSide(color: AppColors.neoChartreuse),
                              label: Text(
                                _filter == 'unpaid' ? 'Belum Bayar' : 'Sudah Lunas',
                                style: AppTypography.badgeLabel.copyWith(color: AppColors.neoChartreuse),
                              ),
                              onDeleted: () => setState(() => _filter = 'all'),
                              deleteIconColor: AppColors.neoChartreuse,
                            ),
                          ),
                        if (_walletFilter != null)
                          Chip(
                            backgroundColor: AppColors.canvasInputSearch,
                            side: const BorderSide(color: AppColors.neoChartreuse),
                            label: Text(
                              'Rek: ${wallets.firstWhere((w) => w.id == _walletFilter, orElse: () => wallets.first).name}',
                              style: AppTypography.badgeLabel.copyWith(color: AppColors.neoChartreuse),
                            ),
                            onDeleted: () => setState(() => _walletFilter = null),
                            deleteIconColor: AppColors.neoChartreuse,
                          ),
                      ],
                    ),
                  ),

                // Interactive Stacked Card Deck strictly matching ref1.jpg
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Text(
                              _searchQuery.isNotEmpty
                                  ? 'Tidak ada tagihan yang cocok dengan "$_searchQuery"'
                                  : 'Tidak ada tagihan dalam filter ini',
                              style: AppTypography.listSubtitle,
                            ),
                          ),
                        )
                      : SubscriptionStackedDeck(
                          subscriptions: filtered,
                          wallets: wallets,
                          onTapCard: (sub, wallet) => _showSubscriptionDetailModal(context, sub, wallet),
                        ),
                ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  void _showSubscriptionDetailModal(BuildContext context, SubscriptionEntry sub, WalletEntry wallet) {
    final now = DateTime.now();
    final isPaidThisMonth = sub.lastPaidDate != null &&
        sub.lastPaidDate!.year == now.year &&
        sub.lastPaidDate!.month == now.month;

    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF13151D),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (modalCtx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.canvasBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sub.title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textWhite,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Jatuh tempo setiap tanggal ${sub.dueDay} • ${sub.billingCycle == 'monthly' ? 'Bulanan' : 'Tahunan'}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    currencyFormatter.format(sub.cost),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.neoCoral,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Account & Deduct Details
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.canvasCardSurface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.canvasBorder),
                ),
                child: Column(
                  children: [
                    _buildDetailRow('Rekening Pembayaran', wallet.name, Icons.account_balance_wallet_outlined),
                    const Divider(color: AppColors.canvasBorder, height: 18),
                    _buildDetailRow('Saldo Rekening Saat Ini', currencyFormatter.format(wallet.balance), Icons.account_balance_outlined),
                    const Divider(color: AppColors.canvasBorder, height: 18),
                    _buildDetailRow('Metode Pembayaran', sub.autoDeduct ? 'Auto-Deduct Aktif' : 'Manual Transfer / QRIS', Icons.sync_rounded),
                    const Divider(color: AppColors.canvasBorder, height: 18),
                    _buildDetailRow(
                      'Status Periode Ini',
                      isPaidThisMonth ? 'Sudah Lunas ✓' : 'Belum Dibayar',
                      isPaidThisMonth ? Icons.verified_rounded : Icons.pending_actions_rounded,
                      valueColor: isPaidThisMonth ? AppColors.neoMint : AppColors.neoCoral,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              if (!isPaidThisMonth) ...[
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.neoChartreuse,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.check_circle_outline, color: AppColors.textDarkPrimary),
                    label: Text(
                      'Tandai Sudah Lunas Bulan Ini',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: AppColors.textDarkPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    onPressed: () {
                      context.read<FinanceBloc>().add(MarkSubscriptionPaidEvent(sub.id));
                      Navigator.pop(modalCtx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.neoMint,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          content: Text(
                            'Tagihan ${sub.title} ditandai lunas! Saldo ${wallet.name} terpotong otomatis.',
                            style: const TextStyle(color: AppColors.textDarkPrimary, fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.neoMint.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.neoMint.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified, color: AppColors.neoMint),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Tagihan ini sudah tercatat lunas untuk periode bulan ini!',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: AppColors.neoMint,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 14),

              // Edit & Delete Action Buttons
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.canvasBorder),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        icon: const Icon(Icons.edit_outlined, color: AppColors.textWhite, size: 18),
                        label: Text(
                          'Edit Tagihan',
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.textWhite,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(modalCtx);
                          AddSubscriptionModal.show(context, subscription: sub);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.neoCoral.withValues(alpha: 0.6)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        icon: const Icon(Icons.delete_outline_rounded, color: AppColors.neoCoral, size: 18),
                        label: Text(
                          'Hapus',
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.neoCoral,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(modalCtx);
                          _confirmDeleteSubscription(context, sub);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDeleteSubscription(BuildContext context, SubscriptionEntry sub) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.canvasCardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Hapus Tagihan?',
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.textWhite,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        content: Text(
          'Tagihan "${sub.title}" akan dihapus dari daftar komitmen pengeluaran Safe-to-Spend. Riwayat transaksi sebelumnya tidak terhapus.',
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.textMuted,
            fontSize: 13.5,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neoCoral,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<FinanceBloc>().add(DeleteSubscriptionEvent(sub.id));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.neoCoral,
                  content: Text(
                    'Tagihan ${sub.title} telah dihapus.',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
            child: Text(
              'Hapus',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon, {Color? valueColor}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 10),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textMuted),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: valueColor ?? AppColors.textWhite,
          ),
        ),
      ],
    );
  }
}

