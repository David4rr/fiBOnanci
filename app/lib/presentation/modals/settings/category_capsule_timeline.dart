import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../bloc/finance/finance_bloc.dart';
import '../../../data/database/app_database.dart';
import '../../theme/app_colors.dart';
import '../../theme/category_icon_resolver.dart';
import 'category_capsule_peek_card.dart';

class CategoryCapsuleTimeline extends StatelessWidget {
  final List<CategoryEntry> categories;
  final String? selectedCategoryId;
  final ValueChanged<String> onSelectCategory;
  final ValueChanged<CategoryEntry> onEditCategory;
  final ValueChanged<CategoryEntry> onDeleteCategory;

  const CategoryCapsuleTimeline({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onSelectCategory,
    required this.onEditCategory,
    required this.onDeleteCategory,
  });

  Color _parseColor(String hex) {
    final cleaned = hex.replaceAll('#', '').trim();
    final val = int.tryParse(cleaned.length == 6 ? 'FF$cleaned' : cleaned, radix: 16);
    return val != null ? Color(val) : AppColors.neoChartreuse;
  }

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();
    final txs = context.watch<FinanceBloc>().state.transactions;
    final counts = <String, int>{};
    final totals = <String, double>{};
    for (final t in txs) {
      if (t.isDeleted) continue;
      counts[t.categoryId] = (counts[t.categoryId] ?? 0) + 1;
      totals[t.categoryId] = (totals[t.categoryId] ?? 0.0) + t.amount;
    }
    final maxCount = counts.values.fold<int>(1, (a, b) => a > b ? a : b);
    final selected = categories.firstWhere((c) => c.id == selectedCategoryId, orElse: () => categories.first);
    const colCount = 4;
    final columns = List.generate(colCount, (c) => <CategoryEntry>[
      for (int i = c; i < categories.length; i += colCount) categories[i],
    ]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSpectrumBar(categories),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int c = 0; c < colCount; c++)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _buildColumnTrack(columns[c], c, counts, maxCount, selected.id),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        CategoryCapsulePeekCard(
          category: selected,
          color: _parseColor(selected.colorHex),
          txCount: counts[selected.id] ?? 0,
          totalAmount: totals[selected.id] ?? 0.0,
          canDelete: categories.length > 1,
          onEdit: () => onEditCategory(selected),
          onDelete: () => onDeleteCategory(selected),
        ),
      ],
    );
  }

  Widget _buildSpectrumBar(List<CategoryEntry> items) {
    final colors = items.map((e) => _parseColor(e.colorHex)).toList();
    if (colors.length == 1) colors.add(colors.first.withValues(alpha: 0.6));
    return Container(
      height: 10,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: LinearGradient(colors: colors),
      ),
    );
  }

  Widget _stem(double height, Color top, Color bottom, {double width = 2.5}) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(2),
      gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [top, bottom]),
    ),
  );

  Widget _buildColumnTrack(List<CategoryEntry> colItems, int colIndex, Map<String, int> counts, int maxCount, String activeId) {
    if (colItems.isEmpty) return const SizedBox.shrink();
    return Column(
      children: [
        _stem(colIndex.isOdd ? 24 : 10, Colors.transparent, _parseColor(colItems.first.colorHex).withValues(alpha: 0.75)),
        for (int i = 0; i < colItems.length; i++) ...[
          _buildCapsule(colItems[i], counts[colItems[i].id] ?? 0, maxCount, colItems[i].id == activeId, i),
          if (i < colItems.length - 1)
            _stem(20, _parseColor(colItems[i].colorHex), _parseColor(colItems[i + 1].colorHex), width: 3)
          else
            _stem(16, _parseColor(colItems[i].colorHex).withValues(alpha: 0.75), Colors.transparent),
        ],
      ],
    );
  }

  Widget _buildCapsule(CategoryEntry cat, int count, int maxCount, bool isSelected, int rowIndex) {
    final color = _parseColor(cat.colorHex);
    final isDarkIcon = ThemeData.estimateBrightnessForColor(color) == Brightness.light;
    final ratio = maxCount > 0 ? (count / maxCount).clamp(0.0, 1.0) : 0.0;
    final baseHeight = count > 0 ? (58.0 + ratio * 44.0) : (56.0 + ((rowIndex % 2) * 14.0));

    return GestureDetector(
      key: Key('settings_cat_capsule_${cat.id}'),
      onTap: () {
        HapticFeedback.selectionClick();
        onSelectCategory(cat.id);
      },
      onLongPress: () {
        HapticFeedback.mediumImpact();
        onSelectCategory(cat.id);
        onEditCategory(cat);
      },
      child: AnimatedScale(
        scale: isSelected ? 1.06 : 1.0,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutBack,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          width: 54,
          height: baseHeight,
          decoration: BoxDecoration(
            color: isSelected ? color : color.withValues(alpha: 0.84),
            borderRadius: BorderRadius.circular(999),
            border: isSelected ? Border.all(color: Colors.white, width: 2.2) : null,
            boxShadow: isSelected
                ? [BoxShadow(color: color.withValues(alpha: 0.42), blurRadius: 14, spreadRadius: 1)]
                : null,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                CategoryIconResolver.mapCategoryIcon(cat.iconName),
                size: 22,
                color: isDarkIcon ? const Color(0xFF0C0D11) : Colors.white,
              ),
              if (count > 0)
                Positioned(
                  bottom: 7,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$count',
                      style: GoogleFonts.plusJakartaSans(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
