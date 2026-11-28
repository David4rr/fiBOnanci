import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/l10n/locale_notifier.dart';
import '../../../core/update/app_update_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/common_widgets.dart';
import '../kofi_webview_modal.dart';
import 'settings_style.dart';

class AboutHeroCard extends StatelessWidget {
  const AboutHeroCard({super.key});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.canvasCardSurface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.canvasBorder, width: 1.0),
        ),
        child: Column(
          children: [
            Container(
              width: 68,
              height: 68,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.canvasBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.canvasBorder, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neoChartreuse.withValues(alpha: 0.12),
                    blurRadius: 18,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Center(
                child: FibonanciLogoMark(
                  size: 46,
                  morphProgress: 1.0,
                  showGlow: true,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'fiBOnanci',
              style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textWhite, letterSpacing: -0.5),
            ),
            const SizedBox(height: 4),
            Text(
              'Smart Offline-First Finance Intelligence',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AppColors.textMuted),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.canvasBorder, width: 0.8),
              ),
              child: Text(
                'v${AppUpdateService.currentVersion} • Build 5',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textAccent,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ),
      );
}

class AboutSpecsSection extends StatelessWidget {
  const AboutSpecsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.canvasCardSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.canvasBorder, width: 1.0),
          ),
          child: Text(
            l10n.aboutPrivacyDesc,
            style: SettingsStyle.sub.copyWith(height: 1.45),
          ),
        ),
        const SizedBox(height: 8),
        SettingsStyle.menuRow(title: l10n.aboutLicenseTitle, valueText: 'MIT Open Source'),
        SettingsStyle.menuRow(title: l10n.aboutStorageTitle, valueText: 'SQLite 3 (SQLCipher)'),
        SettingsStyle.menuRow(title: l10n.aboutParserTitle, valueText: 'Deterministic Regex'),
        SettingsStyle.menuRow(
          key: const Key('about_github_repo_row'),
          title: l10n.aboutGithubTitle,
          valueText: 'David4rr/fiBOnanci',
          valueColor: AppColors.textAccent,
          onTap: () => KofiWebViewModal.showUrl(context, url: 'https://github.com/David4rr/fiBOnanci'),
        ),
        SettingsStyle.menuRow(
          key: const Key('about_releases_row'),
          title: l10n.aboutReleasesTitle,
          valueText: l10n.aboutOpenBrowser,
          valueColor: AppColors.textAccent,
          onTap: () => KofiWebViewModal.showUrl(context, url: 'https://github.com/David4rr/fiBOnanci/releases'),
        ),
        const SizedBox(height: 12),
        KofiSupportButton(
          key: const Key('about_kofi_row'),
          label: l10n.kofiPromptSupportBtn,
          onTap: () => KofiWebViewModal.show(context),
        ),
      ],
    );
  }
}
