import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../bloc/finance/finance_bloc.dart';
import '../../../bloc/finance/finance_state.dart';
import '../../../data/database/app_database.dart';
import '../../widgets/common/common_widgets.dart';
import 'subscription_detail_app_bar.dart';
import 'subscription_detail_content.dart';
import 'subscription_detail_edit_tab.dart';
import 'subscription_detail_modal_route.dart';

export 'subscription_detail_actions.dart';
export 'subscription_detail_app_bar.dart';
export 'subscription_detail_content.dart';
export 'subscription_detail_edit_tab.dart';
export 'subscription_detail_hero_card.dart';
export 'subscription_detail_modal_route.dart';
export 'subscription_detail_specs_card.dart';
/// Full-screen modal screen for subscription and installment details with
/// shared-component animations, reactive balance deduction, and gesture drag dismiss.
class SubscriptionDetailScreen extends StatefulWidget {
  final String subscriptionId;
  final WalletEntry initialWallet;
  final int? indexOverride;
  final double initialChildSize;

  const SubscriptionDetailScreen({
    super.key,
    required this.subscriptionId,
    required this.initialWallet,
    this.indexOverride,
    this.initialChildSize = 1.0,
  });

  static Future<void> show(
    BuildContext context, {
    required SubscriptionEntry subscription,
    required WalletEntry wallet,
    int? indexOverride,
    double initialChildSize = 1.0,
  }) {
    return SubscriptionDetailModalRoute.show(
      context,
      subscription: subscription,
      wallet: wallet,
      indexOverride: indexOverride,
      initialChildSize: initialChildSize,
    );
  }

  @override
  State<SubscriptionDetailScreen> createState() => _SubscriptionDetailScreenState();
}

class _SubscriptionDetailScreenState extends State<SubscriptionDetailScreen> {
  final _sheetKey = GlobalKey<ExpandableModalSheetState>();
  late final PageController _pageController;
  int _currentTab = 0;

  static final _currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToEditTab() {
    setState(() => _currentTab = 1);
    _pageController.animateToPage(
      1,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOutCubic,
    );
  }

  void _goToDetailsTab() {
    setState(() => _currentTab = 0);
    _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FinanceBloc, FinanceState>(
      builder: (context, state) {
        final subMatches = state.subscriptions.where((s) => s.id == widget.subscriptionId);
        if (subMatches.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) Navigator.of(context).maybePop();
          });
          return const SizedBox.shrink();
        }

        final sub = subMatches.first;
        final wallet = state.wallets.firstWhere(
          (w) => w.id == sub.walletId,
          orElse: () => widget.initialWallet,
        );
        final subIdx = state.subscriptions.indexWhere((s) => s.id == sub.id);
        final effectiveIndex = widget.indexOverride ?? (subIdx >= 0 ? subIdx : null);

        return PopScope(
          canPop: _currentTab == 0,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop && _currentTab == 1) {
              _goToDetailsTab();
            }
          },
          child: ExpandableModalSheet(
            key: _sheetKey,
            initialChildSize: widget.initialChildSize,
            minChildSize: 0.40,
            maxChildSize: 1.0,
            snapSizes: const [0.85, 1.0],
            builder: (ctx, scrollController, currentSize) {
              return Column(
                children: [
                  SubscriptionDetailAppBar(
                    subscription: sub,
                    currencyFormatter: _currencyFormatter,
                    isEditing: _currentTab == 1,
                    onReturnToDetails: _goToDetailsTab,
                    onDragUpdate: (d) => _sheetKey.currentState?.handleHeaderDragUpdate(d),
                    onDragEnd: (d) => _sheetKey.currentState?.handleHeaderDragEnd(d),
                  ),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        SubscriptionDetailContent(
                          subscription: sub,
                          wallet: wallet,
                          indexOverride: effectiveIndex,
                          currencyFormatter: _currencyFormatter,
                          scrollController: scrollController,
                          onEdit: _goToEditTab,
                        ),
                        SubscriptionDetailEditTab(
                          subscription: sub,
                          onSaved: () => Navigator.of(context).maybePop(),
                          onReturnToDetails: _goToDetailsTab,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
