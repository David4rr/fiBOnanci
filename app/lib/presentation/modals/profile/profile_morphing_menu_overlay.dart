import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/database/app_database.dart';
import '../../theme/app_colors.dart';
import 'profile_delete_dialog.dart';
import '../edit_profile_modal.dart';
import '../financial_health_modal.dart';

class ProfileMorphingMenuOverlay extends StatelessWidget {
  final ProfileEntry profile;
  final int totalProfiles;
  final VoidCallback onClose;
  final void Function(VoidCallback? action) onAction;
  final VoidCallback? onEditProfile;
  final VoidCallback? onNewProfile;
  final VoidCallback? onHealthDetails;
  final VoidCallback onShareProfile;

  const ProfileMorphingMenuOverlay({
    super.key,
    required this.profile,
    required this.totalProfiles,
    required this.onClose,
    required this.onAction,
    this.onEditProfile,
    this.onNewProfile,
    this.onHealthDetails,
    required this.onShareProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      margin: const EdgeInsets.only(top: 2),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.canvasCardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF2E3244), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.65),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.more_horiz_rounded, color: AppColors.neoChartreuse, size: 16),
              const SizedBox(width: 8),
              Text(
                'Menu Profil',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onClose,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                  child: const Icon(Icons.close_rounded, size: 14, color: AppColors.textMuted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ProfileMorphingMenuItem(
            icon: Icons.edit_outlined,
            title: 'Edit Profile',
            subtitle: 'Perbarui nama, jabatan, avatar',
            onTap: () => onAction(onEditProfile ?? () => EditProfileModal.show(context, profile: profile)),
          ),
          const SizedBox(height: 6),
          ProfileMorphingMenuItem(
            icon: Icons.person_add_alt_1_outlined,
            title: 'New Profile',
            subtitle: 'Tambah akun profil baru',
            onTap: () => onAction(onNewProfile ?? () => EditProfileModal.show(context)),
          ),
          const SizedBox(height: 6),
          ProfileMorphingMenuItem(
            icon: Icons.favorite_outline_rounded,
            title: 'Health Finance Details',
            subtitle: 'Audit komprehensif keuangan',
            onTap: () => onAction(onHealthDetails ?? () => FinancialHealthModal.show(context)),
          ),
          ProfileMorphingMenuItem(
            icon: Icons.share_outlined,
            title: 'Share Profile',
            subtitle: 'Bagikan kartu profil finansial',
            onTap: () => onAction(onShareProfile),
          ),
          if (totalProfiles > 1) ...[
            const SizedBox(height: 6),
            ProfileMorphingMenuItem(
              icon: Icons.delete_outline_rounded,
              title: 'Hapus Profil',
              subtitle: 'Hapus akun profil ini',
              iconColor: AppColors.neoCoral,
              titleColor: AppColors.neoCoral,
              onTap: () => onAction(() => showProfileDeleteDialog(context, profile, totalProfiles)),
            ),
          ],
        ],
      ),
    );
  }
}

class ProfileMorphingMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? titleColor;

  const ProfileMorphingMenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.neoChartreuse).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor ?? AppColors.neoChartreuse, size: 15),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: titleColor ?? Colors.white)),
                  Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 9.5, fontWeight: FontWeight.w500, color: AppColors.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 15),
          ],
        ),
      ),
    );
  }
}
