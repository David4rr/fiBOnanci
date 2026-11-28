import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/locale_notifier.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/common/common_widgets.dart';

class ExpenseHistoryAppBar extends StatelessWidget {
  final double totalFiltered;
  final NumberFormat currencyFormatter;
  final GestureDragStartCallback? onDragStart;
  final GestureDragUpdateCallback? onDragUpdate;
  final GestureDragEndCallback? onDragEnd;
  final VoidCallback? onDismiss;
  final bool isEditing;
  final bool isCalendarView;
  final VoidCallback? onReturnToHistory;
  final VoidCallback? onToggleView;
  final String? customTitle;
  final String? customSubtitle;

  const ExpenseHistoryAppBar({
    super.key,
    required this.totalFiltered,
    required this.currencyFormatter,
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
    this.onDismiss,
    this.isEditing = false,
    this.isCalendarView = false,
    this.onReturnToHistory,
    this.onToggleView,
    this.customTitle,
    this.customSubtitle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragStart: onDragStart,
      onVerticalDragUpdate: onDragUpdate,
      onVerticalDragEnd: onDragEnd,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          !isEditing
              ? const Padding(
                  padding: EdgeInsets.only(top: 8, bottom: 4),
                  child: Center(child: ModalGrabHandle()),
                )
              : const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 260),
                    switchInCurve: SmoothPageView.defaultCurve,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: SmoothPageView.headerTitleTransition,
                    layoutBuilder: (currentChild, previousChildren) => Stack(
                      alignment: Alignment.topLeft,
                      children: [...previousChildren, ?currentChild],
                    ),
                    child: Column(
                      key: ValueKey('$isEditing|$isCalendarView|$customTitle|$customSubtitle'),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEditing
                              ? (customTitle ?? AppL10n.of(context).txEditTitle)
                              : (isCalendarView ? AppL10n.of(context).historyTitleCalendar : AppL10n.of(context).historyTitleDefault),
                          style: AppTypography.modalTitle,
                          maxLines: isEditing ? 1 : 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isEditing
                              ? (customSubtitle ?? AppL10n.of(context).txEditSubDefault)
                              : (isCalendarView
                                  ? AppL10n.of(context).historySubCalendar
                                  : AppL10n.of(context).historySubFiltered(currencyFormatter.format(totalFiltered))),
                          style: AppTypography.modalSubtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isEditing && onToggleView != null)
                      IconButton(
                        key: const Key('expense_history_toggle_calendar_button'),
                        onPressed: onToggleView,
                        tooltip: isCalendarView ? AppL10n.of(context).historyTooltipCard : AppL10n.of(context).historyTooltipCalendar,
                        icon: Icon(
                          isCalendarView ? Icons.view_agenda_outlined : Icons.calendar_month_outlined,
                          color: isCalendarView ? AppColors.textAccent : AppColors.textWhite,
                          size: 22,
                        ),
                      ),
                    IconButton(
                      onPressed: isEditing ? (onReturnToHistory ?? () {}) : (onDismiss ?? () => Navigator.of(context).pop()),
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 320),
                    switchInCurve: Curves.easeInOutCubic,
                    switchOutCurve: Curves.easeInOutCubic,
                    transitionBuilder: (child, anim) {
                      final key = child.key is ValueKey<IconData>
                          ? (child.key as ValueKey<IconData>).value
                          : null;
                      final turnsTween = key == Icons.keyboard_arrow_left_rounded
                          ? Tween<double>(begin: -0.25, end: 0.0)
                          : (key == Icons.keyboard_arrow_down_rounded
                              ? Tween<double>(begin: 0.25, end: 0.0)
                              : Tween<double>(begin: 0.0, end: 0.0));
                      return RotationTransition(
                        turns: anim.drive(turnsTween),
                        child: FadeTransition(opacity: anim, child: child),
                      );
                    },
                    child: Icon(
                      isEditing ? Icons.keyboard_arrow_left_rounded : Icons.keyboard_arrow_down_rounded,
                      key: ValueKey<IconData>(
                        isEditing ? Icons.keyboard_arrow_left_rounded : Icons.keyboard_arrow_down_rounded,
                      ),
                      size: 28,
                      color: AppColors.textWhite,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ],
  ),
);
  }
}
