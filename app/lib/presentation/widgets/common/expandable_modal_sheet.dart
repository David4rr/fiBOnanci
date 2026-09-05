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
  final double initialChildSize;
  final double minChildSize;
  final double maxChildSize;
  final List<double> snapSizes;
  final Color backgroundColor;
  final Color borderColor;
  final double topRadius;
  final ExpandableModalBuilder builder;
  final DraggableScrollableController? controller;

  const ExpandableModalSheet({
    super.key,
    this.initialChildSize = 1.0,
    this.minChildSize = 0.40,
    this.maxChildSize = 1.0,
    this.snapSizes = const [0.85, 1.0],
    this.backgroundColor = AppColors.canvasBg,
    this.borderColor = AppColors.canvasBorder,
    this.topRadius = 16.0,
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
  DraggableScrollableController get controller => _sheetController;
  double get currentSize => _currentSize;

  void _dismiss() {
    if (_isDismissing || !mounted) return;
    _isDismissing = true;
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _sheetController = widget.controller!;
    } else {
      _sheetController = DraggableScrollableController();
      _isInternalController = true;
    }
    _currentSize = widget.initialChildSize;
    _sheetController.addListener(_onSheetSizeChanged);
  }

  void _onSheetSizeChanged() {
    if (!_sheetController.isAttached) return;
    final newSize = _sheetController.size;
    if ((newSize - _currentSize).abs() > 0.005) {
      setState(() => _currentSize = newSize);
    }
  }

  @override
  void dispose() {
    _sheetController.removeListener(_onSheetSizeChanged);
    if (_isInternalController) {
      _sheetController.dispose();
    }
    super.dispose();
  }

  void handleHeaderDragUpdate(DragUpdateDetails details) {
    if (!_sheetController.isAttached) return;
    final screenHeight = MediaQuery.of(context).size.height;
    if (screenHeight <= 0) return;
    final deltaFraction = details.primaryDelta! / screenHeight;
    final newSize = (_sheetController.size - deltaFraction).clamp(widget.minChildSize, widget.maxChildSize);
    _sheetController.jumpTo(newSize);
  }

  void handleHeaderDragEnd(DragEndDetails details) {
    if (!_sheetController.isAttached) return;
    final velocity = details.primaryVelocity ?? 0.0;
    final size = _sheetController.size;

    if (size <= (widget.minChildSize + 0.12) || velocity > 650.0) {
      _dismiss();
    } else if (size >= (widget.snapSizes.last - 0.08) || velocity < -650.0) {
      _sheetController.animateTo(
        widget.maxChildSize,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    } else {
      _sheetController.animateTo(
        widget.snapSizes.first,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFullScreen = _currentSize >= 0.99;
    final currentRadius = isFullScreen ? 0.0 : widget.topRadius;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).pop(),
              child: const SizedBox.expand(),
            ),
          ),
          NotificationListener<DraggableScrollableNotification>(
            onNotification: (notification) {
              if (notification.extent <= (widget.minChildSize + 0.05)) {
                _dismiss();
                return true;
              }
              return false;
            },
            child: DraggableScrollableSheet(
              controller: _sheetController,
              initialChildSize: widget.initialChildSize,
              minChildSize: widget.minChildSize,
              maxChildSize: widget.maxChildSize,
              snap: true,
              snapSizes: widget.snapSizes,
              builder: (ctx, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: widget.backgroundColor,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(currentRadius)),
                    border: Border.all(color: widget.borderColor, width: 1),
                  ),
                  child: SafeArea(
                    top: isFullScreen,
                    bottom: true,
                    child: widget.builder(ctx, scrollController, _currentSize),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
