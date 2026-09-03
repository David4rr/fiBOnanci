import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

const List<Map<String, dynamic>> kPocketTypes = [
  {'id': 'savings', 'label': 'Simpanan', 'icon': Icons.savings_outlined, 'color': '#A855F7'},
  {'id': 'retirement', 'label': 'Masa Tua', 'icon': Icons.elderly_outlined, 'color': '#D4F442'},
  {'id': 'emergency', 'label': 'Dana Darurat', 'icon': Icons.shield_outlined, 'color': '#7DF24E'},
  {'id': 'goal', 'label': 'Target / Impian', 'icon': Icons.flag_outlined, 'color': '#26D9D9'},
];

class PocketTypeSelector extends StatelessWidget {
  final String selectedType;
  final ValueChanged<String> onSelectType;

  const PocketTypeSelector({
    super.key,
    required this.selectedType,
    required this.onSelectType,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: kPocketTypes.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final t = kPocketTypes[index];
          final isSelected = t['id'] == selectedType;
          final Color typeColor = Color(int.parse((t['color'] as String).replaceAll('#', '0xFF')));

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              HapticFeedback.selectionClick();
              onSelectType(t['id'] as String);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? typeColor.withValues(alpha: 0.18) : AppColors.canvasInputSearch,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? typeColor : AppColors.canvasBorder,
                  width: isSelected ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(t['icon'] as IconData, size: 16, color: isSelected ? typeColor : AppColors.textMuted),
                  const SizedBox(width: 6),
                  Text(
                    t['label'] as String,
                    style: TextStyle(
                      color: isSelected ? typeColor : AppColors.textMuted,
                      fontSize: 12.5,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  static Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    String? errorText,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      style: AppTypography.listTitle,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        errorText: errorText,
        filled: true,
        fillColor: AppColors.canvasInputSearch,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    );
  }
}
