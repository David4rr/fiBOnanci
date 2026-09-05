import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

/// Segmented toggle between routine subscription and installment / planned bill.
class SubscriptionTypeToggle extends StatelessWidget {
  final bool isInstallment;
  final ValueChanged<bool> onToggleInstallment;

  const SubscriptionTypeToggle({
    super.key,
    required this.isInstallment,
    required this.onToggleInstallment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.canvasInputSearch,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.canvasBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTypePill(
              'Langganan Rutin',
              Icons.all_inclusive_rounded,
              !isInstallment,
              () => onToggleInstallment(false),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildTypePill(
              'Cicilan / Rencana',
              Icons.timelapse_rounded,
              isInstallment,
              () => onToggleInstallment(true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypePill(String title, IconData icon, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.canvasCardSurface : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: AppColors.canvasBorder) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: isSelected ? AppColors.neoChartreuse : AppColors.textMuted),
            const SizedBox(width: 6),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? AppColors.textWhite : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
