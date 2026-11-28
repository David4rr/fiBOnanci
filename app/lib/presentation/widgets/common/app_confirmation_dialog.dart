import 'package:flutter/material.dart';

import '../../../core/l10n/locale_notifier.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class AppConfirmationDialog {
  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String content,
    String? confirmText,
    String? cancelText,
    Color confirmColor = AppColors.neoCoral,
    Color confirmTextColor = AppColors.textDarkPrimary,
    Widget? titleLeading,
    VoidCallback? onConfirm,
  }) {
    final l10n = AppL10n.of(context);
    final effectiveConfirm = confirmText ?? l10n.txDeleteConfirm;
    final effectiveCancel = cancelText ?? l10n.txCancel;
    return showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.canvasCardSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.canvasBorder),
        ),
        title: titleLeading != null
            ? Row(
                children: [
                  titleLeading,
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: AppTypography.sectionTitle.copyWith(color: AppColors.textWhite, fontSize: 18),
                    ),
                  ),
                ],
              )
            : Text(
                title,
                style: AppTypography.sectionTitle.copyWith(color: AppColors.textWhite, fontSize: 18),
              ),
        content: Text(
          content,
          style: AppTypography.listSubtitle.copyWith(color: AppColors.textMuted, fontSize: 14, height: 1.4),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: Text(effectiveCancel, style: AppTypography.listTitle.copyWith(color: AppColors.textMuted, fontSize: 14)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              foregroundColor: confirmTextColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.of(dialogCtx).pop(true);
              onConfirm?.call();
            },
            child: Text(effectiveConfirm, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
