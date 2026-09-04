import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class ModalHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onClose;
  final bool showCloseButton;
  final Color closeIconColor;
  final double closeIconSize;
  final Widget? trailing;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final EdgeInsetsGeometry padding;

  const ModalHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onClose,
    this.showCloseButton = true,
    this.closeIconColor = AppColors.textWhite,
    this.closeIconSize = 18,
    this.trailing,
    this.titleStyle,
    this.subtitleStyle,
    this.padding = const EdgeInsets.only(bottom: 16),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: titleStyle ?? AppTypography.sectionTitle,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: subtitleStyle ?? AppTypography.listSubtitle,
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null)
            trailing!
          else if (showCloseButton)
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              splashRadius: 20,
              onPressed: onClose ?? () => Navigator.of(context).pop(),
              icon: Icon(Icons.close, color: closeIconColor, size: closeIconSize),
            ),
        ],
      ),
    );
  }
}
