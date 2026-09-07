import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../data/database/app_database.dart';
import 'expandable_search_active_chips.dart';
import 'expandable_search_dropdown_overlay.dart';
import 'expandable_search_resting_bar.dart';
import 'filter_choice.dart';

export 'filter_choice.dart';

/// Floating morphing search bar whose dropdown container expands seamlessly
/// on top of subsequent widgets without pushing them down.
class ExpandableSearchFilterBar extends StatefulWidget {
  final TextEditingController searchController;
  final String searchQuery, typeFilter, hintText, headerTitle, primaryFilterTitle;
  final String? walletFilter;
  final List<WalletEntry> wallets;
  final bool showWalletFilter, showActiveChipsBelow;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final void Function(String type, String? walletId) onFilterApplied;
  final VoidCallback? onClearTypeFilter, onClearWalletFilter;
  final List<FilterChoice> primaryFilterChoices;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  const ExpandableSearchFilterBar({
    super.key,
    required this.searchController,
    required this.searchQuery,
    required this.typeFilter,
    this.walletFilter,
    this.wallets = const [],
    this.showWalletFilter = true,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onFilterApplied,
    this.onClearTypeFilter,
    this.onClearWalletFilter,
    this.hintText = 'Cari transaksi, rekening, merchant...',
    this.headerTitle = 'Filter Transaksi',
    this.primaryFilterTitle = 'TIPE TRANSAKSI',
    this.primaryFilterChoices = kDefaultTransactionTypeChoices,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    this.borderRadius = 10,
    this.showActiveChipsBelow = true,
  });

  @override
  State<ExpandableSearchFilterBar> createState() => _ExpandableSearchFilterBarState();
}

class _ExpandableSearchFilterBarState extends State<ExpandableSearchFilterBar>
    with SingleTickerProviderStateMixin {
  final _overlayController = OverlayPortalController();
  final _layerLink = LayerLink();
  late final AnimationController _animController;
  late final Animation<double> _expandAnimation;
  bool _isExpanded = false;
  late String _tempType;
  late String? _tempWalletId;

  @override
  void initState() {
    super.initState();
    _syncTemp();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _expandAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeInCubic,
    );
  }

  @override
  void didUpdateWidget(covariant ExpandableSearchFilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isExpanded) _syncTemp();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _syncTemp() { _tempType = widget.typeFilter; _tempWalletId = widget.walletFilter; }

  void _openOverlay() {
    FocusScope.of(context).unfocus();
    _syncTemp();
    setState(() => _isExpanded = true);
    _overlayController.show();
    _animController.forward(from: 0.0);
  }

  void _closeOverlay({VoidCallback? onComplete}) {
    if (!_isExpanded) return;
    _animController.reverse().then((_) {
      if (mounted) {
        setState(() => _isExpanded = false);
        _overlayController.hide();
        onComplete?.call();
      }
    });
  }

  void _toggleExpanded() {
    HapticFeedback.selectionClick();
    _isExpanded ? _closeOverlay() : _openOverlay();
  }

  void _applyFilter() {
    HapticFeedback.mediumImpact();
    widget.onFilterApplied(_tempType, _tempWalletId);
    _closeOverlay();
  }

  void _resetFilter() {
    HapticFeedback.selectionClick();
    setState(() { _tempType = 'all'; _tempWalletId = null; });
    widget.onFilterApplied('all', null);
    _closeOverlay();
  }

  String get _typeChipLabel => widget.primaryFilterChoices
      .cast<FilterChoice?>()
      .firstWhere((c) => c?.value == widget.typeFilter, orElse: () => null)
      ?.chipLabel ?? 'Tipe: ${widget.typeFilter.toUpperCase()}';

  @override
  Widget build(BuildContext context) {
    final hasActiveFilter = widget.typeFilter != 'all' || widget.walletFilter != null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final pad = widget.padding.resolve(Directionality.of(context));
        final barWidth = constraints.maxWidth.isFinite ? constraints.maxWidth - pad.horizontal : 360.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: widget.padding,
              child: CompositedTransformTarget(
                link: _layerLink,
                child: OverlayPortal(
                  controller: _overlayController,
                  overlayChildBuilder: (context) => ExpandableSearchDropdownOverlay(
                    bar: widget,
                    layerLink: _layerLink,
                    width: barWidth,
                    animation: _expandAnimation,
                    tempType: _tempType,
                    tempWalletId: _tempWalletId,
                    hasActiveFilter: hasActiveFilter,
                    onSelectType: (t) => setState(() => _tempType = t),
                    onSelectWallet: (w) => setState(() => _tempWalletId = w),
                    onReset: _resetFilter,
                    onApply: _applyFilter,
                    onClose: _closeOverlay,
                  ),
                  child: ExpandableSearchRestingBar(
                    searchController: widget.searchController,
                    searchQuery: widget.searchQuery,
                    hintText: widget.hintText,
                    borderRadius: widget.borderRadius,
                    isExpanded: _isExpanded,
                    hasActiveFilter: hasActiveFilter,
                    onSearchChanged: widget.onSearchChanged,
                    onClearSearch: widget.onClearSearch,
                    onToggleExpanded: _toggleExpanded,
                  ),
                ),
              ),
            ),
            if (widget.showActiveChipsBelow && hasActiveFilter && !_isExpanded)
              ExpandableSearchActiveChips(
                typeChipLabel: _typeChipLabel,
                hasTypeFilter: widget.typeFilter != 'all',
                walletFilter: widget.walletFilter,
                wallets: widget.wallets,
                onClearType: widget.onClearTypeFilter ?? () => widget.onFilterApplied('all', widget.walletFilter),
                onClearWallet: widget.onClearWalletFilter ?? () => widget.onFilterApplied(widget.typeFilter, null),
              ),
          ],
        );
      },
    );
  }
}
