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
    final today = DateTime.now().day;
    final isDarkBg = config.backgroundColor.computeLuminance() < 0.35;
    final isPaidState = isCompleted || isPaid || (isInstallment && totalCycles != null && paidCycles >= totalCycles);

    late final Color badgeBg;
    late final Color borderColor;
    late final Color accentColor;
    late final Color textColor;
    late final String statusText;

    if (isCompleted || (isInstallment && totalCycles != null && paidCycles >= totalCycles)) {
      badgeBg = const Color(0xFF0E1015).withValues(alpha: isDarkBg ? 0.82 : 0.92);
      borderColor = const Color(0xFFD4F442).withValues(alpha: isDarkBg ? 0.38 : 0.25);
      accentColor = const Color(0xFFD4F442);
      textColor = const Color(0xFFF8FAFC);
      statusText = 'CICILAN LUNAS ($paidCycles/${totalCycles ?? paidCycles})';
    } else if (isInstallment && isPaid) {
      badgeBg = const Color(0xFF0E1015).withValues(alpha: isDarkBg ? 0.82 : 0.92);
      borderColor = const Color(0xFFD4F442).withValues(alpha: isDarkBg ? 0.38 : 0.25);
      accentColor = const Color(0xFFD4F442);
      textColor = const Color(0xFFF8FAFC);
      statusText = 'CICILAN $paidCycles/${totalCycles ?? "?"} • LUNAS';
    } else if (isPaid) {
      badgeBg = const Color(0xFF0E1015).withValues(alpha: isDarkBg ? 0.82 : 0.92);
      borderColor = const Color(0xFFD4F442).withValues(alpha: isDarkBg ? 0.38 : 0.25);
      accentColor = const Color(0xFFD4F442);
      textColor = const Color(0xFFF8FAFC);
      statusText = 'LUNAS BULAN INI';
    } else {
      final currentStep = (paidCycles + 1).clamp(1, totalCycles ?? 99);
      final prefix = isInstallment ? 'CICILAN $currentStep/$totalCycles • ' : 'JATUH TEMPO ';
      if (today == dueDay) {
        badgeBg = const Color(0xFF141115).withValues(alpha: 0.90);
        borderColor = const Color(0xFFFF6B6B).withValues(alpha: 0.45);
        accentColor = const Color(0xFFFF6B6B);
        textColor = const Color(0xFFFFF1F2);
        statusText = '${prefix}HARI INI';
      } else if (today < dueDay && (dueDay - today) <= 3) {
        final diff = dueDay - today;
        badgeBg = const Color(0xFF121318).withValues(alpha: 0.88);
        borderColor = const Color(0xFFFBBF24).withValues(alpha: 0.38);
        accentColor = const Color(0xFFFBBF24);
        textColor = const Color(0xFFFEF3C7);
        statusText = '${prefix}H-$diff';
      } else {
        badgeBg = isDarkBg ? Colors.white.withValues(alpha: 0.10) : Colors.black.withValues(alpha: 0.08);
        borderColor = config.textColor.withValues(alpha: 0.14);
        accentColor = config.textColor.withValues(alpha: 0.70);
        textColor = config.textColor;
        statusText = '${prefix}TGL $dueDay';
      }
    }

    return Container(
      padding: EdgeInsets.fromLTRB(isPaidState ? 5 : 9, 4, 10, 4),
      decoration: BoxDecoration(
        color: badgeBg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor, width: 0.9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isPaidState)
            Container(
              width: 15,
              height: 15,
              decoration: BoxDecoration(shape: BoxShape.circle, color: accentColor),
              child: const Icon(Icons.check_rounded, size: 10.5, color: Color(0xFF0C0D11)),
            )
          else
            Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: accentColor)),
          const SizedBox(width: 6),
          Text(
            statusText,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.35,
              color: textColor,
            ),
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
