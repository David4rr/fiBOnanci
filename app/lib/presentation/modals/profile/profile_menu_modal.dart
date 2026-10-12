import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../data/database/app_database.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/common_widgets.dart';
import '../edit_profile_modal.dart';
import '../financial_health_modal.dart';
import 'profile_morphing_menu.dart';
export 'profile_morphing_menu.dart';
void showProfileMenuModal(BuildContext context, {
  required ProfileEntry profile,
  int totalProfiles = 1,
  VoidCallback? onHealthDetails,
  VoidCallback? onEditProfile,
  VoidCallback? onNewProfile,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.canvasBg,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
            ProfileMorphingMenuItem(
              icon: Icons.person_add_alt_1_outlined,
              title: 'New Profile',
              subtitle: 'Tambah akun profil baru di perangkat',
              onTap: () {
                Navigator.of(ctx).pop();
                if (onNewProfile != null) { onNewProfile(); } else { EditProfileModal.show(context); }
              },
            ),
            const SizedBox(height: 8),
            ProfileMorphingMenuItem(
              icon: Icons.favorite_outline_rounded,
              title: 'Health Finance Details',
              subtitle: 'Audit komprehensif 4 pilar kesehatan keuangan',
              onTap: () {
                Navigator.of(ctx).pop();
                if (onHealthDetails != null) { onHealthDetails(); } else { FinancialHealthModal.show(context); }
              },
            ),
            const SizedBox(height: 8),
            ProfileMorphingMenuItem(
              icon: Icons.share_outlined,
              title: 'Share Profile',
              subtitle: 'Bagikan kartu profil finansial',
              onTap: () {
                Navigator.of(ctx).pop();
                Clipboard.setData(ClipboardData(text: '${profile.fullName} (@${profile.username}) - fiBOnanci'));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Kartu profil berhasil disalin!'), duration: Duration(seconds: 2)),
                );
              },
            ),
          ],
        ),
      ),
    ),
  );
}
