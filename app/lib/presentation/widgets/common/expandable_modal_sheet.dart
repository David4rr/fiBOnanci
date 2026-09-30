import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

typedef ExpandableModalBuilder = Widget Function(
  BuildContext context,
  ScrollController scrollController,
  double currentSize,
);

/// A reusable expandable modal sheet that starts at [initialChildSize] (default 85%)
/// and smoothly expands to full screen (100%) when dragged or scrolled up.
/// Dragging down past [minChildSize] or tapping the backdrop dismisses the sheet.
class ExpandableModalSheet extends StatefulWidget {
  final double initialChildSize, minChildSize, maxChildSize, topRadius;
  final List<double> snapSizes;
  final Color backgroundColor, borderColor;
  final ExpandableModalBuilder builder;
  final DraggableScrollableController? controller;

  const ExpandableModalSheet({
    super.key,
    this.initialChildSize = 1.0,
    this.minChildSize = 0.25,
    this.maxChildSize = 1.0,
    this.snapSizes = const [0.85, 1.0],
    this.backgroundColor = AppColors.canvasBg,
    this.borderColor = AppColors.canvasBorder,
    this.topRadius = 28.0,
    this.controller,
    required this.builder,
  });

  @override
  State<ExpandableModalSheet> createState() => ExpandableModalSheetState();
}
class ExpandableModalSheetState extends State<ExpandableModalSheet> {
  late final DraggableScrollableController _sheetController;
  late double _currentSize;
  bool _isInternalController = false;
  bool _isDismissing = false;
  double _dragStartSize = 1.0;
  bool _isDragging = false;
  double _dragOffset = 0.0;
  DraggableScrollableController get controller => _sheetController;
  double get currentSize => _currentSize;
  double get _baseSize => widget.initialChildSize < widget.maxChildSize
      ? widget.initialChildSize
      : (widget.snapSizes.isNotEmpty ? widget.snapSizes.first : 0.85);

  void _dismiss() {
    if (_isDismissing || !mounted) return;
    _isDismissing = true;
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
    _sheetController = widget.controller ?? DraggableScrollableController();
    _isInternalController = widget.controller == null;
    _currentSize = widget.initialChildSize;
    _sheetController.addListener(_onSheetSizeChanged);
  }

  void _onSheetSizeChanged() {
    if (!_sheetController.isAttached) return;
    final newSize = _sheetController.size;
    if ((newSize - _currentSize).abs() > 0.005) setState(() => _currentSize = newSize);
  }

  @override
  void dispose() {
    _sheetController.removeListener(_onSheetSizeChanged);
    if (_isInternalController) _sheetController.dispose();
    super.dispose();
  }
  void handleHeaderDragStart(DragStartDetails details) {
    if (_isDismissing) return;
    _isDragging = true;
    if (_sheetController.isAttached) {
      _dragStartSize = _sheetController.size;
    }
  }

  void handleHeaderDragUpdate(DragUpdateDetails details) {
    if (_isDismissing) return;
    final delta = details.primaryDelta ?? 0.0;
    if (!_sheetController.isAttached) {
      _isDragging = true;
      setState(() => _dragOffset = (_dragOffset + delta).clamp(0.0, 1000.0));
      return;
    }
    if (!_isDragging) {
      _dragStartSize = _sheetController.size;
      _isDragging = true;
    }
    if ((_sheetController.size <= (_baseSize + 0.02) && delta > 0) || _dragOffset > 0) {
      setState(() => _dragOffset = (_dragOffset + delta).clamp(0.0, 1000.0));
      return;
    }
    final screenHeight = MediaQuery.of(context).size.height;
    if (screenHeight <= 0) return;
    final deltaFraction = delta / screenHeight;
    final newSize = (_sheetController.size - deltaFraction).clamp(widget.minChildSize, widget.maxChildSize);
    _sheetController.jumpTo(newSize);
  }

  void handleHeaderDragEnd(DragEndDetails details) {
    if (_isDismissing) return;
    _isDragging = false;
    final velocity = details.primaryVelocity ?? 0.0;

    if (_dragOffset > 0) {
      if (velocity > 160.0 || _dragOffset > 50.0) {
        _dismiss();
        return;
      }
      setState(() => _dragOffset = 0.0);
      return;
    }

    if (!_sheetController.isAttached) return;
    final size = _sheetController.size;
    final baseSize = _baseSize;
    final wasAtMax = _dragStartSize >= (widget.maxChildSize - 0.04);

    if (velocity > 160.0 && (!wasAtMax || velocity > 350.0)) { _dismiss(); return; }
    if (velocity < -160.0) { _sheetController.animateTo(widget.maxChildSize, duration: const Duration(milliseconds: 220), curve: Curves.easeOutCubic); return; }
    if (!wasAtMax && (size < (_dragStartSize - 0.04) || size <= (widget.minChildSize + 0.08))) { _dismiss(); return; }
    if (wasAtMax && (size <= (widget.minChildSize + 0.08) || size < (baseSize - 0.22))) { _dismiss(); return; }
    if (size >= (widget.maxChildSize - 0.05)) { _sheetController.animateTo(widget.maxChildSize, duration: const Duration(milliseconds: 220), curve: Curves.easeOutCubic); return; }
    _sheetController.animateTo(baseSize, duration: const Duration(milliseconds: 220), curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    final effectiveSnap = (widget.snapSizes.toSet().toList()..sort());
    if (effectiveSnap.length == 1 && effectiveSnap.first == 1.0) effectiveSnap.insert(0, 0.85);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => Navigator.of(context).pop(), child: const SizedBox.expand())),
          NotificationListener<DraggableScrollableNotification>(
            onNotification: (n) { if (n.extent <= (widget.minChildSize + 0.05)) { _dismiss(); return true; } return false; },
            child: AnimatedContainer(
              duration: _isDragging ? Duration.zero : const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              transform: Matrix4.translationValues(0, _dragOffset, 0),
              child: DraggableScrollableSheet(
                controller: _sheetController,
                initialChildSize: widget.initialChildSize,
                minChildSize: widget.minChildSize,
                maxChildSize: widget.maxChildSize,
                snap: true,
                snapSizes: effectiveSnap,
                builder: (ctx, scrollController) => Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: widget.backgroundColor,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(widget.topRadius)),
                    border: Border.all(color: widget.borderColor, width: 1),
                  ),
                  child: SafeArea(top: true, bottom: true, child: widget.builder(ctx, scrollController, _currentSize)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
