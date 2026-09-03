import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../data/database/app_database.dart';
import 'modernist_card_painter.dart';
import 'subscription_card_badges.dart';
import 'subscription_card_resolver.dart';
import 'subscription_card_theme.dart';

export 'modernist_card_painter.dart' show ModernistCardTheme, ModernistCardConfig;
export 'subscription_card_badges.dart';
export 'subscription_card_resolver.dart';
export 'subscription_card_theme.dart';

/// Tactile Swiss-editorial ATM-style Subscription Card strictly matching ref1.jpg.
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

    final theme = SubscriptionCardResolver.resolve(subscription.title, indexOverride ?? subscription.title.hashCode);
    final config = SubscriptionCardThemeConfig.forTheme(theme);
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final maskedNumber = SubscriptionCardResolver.generateMaskedNumber(subscription, wallet);

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
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              subscription.title,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: config.textColor,
                                letterSpacing: -0.4,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              wallet?.name.toUpperCase() ?? 'KARTU UTAMA',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                                color: config.textColor.withValues(alpha: 0.65),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SubscriptionCardBadges.buildNetworkBadge(config),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SubscriptionCardBadges.buildStatusBadge(isPaidThisMonth, subscription.dueDay, config),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currencyFormatter.format(subscription.cost),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 25,
                              fontWeight: FontWeight.w800,
                              color: config.textColor,
                              letterSpacing: -0.8,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subscription.billingCycle == 'monthly' ? '/bulan' : '/tahun',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: config.textColor.withValues(alpha: 0.65),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          CustomPaint(
                            size: const Size(16, 12),
                            painter: ContactlessPainter(color: config.textColor.withValues(alpha: 0.85)),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            maskedNumber,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: config.textColor.withValues(alpha: 0.75),
                              letterSpacing: 1.2,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
