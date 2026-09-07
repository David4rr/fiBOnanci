import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import 'expandable_search_input_row.dart';

/// Fixed 46px resting container that anchors the search bar in layout flow.
class ExpandableSearchRestingBar extends StatelessWidget {
  final TextEditingController searchController;
  final String searchQuery, hintText;
  final double borderRadius;
  final bool isExpanded, hasActiveFilter;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch, onToggleExpanded;

  const ExpandableSearchRestingBar({
    super.key,
    required this.searchController,
    required this.searchQuery,
    required this.hintText,
    required this.borderRadius,
    required this.isExpanded,
    required this.hasActiveFilter,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onToggleExpanded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 46),
      height: 46,
      decoration: BoxDecoration(
        color: AppColors.canvasInputSearch,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: searchQuery.isNotEmpty || hasActiveFilter
              ? AppColors.neoChartreuse.withValues(alpha: 0.5)
              : AppColors.canvasBorder,
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Visibility(
        visible: !isExpanded,
        maintainSize: true,
        maintainAnimation: true,
        maintainState: true,
        child: ExpandableSearchInputRow(
          searchController: searchController,
          searchQuery: searchQuery,
          hintText: hintText,
          isExpanded: false,
          hasActiveFilter: hasActiveFilter,
          onSearchChanged: onSearchChanged,
          onClearSearch: onClearSearch,
          onToggleExpanded: onToggleExpanded,
        ),
      ),
    );
  }
}
