import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../bloc/finance/finance_bloc.dart';
import '../../../bloc/finance/finance_event.dart';
import '../../../data/database/app_database.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/notification_simulator_modal.dart';
import '../../widgets/profile_avatar.dart';
import '../financial_health_modal.dart';

class ProfileActions extends StatelessWidget {
  final ProfileEntry profile;
  final List<ProfileEntry> profiles;

  const ProfileActions({
    super.key,
    required this.profile,
    required this.profiles,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (profiles.length > 1) ...[
          const SizedBox(height: 18),
          Text(
            'DAFTAR PROFIL TERSIMPAN (${profiles.length})',
            style: AppTypography.badgeLabel.copyWith(color: AppColors.neoCyan),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: profiles.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (ctx, i) {
                final p = profiles[i];
                final isCurrent = p.id == profile.id;
                return GestureDetector(
                  onTap: () {
                    if (!isCurrent) {
                      context.read<FinanceBloc>().add(SetActiveProfileEvent(p.id));
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isCurrent ? AppColors.neoChartreuse : AppColors.canvasInputSearch,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isCurrent ? AppColors.neoChartreuse : AppColors.canvasBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ProfileAvatar(avatarPath: p.avatarPath, name: p.username, size: 24, iconSize: 13),
                        const SizedBox(width: 8),
                        Text(
                          p.username,
                          style: GoogleFonts.plusJakartaSans(
                            color: isCurrent ? AppColors.textDarkPrimary : AppColors.textWhite,
                            fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
            FinancialHealthModal.show(context);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF1E212D),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.canvasBorder),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(color: AppColors.neoMint.withValues(alpha: 0.15), shape: BoxShape.circle),
                  child: const Icon(Icons.health_and_safety_outlined, color: AppColors.neoMint, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Audit Kesehatan Finansial', style: GoogleFonts.plusJakartaSans(color: AppColors.textWhite, fontWeight: FontWeight.w700, fontSize: 13.5)),
                      const SizedBox(height: 2),
                      Text('Periksa runway darurat, rasio cicilan & tabungan', style: AppTypography.listSubtitle.copyWith(fontSize: 11)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textMuted, size: 13),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
            NotificationSimulatorModal.show(context);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF1E212D),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.canvasBorder),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(color: AppColors.neoChartreuse.withValues(alpha: 0.15), shape: BoxShape.circle),
                  child: const Icon(Icons.flash_on_rounded, color: AppColors.neoChartreuse, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Simulator Notifikasi Bank', style: GoogleFonts.plusJakartaSans(color: AppColors.textWhite, fontWeight: FontWeight.w700, fontSize: 13.5)),
                      const SizedBox(height: 2),
                      Text('Uji coba parsing BCA, blu, Mandiri, Jago, SeaBank, OVO', style: AppTypography.listSubtitle.copyWith(fontSize: 11)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textMuted, size: 13),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
