import 'package:flutter/material.dart';

import '../../../data/database/app_database.dart';
import '../../widgets/subscription_card.dart';

/// Destination Hero card for full-screen subscription/installment detail view.
class SubscriptionDetailHeroCard extends StatelessWidget {
  final SubscriptionEntry subscription;
  final WalletEntry? wallet;
  final int? indexOverride;

  const SubscriptionDetailHeroCard({
    super.key,
    required this.subscription,
    this.wallet,
    this.indexOverride,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Hero(
        tag: 'subscription_card_${subscription.id}',
        flightShuttleBuilder: (
          flightContext,
          animation,
          flightDirection,
          fromHeroContext,
          toHeroContext,
        ) {
          final Hero toHero = toHeroContext.widget as Hero;
          return Material(
            color: Colors.transparent,
            child: toHero.child,
          );
        },
        child: Material(
          color: Colors.transparent,
          child: SubscriptionCard(
            subscription: subscription,
            wallet: wallet,
            indexOverride: indexOverride,
            isFocused: true,
          ),
        ),
      ),
    );
  }
}
