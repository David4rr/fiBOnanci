import 'package:flutter/material.dart';

/// Shared page-to-page transition container that wraps [PageView] with
/// GPU-composited [RepaintBoundary], synchronized opacity cross-fade, and
/// subtle depth scaling (`0.96 -> 1.0`) driven by [PageController].
class SmoothPageView extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return PageView(
      controller: controller,
      allowImplicitScrolling: allowImplicitScrolling,
      physics: physics,
      onPageChanged: onPageChanged,
      children: [
        for (int index = 0; index < children.length; index++)
          AnimatedBuilder(
            animation: controller,
            child: RepaintBoundary(child: children[index]),
            builder: (context, child) {
              double page = controller.initialPage.toDouble();
              if (controller.hasClients && controller.position.haveDimensions) {
                page = controller.page ?? page;
              }
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
