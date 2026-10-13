import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/native_bridge/notification_bridge.dart';
import '../../theme/app_colors.dart';

class InboxEmptyView extends StatelessWidget {
  const InboxEmptyView({super.key});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.neoMint.withValues(alpha: 0.10),
                border: Border.all(
                  color: AppColors.neoMint.withValues(alpha: 0.20),
                  width: 1.0,
                ),
              ),
              child: const Icon(
                Icons.done_all_rounded,
                color: AppColors.neoMint,
                size: 20,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada antrean notifikasi tertunda.\nSemua transaksi bank Anda sudah rapi tercatat!',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.5,
                color: AppColors.textMuted,
                letterSpacing: -0.1,
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () => NotificationBridge.openPermissionSettings(),
              icon: const Icon(Icons.settings_suggest_rounded, size: 16, color: AppColors.textMuted),
              label: Text(
                'Buka Setelan Akses Notifikasi Android',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textMuted,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
