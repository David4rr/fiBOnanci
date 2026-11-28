import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../core/l10n/locale_notifier.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/profile_avatar.dart';
import '../../widgets/common/common_widgets.dart';

class EditProfileAvatarPicker {
  static Widget buildPickerWidget({
    required BuildContext context,
    required String? avatarPath,
    required String name,
    required VoidCallback onTap,
  }) {
    final hasPhoto = avatarPath != null && avatarPath.isNotEmpty;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.canvasInputSearch,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.canvasBorder),
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                ProfileAvatar(avatarPath: avatarPath, name: name, size: 56, iconSize: 28),
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.neoChartreuse,
                      border: Border.all(color: AppColors.canvasCardSurface, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt, size: 11, color: AppColors.textDarkPrimary),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppL10n.of(context).avatarTitle,
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.textWhite,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    hasPhoto ? AppL10n.of(context).avatarActiveSub : AppL10n.of(context).avatarEmptySub,
                    style: AppTypography.listSubtitle.copyWith(
                      fontSize: 11.5,
                      color: hasPhoto ? AppColors.neoMint : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }

  static Future<String?> pickImage(BuildContext context, ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final ext = p.extension(pickedFile.path).isNotEmpty ? p.extension(pickedFile.path) : '.jpg';
        final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}$ext';
        final savedFile = File('${appDir.path}/$fileName');
        await File(pickedFile.path).copy(savedFile.path);
        return savedFile.path;
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackBar.showError(
          context,
          AppL10n.of(context).avatarErrorTitle,
          message: e.toString(),
          tag: 'AVATAR',
        );
      }
    }
    return null;
  }

  static void showSourceDialog({
    required BuildContext context,
    required bool hasPhoto,
    required ValueChanged<ImageSource> onSelectSource,
    required VoidCallback onRemovePhoto,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.canvasCardSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => SafeArea(
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ModalGrabHandle(padding: EdgeInsets.only(bottom: 14)),
              ModalHeader(
                title: AppL10n.of(ctx).avatarPickerTitle,
                subtitle: AppL10n.of(ctx).avatarPickerSub,
                onClose: () => Navigator.of(ctx).pop(),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.neoChartreuse.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.photo_library_outlined, color: AppColors.neoChartreuse, size: 20)),
                title: Text(AppL10n.of(ctx).avatarGalleryTitle, style: GoogleFonts.plusJakartaSans(color: AppColors.textWhite, fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: Text(AppL10n.of(ctx).avatarGallerySub, style: AppTypography.listSubtitle.copyWith(fontSize: 11)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  onSelectSource(ImageSource.gallery);
                },
              ),
              Divider(color: AppColors.canvasBorder, height: 20),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.neoCyan.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.camera_alt_outlined, color: AppColors.neoCyan, size: 20)),
                title: Text(AppL10n.of(ctx).avatarCameraTitle, style: GoogleFonts.plusJakartaSans(color: AppColors.textWhite, fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: Text(AppL10n.of(ctx).avatarCameraSub, style: AppTypography.listSubtitle.copyWith(fontSize: 11)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  onSelectSource(ImageSource.camera);
                },
              ),
              if (hasPhoto) ...[
                Divider(color: AppColors.canvasBorder, height: 20),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFFEF4444).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 20)),
                  title: Text(AppL10n.of(ctx).avatarRemoveTitle, style: GoogleFonts.plusJakartaSans(color: const Color(0xFFEF4444), fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: Text(AppL10n.of(ctx).avatarRemoveSub, style: AppTypography.listSubtitle.copyWith(fontSize: 11)),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    onRemovePhoto();
                  },
                ),
              ],
            ],
            ),
          ),
        ),
      ),
    );
  }
}
