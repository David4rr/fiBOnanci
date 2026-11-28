import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../core/l10n/locale_notifier.dart';
import '../../domain/services/subscription_schedule_service.dart';
import '../theme/app_colors.dart';
import 'subscription_due_day_slider.dart';

/// Clean due-day slider with a single tappable date pill (`5 Des 2026 ▾`) for month/date selection.
class SubscriptionDueSchedulePicker extends StatelessWidget {
  final int dueDay;
  final DateTime nextDueDate;
  final ValueChanged<int> onDayChanged;
  final ValueChanged<DateTime> onNextDueDateChanged;
  final DateTime? referenceDate;

  const SubscriptionDueSchedulePicker({
    super.key,
    required this.dueDay,
    required this.nextDueDate,
    required this.onDayChanged,
    required this.onNextDueDateChanged,
    this.referenceDate,
  });

  @override
  Widget build(BuildContext context) {
    final now = SubscriptionScheduleService.dateOnly(referenceDate ?? DateTime.now());
    final locale = AppL10n.of(context).localeName;
    final dueOnly = SubscriptionScheduleService.dateOnly(nextDueDate);
    final dateLabel = DateFormat('d MMM yyyy', locale).format(dueOnly);
    final isFutureCycle = dueOnly.year > now.year || (dueOnly.year == now.year && dueOnly.month > now.month);

    return SubscriptionDueDaySlider(
      dueDay: dueDay,
      badgeText: dateLabel,
      isFutureCycle: isFutureCycle,
      onBadgeTap: () => _pickDate(context, now, dueOnly),
      onDayChanged: onDayChanged,
    );
  }

  Future<void> _pickDate(BuildContext context, DateTime now, DateTime currentDue) async {
    final firstDate = DateTime(now.year - 1, 1, 1);
    final lastDate = DateTime(now.year + 5, 12, 31);
    final initial = currentDue.isBefore(firstDate)
        ? now
        : (currentDue.isAfter(lastDate) ? lastDate : currentDue);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.dark(
            primary: AppColors.neoChartreuse,
            onPrimary: AppColors.textDarkPrimary,
            surface: AppColors.canvasCardSurface,
            onSurface: AppColors.textWhite,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      HapticFeedback.selectionClick();
      onNextDueDateChanged(SubscriptionScheduleService.dateOnly(picked));
    }
  }
}
