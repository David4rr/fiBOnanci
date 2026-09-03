import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class WalletTypeSelector extends StatelessWidget {
  final String selectedType;
  final ValueChanged<String> onTypeChanged;

  const WalletTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  Widget _buildTypePill(String label, String value) {
    final isSelected = selectedType == value;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.selectionClick();
          onTypeChanged(value);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.neoChartreuse : AppColors.canvasInputSearch,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppColors.neoChartreuse : AppColors.canvasBorder,
              width: 1.2,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTypography.listTitle.copyWith(
                color: isSelected ? AppColors.textDarkPrimary : AppColors.textWhite,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildTypePill('Bank', 'bank'),
        const SizedBox(width: 8),
        _buildTypePill('E-Wallet', 'ewallet'),
        const SizedBox(width: 8),
        _buildTypePill('Kas Tunai', 'cash'),
      ],
    );
  }
}
