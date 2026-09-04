import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class ModalGrabHandle extends StatelessWidget {
  final double width;
  final double height;
  final Color? color;
  final double radius;
  final EdgeInsetsGeometry padding;

  const ModalGrabHandle({
    super.key,
    this.width = 40,
    this.height = 4,
    this.color,
    this.radius = 2,
    this.padding = const EdgeInsets.only(bottom: 14),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Center(
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: color ?? AppColors.textSubtle,
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),
    );
  }
}
