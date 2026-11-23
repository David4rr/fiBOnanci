import 'package:flutter/material.dart';

import '../../../domain/services/cashflow_calendar_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import 'duolingo_animated_flame.dart';

class ActivityCalendarDayCell extends StatelessWidget {
  final int dayNumber;
  final DailyCashflowSummary? summary;
  final bool isSelected;
  final bool isToday;
  final VoidCallback? onTap;

  const ActivityCalendarDayCell({
    super.key,
    required this.dayNumber,
    this.summary,
    this.isSelected = false,
    this.isToday = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = summary?.status ?? DayActivityStatus.neutral;
    final isStreakDay = summary?.isHematDay == true;
    final isOverPace = status == DayActivityStatus.overPace;

    final cellBg = isSelected
        ? AppColors.neoChartreuse.withValues(alpha: 0.15)
        : (isToday
            ? AppColors.textWhite.withValues(alpha: 0.06)
            : Colors.transparent);

    final border = isSelected
        ? Border.all(color: AppColors.neoChartreuse, width: 1.2)
        : (isToday
            ? Border.all(color: AppColors.textWhite.withValues(alpha: 0.3), width: 1.0)
            : null);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: cellBg,
          borderRadius: BorderRadius.circular(10),
          border: border,
        ),
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$dayNumber',
              style: AppTypography.tabularFigures.copyWith(
                fontSize: 11.5,
                fontWeight: isSelected || isToday ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? AppColors.neoChartreuse
                    : (status == DayActivityStatus.neutral
                        ? AppColors.textSubtle.withValues(alpha: 0.4)
                        : AppColors.textWhite),
              ),
            ),
            const SizedBox(height: 2),
            if (isStreakDay)
              const DuolingoAnimatedFlame(
                size: 13,
                isLit: true,
              )
            else if (isOverPace)
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppColors.neoCoral,
                  shape: BoxShape.circle,
                ),
              )
            else
              const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}
