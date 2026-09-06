import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/database/app_database.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/common_widgets.dart';
import '../edit_profile_modal.dart';
import '../financial_health_modal.dart';
import 'profile_delete_dialog.dart';

void showProfileMenuModal(BuildContext context, {required ProfileEntry profile, int totalProfiles = 1}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.canvasBg,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ModalGrabHandle(),
            const SizedBox(height: 8),
            ModalHeader(
              title: 'Menu Profil',
              padding: EdgeInsets.zero,
              onClose: () => Navigator.of(ctx).pop(),
            ),
            const SizedBox(height: 14),
            _buildItem(
              ctx,
              icon: Icons.edit_outlined,
              title: 'Edit Profile',
              subtitle: 'Perbarui nama, jabatan, dan avatar',
              onTap: () {
                Navigator.of(ctx).pop();
                EditProfileModal.show(context, profile: profile);
              },
            ),
            const SizedBox(height: 8),
            _buildItem(
              ctx,
              icon: Icons.person_add_alt_1_outlined,
              title: 'New Profile',
              subtitle: 'Tambah akun profil baru di perangkat',
              onTap: () {
                Navigator.of(ctx).pop();
                EditProfileModal.show(context);
              },
            ),
            const SizedBox(height: 8),
            _buildItem(
              ctx,
              icon: Icons.favorite_outline_rounded,
              title: 'Health Finance Details',
              subtitle: 'Audit komprehensif 4 pilar kesehatan keuangan',
              onTap: () {
                Navigator.of(ctx).pop();
                FinancialHealthModal.show(context);
              },
            ),
            const SizedBox(height: 8),
            _buildItem(
              ctx,
              icon: Icons.share_outlined,
              title: 'Share Profile',
              subtitle: 'Bagikan kartu profil finansial',
              onTap: () {
                Navigator.of(ctx).pop();
                Clipboard.setData(ClipboardData(text: '${profile.fullName} (@${profile.username}) - fiBOnanci'));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Kartu profil berhasil disalin!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            if (totalProfiles > 1) ...[
              const SizedBox(height: 8),
              _buildItem(
                ctx,
                icon: Icons.delete_outline_rounded,
                title: 'Hapus Profil',
                subtitle: 'Hapus akun profil ini dari perangkat',
                iconColor: AppColors.neoCoral,
                titleColor: AppColors.neoCoral,
                onTap: () {
                  Navigator.of(ctx).pop();
                  showProfileDeleteDialog(context, profile, totalProfiles);
                },
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

Widget _buildItem(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String subtitle,
  required VoidCallback onTap,
  Color? iconColor,
  Color? titleColor,
}) {
  return GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: (iconColor ?? AppColors.neoChartreuse).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor ?? AppColors.neoChartreuse, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: titleColor ?? Colors.white,
                  ),
                ),
                const SizedBox(height: 1.5),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 18),
        ],
      ),
    ),
  );
}
