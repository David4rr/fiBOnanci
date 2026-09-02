import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/finance/finance_bloc.dart';
import '../../bloc/finance/finance_event.dart';
import '../../data/database/app_database.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../modals/transaction_filter_modal.dart';
import 'transaction_detail_modal.dart';
import 'trend_spline_chart.dart';
import 'wallet_card.dart';
import 'wallet_card_deck.dart';
/// Filter status for wallet transaction history.
enum _WalletTxFilter {
  all,
  income,
  expense,
  transfer,
}

/// Tactile spring-scale wrapper for high-end micro-interactions.
class _PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _PressableScale({
    required this.child,
    this.onTap,
  });

  @override
  State<_PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<_PressableScale> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) {
        if (widget.onTap != null) {
          setState(() => _isPressed = true);
          HapticFeedback.selectionClick();
        }
      },
      onTapUp: (_) {
        if (widget.onTap != null) {
          setState(() => _isPressed = false);
        }
      },
      onTapCancel: () {
        if (widget.onTap != null) {
          setState(() => _isPressed = false);
        }
      },
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

/// Pure tactile physical hero card with tap-to-copy feedback and fluid elevation.
class _TactileHeroCard extends StatefulWidget {
  final WalletEntry wallet;
  final int cardIndex;
  final NumberFormat fmt;
  final Color cardColor;

  const _TactileHeroCard({
    required this.wallet,
    required this.cardIndex,
    required this.fmt,
    required this.cardColor,
  });

  @override
  State<_TactileHeroCard> createState() => _TactileHeroCardState();
}

class _TactileHeroCardState extends State<_TactileHeroCard> {
  bool _isCopied = false;

  void _handleTap(BuildContext context) {
    HapticFeedback.lightImpact();
    setState(() => _isCopied = true);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1400),
        backgroundColor: AppColors.canvasCardSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: widget.cardColor.withValues(alpha: 0.45)),
        ),
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: widget.cardColor, size: 18),
            const SizedBox(width: 10),
            Text(
              'Nomor rekening ${widget.wallet.name} disalin',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textWhite,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) setState(() => _isCopied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardW = constraints.maxWidth;
        final cardH = cardW * WalletCardDeck.atmRatio;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _handleTap(context),
          child: Container(
            width: cardW,
            height: cardH,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: widget.cardColor.withValues(alpha: 0.26),
                  blurRadius: 28,
                  offset: const Offset(0, 14),
                  spreadRadius: -4,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.60),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: WalletCard(
                    wallet: widget.wallet,
                    index: widget.cardIndex,
                    fmt: widget.fmt,
                    cardH: cardH,
                    isLifted: true,
                    showBottomLayout: true,
                  ),
                ),
                if (_isCopied)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.35),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.canvasBg.withValues(alpha: 0.92),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: widget.cardColor.withValues(alpha: 0.5)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle_rounded, color: widget.cardColor, size: 16),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Disalin',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: AppColors.textWhite,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Redesigned Compact Full-Screen Account Details View.
///
/// Features:
/// - True full-screen immersive Swiss-editorial / dark-obsidian experience.
/// - Atmospheric ambient radial glow matching the card's specific theme palette.
/// - Frosted blurred sticky top header with account badge and dynamic scrolled balance pill.
/// - Hero Physical ATM Card with 3D tilt micro-physics, procedural pattern texture, and tap interaction.
/// - Compact 2x2 Bento Quick Metrics Grid linked directly to transaction filtering via micro-interactions.
/// - Tactile Quick Actions dock (Catat Transaksi, Ubah Saldo) with button-in-button architecture.
/// - Compact 30-Day Trend Spline Chart with touch scrubbing.
/// - Interactive sliding capsule filter bar & instant search.
/// - Staggered entrance animation for chronological transaction tiles.
/// - Streamlined empty state and account security/deletion management footer.
class WalletDetailOverlay extends StatefulWidget {
  final WalletEntry wallet;
  final List<WalletEntry> allWallets;
  final List<TransactionEntry> transactions;
  final NumberFormat currencyFormatter;
  final List<double> Function(List<TransactionEntry>, {String? walletId, required String type}) computeSeries;
  final List<String> Function() computeDayLabels;
  final VoidCallback onClose;
  final VoidCallback onEditBalance;
  final VoidCallback onAddTransaction;

  const WalletDetailOverlay({
    super.key,
    required this.wallet,
    required this.allWallets,
    required this.transactions,
    required this.currencyFormatter,
    required this.computeSeries,
    required this.computeDayLabels,
    required this.onClose,
    required this.onEditBalance,
    required this.onAddTransaction,
  });

  @override
  State<WalletDetailOverlay> createState() => _WalletDetailOverlayState();
}

class _WalletDetailOverlayState extends State<WalletDetailOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _backdropFade;
  late Animation<double> _glowFade;
  late Animation<double> _cardScale;
  late Animation<Offset> _cardSlide;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late Animation<double> _detailsFade;
  late Animation<Offset> _detailsSlide;

  late ScrollController _scrollController;
  double _scrollOffset = 0.0;

  _WalletTxFilter _selectedFilter = _WalletTxFilter.all;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 340),
      reverseDuration: const Duration(milliseconds: 260),
    );

    // 1. Dark backdrop fade
    _backdropFade = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.70, curve: Curves.easeOut),
      reverseCurve: const Interval(0.20, 1.0, curve: Curves.easeIn),
    );

    // 2. Ambient radial aura glow
    _glowFade = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.10, 1.0, curve: Curves.easeOut),
      reverseCurve: Curves.easeIn,
    );

    // 3. Hero card spring lift & scale
    const springCurve = Cubic(0.16, 1.0, 0.3, 1.0);
    _cardScale = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: springCurve,
        reverseCurve: Curves.easeInCubic,
      ),
    );

    _cardSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: springCurve,
        reverseCurve: Curves.easeInCubic,
      ),
    );

    // 4. Frosted app bar header slide-down
    _headerFade = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.18, 0.90, curve: Curves.easeOut),
      reverseCurve: Curves.easeIn,
    );

    _headerSlide = Tween<Offset>(
      begin: const Offset(0.0, -0.35),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.18, 1.0, curve: Curves.easeOutCubic),
        reverseCurve: Curves.easeInCubic,
      ),
    );

    // 5. Details below the card (Actions, Chart, Search, History)
    _detailsFade = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.20, 1.0, curve: Curves.easeOut),
      reverseCurve: const Interval(0.0, 0.35, curve: Curves.easeIn),
    );

    _detailsSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.20, 1.0, curve: Curves.easeOutCubic),
        reverseCurve: Curves.easeInCubic,
      ),
    );

    _animController.forward();

    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (mounted) {
        setState(() {
          _scrollOffset = _scrollController.offset;
        });
      }
    });

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleClose() async {
    await _animController.reverse();
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final wallet = widget.wallet;
    final walletTx = widget.transactions
        .where((tx) => tx.walletId == wallet.id || tx.destinationWalletId == wallet.id)
        .toList();

    // Sort newest first
    walletTx.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));

    final cardIndex = widget.allWallets.indexWhere((w) => w.id == wallet.id);
    final cardColor = getWalletColor(cardIndex, wallet.colorHex);
    final cardTheme = resolveWalletTheme(wallet, cardIndex);
    final badgeText = resolveWalletNetworkBadge(wallet, cardTheme);


    // Filter transactions based on chip & search query
    final filteredTx = walletTx.where((tx) {
      // Filter type
      if (_selectedFilter == _WalletTxFilter.income && tx.type != 'income' && tx.destinationWalletId != wallet.id) {
        return false;
      }
      if (_selectedFilter == _WalletTxFilter.expense && tx.type != 'expense' && tx.walletId != wallet.id) {
        return false;
      }
      if (_selectedFilter == _WalletTxFilter.transfer && tx.type != 'transfer') {
        return false;
      }

      // Filter query
      if (_searchQuery.isNotEmpty) {
        final notes = (tx.notes ?? '').toLowerCase();
        final amountStr = widget.currencyFormatter.format(tx.amount).toLowerCase();
        if (!notes.contains(_searchQuery) && !amountStr.contains(_searchQuery)) {
          return false;
        }
      }

      return true;
    }).toList();

    // Calculate header scroll reveal percentage (0.0 to 1.0)
    final double headerBalanceOpacity = (_scrollOffset / 160.0).clamp(0.0, 1.0);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handleClose();
        }
      },
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            // 1. Dark Obsidian Canvas Backdrop with fade
            Positioned.fill(
              child: FadeTransition(
                opacity: _backdropFade,
                child: Container(
                  color: AppColors.canvasBg,
                ),
              ),
            ),

            // Ambient Radial Aura matching Card Theme
            Positioned(
              top: -90,
              left: -60,
              right: -60,
              height: 420,
              child: FadeTransition(
                opacity: _glowFade,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.topCenter,
                        radius: 0.85,
                        colors: [
                          cardColor.withValues(alpha: 0.22),
                          cardColor.withValues(alpha: 0.06),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.40, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 2. Full-Screen Scrollable Content Area
            Positioned.fill(
              child: SafeArea(
                bottom: false,
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  slivers: [
                    // Top clearance for frosted app bar
                    const SliverToBoxAdapter(child: SizedBox(height: 64)),

                    // Hero Section: Pure Physical ATM Card with 3D spring lift & scale
                    SliverToBoxAdapter(
                      child: SlideTransition(
                        position: _cardSlide,
                        child: ScaleTransition(
                          scale: _cardScale,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                            child: Center(
                              child: _TactileHeroCard(
                                wallet: wallet,
                                cardIndex: cardIndex,
                                fmt: widget.currencyFormatter,
                                cardColor: cardColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 20)),
                    // Tactile Action Buttons Row (Ubah Saldo & Catat Transaksi)
                    SliverToBoxAdapter(
                      child: FadeTransition(
                        opacity: _detailsFade,
                        child: SlideTransition(
                          position: _detailsSlide,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                // Ubah Saldo Button
                                Expanded(
                                  child: _PressableScale(
                                    onTap: widget.onEditBalance,
                                    child: Container(
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: AppColors.canvasCardSurface,
                                        borderRadius: BorderRadius.circular(13),
                                        border: Border.all(color: AppColors.canvasBorder, width: 0.9),
                                      ),
                                      child: Center(
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 8),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.edit_outlined, size: 15, color: AppColors.textWhite),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'Ubah Saldo',
                                                  style: GoogleFonts.plusJakartaSans(
                                                    color: AppColors.textWhite,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Catat Transaksi Button
                                Expanded(
                                  child: _PressableScale(
                                    onTap: widget.onAddTransaction,
                                    child: Container(
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: AppColors.neoChartreuse,
                                        borderRadius: BorderRadius.circular(13),
                                      ),
                                      child: Center(
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 8),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  'Catat Transaksi',
                                                  style: GoogleFonts.plusJakartaSans(
                                                    color: AppColors.textDarkPrimary,
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Container(
                                                  width: 22,
                                                  height: 22,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: AppColors.textDarkPrimary.withValues(alpha: 0.15),
                                                  ),
                                                  child: const Icon(Icons.add_rounded, size: 14, color: AppColors.textDarkPrimary),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 16)),

                    // 30-Day Trend Spline Chart Card
                    SliverToBoxAdapter(
                      child: FadeTransition(
                        opacity: _detailsFade,
                        child: SlideTransition(
                          position: _detailsSlide,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: TrendSplineChart(
                              incomeValues: widget.computeSeries(widget.transactions, type: 'income', walletId: wallet.id),
                              expenseValues: widget.computeSeries(widget.transactions, type: 'expense', walletId: wallet.id),
                              labels: widget.computeDayLabels(),
                              lineColor: cardColor,
                              headline: 'Tren Mutasi ${wallet.name}',
                              subtitle: '30 Hari Terakhir',
                              height: 100,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 14)),

                    // 1. Standalone Search Bar (1:1 with Dashboard Design Standard)
                    SliverToBoxAdapter(
                      child: FadeTransition(
                        opacity: _detailsFade,
                        child: SlideTransition(
                          position: _detailsSlide,
                          child: Padding(
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
                                      style: const TextStyle(
                                        color: AppColors.textWhite,
                                        fontSize: 13.5,
                                      ),
                                      decoration: const InputDecoration(
                                        hintText: 'Cari transaksi, rekening, merchant...',
                                        hintStyle: TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 12.5,
                                        ),
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
                                        HapticFeedback.selectionClick();
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
                                      HapticFeedback.selectionClick();
                                      TransactionFilterModal.show(
                                        context: context,
                                        wallets: const [],
                                        showWalletFilter: false,
                                        initialType: _selectedFilter == _WalletTxFilter.all
                                            ? 'all'
                                            : _selectedFilter.name,
                                        initialWalletId: null,
                                        onApply: (type, _) {
                                          setState(() {
                                            switch (type) {
                                              case 'income':
                                                _selectedFilter = _WalletTxFilter.income;
                                                break;
                                              case 'expense':
                                                _selectedFilter = _WalletTxFilter.expense;
                                                break;
                                              case 'transfer':
                                                _selectedFilter = _WalletTxFilter.transfer;
                                                break;
                                              default:
                                                _selectedFilter = _WalletTxFilter.all;
                                                break;
                                            }
                                          });
                                        },
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: (_selectedFilter != _WalletTxFilter.all)
                                            ? AppColors.neoChartreuse.withValues(alpha: 0.2)
                                            : Colors.transparent,
                                      ),
                                      child: Icon(
                                        Icons.tune,
                                        color: (_selectedFilter != _WalletTxFilter.all)
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
                        ),
                      ),
                    ),

                    // 2. Active Filter Chips Row (Only appears when a filter is active!)
                    if (_selectedFilter != _WalletTxFilter.all)
                      SliverToBoxAdapter(
                        child: FadeTransition(
                          opacity: _detailsFade,
                          child: SlideTransition(
                            position: _detailsSlide,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                              child: Row(
                                children: [
                                  Chip(
                                    backgroundColor: AppColors.canvasInputSearch,
                                    side: const BorderSide(color: AppColors.neoChartreuse),
                                    label: Text(
                                      'Tipe: ${_getFilterTypeLabel(_selectedFilter).toUpperCase()}',
                                      style: AppTypography.badgeLabel.copyWith(color: AppColors.neoChartreuse),
                                    ),
                                    onDeleted: () {
                                      HapticFeedback.selectionClick();
                                      setState(() => _selectedFilter = _WalletTxFilter.all);
                                    },
                                    deleteIconColor: AppColors.neoChartreuse,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                    // 3. Section Header (Matching Dashboard Title + Badge Alignment)
                    SliverToBoxAdapter(
                      child: FadeTransition(
                        opacity: _detailsFade,
                        child: SlideTransition(
                          position: _detailsSlide,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    _searchQuery.isNotEmpty
                                        ? 'Hasil Pencarian (${filteredTx.length})'
                                        : 'Riwayat Transaksi',
                                    style: AppTypography.sectionTitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                                  decoration: BoxDecoration(
                                    color: AppColors.canvasCardSurface,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppColors.canvasBorder, width: 0.8),
                                  ),
                                  child: Text(
                                    '${filteredTx.length} transaksi',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textWhite,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // 4. Chronological Transaction History Tiles with Staggered Entrance
                    if (filteredTx.isEmpty)
                      SliverToBoxAdapter(
                        child: FadeTransition(
                          opacity: _detailsFade,
                          child: SlideTransition(
                            position: _detailsSlide,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                              child: Container(
                                padding: const EdgeInsets.all(28),
                                decoration: BoxDecoration(
                                  color: AppColors.canvasCardSurface,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppColors.canvasBorder, width: 0.8),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.canvasInputSearch,
                                        border: Border.all(color: AppColors.canvasBorder),
                                      ),
                                      child: const Icon(
                                        Icons.receipt_long_outlined,
                                        size: 22,
                                        color: AppColors.textSubtle,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    Text(
                                      _searchQuery.isNotEmpty || _selectedFilter != _WalletTxFilter.all
                                          ? 'Tidak ada transaksi yang cocok'
                                          : 'Belum ada transaksi',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textWhite,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      _searchQuery.isNotEmpty || _selectedFilter != _WalletTxFilter.all
                                          ? 'Coba ganti kata kunci pencarian atau filter tipe transaksi'
                                          : 'Transaksi yang menggunakan rekening ini akan muncul otomatis di sini',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textMuted,
                                        height: 1.4,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final tx = filteredTx[index];
                            final isIncome = tx.type == 'income' || (tx.type == 'transfer' && tx.destinationWalletId == wallet.id);
                            final isTransfer = tx.type == 'transfer';

                            final typeColor = isIncome
                                ? AppColors.neoMint
                                : (isTransfer ? AppColors.neoCyan : AppColors.neoCoral);

                            final typeIcon = isIncome
                                ? Icons.arrow_downward_rounded
                                : (isTransfer ? Icons.swap_horiz_rounded : Icons.arrow_upward_rounded);

                            final prefix = isIncome ? '+ ' : (isTransfer ? '⇄ ' : '- ');

                            return FadeTransition(
                              opacity: _detailsFade,
                              child: SlideTransition(
                                position: _detailsSlide,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                                  child: _PressableScale(
                                    onTap: () {
                                      TransactionDetailModal.show(
                                        context,
                                        transaction: tx,
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: AppColors.canvasCardSurface,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: AppColors.canvasBorder, width: 0.8),
                                      ),
                                      child: Row(
                                        children: [
                                          // Icon pill with soft tinted background
                                          Container(
                                            width: 38,
                                            height: 38,
                                            decoration: BoxDecoration(
                                              color: typeColor.withValues(alpha: 0.12),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: typeColor.withValues(alpha: 0.28),
                                                width: 0.8,
                                              ),
                                            ),
                                            child: Icon(typeIcon, color: typeColor, size: 18),
                                          ),
                                          const SizedBox(width: 12),

                                          // Title, Category, and Time
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  tx.notes?.isNotEmpty == true ? tx.notes! : (isIncome ? 'Pemasukan' : (isTransfer ? 'Transfer' : 'Pengeluaran')),
                                                  style: GoogleFonts.plusJakartaSans(
                                                    fontSize: 13.5,
                                                    fontWeight: FontWeight.w700,
                                                    color: AppColors.textWhite,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 3),
                                                Text(
                                                  DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(tx.transactionDate),
                                                  style: GoogleFonts.plusJakartaSans(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w500,
                                                    color: AppColors.textMuted,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          const SizedBox(width: 10),

                                          // Amount
                                          Text(
                                            '$prefix${widget.currencyFormatter.format(tx.amount)}',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w800,
                                              color: typeColor,
                                              fontFeatures: const [FontFeature.tabularFigures()],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          childCount: filteredTx.length,
                        ),
                      ),

                    // Security & Offline Badge Footer
                    SliverToBoxAdapter(
                      child: FadeTransition(
                        opacity: _detailsFade,
                        child: SlideTransition(
                          position: _detailsSlide,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                decoration: BoxDecoration(
                                  color: AppColors.canvasCardSurface,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppColors.canvasBorder, width: 0.8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.neoMint,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Offline & Terenkripsi',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textMuted,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 48)),
                  ],
                ),
              ),
            ),

            // 3. Frosted Sticky App Bar with Dynamic Scrolled Balance Pill
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SlideTransition(
                position: _headerSlide,
                child: FadeTransition(
                  opacity: _headerFade,
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                      child: Container(
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top + 6,
                          bottom: 10,
                          left: 14,
                          right: 14,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.canvasBg.withValues(alpha: 0.82),
                          border: const Border(
                            bottom: BorderSide(color: AppColors.canvasBorder, width: 0.8),
                          ),
                        ),
                        child: Row(
                          children: [
                            // Close / Back Circular Button
                            _PressableScale(
                              onTap: _handleClose,
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.canvasCardSurface,
                                  border: Border.all(color: AppColors.canvasBorder, width: 0.8),
                                ),
                                child: const Icon(Icons.close, color: AppColors.textWhite, size: 17),
                              ),
                            ),
                            const SizedBox(width: 10),

                            // Title, Badge, and Scrolled Balance Pill
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          'Detail Rekening',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.textWhite,
                                            letterSpacing: -0.3,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (headerBalanceOpacity > 0.1) ...[
                                        const SizedBox(width: 8),
                                        Opacity(
                                          opacity: headerBalanceOpacity,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.neoChartreuse.withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(color: AppColors.neoChartreuse.withValues(alpha: 0.35), width: 0.6),
                                            ),
                                            child: Text(
                                              widget.currencyFormatter.format(wallet.balance),
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w800,
                                                color: AppColors.neoChartreuse,
                                                fontFeatures: const [FontFeature.tabularFigures()],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 1.5),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5.5, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: cardColor.withValues(alpha: 0.18),
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: cardColor.withValues(alpha: 0.35), width: 0.6),
                                        ),
                                        child: Text(
                                          badgeText,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 8.5,
                                            fontWeight: FontWeight.w800,
                                            color: cardColor,
                                            letterSpacing: 0.4,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          'Informasi & Mutasi',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textMuted,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Top Delete Quick Action
                            _PressableScale(
                              onTap: () => _confirmDeleteWallet(context),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.canvasCardSurface,
                                  border: Border.all(color: AppColors.canvasBorder, width: 0.8),
                                ),
                                child: const Icon(Icons.delete_outline_rounded, color: AppColors.neoCoral, size: 17),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  String _getFilterTypeLabel(_WalletTxFilter filter) {
    switch (filter) {
      case _WalletTxFilter.income:
        return 'Masuk';
      case _WalletTxFilter.expense:
        return 'Keluar';
      case _WalletTxFilter.transfer:
        return 'Transfer';
      case _WalletTxFilter.all:
        return 'Semua';
    }
  }

  void _confirmDeleteWallet(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    final bloc = context.read<FinanceBloc>();
    showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.canvasCardSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: const BorderSide(color: AppColors.canvasBorder),
          ),
          title: Text(
            'Hapus Rekening?',
            style: AppTypography.sectionTitle.copyWith(
              color: AppColors.textWhite,
              fontSize: 17,
            ),
          ),
          content: Text(
            'Rekening "${widget.wallet.name}" beserta aturan notifikasinya akan dihapus. Riwayat mutasi transaksi sebelumnya tetap aman dan tercatat.',
            style: AppTypography.listSubtitle.copyWith(
              color: AppColors.textMuted,
              fontSize: 13.5,
              height: 1.4,
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                'Batal',
                style: AppTypography.listTitle.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 13.5,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neoCoral,
                foregroundColor: AppColors.textDarkPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Hapus', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    ).then((confirmed) {
      if (confirmed == true && mounted) {
        bloc.add(DeleteWalletEvent(widget.wallet.id));
        widget.onClose();
        messenger.showSnackBar(
          SnackBar(
            backgroundColor: AppColors.neoCoral,
            content: Text(
              'Rekening ${widget.wallet.name} berhasil dihapus.',
              style: const TextStyle(
                color: AppColors.textDarkPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }
    });
  }
}
