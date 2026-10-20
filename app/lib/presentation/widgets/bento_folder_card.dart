import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'folder_tab_card.dart';
import 'common/peekable_balance_text.dart';

/// Reusable Bento Folder Card with signature asymmetric folder tab clipping,
/// circular icon badge, metric value, subtitle label, and optional progress bar.
///
/// Shared consistently across Dashboard Bento Grid, Wallet Pocket Allocations,
/// and Pocket Detail Header with modular cashflow chart.
class BentoFolderCard extends StatelessWidget {
  final Color backgroundColor;
  final Gradient? gradient;
  final Widget? icon;
  final IconData? iconData;
  final Widget? topTrailing;
  final String title;
  final String? subtitle;
  final Widget? subtitleWidget;
  final Widget? trailingIcon;
  final Widget? rightWidget;
  final double? progress;
  final VoidCallback? onTap;
  final double? height;
  final EdgeInsetsGeometry padding;
  final Color? textColor;
  final Color? subtitleColor;
  final Color? iconColor;
  final Color? iconBgColor;
  final bool? isBalanceHidden;

  const BentoFolderCard({
    super.key,
    required this.backgroundColor,
    this.gradient,
    this.icon,
    this.iconData,
    this.topTrailing,
    required this.title,
    this.subtitle,
    this.subtitleWidget,
    this.trailingIcon,
    this.rightWidget,
    this.progress,
    this.onTap,
    this.height = 132,
    this.padding = const EdgeInsets.all(16),
    this.textColor,
    this.subtitleColor,
    this.iconColor,
    this.iconBgColor,
    this.isBalanceHidden,
  });

  @override
  Widget build(BuildContext context) {
    final bool isNeoPastel = backgroundColor == AppColors.neoCoral ||
        backgroundColor == AppColors.neoChartreuse ||
        backgroundColor == AppColors.neoMint ||
        backgroundColor == AppColors.neoCyan;

    final isDark = isNeoPastel
        ? false
        : ThemeData.estimateBrightnessForColor(backgroundColor) == Brightness.dark;

    final Color primaryText = textColor ?? (isDark ? AppColors.textWhite : AppColors.textDarkPrimary);
    final Color secondaryText = subtitleColor ??
        (isDark ? Colors.white.withValues(alpha: 0.90) : AppColors.textDarkSecondary);
    final Color effectiveIconColor = iconColor ?? primaryText;
    final Color iconBg = iconBgColor ??
        (isDark ? Colors.white.withValues(alpha: 0.18) : AppColors.cardIconBadgeBg);

    final iconWidget = Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(shape: BoxShape.circle, color: iconBg),
      child: Center(
        child: icon ?? Icon(iconData ?? Icons.folder_outlined, color: effectiveIconColor, size: 18),
      ),
    );

    final bottomContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: PeekableBalanceText(
            text: title,
            isHidden: isBalanceHidden,
            style: AppTypography.cardMetricValue.copyWith(color: primaryText),
          ),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Expanded(
              child: subtitleWidget ??
                  Text(
                    subtitle ?? '',
                    style: AppTypography.cardMetricLabel.copyWith(color: secondaryText),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
            ),
            if (trailingIcon != null) ...[const SizedBox(width: 4), trailingIcon!],
          ],
        ),
        if (progress != null) ...[
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress!.clamp(0.0, 1.0),
              minHeight: 3.5,
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: 0.10),
              valueColor: AlwaysStoppedAnimation<Color>(primaryText),
            ),
          ),
        ],
      ],
    );

    final cardBody = rightWidget != null
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [iconWidget, bottomContent],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ?topTrailing,
                    const SizedBox(height: 4),
                    Expanded(child: rightWidget!),
                  ],
                ),
              ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [iconWidget, ?topTrailing],
              ),
              bottomContent,
            ],
          );

    return FolderTabCard(
      backgroundColor: backgroundColor,
      gradient: gradient,
      height: height,
      padding: padding,
      onTap: onTap,
      child: cardBody,
    );
  }
}
