import 'package:flutter/material.dart';

import '../../../domain/services/calendar/cashflow_calendar_models.dart';
import '../../theme/app_colors.dart';
import 'duolingo_animated_flame.dart';

class ActivityCalendarStreakStrip extends StatelessWidget {
  final List<WeekStreakDay> weekDays;

  const ActivityCalendarStreakStrip({super.key, required this.weekDays});

  @override
  Widget build(BuildContext context) {
    if (weekDays.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: weekDays.map((d) {
          final isLit = d.isStreakDay;
          final isToday = d.isToday;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                d.dayLabel,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                  color: isToday
                      ? const Color(0xFFFF9600)
                      : AppColors.textSubtle.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 4),
              DuolingoAnimatedFlame(
                size: isLit ? 18 : 15,
                isLit: isLit,
              ),
              const SizedBox(height: 3),
              Text(
                '${d.date.day}',
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
                  color: isToday
                      ? const Color(0xFFFF9600)
                      : AppColors.textSubtle.withValues(alpha: 0.4),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
