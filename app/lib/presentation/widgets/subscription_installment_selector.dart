import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/l10n/locale_notifier.dart';
import '../../domain/services/subscription_schedule_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'subscription_custom_tenor_row.dart';
import 'subscription_type_toggle.dart';

/// Segmented toggle and mandatory deadline / tenor selector for installment plans.
class SubscriptionInstallmentSelector extends StatefulWidget {
  final bool isInstallment;
  final int totalCycles;
  final int dueDay;
  final DateTime firstDueDate;
  final int paidCycles;
  final ValueChanged<bool> onToggleInstallment;
  final ValueChanged<int> onCyclesChanged;

  const SubscriptionInstallmentSelector({
    super.key,
    required this.isInstallment,
    required this.totalCycles,
    required this.dueDay,
    required this.firstDueDate,
    this.paidCycles = 0,
    required this.onToggleInstallment,
    required this.onCyclesChanged,
  });

  static const tenorPresets = [3, 6, 12];

  static DateTime calculateDeadlineDate({
    required int dueDay,
    required int totalCycles,
    DateTime? firstDueDate,
    int paidCycles = 0,
    DateTime? referenceDate,
  }) {
    final now = referenceDate ?? DateTime.now();
    final effectiveFirst = firstDueDate ??
        SubscriptionScheduleService.resolveFirstDueDate(
          dueDay: dueDay,
          monthOffset: SubscriptionScheduleService.defaultMonthOffset(dueDay: dueDay, referenceDate: now),
          referenceDate: now,
        );
    return SubscriptionScheduleService.calculateInstallmentDeadline(
      firstDueDate: effectiveFirst,
      dueDay: dueDay,
      totalCycles: totalCycles,
      paidCycles: paidCycles,
    );
  }

  @override
  State<SubscriptionInstallmentSelector> createState() => _SubscriptionInstallmentSelectorState();
}

class _SubscriptionInstallmentSelectorState extends State<SubscriptionInstallmentSelector> {
  late bool _isCustom;
  late final TextEditingController _customController;

  @override
  void initState() {
    super.initState();
    _isCustom = !SubscriptionInstallmentSelector.tenorPresets.contains(widget.totalCycles);
    _customController = TextEditingController(text: widget.totalCycles.toString());
  }

  @override
  void didUpdateWidget(covariant SubscriptionInstallmentSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.totalCycles != widget.totalCycles) {
      if (!SubscriptionInstallmentSelector.tenorPresets.contains(widget.totalCycles)) {
        _isCustom = true;
      }
      if (_customController.text != widget.totalCycles.toString()) {
        _customController.text = widget.totalCycles.toString();
      }
    }
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  void _updateCycles(int val) {
    final clamped = val.clamp(1, 120);
    _customController.text = clamped.toString();
    widget.onCyclesChanged(clamped);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final deadline = SubscriptionInstallmentSelector.calculateDeadlineDate(
      dueDay: widget.dueDay,
      totalCycles: widget.totalCycles,
      firstDueDate: widget.firstDueDate,
      paidCycles: widget.paidCycles,
    );
    final deadlineStr = DateFormat('MMMM yyyy', l10n.localeName).format(deadline);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SubscriptionTypeToggle(
          isInstallment: widget.isInstallment,
          onToggleInstallment: widget.onToggleInstallment,
        ),
        if (widget.isInstallment) ...[
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  l10n.subInstallmentDeadlineHeader,
                  style: AppTypography.badgeLabel.copyWith(color: AppColors.neoCoral, letterSpacing: 0.8),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.neoCoral.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  l10n.subInstallmentFinishDate(deadlineStr),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.neoCoral,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final preset in SubscriptionInstallmentSelector.tenorPresets) ...[
                Expanded(
                  child: SubscriptionTenorPresetButton(
                    label: '${preset}x',
                    isSelected: !_isCustom && widget.totalCycles == preset,
                    onTap: () {
                      setState(() => _isCustom = false);
                      _updateCycles(preset);
                    },
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: SubscriptionTenorPresetButton(
                  label: l10n.subInstallmentCustomBtn,
                  isSelected: _isCustom,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _isCustom = true);
                  },
                ),
              ),
            ],
          ),
          if (_isCustom) ...[
            const SizedBox(height: 10),
            SubscriptionCustomTenorRow(
              controller: _customController,
              totalCycles: widget.totalCycles,
              onChanged: widget.onCyclesChanged,
            ),
          ],
        ],
      ],
    );
  }

}
