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
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? AppColors.textDarkPrimary : AppColors.textMuted,
            ),
            child: Text(label),
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
      child: Stack(
        children: [
          AnimatedAlign(
            alignment: selectedSegment == 0 ? Alignment.centerLeft : Alignment.centerRight,
            duration: const Duration(milliseconds: 280),
            curve: const Cubic(0.22, 1.0, 0.36, 1.0),
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1.0,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.neoChartreuse,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Row(
            children: [
              _buildSegmentButton(index: 0, label: 'Rekening Utama ($walletCount)', isSelected: selectedSegment == 0),
              _buildSegmentButton(index: 1, label: 'Kantong Tabungan ($pocketCount)', isSelected: selectedSegment == 1),
            ],
          ),
        ],
      ),
    );
  }
}
