import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'wallet_screen.dart';

class WalletAddOptionsSheet {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF13141C),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (sheetContext) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF13141C),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(top: BorderSide(color: AppColors.canvasBorder, width: 1.2)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: AppColors.canvasBorder, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              Text('Tambah ke Finansial', style: GoogleFonts.plusJakartaSans(color: AppColors.textWhite, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.3)),
              const SizedBox(height: 6),
              Text('Pilih jenis alokasi atau akun yang ingin kamu buat.', style: AppTypography.listSubtitle),
              const SizedBox(height: 20),
              _buildTile(
                icon: Icons.savings_outlined,
                iconColor: AppColors.neoChartreuse,
                title: 'Kantong Tabungan Baru',
                subtitle: 'Alokasi dana darurat, impian, atau tabungan pensiun',
                onTap: () {
                  Navigator.pop(sheetContext);
                  WalletScreen.showAddPocketModal(context);
                },
              ),
              const SizedBox(height: 12),
              _buildTile(
                icon: Icons.account_balance_wallet_outlined,
                iconColor: AppColors.neoMint,
                title: 'Rekening & Dompet Baru',
                subtitle: 'Bank BCA, Mandiri, GoPay, OVO, atau Kas Tunai',
                onTap: () {
                  Navigator.pop(sheetContext);
                  WalletScreen.showAddWalletModal(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.canvasBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.canvasBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.15), shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.plusJakartaSans(color: AppColors.textWhite, fontSize: 14.5, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text(subtitle, style: AppTypography.listSubtitle.copyWith(fontSize: 11.5)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textMuted, size: 14),
          ],
        ),
      ),
    );
  }
}
