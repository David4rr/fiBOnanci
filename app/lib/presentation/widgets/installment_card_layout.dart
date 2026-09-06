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
  final String maskedNumber;
  final bool isPaidThisMonth;

  const InstallmentCardLayout({
    super.key,
    required this.subscription,
    required this.wallet,
    required this.config,
    required this.currencyFormatter,
    required this.maskedNumber,
    required this.isPaidThisMonth,
  });

  Widget _buildSegmentedProgress(int totalCycles, int paidCycles, Color accent) {
    final clampedCycles = totalCycles.clamp(1, 24);
    return Row(
      children: List.generate(clampedCycles, (index) {
        final isPaid = index < paidCycles;
        return Expanded(
          child: Container(
            height: 5,
            margin: EdgeInsets.only(right: index < clampedCycles - 1 ? 3 : 0),
            decoration: BoxDecoration(
              color: isPaid ? accent : accent.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalCycles = subscription.totalCycles ?? 1;
    final paidCycles = subscription.paidCycles;
    final isCompleted = subscription.status == 'completed' || paidCycles >= totalCycles;
    final remainingCycles = (totalCycles - paidCycles).clamp(0, totalCycles);
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
                            color: accent.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: accent.withValues(alpha: 0.25), width: 0.8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(shape: BoxShape.circle, color: isCompleted ? Colors.greenAccent : accent),
                              ),
                              const SizedBox(width: 4.5),
                              Text(
                                isCompleted ? 'CICILAN LUNAS' : 'FASILITAS CICILAN',
                                style: GoogleFonts.plusJakartaSans(fontSize: 8.5, fontWeight: FontWeight.w800, letterSpacing: 0.7, color: accent),
                              ),
                            ],
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SubscriptionCardBadges.buildStatusBadge(
                    isPaidThisMonth,
                    subscription.dueDay,
                    config,
                    isInstallment: true,
                    totalCycles: totalCycles,
                    paidCycles: paidCycles,
                    isCompleted: isCompleted,
                  ),
                  Text(
                    isCompleted ? 'Semua Tenor Terbayar' : 'Sisa $remainingCycles dari $totalCycles Bulan',
                    style: GoogleFonts.plusJakartaSans(fontSize: 10.5, fontWeight: FontWeight.w700, color: accent.withValues(alpha: 0.85), fontFeatures: const [FontFeature.tabularFigures()]),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildSegmentedProgress(totalCycles, paidCycles, accent),
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
                    style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w800, color: accent, letterSpacing: -0.6, fontFeatures: const [FontFeature.tabularFigures()]),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'cicilan /bulan (tenor $totalCycles bln)',
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
