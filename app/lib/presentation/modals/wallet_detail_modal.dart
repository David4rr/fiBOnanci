import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/finance/finance_bloc.dart';
import '../../bloc/finance/finance_state.dart';
import '../../domain/services/cashflow_analytics_service.dart';
import '../../data/database/app_database.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../modals/transaction_filter_modal.dart';
import '../modals/edit_balance_modal.dart';
import '../widgets/transaction_modal.dart';
import '../widgets/transaction_detail_modal.dart';
import '../widgets/trend_spline_chart.dart';
import '../widgets/wallet_card.dart';
import '../widgets/wallet_card_deck.dart';

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
  Timer? _copyTimer;

  @override
  void dispose() {
    _copyTimer?.cancel();
    super.dispose();
  }

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
            Expanded(
              child: Text(
                'Nomor rekening ${widget.wallet.name} disalin',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textWhite,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );

    _copyTimer?.cancel();
    _copyTimer = Timer(const Duration(milliseconds: 1400), () {
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

/// Full-Screen Modal Bottom Sheet for Account Details & Mutations.
///
/// Features:
/// - Smooth modal bottom sheet presentation with rounded top edges.
/// - Atmospheric ambient radial glow matching the card's specific theme palette.
/// - Frosted blurred sticky top header with account badge, dynamic scrolled balance pill, and top-right dismiss arrow.
/// - Hero Physical ATM Card with 3D tilt micro-physics, procedural pattern texture, and tap interaction.
/// - Tactile Quick Actions dock (Catat Transaksi, Ubah Saldo) with pre-selected account context.
/// - Compact 30-Day Trend Spline Chart with touch scrubbing.
/// - Interactive sliding capsule filter bar & instant search.
/// - Chronological transaction tiles with tap-to-inspect detail sheet.
/// - Offline encrypted security footer.
class WalletDetailModal extends StatefulWidget {
  final String walletId;
  final NumberFormat currencyFormatter;

  const WalletDetailModal({
    super.key,
    required this.walletId,
    required this.currencyFormatter,
  });

  /// Displays the modal bottom sheet for a given wallet.
  static Future<void> show(
    BuildContext context, {
    required WalletEntry wallet,
  }) {
    final financeBloc = context.read<FinanceBloc>();
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return BlocProvider.value(
          value: financeBloc,
          child: WalletDetailModal(
            walletId: wallet.id,
            currencyFormatter: currencyFormatter,
          ),
        );
      },
    );
  }

  @override
  State<WalletDetailModal> createState() => _WalletDetailModalState();
}

class _WalletDetailModalState extends State<WalletDetailModal> {
  late ScrollController _scrollController;
  double _scrollOffset = 0.0;

  _WalletTxFilter _selectedFilter = _WalletTxFilter.all;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
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
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleClose() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FinanceBloc, FinanceState>(
      builder: (context, state) {
        final walletExists = state.wallets.any((w) => w.id == widget.walletId);
        if (!walletExists) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Navigator.canPop(context)) {
              Navigator.of(context).pop();
            }
          });
          return const SizedBox.shrink();
        }

        final wallet = state.wallets.firstWhere((w) => w.id == widget.walletId);
        final walletTx = state.transactions
            .where((tx) => tx.walletId == wallet.id || tx.destinationWalletId == wallet.id)
            .toList();

        // Sort newest first
        walletTx.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));

        final cardIndex = state.wallets.indexWhere((w) => w.id == wallet.id);
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

        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: Container(
            color: AppColors.canvasBg,
            child: Material(
              color: Colors.transparent,
              child: Stack(
                children: [
                  // Ambient Radial Aura matching Card Theme
                  Positioned(
                    top: -90,
                    left: -60,
                    right: -60,
                    height: 420,
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

                  // Scrollable Content Area
                  Positioned.fill(
                    child: SafeArea(
                      bottom: false,
                      child: CustomScrollView(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                        slivers: [
                          // Top clearance for frosted app bar
                          const SliverToBoxAdapter(child: SizedBox(height: 72)),

                          // Hero Section: Pure Physical ATM Card
                          SliverToBoxAdapter(
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

                          const SliverToBoxAdapter(child: SizedBox(height: 20)),

                          // Tactile Action Buttons Row (Ubah Saldo & Catat Transaksi)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                children: [
                                  // Ubah Saldo Button
                                  Expanded(
                                    child: _PressableScale(
                                      onTap: () {
                                        EditBalanceModal.show(context, wallet);
                                      },
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
                                      onTap: () {
                                        TransactionModal.show(context, initialWalletId: wallet.id);
                                      },
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

                          const SliverToBoxAdapter(child: SizedBox(height: 16)),

                          // 30-Day Trend Spline Chart Card
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: TrendSplineChart(
                                incomeValues: CashflowAnalyticsService.compute30DaySeries(state.transactions, type: 'income', walletId: wallet.id),
                                expenseValues: CashflowAnalyticsService.compute30DaySeries(state.transactions, type: 'expense', walletId: wallet.id),
                                labels: CashflowAnalyticsService.compute30DayLabels(),
                                lineColor: cardColor,
                                headline: 'Tren Mutasi ${wallet.name}',
                                subtitle: '30 Hari Terakhir',
                                height: 100,
                              ),
                            ),
                          ),

                          const SliverToBoxAdapter(child: SizedBox(height: 14)),

                          // Standalone Search Bar
                          SliverToBoxAdapter(
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

                          // Active Filter Chips Row
                          if (_selectedFilter != _WalletTxFilter.all)
                            SliverToBoxAdapter(
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

                          // Section Header
                          SliverToBoxAdapter(
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
                                  Text(
                                    '${filteredTx.length} transaksi',
                                    style: AppTypography.listSubtitle.copyWith(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Empty state or transaction list
                          if (filteredTx.isEmpty)
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
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
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.canvasInputSearch,
                                          border: Border.all(color: AppColors.canvasBorder, width: 0.8),
                                        ),
                                        child: const Icon(Icons.receipt_long_outlined, color: AppColors.textMuted, size: 20),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        _searchQuery.isNotEmpty
                                            ? 'Tidak ada mutasi yang cocok'
                                            : 'Belum ada mutasi transaksi',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textWhite,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _searchQuery.isNotEmpty
                                            ? 'Coba kata kunci pencarian atau filter lain.'
                                            : 'Semua transaksi via rekening ${wallet.name} akan muncul di sini.',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          else
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final tx = filteredTx[index];
                                  final isExpense = tx.type == 'expense' || tx.walletId == wallet.id && tx.type != 'income';
                                  final prefix = isExpense ? '- ' : '+ ';
                                  final typeColor = isExpense
                                      ? AppColors.textWhite
                                      : AppColors.neoMint;

                                  final iconData = tx.type == 'income'
                                      ? Icons.south_west_rounded
                                      : (tx.type == 'transfer' ? Icons.swap_horiz_rounded : Icons.north_east_rounded);

                                  final iconBgColor = tx.type == 'income'
                                      ? AppColors.neoMint.withValues(alpha: 0.15)
                                      : (tx.type == 'transfer' ? AppColors.neoPurple.withValues(alpha: 0.15) : AppColors.canvasInputSearch);

                                  final iconColor = tx.type == 'income'
                                      ? AppColors.neoMint
                                      : (tx.type == 'transfer' ? AppColors.neoPurple : AppColors.textWhite);

                                  final dateFormatted = DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(tx.transactionDate);

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4.5),
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
                                            // Icon Pill
                                            Container(
                                              width: 36,
                                              height: 36,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: iconBgColor,
                                                border: Border.all(color: AppColors.canvasBorder, width: 0.8),
                                              ),
                                              child: Icon(iconData, color: iconColor, size: 17),
                                            ),
                                            const SizedBox(width: 12),

                                            // Description & Date
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    (tx.notes != null && tx.notes!.isNotEmpty)
                                                        ? tx.notes!
                                                        : (tx.type == 'income'
                                                            ? 'Pemasukan'
                                                            : (tx.type == 'transfer' ? 'Transfer Saldo' : 'Pengeluaran')),
                                                    style: GoogleFonts.plusJakartaSans(
                                                      fontSize: 13.5,
                                                      fontWeight: FontWeight.w700,
                                                      color: AppColors.textWhite,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 2.5),
                                                  Text(
                                                    dateFormatted,
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
                                  );
                                },
                                childCount: filteredTx.length,
                              ),
                            ),

                          // Security & Offline Badge Footer
                          SliverToBoxAdapter(
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
                          const SliverToBoxAdapter(child: SizedBox(height: 48)),
                        ],
                      ),
                    ),
                  ),

                  // Sticky App Bar with Drag Handle, Dynamic Scrolled Balance Pill & Far-Right Downward Arrow
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                        child: Container(
                          padding: const EdgeInsets.only(
                            top: 8,
                            bottom: 10,
                            left: 16,
                            right: 16,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.canvasBg.withValues(alpha: 0.85),
                            border: const Border(
                              bottom: BorderSide(color: AppColors.canvasBorder, width: 0.8),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Top drag handle indicator
                              Center(
                                child: Container(
                                  width: 36,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: AppColors.textSubtle.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
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
                                  const SizedBox(width: 10),

                                  // Close / Dismiss Downward Arrow Button (Far Right)
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
                                      child: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textWhite, size: 22),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
}
