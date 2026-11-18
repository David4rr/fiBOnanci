import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/category_icon_resolver.dart';

class CategoryIconPicker extends StatelessWidget {
  final String selectedIcon;
  final ValueChanged<String> onIconChanged;
  final Color? accentColor;

  const CategoryIconPicker({
    super.key,
    required this.selectedIcon,
    required this.onIconChanged,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = accentColor ?? AppColors.neoChartreuse;
    final currentItem = CategoryIconResolver.availableIcons.firstWhere(
      (item) => item.id == selectedIcon,
      orElse: () => CategoryIconResolver.availableIcons.first,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'PILIH IKON',
              style: AppTypography.badgeLabel.copyWith(
                color: Colors.white38,
                letterSpacing: 1.2,
                fontSize: 10,
              ),
            ),
            Row(
              children: [
                Icon(currentItem.icon, size: 13, color: activeColor),
                const SizedBox(width: 4),
                Text(
                  currentItem.label,
                  style: AppTypography.badgeLabel.copyWith(
                    color: activeColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 48,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: CategoryIconResolver.availableIcons.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final item = CategoryIconResolver.availableIcons[index];
              final isSelected = item.id == selectedIcon;

              return GestureDetector(
                key: Key('category_icon_${item.id}'),
                behavior: HitTestBehavior.opaque,
                onTap: () => onIconChanged(item.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? activeColor.withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? activeColor : Colors.white.withValues(alpha: 0.08),
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      item.icon,
                      size: 20,
                      color: isSelected ? activeColor : Colors.white60,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
