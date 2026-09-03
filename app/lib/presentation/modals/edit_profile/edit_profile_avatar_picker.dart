import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/profile_avatar.dart';

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
                      border: Border.all(color: const Color(0xFF17181F), width: 2),
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
                    'Foto Profil',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.textWhite,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    hasPhoto ? 'Foto kustom aktif • Ketuk untuk ganti' : 'Ketuk untuk pilih dari galeri atau kamera',
                    style: AppTypography.listSubtitle.copyWith(
                      fontSize: 11.5,
                      color: hasPhoto ? AppColors.neoMint : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengambil foto: $e'),
            backgroundColor: AppColors.neoCoral,
            behavior: SnackBarBehavior.floating,
          ),
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
      backgroundColor: const Color(0xFF17181F),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pilih Sumber Foto', style: GoogleFonts.plusJakartaSans(color: AppColors.textWhite, fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.neoChartreuse.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.photo_library_outlined, color: AppColors.neoChartreuse, size: 20)),
                title: Text('Galeri Foto', style: GoogleFonts.plusJakartaSans(color: AppColors.textWhite, fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: Text('Pilih gambar dari galeri perangkat', style: AppTypography.listSubtitle.copyWith(fontSize: 11)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  onSelectSource(ImageSource.gallery);
                },
              ),
              const Divider(color: AppColors.canvasBorder, height: 20),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.neoCyan.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.camera_alt_outlined, color: AppColors.neoCyan, size: 20)),
                title: Text('Kamera', style: GoogleFonts.plusJakartaSans(color: AppColors.textWhite, fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: Text('Ambil foto baru langsung dari kamera', style: AppTypography.listSubtitle.copyWith(fontSize: 11)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  onSelectSource(ImageSource.camera);
                },
              ),
              if (hasPhoto) ...[
                const Divider(color: AppColors.canvasBorder, height: 20),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFFEF4444).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 20)),
                  title: Text('Hapus Foto Profil', style: GoogleFonts.plusJakartaSans(color: const Color(0xFFEF4444), fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: Text('Gunakan inisial nama sebagai avatar', style: AppTypography.listSubtitle.copyWith(fontSize: 11)),
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
    );
  }
}
