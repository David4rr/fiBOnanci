import 'package:flutter/material.dart';

/// Shared page-to-page transition container that wraps [PageView] with
/// GPU-composited [RepaintBoundary], synchronized opacity cross-fade, and
/// subtle depth scaling (`0.96 -> 1.0`) driven by [PageController].
class SmoothPageView extends StatefulWidget {
  static const Duration defaultDuration = Duration(milliseconds: 340);
  static const Curve defaultCurve = Cubic(0.22, 1.0, 0.36, 1.0);

  final PageController controller;
  final List<Widget> children;
  final bool allowImplicitScrolling;
  final ScrollPhysics physics;
  final ValueChanged<int>? onPageChanged;

  const SmoothPageView({
    super.key,
    required this.controller,
    required this.children,
    this.allowImplicitScrolling = true,
    this.physics = const NeverScrollableScrollPhysics(),
    this.onPageChanged,
  });

  static Future<void> animateTo(PageController controller, int page) {
    if (!controller.hasClients) return Future<void>.value();
    return controller.animateToPage(
      page,
      duration: defaultDuration,
      curve: defaultCurve,
    );
  }

  static Widget headerTitleTransition(Widget child, Animation<double> animation) {
    final slide = Tween<Offset>(
      begin: const Offset(0.035, 0.0),
      end: Offset.zero,
    ).animate(animation);
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(position: slide, child: child),
    );
  }

  @override
  State<SmoothPageView> createState() => _SmoothPageViewState();
}

class _SmoothPageViewState extends State<SmoothPageView> {
  late double _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.controller.initialPage.toDouble();
    widget.controller.addListener(_handleScroll);
  }

  @override
  void didUpdateWidget(covariant SmoothPageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleScroll);
      widget.controller.addListener(_handleScroll);
      _syncCurrentPage();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleScroll);
    super.dispose();
  }

  void _handleScroll() {
    _syncCurrentPage();
  }

  void _syncCurrentPage() {
    if (widget.controller.hasClients &&
        widget.controller.positions.length == 1 &&
        widget.controller.position.haveDimensions) {
      final p = widget.controller.page;
      if (p != null && (p - _currentPage).abs() > 0.0001) {
        _currentPage = p;
      }
    }
  }

  double _resolveCurrentPage() {
    _syncCurrentPage();
    return _currentPage;
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: widget.controller,
      allowImplicitScrolling: widget.allowImplicitScrolling,
      physics: widget.physics,
      onPageChanged: widget.onPageChanged,
      children: [
        for (int index = 0; index < widget.children.length; index++)
          AnimatedBuilder(
            animation: widget.controller,
            child: RepaintBoundary(child: widget.children[index]),
            builder: (context, child) {
              final page = _resolveCurrentPage();
              final delta = (page - index).abs().clamp(0.0, 1.0);
              if (delta <= 0.001) return child!;
              final opacity = (1.0 - (delta * 0.5)).clamp(0.0, 1.0);
              final scale = 1.0 - (delta * 0.04);
              return Opacity(
                opacity: opacity,
                child: Transform.scale(
                  scale: scale,
                  alignment: Alignment.center,
                  child: child,
                ),
              );
            },
          ),
      ],
    );
  }
}
