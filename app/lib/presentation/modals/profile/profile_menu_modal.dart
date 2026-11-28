import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/l10n/locale_notifier.dart';
import '../../../data/database/app_database.dart';
import '../../screens/onboarding/onboarding_submit.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/common_widgets.dart';
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
    builder: (ctx) {
      final l10n = AppL10n.of(ctx);
      return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ModalGrabHandle(),
            const SizedBox(height: 8),
            ModalHeader(
              title: l10n.profileMenuTitle,
              padding: EdgeInsets.zero,
              onClose: () => Navigator.of(ctx).pop(),
            ),
            const SizedBox(height: 14),
            ProfileMorphingMenuItem(
              icon: Icons.person_add_alt_1_outlined,
              title: l10n.profileMenuNewTitle,
              subtitle: l10n.profileAddSub,
              onTap: () {
                Navigator.of(ctx).pop();
                if (onNewProfile != null) { onNewProfile(); } else { OnboardingSubmit.openNewProfile(context); }
              },
            ),
            const SizedBox(height: 8),
            ProfileMorphingMenuItem(
              icon: Icons.favorite_outline_rounded,
              title: l10n.profileMenuHealthTitle,
              subtitle: l10n.profileMenuHealthSub,
              onTap: () {
                Navigator.of(ctx).pop();
                if (onHealthDetails != null) { onHealthDetails(); } else { FinancialHealthModal.show(context); }
              },
            ),
            const SizedBox(height: 8),
            ProfileMorphingMenuItem(
              icon: Icons.share_outlined,
              title: l10n.profileMenuShareTitle,
              subtitle: l10n.profileMenuShareSub,
              onTap: () {
                Navigator.of(ctx).pop();
                Clipboard.setData(ClipboardData(text: '${profile.fullName} (@${profile.username}) - fiBOnanci'));
                AppSnackBar.showInfo(context, l10n.profileCopiedTitle, message: l10n.profileCopiedMsg, tag: 'SALIN');
              },
            ),
          ],
        ),
      ),
    );
    },
  );
}
