import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../bloc/finance/finance_bloc.dart';
import '../../bloc/finance/finance_state.dart';
import '../../domain/services/cashflow_analytics_service.dart';
import '../modals/add_pocket_modal.dart';
import '../modals/add_wallet_modal.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/trend_spline_chart.dart';
import '../widgets/wallet_card_deck.dart';
import '../widgets/wallet_cashflow_summary.dart';
import 'wallet/wallet_pockets_view.dart';
import 'wallet/wallet_segmented_toggle.dart';
import 'wallet/wallet_total_balance_card.dart';
import 'wallet_detail_screen.dart';

export 'wallet/wallet_pockets_view.dart';
export 'wallet/wallet_segmented_toggle.dart';
export 'wallet/wallet_total_balance_card.dart';

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

  static void showAddWalletModal(BuildContext context) => AddWalletModal.show(context);
  static void showAddPocketModal(BuildContext context) => AddPocketModal.show(context);

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
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

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

          final incomeSeries = CashflowAnalyticsService.compute30DaySeries(state.transactions, type: 'income');
          final expenseSeries = CashflowAnalyticsService.compute30DaySeries(state.transactions, type: 'expense');
          final dateLabels = CashflowAnalyticsService.compute30DayLabels();
          final monthlyCashflow = CashflowAnalyticsService.calculateMonthlyCashflow(state.transactions);

          return SafeArea(
            bottom: false,
            child: CustomScrollView(
              slivers: [
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
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: WalletSegmentedToggle(
                      selectedSegment: _selectedSegment,
                      walletCount: wallets.length,
                      pocketCount: pockets.length,
                      onSegmentChanged: (idx) {
                        setState(() => _selectedSegment = idx);
                        widget.onSegmentChanged?.call(idx);
                      },
                    ),
                  ),
                ),
                if (_selectedSegment == 0) ...[
                  SliverToBoxAdapter(
                    child: WalletTotalBalanceCard(
                      totalRealBalance: totalRealBalance,
                      currencyFormatter: currencyFormatter,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: WalletCashflowSummary(
                        monthlyIncome: monthlyCashflow.income,
                        monthlyExpense: monthlyCashflow.expense,
                        currencyFormatter: currencyFormatter,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: TrendSplineChart(
                        incomeValues: incomeSeries,
                        expenseValues: expenseSeries,
                        labels: dateLabels,
                        headline: 'Tren Arus Kas (Semua Rekening)',
                        subtitle: '30 Hari Terakhir',
                        height: 110,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: WalletCardDeck(
                        wallets: wallets,
                        fmt: currencyFormatter,
                        onSelectWallet: (wallet) {
                          widget.onDetailViewChanged?.call(true);
                          return WalletDetailScreen.push(context, wallet: wallet)
                              .then((_) => widget.onDetailViewChanged?.call(false));
                        },
                      ),
                    ),
                  ),
                ] else ...[
                  WalletPocketsView(
                    pockets: pockets,
                    totalPocketsAmount: totalPocketsAmount,
                    transactions: state.transactions,
                    currencyFormatter: currencyFormatter,
                  ),
                ],
                const SliverToBoxAdapter(child: SizedBox(height: 140)),
              ],
            ),
          );
        },
      ),
    );
  }
}
