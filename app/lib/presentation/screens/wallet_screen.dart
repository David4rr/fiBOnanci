import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/finance/finance_bloc.dart';
import '../../bloc/finance/finance_state.dart';
import '../../core/formatters/app_currency.dart';
import '../../domain/services/cashflow_analytics_service.dart';
import '../modals/add_pocket_modal.dart';
import '../modals/add_wallet_modal.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/wallet_card_deck.dart';
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

class _WalletScreenState extends State<WalletScreen> with SingleTickerProviderStateMixin {
  late int _selectedSegment;
  late final AnimationController _segmentAnim;
  late final Animation<double> _segmentOpacity;

  @override
  void initState() {
    super.initState();
    _selectedSegment = widget.initialSegment;
    _segmentAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 260), value: 1.0);
    _segmentOpacity = CurvedAnimation(parent: _segmentAnim, curve: const Cubic(0.22, 1.0, 0.36, 1.0));
  }

  @override
  void dispose() {
    _segmentAnim.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasBg,
      body: BlocBuilder<FinanceBloc, FinanceState>(
        builder: (context, state) {
          final currencyFormatter = AppCurrency.forCode(state.profile.currency);
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
                        if (idx == _selectedSegment) return;
                        setState(() => _selectedSegment = idx);
                        _segmentAnim.forward(from: 0.0);
                        widget.onSegmentChanged?.call(idx);
                      },
                    ),
                  ),
                ),
                SliverFadeTransition(
                  opacity: _segmentOpacity,
                  sliver: SliverMainAxisGroup(
                    slivers: [
                      if (_selectedSegment == 0) ...[
                        if (wallets.isNotEmpty) ...[
                          SliverToBoxAdapter(
                            child: WalletTotalBalanceCard(
                              totalRealBalance: totalRealBalance,
                              monthlyIncome: monthlyCashflow.income,
                              monthlyExpense: monthlyCashflow.expense,
                              incomeSeries: incomeSeries,
                              expenseSeries: expenseSeries,
                              dateLabels: dateLabels,
                              showChart: totalRealBalance > 0 || state.transactions.isNotEmpty,
                              currencyFormatter: currencyFormatter,
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                              child: WalletCardDeck(
                                wallets: wallets,
                                fmt: currencyFormatter,
                                onSelectWallet: (wallet) => WalletDetailScreen.push(context, wallet: wallet),
                              ),
                            ),
                          ),
                        ] else ...[
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(24, 0, 24, 80),
                                child: WalletCardDeck(
                                  wallets: wallets,
                                  fmt: currencyFormatter,
                                  onSelectWallet: (wallet) => WalletDetailScreen.push(context, wallet: wallet),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ] else ...[
                        WalletPocketsView(
                          pockets: pockets,
                          totalPocketsAmount: totalPocketsAmount,
                          transactions: state.transactions,
                          currencyFormatter: currencyFormatter,
                        ),
                      ],
                      if ((_selectedSegment == 0 && wallets.isNotEmpty) || (_selectedSegment == 1 && pockets.isNotEmpty))
                        const SliverToBoxAdapter(child: SizedBox(height: 140)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
