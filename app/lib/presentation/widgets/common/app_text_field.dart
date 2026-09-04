import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextStyle? hintStyle;
  final TextStyle? style;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final ValueChanged<String>? onChanged;
  final int maxLines;
  final bool autofocus;
  final double borderRadius;
  final Color fillColor;
  final String? errorText;

  const AppTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.hintStyle,
    this.style,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.onChanged,
    this.maxLines = 1,
    this.autofocus = false,
    this.borderRadius = 16,
    this.fillColor = AppColors.canvasInputSearch,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      autofocus: autofocus,
      maxLines: maxLines,
      onChanged: onChanged,
      style: style ?? AppTypography.listTitle,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: hintStyle ?? AppTypography.listSubtitle,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        errorText: errorText,
        filled: true,
        fillColor: fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
