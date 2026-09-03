import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/database/app_database.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/profile_avatar.dart';
import '../edit_profile_modal.dart';
import 'profile_delete_dialog.dart';

export 'profile_delete_dialog.dart';

class ProfileHeaderCard extends StatelessWidget {
  final ProfileEntry profile;
  final int totalProfiles;

  const ProfileHeaderCard({
    super.key,
    required this.profile,
    required this.totalProfiles,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.canvasInputSearch,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.canvasBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => EditProfileModal.show(context, profile: profile),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ProfileAvatar(avatarPath: profile.avatarPath, name: profile.username, size: 64, iconSize: 34),
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
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            profile.fullName,
                            style: AppTypography.heroGreeting.copyWith(fontSize: 18),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.neoMint.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'AKTIF',
                            style: GoogleFonts.plusJakartaSans(color: AppColors.neoMint, fontSize: 9, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '@${profile.username}',
                      style: GoogleFonts.plusJakartaSans(color: AppColors.neoChartreuse, fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile.occupation?.isNotEmpty == true ? profile.occupation! : 'Pengguna fiBOnanci',
                      style: AppTypography.listSubtitle.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: GestureDetector(
                  onTap: () => EditProfileModal.show(context, profile: profile),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(color: AppColors.neoChartreuse, borderRadius: BorderRadius.circular(12)),
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.edit_outlined, color: AppColors.textDarkPrimary, size: 15),
                            const SizedBox(width: 6),
                            Text('Edit Profil', style: GoogleFonts.plusJakartaSans(color: AppColors.textDarkPrimary, fontWeight: FontWeight.w700, fontSize: 12.5)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: GestureDetector(
                  onTap: () => EditProfileModal.show(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(color: const Color(0xFF1E212D), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.canvasBorder)),
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.person_add_alt_1_outlined, color: AppColors.textWhite, size: 15),
                            const SizedBox(width: 6),
                            Text('+ Profil Baru', style: GoogleFonts.plusJakartaSans(color: AppColors.textWhite, fontWeight: FontWeight.w600, fontSize: 12.5)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => showProfileDeleteDialog(context, profile, totalProfiles),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
                  ),
                  child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 18),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
