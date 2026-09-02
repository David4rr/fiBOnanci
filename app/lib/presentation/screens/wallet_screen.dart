import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../modals/add_pocket_modal.dart';
import '../modals/pocket_detail_modal.dart';
import '../widgets/bento_folder_card.dart';
import '../widgets/pocket_stock_chart_card.dart';

import '../../bloc/finance/finance_bloc.dart';
import '../../bloc/finance/finance_state.dart';
import '../../domain/services/cashflow_analytics_service.dart';
import '../modals/add_wallet_modal.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/trend_spline_chart.dart';
import '../widgets/wallet_card_deck.dart';
import '../widgets/wallet_cashflow_summary.dart';
import '../modals/wallet_detail_modal.dart';

class WalletScreen extends StatefulWidget {
  final ValueChanged<int>? onSegmentChanged;
  final ValueChanged<bool>? onDetailViewChanged;
  final int initialSegment;

  const WalletScreen({
    super.key,
    this.onSegmentChanged,
    this.onDetailViewChanged,
    this.initialSegment = 0,
  });
  static void showAddWalletModal(BuildContext context) {
    AddWalletModal.show(context);
  }

  static void showAddPocketModal(BuildContext context) {
    AddPocketModal.show(context);
  }

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  late int _selectedSegment;
  @override
  void initState() {
    super.initState();
    _selectedSegment = widget.initialSegment;
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
          final pockets = state.pockets;

          double totalRealBalance = 0;
          for (final w in wallets) {
            totalRealBalance += w.balance;
          }

          double totalPocketsAmount = 0;
          for (final p in pockets) {
            totalPocketsAmount += p.currentAmount;
          }
          return SafeArea(
            bottom: false,
            child: CustomScrollView(
              slivers: [
                    // Header
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

                    // Segmented Toggle: [ Rekening Utama ] | [ Kantong Tabungan ]
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                        child: Container(
                          height: 48,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.canvasCardSurface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.canvasBorder),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    setState(() => _selectedSegment = 0);
                                    widget.onSegmentChanged?.call(0);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: _selectedSegment == 0 ? AppColors.neoChartreuse : Colors.transparent,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Rekening Utama (${wallets.length})',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: _selectedSegment == 0 ? AppColors.canvasBg : AppColors.textMuted,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    setState(() => _selectedSegment = 1);
                                    widget.onSegmentChanged?.call(1);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: _selectedSegment == 1 ? AppColors.neoChartreuse : Colors.transparent,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Kantong Tabungan (${state.pockets.length})',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: _selectedSegment == 1 ? AppColors.canvasBg : AppColors.textMuted,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
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

                    if (_selectedSegment == 0) ...[
                      // Total Real Balance Hero
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
                                        style: AppTypography.heroGreeting.copyWith(color: AppColors.neoChartreuse, fontSize: 24),
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
                                    color: AppColors.neoChartreuse.withValues(alpha: 0.15),
                                  ),
                                  child: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.neoChartreuse, size: 26),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Monthly Cashflow Summary (Income & Expense)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                          child: WalletCashflowSummary(
                            monthlyIncome: state.monthlyCashflow.income,
                            monthlyExpense: state.monthlyCashflow.expense,
                            currencyFormatter: currencyFormatter,
                          ),
                        ),
                      ),

                      // All Wallets Cash Flow Trend Chart (30 Days, Dual series)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                          child: TrendSplineChart(
                            incomeValues: CashflowAnalyticsService.compute30DaySeries(state.transactions, type: 'income'),
                            expenseValues: CashflowAnalyticsService.compute30DaySeries(state.transactions, type: 'expense'),
                            labels: CashflowAnalyticsService.compute30DayLabels(),
                            headline: 'Tren Arus Kas (Semua Rekening)',
                            subtitle: '30 Hari Terakhir',
                            height: 110,
                          ),
                        ),
                      ),

                      // Section label
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

                      // Stacked Card Deck (Fixed Height, Uniform Peeking, No Clones)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: WalletCardDeck(
                            wallets: wallets,
                            fmt: currencyFormatter,
                            onSelectWallet: (wallet) {
                              WalletDetailModal.show(context, wallet: wallet);
                            },
                          ),
                        ),
                      ),

                      // Tip footer
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
                    ] else ...[
                      // Kantong Tabungan Stock Trend Card (Compact single-container)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                          child: PocketStockChartCard(
                            currentTotal: totalPocketsAmount,
                            pocketsCount: pockets.length,
                            transactions: state.transactions,
                          ),
                        ),
                      ),

                      // Empty State or Bento Grid of Pockets
                      if (pockets.isEmpty) ...[
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                            child: Container(
                              padding: const EdgeInsets.all(28),
                              decoration: BoxDecoration(
                                color: AppColors.canvasCardSurface,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: AppColors.canvasBorder),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.neoChartreuse.withValues(alpha: 0.12),
                                    ),
                                    child: const Center(
                                      child: Icon(Icons.savings_outlined, color: AppColors.neoChartreuse, size: 30),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text('Belum Ada Kantong Tabungan', style: AppTypography.sectionTitle),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Pisahkan dana untuk Tabungan Pensiun/Masa Tua, Dana Darurat, atau Impianmu agar aman dari belanja harian.',
                                    textAlign: TextAlign.center,
                                    style: AppTypography.listSubtitle,
                                  ),
                                  const SizedBox(height: 20),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: AppColors.neoChartreuse.withValues(alpha: 0.10),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: AppColors.neoChartreuse.withValues(alpha: 0.25)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.add_circle_outline, color: AppColors.neoChartreuse, size: 16),
                                        const SizedBox(width: 8),
                                        Flexible(
                                          child: Text(
                                            'Ketuk tombol + di bawah untuk membuat',
                                            style: GoogleFonts.plusJakartaSans(
                                              color: AppColors.neoChartreuse,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12.0,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                          sliver: SliverGrid(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                              mainAxisExtent: 148,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                if (index < pockets.length) {
                                  final pocket = pockets[index];
                                  final Color pColor = Color(int.parse(pocket.colorHex.replaceAll('#', '0xFF')));
                                  final target = pocket.targetAmount;
                                  final current = pocket.currentAmount;
                                  final double? progress = (target != null && target > 0)
                                      ? (current / target).clamp(0.0, 1.0)
                                      : null;
                                  final isDark = ThemeData.estimateBrightnessForColor(pColor) == Brightness.dark;
                                  final Color primaryText = isDark ? AppColors.textWhite : AppColors.textDarkPrimary;
                                  final Color secondaryText = isDark
                                      ? Colors.white.withValues(alpha: 0.95)
                                      : AppColors.textDarkPrimary;
                                  final Color tertiaryText = isDark
                                      ? Colors.white.withValues(alpha: 0.70)
                                      : AppColors.textDarkSecondary;

                                  return BentoFolderCard(
                                    backgroundColor: pColor,
                                    height: 148,
                                    iconData: _getPocketIcon(pocket.type),
                                    title: currencyFormatter.format(current),
                                    subtitleWidget: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Pocket Name - Prominent, Bold & Clearly Visible!
                                        Text(
                                          pocket.name,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w700,
                                            color: secondaryText,
                                            letterSpacing: -0.2,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 3),
                                        // Target & Percentage (No progress bar line)
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                target != null && target > 0
                                                    ? currencyFormatter.format(target)
                                                    : 'Tanpa target',
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 10.5,
                                                  fontWeight: FontWeight.w600,
                                                  color: tertiaryText,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (progress != null) ...[
                                              const SizedBox(width: 4),
                                              Text(
                                                '${(progress * 100).toInt()}%',
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w800,
                                                  color: primaryText,
                                                  fontFeatures: const [FontFeature.tabularFigures()],
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                    onTap: () => PocketDetailModal.show(context, pocket: pocket),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                              childCount: pockets.length,
                            ),
                          ),
                        ),
                      ],

                    ],

                    const SliverToBoxAdapter(child: SizedBox(height: 140)),
                  ],
                ),
              );
        },
      ),
    );
  }

  IconData _getPocketIcon(String type) {
    switch (type) {
      case 'retirement':
        return Icons.elderly_outlined;
      case 'emergency':
        return Icons.shield_outlined;
      case 'goal':
        return Icons.flag_outlined;
      case 'savings':
      default:
        return Icons.savings_outlined;
    }
  }

}
