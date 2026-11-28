import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/database/app_database.dart';
import '../../../core/l10n/locale_notifier.dart';
import '../../screens/onboarding/onboarding_submit.dart';
import '../../theme/app_colors.dart';
import '../financial_health_modal.dart';

class ProfileMorphingMenuOverlay extends StatelessWidget {
  final ProfileEntry profile;
  final int totalProfiles;
  final VoidCallback onClose;
  final void Function(VoidCallback? action) onAction;
  final VoidCallback? onEditProfile;
  final VoidCallback? onNewProfile;
  final VoidCallback? onHealthDetails;
  final VoidCallback? onFinancialReport;
  final VoidCallback? onSettings;
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
    this.onFinancialReport,
    this.onSettings,
    required this.onShareProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 256,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.canvasCardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.canvasBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: AppColors.isDark ? 0.65 : 0.12),
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
              Icon(Icons.more_horiz_rounded, color: AppColors.textAccent, size: 16),
              const SizedBox(width: 8),
              Text(
                AppL10n.of(context).profileMenuTitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onClose,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surfaceSubtle,
                  ),
                  child: Icon(Icons.close_rounded, size: 14, color: AppColors.textMuted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ProfileMorphingMenuItem(
            icon: Icons.person_add_alt_1_outlined,
            title: 'New Profile',
            subtitle: AppL10n.of(context).profileMenuNew,
            onTap: () => onAction(onNewProfile ?? () => OnboardingSubmit.openNewProfile(context)),
          ),
          const SizedBox(height: 8),
          ProfileMorphingMenuItem(
            icon: Icons.favorite_outline_rounded,
            title: 'Health Finance Details',
            subtitle: AppL10n.of(context).profileMenuHealth,
            onTap: () => onAction(onHealthDetails ?? () => FinancialHealthModal.show(context)),
          ),
          if (onFinancialReport != null) ...[
            const SizedBox(height: 8),
            ProfileMorphingMenuItem(
              key: const Key('profile_financial_report_button'),
              icon: Icons.pie_chart_outline_rounded,
              title: AppL10n.of(context).financialReportTitle,
              subtitle: AppL10n.of(context).profileMenuReport,
              onTap: () => onAction(onFinancialReport),
            ),
          ],
          if (onSettings != null) ...[
            const SizedBox(height: 8),
            ProfileMorphingMenuItem(
              key: const Key('profile_settings_button'),
              icon: Icons.tune_rounded,
              title: AppL10n.of(context).settingsTitle,
              subtitle: AppL10n.of(context).profileMenuSettings,
              onTap: () => onAction(onSettings),
            ),
          ],
          const SizedBox(height: 8),
          ProfileMorphingMenuItem(
            icon: Icons.share_outlined,
            title: 'Share Profile',
            subtitle: AppL10n.of(context).profileMenuShare,
            onTap: () => onAction(onShareProfile),
          ),
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
          color: AppColors.surfaceSubtle,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.textAccent).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor ?? AppColors.textAccent, size: 15),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: titleColor ?? AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 9.5, fontWeight: FontWeight.w500, color: AppColors.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 15),
          ],
        ),
      ),
    );
  }
}
