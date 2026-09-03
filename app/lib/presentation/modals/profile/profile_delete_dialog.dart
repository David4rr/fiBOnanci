import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../bloc/finance/finance_bloc.dart';
import '../../../bloc/finance/finance_event.dart';
import '../../../data/database/app_database.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

void showProfileDeleteDialog(BuildContext context, ProfileEntry profile, int totalProfiles) {
  final bloc = context.read<FinanceBloc>();
  showDialog(
    context: context,
    builder: (dialogCtx) => AlertDialog(
      backgroundColor: AppColors.canvasCardSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.canvasBorder),
      ),
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFEF4444).withValues(alpha: 0.15),
            ),
            child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 20),
          ),
          const SizedBox(width: 10),
          Text(
            totalProfiles > 1 ? 'Hapus Profil?' : 'Reset Profil?',
            style: GoogleFonts.plusJakartaSans(color: AppColors.textWhite, fontWeight: FontWeight.w700, fontSize: 17),
          ),
        ],
      ),
      content: Text(
        totalProfiles > 1
            ? 'Profil "${profile.username}" akan dihapus. Anda dapat beralih ke profil lain yang masih tersimpan.'
            : 'Profil "${profile.username}" adalah satu-satunya profil. Profil akan direset ke pengaturan default.',
        style: AppTypography.listSubtitle.copyWith(fontSize: 13),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogCtx).pop(),
          child: const Text('Batal', style: TextStyle(color: AppColors.textMuted)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEF4444),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            Navigator.of(dialogCtx).pop();
            bloc.add(DeleteProfileEvent(profile.id));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(totalProfiles > 1 ? 'Profil "${profile.username}" berhasil dihapus' : 'Profil berhasil direset'),
                backgroundColor: AppColors.neoCoral,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          child: Text(totalProfiles > 1 ? 'Hapus' : 'Reset', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        ),
      ],
    ),
  );
}
