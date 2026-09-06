import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/database/app_database.dart';
import 'billing_card_layout.dart';
import 'installment_card_layout.dart';
import 'modernist_card_painter.dart';
import 'subscription_card_resolver.dart';
export 'billing_card_layout.dart';
export 'installment_card_layout.dart';
export 'modernist_card_theme.dart';
export 'subscription_card_badges.dart';
export 'subscription_card_resolver.dart';
export 'subscription_card_theme.dart';
/// Tactile ATM-style card representing either a fixed installment plan or recurring subscription.
class SubscriptionCard extends StatelessWidget {
  final SubscriptionEntry subscription;
  final WalletEntry? wallet;
  final VoidCallback? onTap;
  final int? indexOverride;
  final bool isFocused;

  const SubscriptionCard({
    super.key,
    required this.subscription,
    this.wallet,
    this.onTap,
    this.indexOverride,
    this.isFocused = true,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isPaidThisMonth = subscription.lastPaidDate != null &&
        subscription.lastPaidDate!.year == now.year &&
        subscription.lastPaidDate!.month == now.month;

    final effectiveIdx = (indexOverride ?? subscription.title.hashCode).abs();
    final theme = SubscriptionCardResolver.resolve(subscription.title, effectiveIdx, index: indexOverride);
    final config = SubscriptionCardResolver.resolveConfig(
      subscription: subscription,
      index: effectiveIdx,
      wallet: wallet,
    );
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 215.0,
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: config.backgroundColor,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              blurRadius: 18,
              offset: const Offset(0, 8),
              spreadRadius: 1,
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: ModernistCardPainter(
                  theme: theme,
                  primaryColor: config.primaryGraphicColor,
                  secondaryColor: config.secondaryGraphicColor,
                ),
              ),
            ),
            subscription.isInstallment
                ? InstallmentCardLayout(
                    subscription: subscription,
                    wallet: wallet,
                    config: config,
                    currencyFormatter: currencyFormatter,
                    isPaidThisMonth: isPaidThisMonth,
                  )
                : BillingCardLayout(
                    subscription: subscription,
                    wallet: wallet,
                    config: config,
                    currencyFormatter: currencyFormatter,
                    isPaidThisMonth: isPaidThisMonth,
                  ),
          ],
        ),
      ),
    );
  }
}
