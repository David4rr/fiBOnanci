import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../bloc/finance/finance_bloc.dart';
import '../../../bloc/finance/finance_state.dart';
import '../../../data/database/app_database.dart';
import '../../widgets/common/common_widgets.dart';
import 'subscription_detail_actions.dart';
import 'subscription_detail_app_bar.dart';
import 'subscription_detail_hero_card.dart';
import 'subscription_detail_modal_route.dart';
import 'subscription_detail_specs_card.dart';

export 'subscription_detail_actions.dart';
export 'subscription_detail_app_bar.dart';
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
  static final _currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

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

        return ExpandableModalSheet(
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
                  onDragUpdate: (d) => _sheetKey.currentState?.handleHeaderDragUpdate(d),
                  onDragEnd: (d) => _sheetKey.currentState?.handleHeaderDragEnd(d),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 8),
                        SubscriptionDetailHeroCard(
                          subscription: sub,
                          wallet: wallet,
                          indexOverride: effectiveIndex,
                        ),
                        const SizedBox(height: 18),
                        SubscriptionDetailSpecsCard(
                          subscription: sub,
                          wallet: wallet,
                          currencyFormatter: _currencyFormatter,
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 12),
                    child: SubscriptionDetailActions(
                      subscription: sub,
                      wallet: wallet,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
