import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

class InboxTabSelector extends StatelessWidget {
  final int selectedTab;
  final int pendingCount;
  final int unreadCount;
  final ValueChanged<int> onTabSelected;

  const InboxTabSelector({
    super.key,
    required this.selectedTab,
    required this.pendingCount,
    required this.unreadCount,
    required this.onTabSelected,
  });

  Widget _buildTab({
    required int index,
    required String label,
    required int count,
    required IconData icon,
  }) {
    final isSelected = selectedTab == index;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTabSelected(index),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.neoChartreuse : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 15,
                  color: isSelected ? Colors.black : AppColors.textMuted,
                ),
                const SizedBox(width: 5),
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected ? Colors.black : AppColors.textMuted,
                  ),
                ),
                if (count > 0) ...[
                  const SizedBox(width: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.black.withAlpha(40) : AppColors.neoChartreuse.withAlpha(40),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$count',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.black : AppColors.neoChartreuse,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.canvasCardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.canvasBorder, width: 1),
      ),
      child: Row(
        children: [
          _buildTab(
            index: 0,
            label: 'Transaksi',
            count: pendingCount,
            icon: Icons.receipt_long_rounded,
          ),
          _buildTab(
            index: 1,
            label: 'Pengingat',
            count: unreadCount,
            icon: Icons.notifications_none_rounded,
          ),
        ],
      ),
    );
  }
}
