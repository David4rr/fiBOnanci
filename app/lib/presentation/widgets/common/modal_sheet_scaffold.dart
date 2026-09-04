import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class ModalSheetScaffold extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color backgroundColor;
  final Color borderColor;
  final double topRadius;
  final bool applyKeyboardInset;

  const ModalSheetScaffold({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor = AppColors.canvasCardSurface,
    this.borderColor = AppColors.canvasBorder,
    this.topRadius = 28,
    this.applyKeyboardInset = true,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = applyKeyboardInset ? MediaQuery.of(context).viewInsets.bottom : 0.0;
    final defaultPadding = EdgeInsets.fromLTRB(20, 12, 20, bottomInset + 24);

    return Container(
      padding: padding ?? defaultPadding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(topRadius)),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: SafeArea(
        top: false,
        child: child,
      ),
    );
  }
}
