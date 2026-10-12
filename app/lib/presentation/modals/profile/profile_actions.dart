import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/database/app_database.dart';
import '../../theme/app_colors.dart';
import '../../widgets/notification_simulator_modal.dart';

class ProfileActions extends StatelessWidget {
  final ProfileEntry profile;
  final List<ProfileEntry> profiles;

  const ProfileActions({
    super.key,
    required this.profile,
    required this.profiles,
  });

  Widget _buildActionCard({
    Key? cardKey,
    required IconData icon,
    required Color accent,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      key: cardKey,
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.canvasInputSearch,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(child: Icon(icon, color: accent, size: 20)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.plusJakartaSans(color: AppColors.textWhite, fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: GoogleFonts.plusJakartaSans(color: AppColors.textMuted, fontSize: 11)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textMuted, size: 14),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 18),
        Text(
          'PENGATURAN & ALAT',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10.5, fontWeight: FontWeight.w700,
            color: AppColors.textMuted, letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 10),
        _buildActionCard(
          icon: Icons.notifications_active_outlined,
          accent: AppColors.neoChartreuse,
          title: 'Simulator Push Notifikasi',
          subtitle: 'Uji parser regex bank & e-wallet offline',
          onTap: () {
            Navigator.of(context).pop();
            NotificationSimulatorModal.show(context);
          },
        ),
      ],
    );
  }
}
