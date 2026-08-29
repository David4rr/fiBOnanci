import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../bloc/finance/finance_bloc.dart';
import '../../bloc/finance/finance_event.dart';
import '../../data/database/app_database.dart';
import '../../domain/services/safe_to_spend_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Real-world filter status for subscriptions.
enum _BillFilterStatus {
  all,
  pending,
  paid,
}

/// Real-world sorting options for subscriptions.
enum _BillSortOrder {
  dueDate,
  highestCost,
}

/// Swiss-minimalist / Retro-editorial Budgeting and Spending Insights Modal.
///
/// Refined with:
/// - 100% real data from active user subscriptions and Safe-to-Spend metrics.
/// - Large, bold Neo-Coral geometric circles motif (165dp height).
/// - Clean bottom controls with real status filter and carousel/grid toggle (VISA removed).
/// - Deep Obsidian dark theme integration (#0C0D11, #17181F, #FF7052).
class BudgetingInsightsModal extends StatefulWidget {
  final List<SubscriptionEntry> subscriptions;
  final List<WalletEntry> wallets;
  final SafeToSpendMetrics? metrics;
  final NumberFormat? currencyFormatter;

  const BudgetingInsightsModal({
    super.key,
    required this.subscriptions,
    this.wallets = const [],
    this.metrics,
    this.currencyFormatter,
  });

  /// Displays the modal as a full-screen bottom sheet matching the Swiss-editorial design reference.
  static void show(
    BuildContext context, {
    required List<SubscriptionEntry> subscriptions,
    List<WalletEntry> wallets = const [],
    SafeToSpendMetrics? metrics,
    NumberFormat? currencyFormatter,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BudgetingInsightsModal(
        subscriptions: subscriptions,
        wallets: wallets,
        metrics: metrics,
        currencyFormatter: currencyFormatter,
      ),
    );
  }

  @override
  State<BudgetingInsightsModal> createState() => _BudgetingInsightsModalState();
}

class _BudgetingInsightsModalState extends State<BudgetingInsightsModal> {
  bool _isGridView = false;
  _BillFilterStatus _filterStatus = _BillFilterStatus.all;
  _BillSortOrder _sortOrder = _BillSortOrder.dueDate;

  IconData _getSubscriptionIcon(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('netflix') ||
        lower.contains('disney') ||
        lower.contains('prime') ||
        lower.contains('tv') ||
        lower.contains('hbo') ||
        lower.contains('youtube')) {
      return Icons.tv_rounded;
    }
    if (lower.contains('spotify') ||
        lower.contains('apple music') ||
        lower.contains('music') ||
        lower.contains('lagu')) {
      return Icons.music_note_rounded;
    }
    if (lower.contains('wifi') ||
        lower.contains('internet') ||
        lower.contains('indihome') ||
        lower.contains('biznet') ||
        lower.contains('first media') ||
        lower.contains('myrepublic')) {
      return Icons.wifi_rounded;
    }
    if (lower.contains('pln') ||
        lower.contains('listrik') ||
        lower.contains('token')) {
      return Icons.bolt_rounded;
    }
    if (lower.contains('pdam') || lower.contains('air')) {
      return Icons.water_drop_rounded;
    }
    if (lower.contains('kost') ||
        lower.contains('kos') ||
        lower.contains('sewa') ||
        lower.contains('kontrakan') ||
        lower.contains('apartemen')) {
      return Icons.home_work_rounded;
    }
    if (lower.contains('icloud') ||
        lower.contains('google one') ||
        lower.contains('storage') ||
        lower.contains('drive')) {
      return Icons.cloud_outlined;
    }
    if (lower.contains('gym') || lower.contains('fitness')) {
      return Icons.fitness_center_rounded;
    }
    if (lower.contains('bpjs') || lower.contains('asuransi')) {
      return Icons.health_and_safety_outlined;
    }
    return Icons.receipt_long_rounded;
  }

  Color _getSubscriptionColor(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('spotify') || lower.contains('music')) {
      return AppColors.neoMint;
    }
    if (lower.contains('wifi') ||
        lower.contains('internet') ||
        lower.contains('cloud')) {
      return AppColors.neoCyan;
    }
    if (lower.contains('pln') || lower.contains('listrik')) {
      return const Color(0xFFFFD166);
    }
    if (lower.contains('kost') || lower.contains('sewa')) {
      return AppColors.neoChartreuse;
    }
    return AppColors.neoCoral;
  }

  List<SubscriptionEntry> _filterAndSortSubscriptions(
    List<SubscriptionEntry> source,
    DateTime now,
  ) {
    var list = source.where((sub) {
      final isPaid = sub.lastPaidDate != null && sub.lastPaidDate!.month == now.month;
      switch (_filterStatus) {
        case _BillFilterStatus.all:
          return true;
        case _BillFilterStatus.pending:
          return !isPaid;
        case _BillFilterStatus.paid:
          return isPaid;
      }
    }).toList();

    list.sort((a, b) {
      if (_sortOrder == _BillSortOrder.highestCost) {
        return b.cost.compareTo(a.cost);
      }
      return a.dueDay.compareTo(b.dueDay);
    });

    return list;
  }

  void _showFilterModal(
    BuildContext context,
    int totalCount,
    int pendingCount,
    int paidCount,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.canvasCardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
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
                  Text('Filter Tagihan', style: AppTypography.heroGreeting),
                  const SizedBox(height: 16),
                  Text(
                    'STATUS PEMBAYARAN',
                    style: AppTypography.badgeLabel.copyWith(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildFilterChoiceChip(
                        label: 'Semua ($totalCount)',
                        selected: _filterStatus == _BillFilterStatus.all,
                        onSelected: () {
                          setState(() => _filterStatus = _BillFilterStatus.all);
                          setSheetState(() {});
                        },
                      ),
                      _buildFilterChoiceChip(
                        label: 'Belum Lunas ($pendingCount)',
                        selected: _filterStatus == _BillFilterStatus.pending,
                        onSelected: () {
                          setState(() => _filterStatus = _BillFilterStatus.pending);
                          setSheetState(() {});
                        },
                      ),
                      _buildFilterChoiceChip(
                        label: 'Sudah Lunas ($paidCount)',
                        selected: _filterStatus == _BillFilterStatus.paid,
                        onSelected: () {
                          setState(() => _filterStatus = _BillFilterStatus.paid);
                          setSheetState(() {});
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'URUTKAN BERDASARKAN',
                    style: AppTypography.badgeLabel.copyWith(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildFilterChoiceChip(
                        label: 'Jatuh Tempo Terdekat',
                        selected: _sortOrder == _BillSortOrder.dueDate,
                        onSelected: () {
                          setState(() => _sortOrder = _BillSortOrder.dueDate);
                          setSheetState(() {});
                        },
                      ),
                      _buildFilterChoiceChip(
                        label: 'Nominal Tertinggi',
                        selected: _sortOrder == _BillSortOrder.highestCost,
                        onSelected: () {
                          setState(() => _sortOrder = _BillSortOrder.highestCost);
                          setSheetState(() {});
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterChoiceChip({
    required String label,
    required bool selected,
    required VoidCallback onSelected,
  }) {
    return ChoiceChip(
      label: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? AppColors.textDarkPrimary : AppColors.textWhite,
        ),
      ),
      selected: selected,
      selectedColor: AppColors.neoChartreuse,
      backgroundColor: AppColors.canvasInputSearch,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected ? AppColors.neoChartreuse : AppColors.canvasBorder,
        ),
      ),
      onSelected: (_) => onSelected(),
    );
  }

  void _showSubscriptionActionModal(BuildContext context, SubscriptionEntry sub) {
    final now = DateTime.now();
    final isPaid = sub.lastPaidDate != null && sub.lastPaidDate!.month == now.month;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.canvasCardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetCtx) {
        return Padding(
          padding: const EdgeInsets.all(20),
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
              Text(sub.title, style: AppTypography.heroGreeting),
              const SizedBox(height: 4),
              Text(
                'Biaya: Rp ${sub.cost.toStringAsFixed(0)} • Jatuh tempo tgl ${sub.dueDay}',
                style: AppTypography.listSubtitle,
              ),
              const SizedBox(height: 24),
              if (!isPaid) ...[
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.neoChartreuse,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(
                      Icons.check_circle_outline,
                      color: AppColors.textDarkPrimary,
                    ),
                    label: Text(
                      'Tandai Sudah Lunas Bulan Ini',
                      style: AppTypography.listTitle.copyWith(
                        color: AppColors.textDarkPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onPressed: () {
                      try {
                        context.read<FinanceBloc>().add(MarkSubscriptionPaidEvent(sub.id));
                      } catch (_) {}
                      Navigator.pop(sheetCtx);
                      setState(() {});
                    },
                  ),
                ),
              ] else ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.neoChartreuse.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.neoChartreuse.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.neoChartreuse,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Tagihan ini sudah lunas bulan ini ✓',
                        style: AppTypography.badgeLabel.copyWith(
                          color: AppColors.neoChartreuse,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Attempt to read live FinanceBloc state, fallback to constructor parameters
    List<SubscriptionEntry> currentSubs = widget.subscriptions;
    SafeToSpendMetrics? currentMetrics = widget.metrics;

    try {
      final bloc = BlocProvider.of<FinanceBloc>(context, listen: true);
      currentSubs = bloc.state.subscriptions;
      currentMetrics = bloc.state.metrics;
    } catch (_) {
      // Standalone mode / widget testing
    }

    final now = DateTime.now();
    final pendingSubs = currentSubs
        .where((s) => s.lastPaidDate == null || s.lastPaidDate!.month != now.month)
        .toList();
    final paidSubs = currentSubs
        .where((s) => s.lastPaidDate != null && s.lastPaidDate!.month == now.month)
        .toList();

    final filteredSubs = _filterAndSortSubscriptions(currentSubs, now);

    final currencyFormatter = widget.currencyFormatter ??
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    // Calculate real pending bills total
    final double totalPendingBills = currentMetrics?.pendingBills ??
        pendingSubs.fold<double>(0.0, (sum, s) => sum + s.cost);

    final double totalAllBills = currentSubs.fold<double>(0.0, (sum, s) => sum + s.cost);

    final double displayAmount = totalPendingBills > 0 ? totalPendingBills : totalAllBills;
    final formattedAmount = currencyFormatter.format(displayAmount);
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.canvasBg,
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header: Title & Close Chevron (placed cleanly below status bar, 20px padding)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      'Wawasan\nAnggaran &\nPengeluaran',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textWhite,
                        height: 1.06,
                        letterSpacing: -0.8,
                      ),
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.topRight,
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 36,
                        color: AppColors.textWhite,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content Area
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Central Geometric Motif (Monumental 200dp Height, Touching Neo-Green Circles)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: SizedBox(
                        height: 200,
                        child: ClipRect(
                          child: CustomPaint(
                            painter: const _ThreeCirclesGeometricPainter(
                              color: AppColors.neoChartreuse,
                              gap: 0.0,
                            ),
                            size: const Size(double.infinity, 200),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Total Pending Bills Section (Real Data)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            totalPendingBills > 0
                                ? 'Total Tagihan Bulan Ini'
                                : (currentSubs.isNotEmpty
                                    ? 'Total Tagihan (Semua Lunas)'
                                    : 'Total Tagihan Rutin'),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textMuted,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formattedAmount,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 38,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textWhite,
                              letterSpacing: -1.2,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currentSubs.isEmpty
                                ? 'Belum ada tagihan terdaftar'
                                : (pendingSubs.isEmpty
                                    ? 'Semua ${currentSubs.length} tagihan bulan ini sudah lunas ✓'
                                    : '${pendingSubs.length} belum dibayar dari ${currentSubs.length} tagihan aktif'),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: pendingSubs.isEmpty && currentSubs.isNotEmpty
                                  ? AppColors.neoChartreuse
                                  : AppColors.textSubtle,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Spending Cards List / Grid (Real Data - Tall Swiss-Editorial Cards)
                    if (currentSubs.isEmpty)
                      _buildEmptyState()
                    else if (filteredSubs.isEmpty)
                      _buildNoFilterMatches()
                    else if (_isGridView)
                      _buildGridView(filteredSubs, currencyFormatter, now)
                    else
                      _buildCarouselView(filteredSubs, currencyFormatter, now),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Bottom Unified Dock: Filter Tune, Unified < Filter Pill >, View Mode Toggle
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Filter / Tune Settings Button
                  _buildCircleButton(
                    icon: Icons.tune_rounded,
                    hasActiveDot: _filterStatus != _BillFilterStatus.all ||
                        _sortOrder != _BillSortOrder.dueDate,
                    onTap: () => _showFilterModal(
                      context,
                      currentSubs.length,
                      pendingSubs.length,
                      paidSubs.length,
                    ),
                  ),

                  // Unified Integrated Filter Controller (< Label >)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _cycleFilter(forward: true),
                    child: Container(
                      height: 46,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppColors.canvasCardSurface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: _filterStatus != _BillFilterStatus.all
                              ? AppColors.neoChartreuse.withValues(alpha: 0.6)
                              : AppColors.canvasBorder,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => _cycleFilter(forward: false),
                            child: const Padding(
                              padding: EdgeInsets.only(right: 6),
                              child: Icon(
                                Icons.chevron_left_rounded,
                                size: 20,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                          if (_filterStatus == _BillFilterStatus.pending) ...[
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.neoChartreuse,
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            _getFilterPillText(
                              filteredSubs.length,
                              currentSubs.length,
                              pendingSubs.length,
                            ),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _filterStatus == _BillFilterStatus.pending
                                  ? AppColors.neoChartreuse
                                  : AppColors.textWhite,
                            ),
                          ),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => _cycleFilter(forward: true),
                            child: const Padding(
                              padding: EdgeInsets.only(left: 6),
                              child: Icon(
                                Icons.chevron_right_rounded,
                                size: 20,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Carousel / Grid Toggle Button
                  _buildCircleButton(
                    icon: _isGridView
                        ? Icons.view_carousel_rounded
                        : Icons.grid_view_rounded,
                    onTap: () {
                      setState(() {
                        _isGridView = !_isGridView;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _cycleFilter({bool forward = true}) {
    setState(() {
      final statuses = _BillFilterStatus.values;
      final currentIndex = statuses.indexOf(_filterStatus);
      if (forward) {
        _filterStatus = statuses[(currentIndex + 1) % statuses.length];
      } else {
        _filterStatus = statuses[(currentIndex - 1 + statuses.length) % statuses.length];
      }
    });
  }

  String _getFilterPillText(int filteredCount, int totalCount, int pendingCount) {
    switch (_filterStatus) {
      case _BillFilterStatus.all:
        return '$totalCount Tagihan Aktif';
      case _BillFilterStatus.pending:
        return '$pendingCount Belum Lunas';
      case _BillFilterStatus.paid:
        return '$filteredCount Sudah Lunas';
    }
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
        decoration: BoxDecoration(
          color: AppColors.canvasCardSurface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.canvasBorder),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.neoChartreuse.withValues(alpha: 0.15),
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                color: AppColors.neoChartreuse,
                size: 26,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Belum Ada Tagihan Rutin',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textWhite,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tambahkan langganan seperti Netflix, Spotify, Listrik, atau Kost agar Safe-to-Spend menghitung sisa dana secara otomatis.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppColors.textMuted,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoFilterMatches() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.canvasCardSurface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.canvasBorder),
        ),
        child: Column(
          children: [
            const Icon(Icons.filter_list_off_rounded, color: AppColors.textMuted, size: 36),
            const SizedBox(height: 10),
            Text(
              'Tidak ada tagihan dengan filter ini',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textWhite,
              ),
            ),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () => setState(() => _filterStatus = _BillFilterStatus.all),
              child: Text(
                'Tampilkan Semua Tagihan',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neoChartreuse,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarouselView(
    List<SubscriptionEntry> items,
    NumberFormat formatter,
    DateTime now,
  ) {
    return SizedBox(
      height: 280,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final sub = items[index];
          return SizedBox(
            width: 185,
            child: _buildSubscriptionCard(sub, formatter, now),
          );
        },
      ),
    );
  }

  Widget _buildGridView(
    List<SubscriptionEntry> items,
    NumberFormat formatter,
    DateTime now,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.68,
        ),
        itemBuilder: (context, index) {
          final sub = items[index];
          return _buildSubscriptionCard(sub, formatter, now);
        },
      ),
    );
  }

  Widget _buildSubscriptionCard(
    SubscriptionEntry sub,
    NumberFormat formatter,
    DateTime now,
  ) {
    final isPaid = sub.lastPaidDate != null && sub.lastPaidDate!.month == now.month;
    final icon = _getSubscriptionIcon(sub.title);
    final accentColor = _getSubscriptionColor(sub.title);

    return GestureDetector(
      onTap: () => _showSubscriptionActionModal(context, sub),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.canvasCardSurface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isPaid
                ? AppColors.neoChartreuse.withValues(alpha: 0.3)
                : AppColors.canvasBorder,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Icon Badge + Status Tag
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentColor.withValues(alpha: 0.15),
                  ),
                  child: Center(
                    child: Icon(icon, color: accentColor, size: 20),
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isPaid
                          ? AppColors.neoChartreuse.withValues(alpha: 0.15)
                          : (sub.autoDeduct
                              ? AppColors.neoCyan.withValues(alpha: 0.15)
                              : AppColors.neoCoral.withValues(alpha: 0.15)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isPaid
                          ? 'Lunas ✓'
                          : (sub.autoDeduct ? 'Auto' : 'Tgl ${sub.dueDay}'),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isPaid
                            ? AppColors.neoChartreuse
                            : (sub.autoDeduct ? AppColors.neoCyan : AppColors.neoCoral),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),

            // Spacious center breathing room (Tall card reference design)
            const Spacer(),

            // Category / Billing Cycle subtle kicker
            Text(
              sub.billingCycle == 'monthly'
                  ? 'LANGGANAN BULANAN'
                  : (sub.billingCycle == 'yearly' ? 'LANGGANAN TAHUNAN' : sub.billingCycle.toUpperCase()),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: AppColors.textSubtle,
                letterSpacing: 0.6,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),

            // Bottom Section: Title and Amount
            Text(
              sub.title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textWhite,
                letterSpacing: -0.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '-${formatter.format(sub.cost)}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: isPaid ? AppColors.textMuted : AppColors.textWhite,
                letterSpacing: -0.6,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
    bool hasActiveDot = false,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.canvasCardSurface,
          border: Border.all(
            color: hasActiveDot ? AppColors.neoChartreuse : AppColors.canvasBorder,
            width: 1,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: hasActiveDot ? AppColors.neoChartreuse : AppColors.textWhite,
            ),
            if (hasActiveDot)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.neoChartreuse,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for the 3 Neo-Green Geometric Shapes.
///
/// Draws 3 identical large circles of diameter = size.height (190dp).
/// - Center circle: (size.width / 2, centerY)
/// - Left circle: (size.width / 2 - (2*radius + gap), centerY)
/// - Right circle: (size.width / 2 + (2*radius + gap), centerY)
///
/// Clipped at container boundaries to create dramatic Swiss-editorial
/// hourglass curves and negative space.
class _ThreeCirclesGeometricPainter extends CustomPainter {
  final Color color;
  final double gap;

  const _ThreeCirclesGeometricPainter({
    required this.color,
    this.gap = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final paint = Paint()
      ..color = color
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;

    final centerY = size.height / 2;
    final centerX = size.width / 2;
    final radius = size.height / 2;
    final offsetDist = 2 * radius + gap;

    // Center full circle
    canvas.drawCircle(Offset(centerX, centerY), radius, paint);

    // Left circle touching center circle
    canvas.drawCircle(Offset(centerX - offsetDist, centerY), radius, paint);

    // Right circle touching center circle
    canvas.drawCircle(Offset(centerX + offsetDist, centerY), radius, paint);
  }

  @override
  bool shouldRepaint(covariant _ThreeCirclesGeometricPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.gap != gap;
  }
}
