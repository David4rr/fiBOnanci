import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../modals/add_pocket_modal.dart';
import '../modals/pocket_detail_modal.dart';

import '../../bloc/finance/finance_bloc.dart';
import '../../bloc/finance/finance_state.dart';
import '../../data/database/app_database.dart';
import '../../domain/services/cashflow_analytics_service.dart';
import '../modals/add_wallet_modal.dart';
import '../modals/edit_balance_modal.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/transaction_modal.dart';
import '../widgets/trend_spline_chart.dart';
import '../widgets/wallet_card_deck.dart';
import '../widgets/wallet_cashflow_summary.dart';
import '../widgets/wallet_detail_overlay.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  static void showAddWalletModal(BuildContext context) {
    AddWalletModal.show(context);
  }

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  int _selectedSegment = 0;
  WalletEntry? _liftedWallet;


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
                                  onTap: () => setState(() => _selectedSegment = 0),
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
                                  onTap: () => setState(() => _selectedSegment = 1),
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
                            liftedWalletId: activeSelected?.id,
                            onSelectWallet: (wallet) => setState(() => _liftedWallet = wallet),
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
                      // Kantong Tabungan Hero Card
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
                                      Text('TOTAL DANA TERKUMPUL', style: AppTypography.badgeLabel.copyWith(color: AppColors.textMuted)),
                                      const SizedBox(height: 6),
                                      Text(
                                        currencyFormatter.format(totalPocketsAmount),
                                        style: AppTypography.heroGreeting.copyWith(color: AppColors.neoMint, fontSize: 24),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${pockets.length} kantong aktif terisolasi',
                                        style: AppTypography.listSubtitle,
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => AddPocketModal.show(context),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: AppColors.neoChartreuse,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.add_rounded, color: AppColors.canvasBg, size: 18),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Kantong',
                                          style: GoogleFonts.plusJakartaSans(
                                            color: AppColors.canvasBg,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Empty State or List of Pockets
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
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.neoChartreuse,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    ),
                                    icon: const Icon(Icons.add, color: AppColors.canvasBg, size: 18),
                                    label: Text(
                                      'Buat Kantong Sekarang',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: AppColors.canvasBg,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    onPressed: () => AddPocketModal.show(context),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final pocket = pockets[index];
                                final Color pColor = Color(int.parse(pocket.colorHex.replaceAll('#', '0xFF')));
                                final target = pocket.targetAmount;
                                final current = pocket.currentAmount;
                                final double progress = (target != null && target > 0)
                                    ? (current / target).clamp(0.0, 1.0)
                                    : 1.0;

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () => PocketDetailModal.show(context, pocket: pocket),
                                    child: Container(
                                      padding: const EdgeInsets.all(18),
                                      decoration: BoxDecoration(
                                        color: AppColors.canvasCardSurface,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: AppColors.canvasBorder),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  color: pColor.withValues(alpha: 0.15),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Icon(_getPocketIcon(pocket.type), color: pColor, size: 20),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(pocket.name, style: AppTypography.listTitle),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      _getPocketTypeLabel(pocket.type),
                                                      style: TextStyle(color: pColor, fontSize: 11, fontWeight: FontWeight.w600),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 20),
                                            ],
                                          ),
                                          const SizedBox(height: 14),
                                          Text(
                                            currencyFormatter.format(current),
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.textWhite,
                                              fontFeatures: const [FontFeature.tabularFigures()],
                                            ),
                                          ),
                                          if (target != null && target > 0) ...[
                                            const SizedBox(height: 10),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text('Target: ${currencyFormatter.format(target)}', style: AppTypography.listSubtitle),
                                                Text(
                                                  '${(progress * 100).toStringAsFixed(0)}%',
                                                  style: TextStyle(color: pColor, fontSize: 12, fontWeight: FontWeight.w700),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(6),
                                              child: LinearProgressIndicator(
                                                value: progress,
                                                minHeight: 6,
                                                backgroundColor: Colors.white.withValues(alpha: 0.08),
                                                valueColor: AlwaysStoppedAnimation<Color>(pColor),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                );
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
              ),

              // Lifted Card Detail Overlay (Unenclosed standalone card, actions, chart & history)
              if (activeSelected != null)
                WalletDetailOverlay(
                  wallet: activeSelected,
                  allWallets: wallets,
                  transactions: state.transactions,
                  currencyFormatter: currencyFormatter,
                  computeSeries: CashflowAnalyticsService.compute30DaySeries,
                  computeDayLabels: CashflowAnalyticsService.compute30DayLabels,
                  onClose: () => setState(() => _liftedWallet = null),
                  onEditBalance: () {
                    final w = activeSelected;
                    setState(() => _liftedWallet = null);
                    EditBalanceModal.show(context, w);
                  },
                  onAddTransaction: () {
                    setState(() => _liftedWallet = null);
                    TransactionModal.show(context);
                  },
                ),
            ],
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

  String _getPocketTypeLabel(String type) {
    switch (type) {
      case 'retirement':
        return 'Masa Tua';
      case 'emergency':
        return 'Dana Darurat';
      case 'goal':
        return 'Target Impian';
      case 'savings':
      default:
        return 'Simpanan';
    }
  }
}
