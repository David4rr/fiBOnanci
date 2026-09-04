import 'package:flutter/material.dart';

import '../../../core/formatters/rupiah_input_formatter.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class CurrencyAmountField extends StatelessWidget {
  final TextEditingController controller;
  final Color? prefixColor;
  final bool autofocus;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final TextStyle? style;
  final TextStyle? prefixStyle;
  final double borderRadius;
  final Color fillColor;

  const CurrencyAmountField({
    super.key,
    required this.controller,
    this.prefixColor,
    this.autofocus = false,
    this.focusNode,
    this.onChanged,
    this.style,
    this.prefixStyle,
    this.borderRadius = 16,
    this.fillColor = AppColors.canvasInputSearch,
  });

  @override
  Widget build(BuildContext context) {
    final effectivePrefixColor = prefixColor ?? AppColors.neoChartreuse;
    final effectiveStyle = style ?? AppTypography.heroGreeting.copyWith(color: AppColors.textWhite);
    final effectivePrefixStyle = prefixStyle ?? AppTypography.heroGreeting.copyWith(color: effectivePrefixColor);

    return TextField(
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus,
      keyboardType: TextInputType.number,
      inputFormatters: [RupiahInputFormatter()],
      style: effectiveStyle,
      onChanged: onChanged,
      decoration: InputDecoration(
        prefixText: 'Rp ',
        prefixStyle: effectivePrefixStyle,
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
