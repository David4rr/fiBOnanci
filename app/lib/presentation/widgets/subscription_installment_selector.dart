import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'subscription_custom_tenor_row.dart';
import 'subscription_type_toggle.dart';

/// Segmented toggle and mandatory deadline / tenor selector for installment plans.
class SubscriptionInstallmentSelector extends StatefulWidget {
  final bool isInstallment;
  final int totalCycles;
  final int dueDay;
  final ValueChanged<bool> onToggleInstallment;
  final ValueChanged<int> onCyclesChanged;

  const SubscriptionInstallmentSelector({
    super.key,
    required this.isInstallment,
    required this.totalCycles,
    required this.dueDay,
    required this.onToggleInstallment,
    required this.onCyclesChanged,
  });

  static const tenorPresets = [3, 6, 12];

  static DateTime calculateDeadlineDate({
    required int dueDay,
    required int totalCycles,
    DateTime? referenceDate,
  }) {
    final now = referenceDate ?? DateTime.now();
    final startMonth = now.day <= dueDay ? now.month : now.month + 1;
    final totalMonths = startMonth + totalCycles - 1;
    final targetYear = now.year + ((totalMonths - 1) ~/ 12);
    final targetMonth = ((totalMonths - 1) % 12) + 1;
    final maxDays = DateTime(targetYear, targetMonth + 1, 0).day;
    final clampedDay = dueDay.clamp(1, maxDays);
    return DateTime(targetYear, targetMonth, clampedDay, 23, 59, 59);
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
    final deadline = SubscriptionInstallmentSelector.calculateDeadlineDate(
      dueDay: widget.dueDay,
      totalCycles: widget.totalCycles,
    );
    final deadlineStr = DateFormat('MMMM yyyy', 'id_ID').format(deadline);

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
              Text(
                'TENGGAT WAKTU CICILAN (WAJIB)',
                style: AppTypography.badgeLabel.copyWith(color: AppColors.neoCoral, letterSpacing: 0.8),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.neoCoral.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Selesai $deadlineStr',
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
                  label: 'Custom',
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
