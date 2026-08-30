import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

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
}
