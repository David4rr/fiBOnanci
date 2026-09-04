import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class PrimaryActionButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color foregroundColor;
  final double height;
  final double borderRadius;
  final bool isLoading;
  final IconData? icon;
  final TextStyle? textStyle;

  const PrimaryActionButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor = AppColors.neoChartreuse,
    this.foregroundColor = AppColors.textDarkPrimary,
    this.height = 52,
    this.borderRadius = 16,
    this.isLoading = false,
    this.icon,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final style = textStyle ??
        AppTypography.listTitle.copyWith(
          color: foregroundColor,
          fontWeight: FontWeight.w800,
        );

    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
          elevation: 0,
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: foregroundColor,
                ),
              )
            : icon != null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 20, color: foregroundColor),
                      const SizedBox(width: 8),
                      Text(text, style: style),
                    ],
                  )
                : Text(text, style: style),
      ),
    );
  }
}
