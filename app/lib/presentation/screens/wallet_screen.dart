import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../bloc/finance/finance_bloc.dart';
import '../../bloc/finance/finance_event.dart';
import '../../bloc/finance/finance_state.dart';
import '../../data/database/app_database.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/transaction_detail_modal.dart';
import '../widgets/transaction_modal.dart';
import '../widgets/trend_spline_chart.dart';

// ── Wallet card color palette (cycles through wallets) ──────────────────────
const _kWalletColors = [
  Color(0xFF7DF24E), // neoMint
  Color(0xFFFF7052), // neoCoral
  Color(0xFF26D9D9), // neoCyan
  Color(0xFFD4F442), // neoChartreuse
  Color(0xFFA855F7), // neoPurple
  Color(0xFFF59E0B), // amber
  Color(0xFF60A5FA), // blue
  Color(0xFFF472B6), // pink
];

Color _walletColor(int index, String colorHex) {
  // Prefer the stored hex; fall back to palette if it's the default green
  if (colorHex != '#10B981' && colorHex != '#10b981') {
    try {
      return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    } catch (_) {}
  }
  return _kWalletColors[index % _kWalletColors.length];
}

// ── WalletCardDeck ────────────────────────────────────────────────────────────
// ATM card ratio: ISO 7810 ID-1 = 85.60 × 53.98mm → height = width × 0.631
// Clean tactile stacked card view with uniform peeking cards.
// When a card is lifted, its placeholder in the deck is hidden (zero duplicate cards),
// and the deck below never expands downwards.
class _WalletCardDeck extends StatelessWidget {
  final List<WalletEntry> wallets;
  final NumberFormat fmt;
  final String? liftedWalletId;
  final ValueChanged<WalletEntry> onSelectWallet;

  static const double atmRatio   = 53.98 / 85.60; // ≈ 0.631
  static const double peekHeight = 78.0;          // 78px per peek
  static const Duration liftAnim = Duration(milliseconds: 240);
  const _WalletCardDeck({
    super.key,
    required this.wallets,
    required this.fmt,
    required this.liftedWalletId,
    required this.onSelectWallet,
  });

  @override
  Widget build(BuildContext context) {
    if (wallets.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppColors.canvasCardSurface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.canvasBorder),
        ),
        child: Center(
          child: Text('Belum ada rekening. Ketuk + untuk menambahkan.',
              textAlign: TextAlign.center, style: AppTypography.listSubtitle),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardW  = constraints.maxWidth;
        final cardH  = cardW * atmRatio;
        final stackH = (wallets.length - 1) * peekHeight + cardH + 16.0;

        return SizedBox(
          height: stackH,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              for (int i = 0; i < wallets.length; i++) ...[
                Builder(builder: (context) {
                  final wallet = wallets[i];
                  final isLifted = liftedWalletId == wallet.id;
                  if (isLifted) {
                    return const SizedBox.shrink();
                  }

                  final double topPos = i * peekHeight;

                  return Positioned(
                    key: ValueKey('deck_card_${wallet.id}'),
                    top: topPos,
                    left: 0,
                    right: 0,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onSelectWallet(wallet),
                      child: _WalletCard(
                        wallet: wallet,
                        index: i,
                        fmt: fmt,
                        cardH: cardH,
                        isLifted: false,
                        // ShopeePay (yang paling akhir) sits in front with text at bottom.
                        // Cards 0..N-2 are covered by the next card, so text is at top!
                        showBottomLayout: i == wallets.length - 1,
                      ),
                    ),
                  );
                }),
              ],
            ],
          ),
        );
      },
    );
  }
}


// ── _WalletCard ───────────────────────────────────────────────────────────────
// showBottomLayout=false → content (icon+name+balance) at TOP (always visible in peek)
// showBottomLayout=true  → content at BOTTOM (full ATM card view: icon top, info bottom)
// Transition animated via AnimatedCrossFade.
class _WalletCard extends StatelessWidget {
  final WalletEntry  wallet;
  final int          index;
  final NumberFormat fmt;
  final double       cardH;
  final bool         isLifted;
  final bool         showBottomLayout;

  const _WalletCard({
    required this.wallet,
    required this.index,
    required this.fmt,
    required this.cardH,
    required this.isLifted,
    required this.showBottomLayout,
  });

  String get _typeLabel {
    switch (wallet.type) {
      case 'ewallet': return 'E-Wallet';
      case 'cash':    return 'Kas Tunai';
      default:        return 'Bank';
    }
  }

  IconData get _typeIcon {
    switch (wallet.type) {
      case 'ewallet': return Icons.smartphone_outlined;
      case 'cash':    return Icons.payments_outlined;
      default:        return Icons.account_balance_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg            = _walletColor(index, wallet.colorHex);
    final isDark        = bg.computeLuminance() > 0.4;
    final textPrimary   = isDark ? const Color(0xFF0A0B0E) : Colors.white;
    final textSecondary = isDark ? const Color(0xFF2C303E) : Colors.white70;

    // ── Shared sub-widgets ─────────────────────────────────────────────────
    final iconBadge = Container(
      width: 34, height: 34,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: textSecondary.withOpacity(0.18),
      ),
      child: Icon(_typeIcon, color: textPrimary, size: 17),
    );

    final nameBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _typeLabel.toUpperCase(),
          style: AppTypography.badgeLabel.copyWith(
            color: textSecondary, fontSize: 9, letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          wallet.name,
          style: AppTypography.listTitle.copyWith(
            color: textPrimary, fontWeight: FontWeight.w700, fontSize: 15,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );

    final balanceBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Saldo',
          style: AppTypography.badgeLabel.copyWith(color: textSecondary, fontSize: 9)),
        const SizedBox(height: 2),
        Text(
          fmt.format(wallet.balance),
          style: AppTypography.listTitle.copyWith(
            color: textPrimary, fontWeight: FontWeight.w800, fontSize: 14,
          ),
          maxLines: 1, overflow: TextOverflow.ellipsis,
        ),
      ],
    );

    // ── Top layout: icon+name+balance row at the very top ─────────────────
    // ── Top layout: icon+name+balance row pinned at the VERY TOP of the card ─
    final topLayout = Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            iconBadge,
            const SizedBox(width: 12),
            Expanded(child: nameBlock),
            const SizedBox(width: 10),
            balanceBlock,
          ],
        ),
      ),
    );

    // ── Bottom layout: full tactile ATM card view ─────────────────────────
    final bottomLayout = Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top row: Icon badge + Account Type chip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              iconBadge,
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: textSecondary.withOpacity(0.18),
                ),
                child: Text(
                  _typeLabel.toUpperCase(),
                  style: AppTypography.badgeLabel.copyWith(
                    color: textPrimary,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),

          // Middle: EMV Card Chip & Contactless indicator
          Row(
            children: [
              Container(
                width: 36,
                height: 26,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: textSecondary.withOpacity(0.20),
                  border: Border.all(color: textSecondary.withOpacity(0.35), width: 1),
                ),
                child: Center(
                  child: Container(
                    width: 20,
                    height: 14,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(color: textSecondary.withOpacity(0.4), width: 0.8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Icon(Icons.wifi, color: textSecondary.withOpacity(0.5), size: 18),
            ],
          ),

          // Bottom row: Account Name + Balance
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'NAMA REKENING',
                      style: AppTypography.badgeLabel.copyWith(
                        color: textSecondary,
                        fontSize: 9,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      wallet.name,
                      style: AppTypography.listTitle.copyWith(
                        color: textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'TOTAL SALDO',
                    style: AppTypography.badgeLabel.copyWith(
                      color: textSecondary,
                      fontSize: 9,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    fmt.format(wallet.balance),
                    style: AppTypography.listTitle.copyWith(
                      color: textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    return AnimatedContainer(
      duration: _WalletCardDeck.liftAnim,
      height: cardH,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isLifted
            ? [
                BoxShadow(color: bg.withOpacity(0.45), blurRadius: 24, offset: const Offset(0, 12)),
                BoxShadow(color: Colors.black.withOpacity(0.35), blurRadius: 14, offset: const Offset(0, 6)),
              ]
            : [
                BoxShadow(color: Colors.black.withOpacity(0.30), blurRadius: 10, offset: const Offset(0, 4)),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: AnimatedSwitcher(
          duration: _WalletCardDeck.liftAnim,
          child: showBottomLayout
              ? SizedBox(
                  key: const ValueKey('bottom_layout'),
                  height: cardH,
                  width: double.infinity,
                  child: bottomLayout,
                )
              : SizedBox(
                  key: const ValueKey('top_layout'),
                  height: cardH,
                  width: double.infinity,
                  child: topLayout,
                ),
        ),
      ),
    );
  }
}



// ── WalletScreen ─────────────────────────────────────────────────────────────
class WalletScreen extends StatefulWidget {
  final AppDatabase db;

  const WalletScreen({super.key, required this.db});

  static void showAddWalletModal(BuildContext context) {
    _WalletScreenState.showAddWalletModal(context);
  }

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  WalletEntry? _liftedWallet;
  List<double> _computeSeries(
    List<TransactionEntry> transactions, {
    required String type,
    String? walletId,
  }) {
    final now = DateTime.now();
    final List<double> dailyValues = List.filled(30, 0.0);

    for (final tx in transactions) {
      if (walletId != null && tx.walletId != walletId && tx.destinationWalletId != walletId) {
        continue;
      }
      if (tx.type != type) continue;

      final diff = now.difference(tx.transactionDate).inDays;
      if (diff >= 0 && diff < 30) {
        final index = 29 - diff;
        dailyValues[index] += tx.amount;
      }
    }
    return dailyValues;
  }

  List<String> _computeDayLabels() {
    final now = DateTime.now();
    return List.generate(30, (i) {
      if (i == 0 || i == 7 || i == 14 || i == 21 || i == 29) {
        final d = now.subtract(Duration(days: 29 - i));
        return '${d.day}/${d.month}';
      }
      return '';
    });
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
      body: BlocBuilder<FinanceBloc, FinanceState>(
        builder: (context, state) {
          final wallets = state.wallets;

          double totalRealBalance = 0;
          for (final w in wallets) {
            totalRealBalance += w.balance;
          }

          final activeSelected = _liftedWallet == null
              ? null
              : wallets.firstWhere(
                  (w) => w.id == _liftedWallet!.id,
                  orElse: () => _liftedWallet!,
                );

          return Stack(
            children: [
              SafeArea(
                bottom: false,
                child: CustomScrollView(
                  slivers: [
                    // ── Header ────────────────────────────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Rekening & Dompet', style: AppTypography.heroGreeting.copyWith(fontSize: 26)),
                            const SizedBox(height: 4),
                            Text('${wallets.length} rekening terhubung', style: AppTypography.listSubtitle),
                          ],
                        ),
                      ),
                    ),

                    // ── Total Balance Hero (Static in Layer 1, never lifts) ─
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                          decoration: BoxDecoration(
                            color: AppColors.canvasCardSurface,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppColors.canvasBorder),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('TOTAL SALDO RIIL', style: AppTypography.badgeLabel.copyWith(color: AppColors.textMuted)),
                                    const SizedBox(height: 6),
                                    Text(
                                      currencyFormatter.format(totalRealBalance),
                                      style: AppTypography.heroGreeting.copyWith(color: AppColors.neoMint, fontSize: 24),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.neoMint.withOpacity(0.15),
                                ),
                                child: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.neoMint, size: 26),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // ── All Wallets Cash Flow Trend Chart ──────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                        child: TrendSplineChart(
                          incomeValues: _computeSeries(state.transactions, type: 'income'),
                          expenseValues: _computeSeries(state.transactions, type: 'expense'),
                          labels: _computeDayLabels(),
                          headline: 'Tren Arus Kas (Semua Rekening)',
                          subtitle: '30 Hari Terakhir',
                          height: 110,
                        ),
                      ),
                    ),

                    // ── Section label ─────────────────────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 28, 20, 14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Rekening Aktif', style: AppTypography.sectionTitle),
                            Text('${wallets.length} akun', style: AppTypography.listSubtitle),
                          ],
                        ),
                      ),
                    ),

                    // ── Stacked Card Deck (Constant Height — Never Expands Downwards) ──
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _WalletCardDeck(
                          wallets: wallets,
                          fmt: currencyFormatter,
                          liftedWalletId: activeSelected?.id,
                          onSelectWallet: (wallet) => setState(() => _liftedWallet = wallet),
                        ),
                      ),
                    ),

                    // ── Tip footer ────────────────────────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.canvasCardSurface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.canvasBorder),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.touch_app_outlined, color: AppColors.textMuted, size: 18),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Ketuk kartu untuk mengangkatnya & melihat riwayat mutasi transaksi.',
                                  style: AppTypography.listSubtitle.copyWith(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 140)),
                  ],
                ),
              ),

              // ── Layer 2: Lifted Card View (Zero double cards: original in deck is hidden!) ──
              if (activeSelected != null) ...[
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => _liftedWallet = null),
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.80),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: SafeArea(
                    child: Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.85,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // ── Top Header Row ────────────────────────────
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Detail Rekening',
                                  style: AppTypography.heroGreeting.copyWith(fontSize: 20),
                                ),
                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () => setState(() => _liftedWallet = null),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.canvasCardSurface,
                                      border: Border.all(color: AppColors.canvasBorder, width: 1),
                                    ),
                                    child: const Icon(Icons.close, color: AppColors.textWhite, size: 16),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // ── Element 1: Standalone Floating ATM Card ──
                            AspectRatio(
                              aspectRatio: 85.60 / 53.98,
                              child: _WalletCard(
                                wallet: activeSelected,
                                index: wallets.indexWhere((w) => w.id == activeSelected.id),
                                fmt: currencyFormatter,
                                cardH: 200,
                                isLifted: true,
                                showBottomLayout: true,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // ── Element 2: Bawahnya (Separate Container for Actions, Chart, History) ──
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.canvasCardSurface,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: AppColors.canvasBorder, width: 1.2),
                                ),
                                child: ListView(
                                  shrinkWrap: true,
                                  padding: EdgeInsets.zero,
                                  children: [
                                    // Action Buttons Row
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.neoMint,
                                              foregroundColor: AppColors.textDarkPrimary,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                              padding: const EdgeInsets.symmetric(vertical: 11),
                                              elevation: 0,
                                            ),
                                            icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.textDarkPrimary),
                                            label: Text(
                                              'Ubah Saldo',
                                              style: AppTypography.listTitle.copyWith(
                                                color: AppColors.textDarkPrimary,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                            ),
                                            onPressed: () {
                                              final w = activeSelected;
                                              setState(() => _liftedWallet = null);
                                              _showEditBalanceModal(context, w);
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: AppColors.textWhite,
                                              side: const BorderSide(color: AppColors.canvasBorder, width: 1),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                              padding: const EdgeInsets.symmetric(vertical: 11),
                                            ),
                                            icon: const Icon(Icons.add_rounded, size: 16, color: AppColors.neoChartreuse),
                                            label: Text(
                                              'Catat Transaksi',
                                              style: AppTypography.listTitle.copyWith(
                                                color: AppColors.textWhite,
                                                fontSize: 13,
                                              ),
                                            ),
                                            onPressed: () {
                                              setState(() => _liftedWallet = null);
                                              TransactionModal.show(context, widget.db);
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 14),

                                    // 30-Day Trend Chart
                                    TrendSplineChart(
                                      incomeValues: _computeSeries(state.transactions, type: 'income', walletId: activeSelected.id),
                                      expenseValues: _computeSeries(state.transactions, type: 'expense', walletId: activeSelected.id),
                                      labels: _computeDayLabels(),
                                      headline: 'Tren Mutasi ${activeSelected.name}',
                                      subtitle: '30 Hari Terakhir',
                                      height: 95,
                                    ),
                                    const SizedBox(height: 14),

                                    // Riwayat Transaksi Header & List
                                    Builder(builder: (context) {
                                      final walletTx = state.transactions
                                          .where((tx) => tx.walletId == activeSelected.id || tx.destinationWalletId == activeSelected.id)
                                          .toList();

                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  'Riwayat Transaksi',
                                                  style: AppTypography.sectionTitle.copyWith(fontSize: 14),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Text('${walletTx.length} transaksi', style: AppTypography.listSubtitle),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          if (walletTx.isEmpty)
                                            Container(
                                              padding: const EdgeInsets.all(14),
                                              decoration: BoxDecoration(
                                                color: AppColors.canvasInputSearch,
                                                borderRadius: BorderRadius.circular(14),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  'Belum ada transaksi di rekening ini.',
                                                  style: AppTypography.listSubtitle,
                                                ),
                                              ),
                                            )
                                          else
                                            for (final tx in walletTx.take(5)) ...[
                                              GestureDetector(
                                                behavior: HitTestBehavior.opaque,
                                                onTap: () => TransactionDetailModal.show(context, db: widget.db, transaction: tx),
                                                child: Container(
                                                  margin: const EdgeInsets.only(bottom: 6),
                                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.canvasInputSearch,
                                                    borderRadius: BorderRadius.circular(12),
                                                    border: Border.all(color: AppColors.canvasBorder, width: 0.6),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        width: 32,
                                                        height: 32,
                                                        decoration: BoxDecoration(
                                                          shape: BoxShape.circle,
                                                          color: (tx.type == 'income'
                                                                   ? AppColors.neoMint
                                                                   : (tx.type == 'transfer' ? AppColors.neoCyan : AppColors.neoCoral))
                                                              .withValues(alpha: 0.15),
                                                        ),
                                                        child: Icon(
                                                          tx.type == 'income'
                                                              ? Icons.arrow_downward
                                                              : (tx.type == 'transfer' ? Icons.swap_horiz : Icons.arrow_upward),
                                                          color: tx.type == 'income'
                                                              ? AppColors.neoMint
                                                              : (tx.type == 'transfer' ? AppColors.neoCyan : AppColors.neoCoral),
                                                          size: 16,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 10),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              tx.notes ??
                                                                  (tx.type == 'transfer'
                                                                      ? 'Transfer Saldo'
                                                                      : (tx.type == 'income' ? 'Pemasukan' : 'Pengeluaran')),
                                                              style: AppTypography.listTitle.copyWith(fontSize: 13),
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                            const SizedBox(height: 2),
                                                            Text(
                                                              DateFormat('d MMM, HH:mm', 'id_ID').format(tx.transactionDate.toLocal()),
                                                              style: AppTypography.listSubtitle.copyWith(fontSize: 10),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(width: 6),
                                                      Text(
                                                        '${tx.type == 'expense' ? '-' : (tx.type == 'income' ? '+' : '')}${currencyFormatter.format(tx.amount)}',
                                                        style: AppTypography.listAmount.copyWith(
                                                          fontSize: 13,
                                                          color: tx.type == 'income'
                                                              ? AppColors.neoMint
                                                              : (tx.type == 'transfer' ? AppColors.neoCyan : AppColors.textWhite),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                        ],
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
  void _showEditBalanceModal(BuildContext context, WalletEntry wallet) {
    final controller = TextEditingController(text: wallet.balance.toStringAsFixed(0));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.canvasCardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + MediaQuery.of(context).viewInsets.bottom),
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
              Text('Penyesuaian Saldo: ${wallet.name}', style: AppTypography.sectionTitle),
              const SizedBox(height: 6),
              Text('Ubah saldo awal rekening sesuai saldo riil saat ini di m-banking.', style: AppTypography.listSubtitle),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                autofocus: false,
                style: AppTypography.heroGreeting.copyWith(color: AppColors.textWhite),
                decoration: InputDecoration(
                  prefixText: 'Rp ',
                  prefixStyle: AppTypography.heroGreeting.copyWith(color: AppColors.neoMint),
                  filled: true,
                  fillColor: AppColors.canvasInputSearch,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neoMint,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    'Perbarui Saldo',
                    style: AppTypography.listTitle.copyWith(color: AppColors.textDarkPrimary, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    final raw = controller.text.replaceAll(RegExp(r'[^\d]'), '');
                    final newBal = double.tryParse(raw);
                    if (newBal != null) {
                      context.read<FinanceBloc>().add(
                        UpdateWalletBalanceEvent(walletId: wallet.id, newBalance: newBal),
                      );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.neoMint,
                          content: Text(
                            'Saldo ${wallet.name} diubah menjadi Rp ${newBal.toStringAsFixed(0)}',
                            style: const TextStyle(color: AppColors.textDarkPrimary, fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static void showAddWalletModal(BuildContext context) {
    final nameController = TextEditingController();
    final balanceController = TextEditingController();
    String type = 'bank';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.canvasCardSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + MediaQuery.of(context).viewInsets.bottom),
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
                  Text('Tambah Dompet / Rekening Baru', style: AppTypography.sectionTitle),
                  const SizedBox(height: 14),
                  TextField(
                    controller: nameController,
                    style: AppTypography.listTitle,
                    decoration: InputDecoration(
                      hintText: 'Nama Rekening (cth: Kas Tunai, Bank Jago Saving)',
                      hintStyle: AppTypography.listSubtitle,
                      filled: true,
                      fillColor: AppColors.canvasInputSearch,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: balanceController,
                    keyboardType: TextInputType.number,
                    style: AppTypography.listTitle,
                    decoration: InputDecoration(
                      hintText: 'Saldo Awal (Rp)',
                      hintStyle: AppTypography.listSubtitle,
                      prefixText: 'Rp ',
                      filled: true,
                      fillColor: AppColors.canvasInputSearch,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildTypePill(label: 'Bank', isSelected: type == 'bank', onTap: () => setModalState(() => type = 'bank')),
                      const SizedBox(width: 8),
                      _buildTypePill(label: 'E-Wallet', isSelected: type == 'ewallet', onTap: () => setModalState(() => type = 'ewallet')),
                      const SizedBox(width: 8),
                      _buildTypePill(label: 'Kas Tunai', isSelected: type == 'cash', onTap: () => setModalState(() => type = 'cash')),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.neoMint,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        'Simpan Rekening',
                        style: AppTypography.listTitle.copyWith(color: AppColors.textDarkPrimary, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        final name = nameController.text.trim();
                        final raw = balanceController.text.replaceAll(RegExp(r'[^\d]'), '');
                        final bal = double.tryParse(raw) ?? 0.0;

                        if (name.isNotEmpty) {
                          context.read<FinanceBloc>().add(
                            AddWalletEvent(
                              name: name,
                              type: type,
                              initialBalance: bal,
                              colorHex: '#10B981',
                              iconName: 'wallet',
                            ),
                          );
                          Navigator.pop(modalContext);
                        }
                      },
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

  static Widget _buildTypePill({required String label, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.neoMint : AppColors.canvasInputSearch,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: AppTypography.badgeLabel.copyWith(
            color: isSelected ? AppColors.textDarkPrimary : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}
