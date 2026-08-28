import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class OverlappingDeckItem extends StatelessWidget {
  final String title;
  final String category;
  final double amount;
  final Color categoryColor;
  final IconData iconData;
  final String? subtitle;
  final bool isExpense;
  final VoidCallback? onTap;

  const OverlappingDeckItem({
    super.key,
    required this.title,
    required this.category,
    required this.amount,
    required this.categoryColor,
    required this.iconData,
    this.subtitle,
    this.isExpense = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: isExpense ? '-Rp ' : '+Rp ',
      decimalDigits: 0,
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF161822),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF26293A), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Circular Avatar Badge
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFF0F1118),
                shape: BoxShape.circle,
                border: Border.all(color: categoryColor.withOpacity(0.35), width: 1.5),
              ),
              child: Center(
                child: Icon(iconData, color: categoryColor, size: 20),
              ),
            ),
            const SizedBox(width: 14),

            // Title and Category Eyebrow
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    category.toUpperCase(),
                    style: AppTypography.badgeLabel.copyWith(color: categoryColor),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    style: AppTypography.listTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: AppTypography.listSubtitle,
                      maxLines: 1,
                    ),
                  ],
                ],
              ),
            ),

            // Formatted Tabular Amount
            Text(
              currencyFormatter.format(amount.abs()),
              style: AppTypography.listAmount.copyWith(
                color: isExpense ? AppColors.textWhite : AppColors.neoMint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Vertically stacked deck of cards overlapping by negative vertical margin
class OverlappingDeckList extends StatelessWidget {
  final List<Widget> children;
  final double overlapOffset;

  const OverlappingDeckList({
    super.key,
    required this.children,
    this.overlapOffset = 14.0,
  });

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        for (int i = 0; i < children.length; i++)
          Transform.translate(
            offset: Offset(0, -i * overlapOffset),
            child: children[i],
          ),
      ],
    );
  }
}
