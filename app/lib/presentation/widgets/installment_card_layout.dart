import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../data/database/app_database.dart';
import 'contactless_painter.dart';
import 'subscription_card_badges.dart';
import 'subscription_card_theme.dart';

class InstallmentCardLayout extends StatelessWidget {
  final SubscriptionEntry subscription;
  final WalletEntry? wallet;
  final SubscriptionCardThemeConfig config;
  final NumberFormat currencyFormatter;
  final bool isPaidThisMonth;

  const InstallmentCardLayout({
    super.key,
    required this.subscription,
    required this.wallet,
    required this.config,
    required this.currencyFormatter,
    required this.isPaidThisMonth,
  });

  @override
  Widget build(BuildContext context) {
    final totalCycles = subscription.totalCycles ?? 1;
    final paidCycles = subscription.paidCycles;
    final isCompleted = subscription.status == 'completed' || paidCycles >= totalCycles;
    final accent = config.textColor;

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top Row: Title on Left & Installment Status Badge on Right
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  subscription.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: accent,
                    letterSpacing: -0.4,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 10),
              SubscriptionCardBadges.buildStatusBadge(
                isPaidThisMonth,
                subscription.dueDay,
                config,
                isInstallment: true,
                totalCycles: totalCycles,
                paidCycles: paidCycles,
                isCompleted: isCompleted,
              ),
            ],
          ),

          // Bottom Row: Monthly Installment Cost & Contactless Icon (Account Number eliminated)
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currencyFormatter.format(subscription.cost),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: accent,
                      letterSpacing: -0.6,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'cicilan /bulan (tenor $totalCycles bln)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: accent.withValues(alpha: 0.65),
                    ),
                  ),
                ],
              ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: CustomPaint(
                  size: const Size(20, 15),
                  painter: ContactlessPainter(color: accent.withValues(alpha: 0.85)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
