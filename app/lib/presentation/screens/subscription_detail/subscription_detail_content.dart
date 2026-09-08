import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/database/app_database.dart';
import 'subscription_detail_actions.dart';
import 'subscription_detail_hero_card.dart';
import 'subscription_detail_specs_card.dart';

/// Primary detail view content displaying hero card, specs, and action buttons.
class SubscriptionDetailContent extends StatelessWidget {
  final SubscriptionEntry subscription;
  final WalletEntry wallet;
  final int? indexOverride;
  final NumberFormat currencyFormatter;
  final ScrollController scrollController;
  final VoidCallback onEdit;

  const SubscriptionDetailContent({
    super.key,
    required this.subscription,
    required this.wallet,
    this.indexOverride,
    required this.currencyFormatter,
    required this.scrollController,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            controller: scrollController,
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                SubscriptionDetailHeroCard(
                  subscription: subscription,
                  wallet: wallet,
                  indexOverride: indexOverride,
                ),
                const SizedBox(height: 18),
                SubscriptionDetailSpecsCard(
                  subscription: subscription,
                  wallet: wallet,
                  currencyFormatter: currencyFormatter,
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
              subscription: subscription,
              wallet: wallet,
              onEdit: onEdit,
            ),
          ),
        ),
      ],
    );
  }
}
