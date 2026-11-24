import 'package:flutter/material.dart';

import '../../../domain/services/cashflow_calendar_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

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

    String expenseText = '';
    Color expenseColor = AppColors.textSubtle;

    if (summary != null && status != DayActivityStatus.neutral) {
      if (summary!.totalExpense > 0) {
        expenseText = CashflowCalendarService.formatCompactAmount(summary!.totalExpense);
        expenseColor = AppColors.neoCoral;
      } else if (summary!.isNoSpendDay) {
        expenseText = '0';
        expenseColor = isSelected ? AppColors.neoChartreuse : AppColors.textSubtle;
      }
    }

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
            if (expenseText.isNotEmpty)
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  expenseText,
                  style: AppTypography.tabularFigures.copyWith(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                    color: expenseColor,
                  ),
                  maxLines: 1,
                ),
              )
            else
              const SizedBox(height: 11),
          ],
        ),
      ),
    );
  }
}
