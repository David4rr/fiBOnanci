import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

class InboxEmptyView extends StatelessWidget {
  final VoidCallback onSimulationTap;

  const InboxEmptyView({super.key, required this.onSimulationTap});

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
            const SizedBox(height: 24),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: onSimulationTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.neoChartreuse,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.bolt_rounded,
                        size: 15,
                        color: AppColors.textDarkPrimary,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Coba Simulasi Notifikasi Masuk',
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.textDarkPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                            letterSpacing: -0.1,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
