import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class TransactionTypeToggle extends StatelessWidget {
  final String selectedType;
  final ValueChanged<String> onTypeChanged;

  const TransactionTypeToggle({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  Widget _buildPill(String label, String value, Color activeColor) {
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
            color: isSelected ? activeColor : AppColors.canvasInputSearch,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? activeColor : AppColors.canvasBorder,
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
        _buildPill('Pengeluaran', 'expense', AppColors.neoCoral),
        const SizedBox(width: 8),
        _buildPill('Pemasukan', 'income', AppColors.neoMint),
        const SizedBox(width: 8),
        _buildPill('Transfer', 'transfer', AppColors.neoCyan),
      ],
    );
  }
}

class TransactionDropdownContainer extends StatelessWidget {
  final Widget child;

  const TransactionDropdownContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.canvasInputSearch,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.canvasBorder, width: 0.8),
      ),
      child: DropdownButtonHideUnderline(child: child),
    );
  }
}
