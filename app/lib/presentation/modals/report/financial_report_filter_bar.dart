import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../domain/services/financial_report_service.dart';
import '../../../core/l10n/locale_notifier.dart';
import '../../../l10n/app_localizations.dart';
import '../../theme/app_colors.dart';

/// Top filter controls (flow type dropdown + granularity segmented pill)
/// and 3-slot swipeable period carousel matching the Statistics reference.
class FinancialReportFilterBar extends StatelessWidget {
  final ReportFlowType flowType;
  final ReportGranularity granularity;
  final int periodOffset;
  final ValueChanged<ReportFlowType> onFlowTypeChanged;
  final ValueChanged<ReportGranularity> onGranularityChanged;
  final ValueChanged<int> onPeriodOffsetChanged;

  const FinancialReportFilterBar({
    super.key,
    required this.flowType,
    required this.granularity,
    required this.periodOffset,
    required this.onFlowTypeChanged,
    required this.onGranularityChanged,
    required this.onPeriodOffsetChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;
    final now = DateTime.now();
    final prevLabel = FinancialReportService.formatGranularityLabel(granularity, periodOffset - 1, now, localeCode: localeCode);
    final currLabel = FinancialReportService.formatGranularityLabel(granularity, periodOffset, now, localeCode: localeCode);
    final nextLabel = FinancialReportService.formatGranularityLabel(granularity, periodOffset + 1, now, localeCode: localeCode);
    final canGoNext = periodOffset < 0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(child: _buildFlowDropdown(context, l10n)),
            const SizedBox(width: 8),
            _buildGranularityPill(l10n),
          ],
        ),
        const SizedBox(height: 18),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragEnd: (details) {
            final v = details.primaryVelocity ?? 0.0;
            if (v > 200) {
              onPeriodOffsetChanged(periodOffset - 1);
            } else if (v < -200 && canGoNext) {
              onPeriodOffsetChanged(periodOffset + 1);
            }
          },
          child: Row(
            children: [
              Expanded(child: _buildPeriodSlot(const Key('report_period_prev'), prevLabel, 0.65, () => onPeriodOffsetChanged(periodOffset - 1))),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(anim),
                      child: child,
                    ),
                  ),
                  child: Text(
                    currLabel,
                    key: ValueKey('${granularity.name}_$periodOffset'),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(fontSize: 15.5, fontWeight: FontWeight.w700, color: AppColors.textWhite),
                  ),
                ),
              ),
              Expanded(child: _buildPeriodSlot(const Key('report_period_next'), nextLabel, canGoNext ? 0.65 : 0.22, canGoNext ? () => onPeriodOffsetChanged(periodOffset + 1) : null)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodSlot(Key key, String label, double alpha, VoidCallback? onTap) {
    return GestureDetector(
      key: key,
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Text(
        label,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
          color: AppColors.textMuted.withValues(alpha: alpha),
        ),
      ),
    );
  }

  String _flowLabel(ReportFlowType t, AppLocalizations l10n) => switch (t) {
        ReportFlowType.expense => l10n.reportExpenses,
        ReportFlowType.income => l10n.reportIncome,
        ReportFlowType.all => l10n.reportAllFlow,
      };

  String _granularityLabel(ReportGranularity g, AppLocalizations l10n) => switch (g) {
        ReportGranularity.week => l10n.reportWeek,
        ReportGranularity.month => l10n.reportMonth,
        ReportGranularity.quarter => l10n.reportQuarter,
      };

  Widget _buildFlowDropdown(BuildContext context, AppLocalizations l10n) {
    return PopupMenuButton<ReportFlowType>(
      key: const Key('report_flow_type_button'),
      initialValue: flowType,
      color: AppColors.canvasCardSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: AppColors.borderSubtle),
      ),
      onSelected: onFlowTypeChanged,
      itemBuilder: (_) => ReportFlowType.values.map((t) {
        final active = t == flowType;
        return PopupMenuItem<ReportFlowType>(
          value: t,
          child: Text(_flowLabel(t, l10n), style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: active ? FontWeight.w700 : FontWeight.w500, color: active ? AppColors.neoChartreuse : AppColors.textWhite)),
        );
      }).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: AppColors.surfaceSubtle, borderRadius: BorderRadius.circular(999), border: Border.all(color: AppColors.borderSubtle)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(child: Text(_flowLabel(flowType, l10n), maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textWhite))),
            const SizedBox(width: 2),
            Icon(Icons.keyboard_arrow_down_rounded, size: 15, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildGranularityPill(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ReportGranularity.values.map((g) {
          final isSelected = g == granularity;
          return GestureDetector(
            key: Key('report_granularity_${g.name}'),
            behavior: HitTestBehavior.opaque,
            onTap: () => onGranularityChanged(g),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: isSelected ? (AppColors.isDark ? Colors.white.withValues(alpha: 0.14) : AppColors.pureWhite) : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(_granularityLabel(g, l10n), style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, color: isSelected ? AppColors.textWhite : AppColors.textMuted)),
            ),
          );
        }).toList(),
      ),
    );
  }
}
