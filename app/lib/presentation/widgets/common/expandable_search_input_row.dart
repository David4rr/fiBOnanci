import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// The 46px search input row with search icon, textfield, clear action, and rotating tune button.
class ExpandableSearchInputRow extends StatelessWidget {
  final TextEditingController searchController;
  final String searchQuery;
  final String hintText;
  final bool isExpanded;
  final bool hasActiveFilter;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final VoidCallback onToggleExpanded;

  const ExpandableSearchInputRow({
    super.key,
    required this.searchController,
    required this.searchQuery,
    required this.hintText,
    required this.isExpanded,
    required this.hasActiveFilter,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onToggleExpanded,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            const Icon(Icons.search, color: AppColors.textMuted, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: searchController,
                style: const TextStyle(color: AppColors.textWhite, fontSize: 13.5),
                onChanged: onSearchChanged,
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12.5),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            if (searchQuery.isNotEmpty)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onClearSearch,
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.close, color: AppColors.textMuted, size: 16),
                ),
              ),
            const SizedBox(width: 6),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onToggleExpanded,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: (isExpanded || hasActiveFilter)
                      ? AppColors.neoChartreuse.withValues(alpha: 0.2)
                      : Colors.transparent,
                ),
                child: AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.fastOutSlowIn,
                  child: Icon(
                    Icons.tune,
                    color: (isExpanded || hasActiveFilter)
                        ? AppColors.neoChartreuse
                        : AppColors.textWhite,
                    size: 17,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
