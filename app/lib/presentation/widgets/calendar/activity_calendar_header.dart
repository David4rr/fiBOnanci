import 'package:flutter/material.dart';

import '../../../domain/services/cashflow_calendar_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import 'activity_calendar_streak_strip.dart';
import 'duolingo_animated_flame.dart';

class ActivityCalendarMonthNavigator extends StatelessWidget {
  final String monthLabel;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const ActivityCalendarMonthNavigator({
    super.key,
    required this.monthLabel,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: onPrev,
            icon: const Icon(Icons.chevron_left_rounded, color: AppColors.textWhite, size: 26),
            splashRadius: 20,
          ),
          Text(
            monthLabel,
            style: const TextStyle(color: AppColors.textWhite, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          IconButton(
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right_rounded, color: AppColors.textWhite, size: 26),
            splashRadius: 20,
          ),
        ],
      ),
    );
  }
}

class ActivityCalendarStreakSummaryBar extends StatelessWidget {
  final MonthCashflowReport report;

  const ActivityCalendarStreakSummaryBar({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final hasStreak = report.currentStreak > 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                DuolingoAnimatedFlame(
                  size: 38,
                  isLit: hasStreak,
                ),
                const SizedBox(height: 6),
                Text(
                  '${report.currentStreak} Streak',
                  textAlign: TextAlign.center,
                  style: AppTypography.tabularFigures.copyWith(
                    color: AppColors.textWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Streak Hemat',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: hasStreak
                        ? const Color(0xFFFF9600)
                        : AppColors.textSubtle.withValues(alpha: 0.6),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (report.currentWeekStreak.isNotEmpty)
          ActivityCalendarStreakStrip(weekDays: report.currentWeekStreak),
      ],
    );
  }
}

class ActivityCalendarWeekdayHeader extends StatelessWidget {
  const ActivityCalendarWeekdayHeader({super.key});

  @override
  Widget build(BuildContext context) {
    const weekdays = ['SEN', 'SEL', 'RAB', 'KAM', 'JUM', 'SAB', 'MIN'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(7, (i) {
          final isWeekend = i >= 5;
          return Expanded(
            child: Center(
              child: Text(
                weekdays[i],
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isWeekend ? AppColors.neoCoral.withValues(alpha: 0.8) : AppColors.textSubtle.withValues(alpha: 0.6),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
