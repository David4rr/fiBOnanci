import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/database/app_database.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class NotificationReviewSelectors {
  static Widget buildTypePill({
    required String label,
    required bool isSelected,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? activeColor.withValues(alpha: 0.15) : AppColors.canvasInputSearch,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isSelected ? activeColor : AppColors.canvasBorder, width: isSelected ? 1.5 : 1),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(color: isSelected ? activeColor : AppColors.textMuted, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ),
      ),
    );
  }

  static Widget buildWalletDropdown({
    required List<WalletEntry> wallets,
    required String? selectedWalletId,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.canvasInputSearch,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neoChartreuse.withValues(alpha: 0.5), width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: wallets.any((w) => w.id == selectedWalletId) ? selectedWalletId : (wallets.isNotEmpty ? wallets.first.id : null),
          isExpanded: true,
          dropdownColor: AppColors.canvasCardSurface,
          style: AppTypography.listTitle,
          items: wallets.map((w) {
            return DropdownMenuItem<String>(
              value: w.id,
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Color(int.parse(w.colorHex.replaceFirst('#', '0xFF'))),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(w.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Text(NumberFormat.compactSimpleCurrency(locale: 'id_ID').format(w.balance), style: AppTypography.listSubtitle),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  static Widget buildCategoryDropdown({
    required List<CategoryEntry> categories,
    required String? selectedCategoryId,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.canvasInputSearch,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.canvasBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: categories.any((c) => c.id == selectedCategoryId) ? selectedCategoryId : (categories.isNotEmpty ? categories.first.id : null),
          isExpanded: true,
          dropdownColor: AppColors.canvasCardSurface,
          style: AppTypography.listTitle,
          items: categories.map((c) => DropdownMenuItem<String>(value: c.id, child: Text(c.name))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
