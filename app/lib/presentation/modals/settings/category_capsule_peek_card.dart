import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/formatters/app_currency.dart';
import '../../../core/l10n/category_localizer.dart';
import '../../../core/l10n/locale_notifier.dart';
import '../../../data/database/app_database.dart';
import '../../theme/app_colors.dart';
import '../../theme/category_icon_resolver.dart';

class CategoryCapsulePeekCard extends StatelessWidget {
  final CategoryEntry category;
  final Color color;
  final int txCount;
  final double totalAmount;
  final bool canDelete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CategoryCapsulePeekCard({
    super.key,
    required this.category,
    required this.color,
    required this.txCount,
    required this.totalAmount,
    required this.canDelete,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final fmt = AppCurrency.of(context);
    final catName = CategoryLocalizer.entry(context, category);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.canvasCardSurface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 3,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.canvasBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surfaceSubtle,
                        border: Border.all(color: color, width: 2.2),
                      ),
                      child: Icon(CategoryIconResolver.mapCategoryIcon(category.iconName), color: color, size: 20),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      catName,
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textWhite),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      txCount > 0 ? '${l10n.catTimelineTxCount(txCount)} • ${fmt.format(totalAmount)}' : l10n.catTimelineTxCount(0),
                      style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.textMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 48, color: AppColors.canvasBorder.withValues(alpha: 0.7)),
              Expanded(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionCircle(
                      key: Key('settings_edit_cat_${category.id}'),
                      icon: Icons.edit_rounded,
                      label: l10n.catEditAction,
                      color: AppColors.neoCyan,
                      onTap: onEdit,
                    ),
                    if (canDelete)
                      _buildActionCircle(
                        key: Key('settings_delete_cat_${category.id}'),
                        icon: Icons.delete_outline_rounded,
                        label: l10n.txDeleteConfirm,
                        color: AppColors.neoCoral,
                        onTap: onDelete,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCircle({
    required Key key,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      key: key,
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.14),
            ),
            child: Icon(icon, color: color, size: 19),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
