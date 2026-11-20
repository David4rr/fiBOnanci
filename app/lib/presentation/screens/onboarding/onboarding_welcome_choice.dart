import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class OnboardingWelcomeChoice extends StatelessWidget {
  final VoidCallback onStartNew;
  final VoidCallback onImportBackup;

  const OnboardingWelcomeChoice({
    super.key,
    required this.onStartNew,
    required this.onImportBackup,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 16),
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            color: AppColors.neoChartreuse.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.neoChartreuse.withValues(alpha: 0.35), width: 1.5),
          ),
          child: const Center(
            child: Icon(Icons.account_balance_wallet_rounded, color: AppColors.neoChartreuse, size: 38),
          ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.canvasCardSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.canvasBorder),
          ),
          child: const Text(
            'OFFLINE-FIRST & ZERO-LATENCY',
            style: TextStyle(color: AppColors.neoChartreuse, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'fiBOnanci',
          style: TextStyle(color: AppColors.textWhite, fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5),
        ),
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Kelola keuangan pribadi dengan kecerdasan Safe-to-Spend & privasi 100% on-device.',
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
          title: 'Buat Akun Baru',
          subtitle: 'Pengguna baru: Mulai dari awal dalam 1 menit',
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
          title: 'Pulihkan dari Cadangan',
          subtitle: 'Sudah pernah pakai? Pulihkan berkas .json Anda',
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.neoMint.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              '.JSON',
              style: TextStyle(color: AppColors.neoMint, fontSize: 10, fontWeight: FontWeight.bold),
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
                  Text(title, style: const TextStyle(color: AppColors.textWhite, fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5)),
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
