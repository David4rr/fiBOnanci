import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/common_widgets.dart';
import 'category_donut_chart.dart';

/// 2-column category breakdown grid with colored dot, label, and animated counting nominal.
class FinancialReportCategoryGrid extends StatelessWidget {
  final List<UnifiedDonutSlice> slices;
  final int? selectedIndex;
  final String Function(double) formatter;
  final ValueChanged<int> onTapSlice;

  const FinancialReportCategoryGrid({
    super.key,
    required this.slices,
    required this.selectedIndex,
    required this.formatter,
    required this.onTapSlice,
  });

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (int i = 0; i < slices.length; i += 2) {
      final left = _buildItem(slices[i], i);
      final right = i + 1 < slices.length ? _buildItem(slices[i + 1], i + 1) : const SizedBox.shrink();
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Expanded(child: left),
              const SizedBox(width: 18),
              Expanded(child: right),
            ],
          ),
        ),
      );
    }
    return Column(children: rows);
  }

  Widget _buildItem(UnifiedDonutSlice item, int index) {
    final isSelected = selectedIndex == index;
    return GestureDetector(
      key: Key('report_category_row_$index'),
      behavior: HitTestBehavior.opaque,
      onTap: () => onTapSlice(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surfaceSubtle : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(shape: BoxShape.circle, color: item.color),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                item.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.textWhite : AppColors.textMuted,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: AnimatedCountingText(
                value: item.amount,
                formatter: formatter,
                textAlign: TextAlign.right,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textWhite,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
