import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class CardlessEmptyView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? hint;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  const CardlessEmptyView({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.hint,
    this.onTap,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.04),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
                width: 1.0,
              ),
            ),
            child: Center(
              child: Icon(
                icon,
                color: AppColors.textSubtle,
                size: 24,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: AppTypography.sectionTitle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: AppTypography.listSubtitle,
          ),
          if (hint != null) ...[
            const SizedBox(height: 12),
            Text(
              hint!,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.0,
                fontWeight: FontWeight.w500,
                color: AppColors.textSubtle,
                letterSpacing: -0.1,
              ),
            ),
          ],
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: double.infinity,
          child: content,
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: content,
    );
  }
}
