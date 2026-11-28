import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../core/l10n/locale_notifier.dart';
import '../../theme/app_colors.dart';

bool get _isFlutterTest => !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');

class OnboardingWelcomeChoice extends StatelessWidget {
  final VoidCallback onStartNew;
  final VoidCallback onImportBackup;
  final VoidCallback? onBack;

  const OnboardingWelcomeChoice({
    super.key,
    required this.onStartNew,
    required this.onImportBackup,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (onBack != null)
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: Icon(Icons.arrow_back_rounded, color: AppColors.textWhite, size: 22),
              onPressed: onBack,
            ),
          ),
        SizedBox(
          height: 156,
          width: 200,
          child: Lottie.asset(
            'assets/lottie/onb_welcome.json',
            height: 156,
            animate: !_isFlutterTest,
            repeat: true,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => const Icon(
              Icons.account_balance_wallet_rounded,
              color: AppColors.neoChartreuse,
              size: 56,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.canvasCardSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.canvasBorder),
          ),
          child: Text(
            'OFFLINE-FIRST & ZERO-LATENCY',
            style: TextStyle(color: AppColors.textAccent, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'fiBOnanci',
          style: TextStyle(color: AppColors.textWhite, fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            AppL10n.of(context).onbWelcomeTagline,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted, fontSize: 13, height: 1.4),
          ),
        ),
        const SizedBox(height: 28),
        _buildOptionCard(
          key: const Key('welcome_start_new_btn'),
          onTap: onStartNew,
          icon: Icons.person_add_rounded,
          iconBg: AppColors.neoChartreuse,
          iconColor: AppColors.textDarkPrimary,
          borderColor: AppColors.neoChartreuse.withValues(alpha: 0.5),
          bgColor: AppColors.neoChartreuse.withValues(alpha: 0.12),
          title: AppL10n.of(context).onbCreateAccountTitle,
          subtitle: AppL10n.of(context).onbCreateAccountSub,
          trailing: const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.neoChartreuse, size: 14),
        ),
        const SizedBox(height: 12),
        _buildOptionCard(
          key: const Key('welcome_import_backup_btn'),
          onTap: onImportBackup,
          icon: Icons.settings_backup_restore_rounded,
          iconBg: AppColors.neoMint.withValues(alpha: 0.12),
          iconColor: AppColors.neoMint,
          borderColor: AppColors.canvasBorder,
          bgColor: AppColors.canvasCardSurface,
          title: AppL10n.of(context).onbRestoreTitle,
          subtitle: AppL10n.of(context).onbRestoreSub,
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.neoMint.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '.JSON',
              style: TextStyle(color: AppColors.textIncome, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildOptionCard({
    required Key key,
    required VoidCallback onTap,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required Color borderColor,
    required Color bgColor,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return InkWell(
      key: key,
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1.2),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: AppColors.textWhite, fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(color: AppColors.textMuted, fontSize: 11.5)),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
