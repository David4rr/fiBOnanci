import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../data/database/app_database.dart';
import 'contactless_painter.dart';
import 'subscription_card_badges.dart';
import 'subscription_card_theme.dart';

class BillingCardLayout extends StatelessWidget {
  final SubscriptionEntry subscription;
  final WalletEntry? wallet;
  final SubscriptionCardThemeConfig config;
  final NumberFormat currencyFormatter;
  final String maskedNumber;
  final bool isPaidThisMonth;

  const BillingCardLayout({
    super.key,
    required this.subscription,
    required this.wallet,
    required this.config,
    required this.currencyFormatter,
    required this.maskedNumber,
    required this.isPaidThisMonth,
  });

  @override
  Widget build(BuildContext context) {
    final isMonthly = subscription.billingCycle == 'monthly';
    final accent = config.textColor;

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            isMonthly ? 'LANGGANAN BULANAN' : 'LANGGANAN TAHUNAN',
                            style: GoogleFonts.plusJakartaSans(fontSize: 8.5, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: accent),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subscription.title,
                      style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: accent, letterSpacing: -0.4),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SubscriptionCardBadges.buildNetworkBadge(config),
                  const SizedBox(height: 3),
                  Text(
                    wallet?.name.toUpperCase() ?? 'KARTU UTAMA',
                    style: GoogleFonts.plusJakartaSans(fontSize: 9.5, fontWeight: FontWeight.w700, letterSpacing: 0.6, color: accent.withValues(alpha: 0.65)),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: accent.withValues(alpha: 0.14), width: 0.8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SubscriptionCardBadges.buildStatusBadge(
                  isPaidThisMonth,
                  subscription.dueDay,
                  config,
                  isInstallment: false,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.event_repeat_rounded, size: 13, color: accent.withValues(alpha: 0.7)),
                    const SizedBox(width: 4),
                    Text(
                      'Tgl ${subscription.dueDay} / bln',
                      style: GoogleFonts.plusJakartaSans(fontSize: 10.5, fontWeight: FontWeight.w700, color: accent.withValues(alpha: 0.85)),
                    ),
                  ],
                ),
              ],
            ),
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
                    style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w800, color: accent, letterSpacing: -0.6, fontFeatures: const [FontFeature.tabularFigures()]),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isMonthly ? 'tagihan rutin /bulan' : 'tagihan rutin /tahun',
                    style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.w600, color: accent.withValues(alpha: 0.65)),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CustomPaint(size: const Size(16, 12), painter: ContactlessPainter(color: accent.withValues(alpha: 0.85))),
                  const SizedBox(height: 4),
                  Text(
                    maskedNumber,
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: accent.withValues(alpha: 0.75), letterSpacing: 1.0, fontFeatures: const [FontFeature.tabularFigures()]),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
