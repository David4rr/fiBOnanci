import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Standard maximum viewport width matching modern iPhone Pro Max dimensions (430pt).
/// Prevents full-screen horizontal stretching on wide viewports (tablets, desktops, web).
const double kMaxIPhoneViewportWidth = 430.0;

/// A layout container that constrains width to iPhone viewport dimensions and
/// disables full-screen stretching on wide screens.
///
/// On wider viewports (e.g. tablets, desktop, web), the container centers the content
/// horizontally, constrains the maximum width to [maxWidth], overrides [MediaQueryData.size]
/// to match the clamped width, and fills the outer area with [backgroundColor] (Obsidian canvas).
/// On standard mobile viewports (<= [maxWidth]), it passes through the natural screen width.
class IPhoneViewportContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final Color? backgroundColor;

  const IPhoneViewportContainer({
    super.key,
    required this.child,
    this.maxWidth = kMaxIPhoneViewportWidth,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.maybeOf(context);
    final currentWidth = mediaQuery?.size.width ?? double.infinity;
    final isStretched = currentWidth > maxWidth;
    final clampedWidth = isStretched ? maxWidth : currentWidth;

    Widget content = child;
    if (mediaQuery != null && isStretched) {
      content = MediaQuery(
        data: mediaQuery.copyWith(
          size: Size(clampedWidth, mediaQuery.size.height),
          padding: mediaQuery.padding.copyWith(left: 0, right: 0),
          viewPadding: mediaQuery.viewPadding.copyWith(left: 0, right: 0),
        ),
        child: content,
      );
    }

    return Container(
      color: backgroundColor ?? AppColors.canvasBg,
      alignment: Alignment.center,
      child: ClipRect(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: SizedBox(
            width: clampedWidth,
            child: content,
          ),
        ),
      ),
    );
  }
}
