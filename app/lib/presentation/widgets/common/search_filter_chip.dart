import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class SearchFilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onClear;
  final Color color;
  final Color backgroundColor;

  const SearchFilterChip({
    super.key,
    required this.label,
    required this.onClear,
    this.color = AppColors.neoChartreuse,
    this.backgroundColor = AppColors.canvasInputSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: AppTypography.badgeLabel.copyWith(color: color)),
          const SizedBox(width: 4),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onClear,
            child: Icon(Icons.close, size: 14, color: color),
          ),
        ],
      ),
    );
  }
}
