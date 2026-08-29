import 'dart:math' as math;
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
import '../widgets/subscription_card.dart';
import '../widgets/subscription_modal.dart';

class SubscriptionScreen extends StatefulWidget {
  final AppDatabase db;
  final VoidCallback? onAddSubscription;

  const SubscriptionScreen({
    super.key,
    required this.db,
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

            int paidCount = 0;
            int unpaidCount = 0;

            for (final sub in subscriptions) {
              final isPaid = sub.lastPaidDate != null &&
                  sub.lastPaidDate!.year == now.year &&
                  sub.lastPaidDate!.month == now.month;
              if (isPaid) {
                paidCount++;
              } else {
                unpaidCount++;
              }
            }

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
                              onTap: () => AddSubscriptionModal.show(context, widget.db),
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
                          db: widget.db,
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
                          AddSubscriptionModal.show(context, widget.db, subscription: sub);
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

/// Interactive Speedometer / Rolodex Stacked Card Deck for Subscriptions strictly matching ref1.jpg.
///
/// Features:
/// - Exact vertical centering of the active focused card.
/// - Cards above center stack upward with upper headers peeking.
/// - Cards below center stack downward with lower rims peeking.
/// - 120Hz smooth scrolling / flick physics with page snapping.
/// - Tapping a peeking card rolls it directly to center; tapping the center card opens details.
class SubscriptionStackedDeck extends StatefulWidget {
  final List<SubscriptionEntry> subscriptions;
  final List<WalletEntry> wallets;
  final AppDatabase db;
  final void Function(SubscriptionEntry, WalletEntry) onTapCard;

  const SubscriptionStackedDeck({
    super.key,
    required this.subscriptions,
    required this.wallets,
    required this.db,
    required this.onTapCard,
  });

  @override
  State<SubscriptionStackedDeck> createState() => _SubscriptionStackedDeckState();
}

class _SubscriptionStackedDeckState extends State<SubscriptionStackedDeck> with SingleTickerProviderStateMixin {
  double _currentPage = 0.0;
  late AnimationController _animController;
  Animation<double>? _snapAnimation;

  static const double _cardHeight = 215.0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this);
    _animController.addListener(() {
      if (_snapAnimation != null) {
        setState(() {
          _currentPage = _snapAnimation!.value;
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant SubscriptionStackedDeck oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.subscriptions.isNotEmpty && _currentPage >= widget.subscriptions.length) {
      _snapTo((widget.subscriptions.length - 1).toDouble());
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _snapTo(double targetPage) {
    final clamped = targetPage.clamp(0.0, (widget.subscriptions.length - 1).toDouble());
    _snapAnimation = Tween<double>(begin: _currentPage, end: clamped).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _animController.duration = const Duration(milliseconds: 280);
    _animController.forward(from: 0.0);
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_animController.isAnimating) _animController.stop();
    setState(() {
      // 1 full card scroll per ~160dp drag
      final delta = -details.primaryDelta! / 160.0;
      _currentPage = (_currentPage + delta).clamp(-0.2, widget.subscriptions.length - 0.8);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0.0;
    if (velocity.abs() > 250) {
      final target = velocity < 0 ? _currentPage.floor() + 1.0 : _currentPage.ceil() - 1.0;
      _snapTo(target);
    } else {
      _snapTo(_currentPage.roundToDouble());
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = widget.subscriptions;
    if (list.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final double viewportHeight = constraints.maxHeight;
        final double centerY = math.max(0.0, (viewportHeight - _cardHeight) / 2.0 - 15.0);

        // Sort indices by distance from current page descending so the center card is rendered LAST (on top of z-index)
        final sortedIndices = List<int>.generate(list.length, (i) => i)
          ..sort((a, b) {
            final distA = (a - _currentPage).abs();
            final distB = (b - _currentPage).abs();
            return distB.compareTo(distA); // Furthest first, closest last
          });

        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onVerticalDragUpdate: _onDragUpdate,
          onVerticalDragEnd: _onDragEnd,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Stacked Visual Layer with Speedometer Physics
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    for (final i in sortedIndices)
                      Builder(builder: (context) {
                        final sub = list[i];
                        final wallet = widget.wallets.firstWhere(
                          (w) => w.id == sub.walletId,
                          orElse: () => widget.wallets.first,
                        );

                        final double diff = i - _currentPage;
                        final double absDiff = diff.abs();

                        // Position calculation: cards above stack upwards, cards below stack downwards
                        double top;
                        if (diff < 0) {
                          top = centerY - (math.pow(absDiff, 0.78) * 60.0);
                        } else {
                          top = centerY + (math.pow(absDiff, 0.78) * 60.0);
                        }

                        // Slight scale falloff for subtle depth perspective
                        final double scale = (1.0 - absDiff * 0.015).clamp(0.92, 1.0);

                        return Positioned(
                          top: top,
                          left: 0,
                          right: 0,
                          height: _cardHeight,
                          child: Transform.scale(
                            scale: scale,
                            alignment: Alignment.center,
                            child: SubscriptionCard(
                              subscription: sub,
                              wallet: wallet,
                              indexOverride: i,
                              isFocused: absDiff < 0.35,
                              onTap: () {
                                if (absDiff < 0.35) {
                                  widget.onTapCard(sub, wallet);
                                } else {
                                  _snapTo(i.toDouble());
                                }
                              },
                            ),
                          ),
                        );
                      }),
                  ],
                ),
              ),

              // Compact Speedometer Counter Badge at Bottom Center
              if (list.length > 1)
                Positioned(
                  bottom: 8,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF13151D).withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.canvasBorder),
                      ),
                      child: Text(
                        '${(_currentPage.round().clamp(0, list.length - 1) + 1)} / ${list.length}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMuted,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Swiss-Editorial Filter Modal for Subscription Screen matching TransactionFilterModal on Dashboard.
class SubscriptionFilterModal {
  static void show({
    required BuildContext context,
    required List<WalletEntry> wallets,
    required String initialStatus,
    required String? initialWalletId,
    required void Function(String status, String? walletId) onApply,
  }) {
    String currentStatus = initialStatus;
    String? currentWalletId = initialWalletId;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.canvasCardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setFilterState) {
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
                      decoration: BoxDecoration(
                        color: AppColors.textSubtle,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text('Filter Tagihan', style: AppTypography.sectionTitle),
                  const SizedBox(height: 16),

                  Text(
                    'STATUS PEMBAYARAN',
                    style: AppTypography.badgeLabel.copyWith(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildFilterChoiceChip('all', 'Semua Status', currentStatus, (val) {
                        currentStatus = val!;
                        setFilterState(() {});
                      }),
                      _buildFilterChoiceChip('unpaid', 'Belum Bayar', currentStatus, (val) {
                        currentStatus = val!;
                        setFilterState(() {});
                      }),
                      _buildFilterChoiceChip('paid', 'Sudah Lunas', currentStatus, (val) {
                        currentStatus = val!;
                        setFilterState(() {});
                      }),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'REKENING PEMBAYARAN',
                    style: AppTypography.badgeLabel.copyWith(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildFilterChoiceChip(null, 'Semua Rekening', currentWalletId, (val) {
                        currentWalletId = val;
                        setFilterState(() {});
                      }),
                      for (final w in wallets)
                        _buildFilterChoiceChip(w.id, w.name, currentWalletId, (val) {
                          currentWalletId = val;
                          setFilterState(() {});
                        }),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.neoChartreuse,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        onApply(currentStatus, currentWalletId);
                      },
                      child: Text(
                        'Terapkan Filter',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.textDarkPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static Widget _buildFilterChoiceChip<T>(
    T value,
    String label,
    T groupValue,
    ValueChanged<T?> onSelected,
  ) {
    final isSelected = value == groupValue;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(value),
      backgroundColor: AppColors.canvasInputSearch,
      selectedColor: AppColors.neoChartreuse,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.textDarkPrimary : AppColors.textWhite,
        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
        fontSize: 12.5,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.neoChartreuse : AppColors.canvasBorder,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    );
  }
}
