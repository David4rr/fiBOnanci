import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';

/// Instantaneous, zero-latency choice chip for filter dialogs and selectors.
/// Eliminates the Material RawChip 195ms cross-fade animation that causes
/// dual-green color flashes during single-choice switching.
class AppChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool>? onSelected;
  final VoidCallback? onTap;
  final Color selectedColor;
  final Color backgroundColor;
  final Color selectedTextColor;
  final Color unselectedTextColor;
  final Color? selectedBorderColor;
  final Color unselectedBorderColor;
  final double borderRadius;

  const AppChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    this.onSelected,
    this.onTap,
    this.selectedColor = AppColors.neoChartreuse,
    this.backgroundColor = AppColors.canvasInputSearch,
    this.selectedTextColor = AppColors.textDarkPrimary,
    this.unselectedTextColor = AppColors.textWhite,
    this.selectedBorderColor,
    this.unselectedBorderColor = AppColors.canvasBorder,
    this.borderRadius = 14,
  });

  void _handleTap() {
    if (onTap != null) {
      onTap!();
    } else if (onSelected != null) {
      onSelected!(!selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = selected
        ? (selectedBorderColor ?? selectedColor)
        : unselectedBorderColor;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _handleTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8.5),
        decoration: BoxDecoration(
          color: selected ? selectedColor : backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: selected ? selectedTextColor : unselectedTextColor,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
            fontSize: 12.5,
          ),
        ),
      ),
    );
  }
}
