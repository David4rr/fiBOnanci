import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

class WalletSegmentedToggle extends StatelessWidget {
  final int selectedSegment;
  final int walletCount;
  final int pocketCount;
  final ValueChanged<int> onSegmentChanged;

  const WalletSegmentedToggle({
    super.key,
    required this.selectedSegment,
    required this.walletCount,
    required this.pocketCount,
    required this.onSegmentChanged,
  });

  Widget _buildSegmentButton({
    required int index,
    required String label,
    required bool isSelected,
  }) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onSegmentChanged(index),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? AppColors.neoChartreuse : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? AppColors.textDarkPrimary : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.canvasCardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.canvasBorder),
      ),
      child: Row(
        children: [
          _buildSegmentButton(index: 0, label: 'Rekening Utama ($walletCount)', isSelected: selectedSegment == 0),
          _buildSegmentButton(index: 1, label: 'Kantong Tabungan ($pocketCount)', isSelected: selectedSegment == 1),
        ],
      ),
    );
  }
}
