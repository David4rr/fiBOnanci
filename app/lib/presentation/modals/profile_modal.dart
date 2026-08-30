import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../bloc/finance/finance_bloc.dart';
import '../../bloc/finance/finance_event.dart';
import '../../bloc/finance/finance_state.dart';
import '../../data/database/app_database.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/profile_avatar.dart';
import 'edit_profile_modal.dart';
import 'financial_health_modal.dart';

class ProfileModal extends StatelessWidget {
  final int walletCount;
  final int txCount;

  const ProfileModal({
    super.key,
    required this.walletCount,
    required this.txCount,
  });

  static void show(BuildContext context, {required int walletCount, required int txCount}) {
    final bloc = context.read<FinanceBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.canvasCardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => BlocProvider.value(
        value: bloc,
        child: ProfileModal(
          walletCount: walletCount,
          txCount: txCount,
        ),
      ),
    );
  }

  void _confirmDeleteProfile(BuildContext context, ProfileEntry profile, int totalProfiles) {
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
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textWhite,
                fontWeight: FontWeight.w700,
                fontSize: 17,
              ),
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
                  content: Text(
                    totalProfiles > 1
                        ? 'Profil "${profile.username}" berhasil dihapus'
                        : 'Profil berhasil direset',
                  ),
                  backgroundColor: AppColors.neoCoral,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(
              totalProfiles > 1 ? 'Hapus' : 'Reset',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return BlocBuilder<FinanceBloc, FinanceState>(
      builder: (context, state) {
        final profile = state.profile;
        final profiles = state.profiles;

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.90,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top drag indicator and header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.textSubtle,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Profil Pengguna',
                          style: AppTypography.heroGreeting.copyWith(fontSize: 20),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close, color: AppColors.textMuted, size: 20),
                          splashRadius: 20,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(color: AppColors.canvasBorder, height: 16),

              // Scrollable content
              Flexible(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                  children: [
                    // Profile Header Card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.canvasInputSearch,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: AppColors.canvasBorder),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => EditProfileModal.show(context, profile: profile),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    ProfileAvatar(
                                      avatarPath: profile.avatarPath,
                                      name: profile.username,
                                      size: 64,
                                      iconSize: 34,
                                    ),
                                    Positioned(
                                      right: -2,
                                      bottom: -2,
                                      child: Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.neoChartreuse,
                                          border: Border.all(color: const Color(0xFF17181F), width: 2),
                                        ),
                                        child: const Icon(
                                          Icons.camera_alt,
                                          size: 11,
                                          color: AppColors.textDarkPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            profile.fullName,
                                            style: AppTypography.heroGreeting.copyWith(fontSize: 18),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.neoMint.withValues(alpha: 0.18),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            'AKTIF',
                                            style: GoogleFonts.plusJakartaSans(
                                              color: AppColors.neoMint,
                                              fontSize: 9,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '@${profile.username}',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: AppColors.neoChartreuse,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      profile.occupation?.isNotEmpty == true
                                          ? profile.occupation!
                                          : 'Pengguna fiBOnanci',
                                      style: AppTypography.listSubtitle.copyWith(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Quick Action Buttons Row (Edit, Add, Delete)
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: GestureDetector(
                                  onTap: () => EditProfileModal.show(context, profile: profile),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                      color: AppColors.neoChartreuse,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.edit_outlined, color: AppColors.textDarkPrimary, size: 15),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Edit Profil',
                                              style: GoogleFonts.plusJakartaSans(
                                                color: AppColors.textDarkPrimary,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 12.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 3,
                                child: GestureDetector(
                                  onTap: () => EditProfileModal.show(context),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1E212D),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: AppColors.canvasBorder),
                                    ),
                                    child: Center(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.person_add_alt_1_outlined, color: AppColors.textWhite, size: 15),
                                            const SizedBox(width: 6),
                                            Text(
                                              '+ Profil Baru',
                                              style: GoogleFonts.plusJakartaSans(
                                                color: AppColors.textWhite,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => _confirmDeleteProfile(context, profile, profiles.length),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
                                  ),
                                  child: const Icon(
                                    Icons.delete_outline_rounded,
                                    color: Color(0xFFEF4444),
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Multi-profile Switcher Chips (if more than 1 profile exists)
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
                                  border: Border.all(
                                    color: isCurrent ? AppColors.neoChartreuse : AppColors.canvasBorder,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ProfileAvatar(
                                      avatarPath: p.avatarPath,
                                      name: p.username,
                                      size: 24,
                                      iconSize: 13,
                                    ),
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

                    // General Data Section
                    Text(
                      'DATA UMUM & DETAIL AKUN',
                      style: AppTypography.badgeLabel.copyWith(color: AppColors.neoChartreuse),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.canvasInputSearch,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.canvasBorder),
                      ),
                      child: Column(
                        children: [
                          _buildDataRow(
                            icon: Icons.alternate_email_rounded,
                            label: 'Username',
                            value: '@${profile.username}',
                            valueColor: AppColors.neoChartreuse,
                          ),
                          const Divider(color: AppColors.canvasBorder, height: 20),
                          _buildDataRow(
                            icon: Icons.badge_outlined,
                            label: 'Nama Lengkap',
                            value: profile.fullName,
                          ),
                          const Divider(color: AppColors.canvasBorder, height: 20),
                          _buildDataRow(
                            icon: Icons.mail_outline_rounded,
                            label: 'Email',
                            value: profile.email?.isNotEmpty == true ? profile.email! : 'Belum diatur',
                            isMuted: profile.email?.isEmpty ?? true,
                          ),
                          const Divider(color: AppColors.canvasBorder, height: 20),
                          _buildDataRow(
                            icon: Icons.phone_outlined,
                            label: 'No. Handphone',
                            value: profile.phone?.isNotEmpty == true ? profile.phone! : 'Belum diatur',
                            isMuted: profile.phone?.isEmpty ?? true,
                          ),
                          const Divider(color: AppColors.canvasBorder, height: 20),
                          _buildDataRow(
                            icon: Icons.work_outline_rounded,
                            label: 'Profesi / Pekerjaan',
                            value: profile.occupation?.isNotEmpty == true ? profile.occupation! : 'Belum diatur',
                            isMuted: profile.occupation?.isEmpty ?? true,
                          ),
                          const Divider(color: AppColors.canvasBorder, height: 20),
                          _buildDataRow(
                            icon: Icons.notes_rounded,
                            label: 'Bio / Catatan',
                            value: profile.bio?.isNotEmpty == true ? profile.bio! : 'Belum diatur',
                            isMuted: profile.bio?.isEmpty ?? true,
                          ),
                          const Divider(color: AppColors.canvasBorder, height: 20),
                          _buildDataRow(
                            icon: Icons.monetization_on_outlined,
                            label: 'Mata Uang Utama',
                            value: '${profile.currency} (${profile.currency == 'IDR' ? 'Rupiah' : profile.currency})',
                          ),
                          const Divider(color: AppColors.canvasBorder, height: 20),
                          _buildDataRow(
                            icon: Icons.savings_outlined,
                            label: 'Target Pemasukan',
                            value: profile.monthlyIncomeTarget != null && profile.monthlyIncomeTarget! > 0
                                ? currencyFormatter.format(profile.monthlyIncomeTarget)
                                : 'Belum ditentukan',
                            valueColor: profile.monthlyIncomeTarget != null && profile.monthlyIncomeTarget! > 0
                                ? AppColors.neoMint
                                : null,
                            isMuted: profile.monthlyIncomeTarget == null || profile.monthlyIncomeTarget! <= 0,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Financial Statistics Summary
                    Text(
                      'STATISTIK FINANSIAL AKUN',
                      style: AppTypography.badgeLabel.copyWith(color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.canvasInputSearch,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.canvasBorder),
                      ),
                      child: Column(
                        children: [
                          _buildDataRow(
                            icon: Icons.account_balance_wallet_outlined,
                            label: 'Total Rekening Terhubung',
                            value: '$walletCount Rekening',
                            valueColor: AppColors.neoCyan,
                          ),
                          const Divider(color: AppColors.canvasBorder, height: 20),
                          _buildDataRow(
                            icon: Icons.receipt_long_outlined,
                            label: 'Total Transaksi Tercatat',
                            value: '$txCount Transaksi',
                            valueColor: AppColors.neoMint,
                          ),
                          const Divider(color: AppColors.canvasBorder, height: 20),
                          _buildDataRow(
                            icon: Icons.storage_rounded,
                            label: 'Penyimpanan Data',
                            value: 'SQLite 100% On-Device',
                            valueColor: AppColors.neoChartreuse,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Health Audit Shortcut (accessible from Profile)
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
                              decoration: BoxDecoration(
                                color: AppColors.neoMint.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.health_and_safety_outlined, color: AppColors.neoMint, size: 20),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Audit Kesehatan Finansial',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: AppColors.textWhite,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13.5,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Periksa runway darurat, rasio cicilan & tabungan',
                                    style: AppTypography.listSubtitle.copyWith(fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textMuted, size: 13),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDataRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    bool isMuted = false,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textMuted, size: 17),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.textMuted,
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: GoogleFonts.plusJakartaSans(
              color: valueColor ?? (isMuted ? AppColors.textSubtle : AppColors.textWhite),
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
