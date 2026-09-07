import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import 'expandable_search_filter_bar.dart';
import 'expandable_search_filter_panel.dart';
import 'expandable_search_input_row.dart';

/// Floating overlay morphing container that seamlessly expands the search bar
/// on top of subsequent widgets without pushing them down.
class ExpandableSearchDropdownOverlay extends StatelessWidget {
  final ExpandableSearchFilterBar bar;
  final LayerLink layerLink;
  final double width;
  final Animation<double> animation;
  final String tempType;
  final String? tempWalletId;
  final bool hasActiveFilter;
  final ValueChanged<String> onSelectType;
  final ValueChanged<String?> onSelectWallet;
  final VoidCallback onReset, onApply, onClose;

  const ExpandableSearchDropdownOverlay({
    super.key,
    required this.bar,
    required this.layerLink,
    required this.width,
    required this.animation,
    required this.tempType,
    required this.tempWalletId,
    required this.hasActiveFilter,
    required this.onSelectType,
    required this.onSelectWallet,
    required this.onReset,
    required this.onApply,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final hasPendingChange = tempType != 'all' || tempWalletId != null;

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: onClose,
            child: const SizedBox.expand(),
          ),
        ),
        CompositedTransformFollower(
          link: layerLink,
          showWhenUnlinked: false,
          offset: Offset.zero,
          child: Align(
            alignment: Alignment.topLeft,
            child: AnimatedBuilder(
              animation: animation,
              builder: (context, _) {
                final progress = animation.value;
                final currentRadius = bar.borderRadius + (16.0 - bar.borderRadius) * progress;
                final borderColor = Color.lerp(
                  hasActiveFilter
                      ? AppColors.neoChartreuse.withValues(alpha: 0.5)
                      : AppColors.canvasBorder,
                  AppColors.neoChartreuse.withValues(alpha: 0.6),
                  progress,
                )!;

                return Material(
                  color: Colors.transparent,
                  child: Container(
                    width: width,
                    decoration: BoxDecoration(
                      color: AppColors.canvasInputSearch,
                      borderRadius: BorderRadius.circular(currentRadius),
                      border: Border.all(color: borderColor, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.55 * progress),
                          blurRadius: 20 * progress + 4,
                          offset: Offset(0, 8 * progress),
                        ),
                        if (progress > 0.05)
                          BoxShadow(
                            color: AppColors.neoChartreuse.withValues(alpha: 0.06 * progress),
                            blurRadius: 12,
                            offset: const Offset(0, 2),
                          ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ExpandableSearchInputRow(
                          searchController: bar.searchController,
                          searchQuery: bar.searchQuery,
                          hintText: bar.hintText,
                          isExpanded: true,
                          hasActiveFilter: hasActiveFilter,
                          onSearchChanged: bar.onSearchChanged,
                          onClearSearch: bar.onClearSearch,
                          onToggleExpanded: onClose,
                        ),
                        Opacity(
                          opacity: ((progress - 0.15) / 0.85).clamp(0.0, 1.0),
                          child: Container(
                            height: 1,
                            color: AppColors.canvasBorder.withValues(alpha: 0.4),
                          ),
                        ),
                        ClipRect(
                          child: Align(
                            alignment: Alignment.topCenter,
                            heightFactor: progress,
                            child: Opacity(
                              opacity: ((progress - 0.25) / 0.75).clamp(0.0, 1.0),
                              child: ExpandableSearchFilterPanel(
                                headerTitle: bar.headerTitle,
                                primaryFilterTitle: bar.primaryFilterTitle,
                                primaryFilterChoices: bar.primaryFilterChoices,
                                tempType: tempType,
                                tempWalletId: tempWalletId,
                                wallets: bar.wallets,
                                showWalletFilter: bar.showWalletFilter,
                                hasPendingChange: hasPendingChange,
                                onSelectType: onSelectType,
                                onSelectWallet: onSelectWallet,
                                onReset: onReset,
                                onApply: onApply,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
