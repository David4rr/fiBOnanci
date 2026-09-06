import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/database/app_database.dart';
import 'subscription_card_theme.dart';
class SubscriptionCardBadges {
  static Widget buildStatusBadge(
    bool isPaid,
    int dueDay,
    SubscriptionCardThemeConfig config, {
    bool isInstallment = false,
    int? totalCycles,
    int paidCycles = 0,
    bool isCompleted = false,
  }) {
    final now = DateTime.now();
    final today = now.day;
    Color badgeBg;
    Color dotColor;
    Color textColor;
    String statusText;
    final isDarkBg = config.backgroundColor.computeLuminance() < 0.35;

    if (isCompleted || (isInstallment && totalCycles != null && paidCycles >= totalCycles)) {
      badgeBg = isDarkBg ? const Color(0xFF064E3B).withValues(alpha: 0.85) : const Color(0xFF0F172A).withValues(alpha: 0.9);
      dotColor = isDarkBg ? const Color(0xFF34D399) : const Color(0xFF10B981);
      textColor = dotColor;
      statusText = 'CICILAN LUNAS ($paidCycles/${totalCycles ?? paidCycles})';
    } else if (isInstallment && isPaid) {
      badgeBg = isDarkBg ? const Color(0xFF064E3B).withValues(alpha: 0.85) : const Color(0xFF0F172A).withValues(alpha: 0.9);
      dotColor = isDarkBg ? const Color(0xFF34D399) : const Color(0xFF10B981);
      textColor = dotColor;
      statusText = 'CICILAN $paidCycles/${totalCycles ?? "?"} • LUNAS';
    } else if (isInstallment) {
      final currentStep = (paidCycles + 1).clamp(1, totalCycles ?? 99);
      if (today == dueDay) {
        badgeBg = const Color(0xFFDC2626);
        dotColor = Colors.white;
        textColor = Colors.white;
        statusText = 'CICILAN $currentStep/$totalCycles • HARI INI';
      } else if (today < dueDay && (dueDay - today) <= 3) {
        final diff = dueDay - today;
        badgeBg = const Color(0xFF0F172A).withValues(alpha: 0.9);
        dotColor = const Color(0xFFF59E0B);
        textColor = const Color(0xFFFBBF24);
        statusText = 'CICILAN $currentStep/$totalCycles • H-$diff';
      } else {
        badgeBg = isDarkBg ? Colors.black.withValues(alpha: 0.35) : const Color(0xFF0F172A).withValues(alpha: 0.85);
        dotColor = isDarkBg ? Colors.white.withValues(alpha: 0.8) : config.backgroundColor;
        textColor = Colors.white;
        statusText = 'CICILAN $currentStep/$totalCycles • TGL $dueDay';
      }
    } else if (isPaid) {
      badgeBg = isDarkBg ? const Color(0xFF064E3B).withValues(alpha: 0.85) : const Color(0xFF0F172A).withValues(alpha: 0.9);
      dotColor = isDarkBg ? const Color(0xFF34D399) : const Color(0xFF10B981);
      textColor = dotColor;
      statusText = 'LUNAS BULAN INI';
    } else if (today == dueDay) {
      badgeBg = const Color(0xFFDC2626);
      dotColor = Colors.white;
      textColor = Colors.white;
      statusText = 'JATUH TEMPO HARI INI';
    } else if (today < dueDay && (dueDay - today) <= 3) {
      final diff = dueDay - today;
      badgeBg = const Color(0xFF0F172A).withValues(alpha: 0.9);
      dotColor = const Color(0xFFF59E0B);
      textColor = const Color(0xFFFBBF24);
      statusText = 'JATUH TEMPO H-$diff';
    } else {
      badgeBg = isDarkBg ? Colors.black.withValues(alpha: 0.35) : const Color(0xFF0F172A).withValues(alpha: 0.85);
      dotColor = isDarkBg ? Colors.white.withValues(alpha: 0.8) : config.backgroundColor;
      textColor = Colors.white;
      statusText = 'JATUH TEMPO TGL $dueDay';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: badgeBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isPaid
              ? (isDarkBg ? const Color(0xFF10B981).withValues(alpha: 0.4) : Colors.transparent)
              : Colors.white.withValues(alpha: 0.1),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor)),
          const SizedBox(width: 6),
          Text(
            statusText,
            style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.4, color: textColor),
          ),
        ],
      ),
    );
  }

  static Widget buildNetworkBadge(SubscriptionCardThemeConfig config) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(color: config.textColor, borderRadius: BorderRadius.circular(7)),
      child: Text(
        config.networkBadgeText,
        style: GoogleFonts.plusJakartaSans(fontSize: 9.5, fontWeight: FontWeight.w900, color: config.backgroundColor, letterSpacing: 0.6),
      ),
    );
  }

  static Widget buildInstallmentProgress({
    required bool isPaidThisMonth,
    required SubscriptionEntry subscription,
    required SubscriptionCardThemeConfig config,
  }) {
    final totalCycles = subscription.totalCycles ?? 1;
    final paidCycles = subscription.paidCycles;
    final isCompleted = subscription.status == 'completed' || paidCycles >= totalCycles;
    final remainingCycles = (totalCycles - paidCycles).clamp(0, totalCycles);
    final progress = (paidCycles / totalCycles).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            buildStatusBadge(
              isPaidThisMonth,
              subscription.dueDay,
              config,
              isInstallment: true,
              totalCycles: totalCycles,
              paidCycles: paidCycles,
              isCompleted: isCompleted,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(color: config.textColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
              child: Text(
                isCompleted ? 'LUNAS' : 'Sisa $remainingCycles bln',
                style: GoogleFonts.plusJakartaSans(fontSize: 9.5, fontWeight: FontWeight.w800, letterSpacing: 0.5, color: config.textColor),
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: SizedBox(
            height: 4,
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: config.textColor.withValues(alpha: 0.16),
              valueColor: AlwaysStoppedAnimation<Color>(config.textColor),
            ),
          ),
        ),
      ],
    );
  }

  static Widget buildBillingSchedule({
    required bool isPaidThisMonth,
    required SubscriptionEntry subscription,
    required SubscriptionCardThemeConfig config,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        buildStatusBadge(
          isPaidThisMonth,
          subscription.dueDay,
          config,
          isInstallment: false,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
          decoration: BoxDecoration(color: config.textColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
          child: Text(
            subscription.billingCycle == 'monthly' ? 'BULANAN' : 'TAHUNAN',
            style: GoogleFonts.plusJakartaSans(fontSize: 9.5, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: config.textColor),
          ),
        ),
      ],
    );
  }
}
