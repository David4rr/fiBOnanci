import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../data/database/app_database.dart';
import '../../core/l10n/locale_notifier.dart';
import '../../domain/services/subscription_schedule_service.dart';
import 'subscription_card_theme.dart';
class SubscriptionCardBadges {
  static Widget buildStatusBadge(
    bool isPaid,
    DateTime nextDueDate,
    SubscriptionCardThemeConfig config, {
    bool isInstallment = false,
    int? totalCycles,
    int paidCycles = 0,
    bool isCompleted = false,
  }) => Builder(builder: (context) {
    final l10n = AppL10n.of(context);
    final now = DateTime.now();
    final today = SubscriptionScheduleService.dateOnly(now);
    final due = SubscriptionScheduleService.dateOnly(nextDueDate);
    final isDarkBg = config.backgroundColor.computeLuminance() < 0.35;
    final isCompletedPlan = isCompleted || (isInstallment && totalCycles != null && paidCycles >= totalCycles);
    final isPaidState = isCompletedPlan || isPaid;

    late final Color badgeBg, borderColor, accentColor, textColor;
    late final String statusText;

    if (isPaidState) {
      badgeBg = const Color(0xFF0E1015).withValues(alpha: isDarkBg ? 0.82 : 0.92);
      borderColor = const Color(0xFFD4F442).withValues(alpha: isDarkBg ? 0.38 : 0.25);
      accentColor = const Color(0xFFD4F442);
      textColor = const Color(0xFFF8FAFC);
      statusText = isCompletedPlan
          ? l10n.subBadgeInstallmentCompleted(paidCycles, totalCycles ?? paidCycles)
          : isInstallment
              ? l10n.subBadgeInstallmentPaid(paidCycles, '${totalCycles ?? "?"}')
              : l10n.subBadgePaidThisMonth;
    } else {
      final currentStep = (paidCycles + 1).clamp(1, totalCycles ?? 99);
      final prefix = isInstallment ? l10n.subBadgeInstallmentPrefix(currentStep, '${totalCycles ?? "?"}') : l10n.subBadgeDuePrefix;
      final diff = due.difference(today).inDays;
      final dateLabel = DateFormat('d MMM', l10n.localeName).format(due).toUpperCase();
      if (diff <= 0) {
        badgeBg = const Color(0xFF141115).withValues(alpha: 0.90);
        borderColor = const Color(0xFFFF6B6B).withValues(alpha: 0.45);
        accentColor = const Color(0xFFFF6B6B);
        textColor = const Color(0xFFFFF1F2);
        statusText = '$prefix${diff == 0 ? l10n.subBadgeToday : dateLabel}';
      } else if (diff <= 3) {
        badgeBg = const Color(0xFF121318).withValues(alpha: 0.88);
        borderColor = const Color(0xFFFBBF24).withValues(alpha: 0.38);
        accentColor = const Color(0xFFFBBF24);
        textColor = const Color(0xFFFEF3C7);
        statusText = '$prefix${l10n.subBadgeInDays(diff)}';
      } else {
        badgeBg = isDarkBg ? Colors.white.withValues(alpha: 0.10) : Colors.black.withValues(alpha: 0.08);
        borderColor = config.textColor.withValues(alpha: 0.14);
        accentColor = config.textColor.withValues(alpha: 0.70);
        textColor = config.textColor;
        final isSameMonth = due.year == today.year && due.month == today.month;
        statusText = '$prefix${isSameMonth ? l10n.subBadgeOnDay(due.day) : dateLabel}';
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
  });

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
              subscription.nextDueDate,
              config,
              isInstallment: true,
              totalCycles: totalCycles,
              paidCycles: paidCycles,
              isCompleted: isCompleted,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(color: config.textColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
              child: Builder(
                builder: (context) {
                  final l10n = AppL10n.of(context);
                  return Text(
                    isCompleted ? l10n.subBadgePaid : l10n.subBadgeMonthsLeft(remainingCycles),
                    style: GoogleFonts.plusJakartaSans(fontSize: 9.5, fontWeight: FontWeight.w800, letterSpacing: 0.5, color: config.textColor),
                  );
                },
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
          subscription.nextDueDate,
          config,
          isInstallment: false,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
          decoration: BoxDecoration(color: config.textColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
          child: Builder(
            builder: (context) {
              final l10n = AppL10n.of(context);
              return Text(
                subscription.billingCycle == 'monthly' ? l10n.subBadgeCycleMonthly : l10n.subBadgeCycleYearly,
                style: GoogleFonts.plusJakartaSans(fontSize: 9.5, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: config.textColor),
              );
            },
          ),
        ),
      ],
    );
  }
}
