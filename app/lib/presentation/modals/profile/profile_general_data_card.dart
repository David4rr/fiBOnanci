import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../data/database/app_database.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class ProfileGeneralDataCard extends StatelessWidget {
  final ProfileEntry profile;
  final int walletCount;
  final int txCount;

  const ProfileGeneralDataCard({
    super.key,
    required this.profile,
    required this.walletCount,
    required this.txCount,
  });

  static final _currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static Widget buildDataRow({
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
            style: GoogleFonts.plusJakartaSans(color: AppColors.textMuted, fontSize: 12.5, fontWeight: FontWeight.w500),
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('DATA UMUM & DETAIL AKUN', style: AppTypography.badgeLabel.copyWith(color: AppColors.neoChartreuse)),
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
              buildDataRow(icon: Icons.alternate_email_rounded, label: 'Username', value: '@${profile.username}', valueColor: AppColors.neoChartreuse),
              const Divider(color: AppColors.canvasBorder, height: 20),
              buildDataRow(icon: Icons.badge_outlined, label: 'Nama Lengkap', value: profile.fullName),
              const Divider(color: AppColors.canvasBorder, height: 20),
              buildDataRow(icon: Icons.mail_outline_rounded, label: 'Email', value: profile.email?.isNotEmpty == true ? profile.email! : 'Belum diatur', isMuted: profile.email?.isEmpty ?? true),
              const Divider(color: AppColors.canvasBorder, height: 20),
              buildDataRow(icon: Icons.phone_outlined, label: 'No. Handphone', value: profile.phone?.isNotEmpty == true ? profile.phone! : 'Belum diatur', isMuted: profile.phone?.isEmpty ?? true),
              const Divider(color: AppColors.canvasBorder, height: 20),
              buildDataRow(icon: Icons.work_outline_rounded, label: 'Profesi / Pekerjaan', value: profile.occupation?.isNotEmpty == true ? profile.occupation! : 'Belum diatur', isMuted: profile.occupation?.isEmpty ?? true),
              const Divider(color: AppColors.canvasBorder, height: 20),
              buildDataRow(icon: Icons.notes_rounded, label: 'Bio / Catatan', value: profile.bio?.isNotEmpty == true ? profile.bio! : 'Belum diatur', isMuted: profile.bio?.isEmpty ?? true),
              const Divider(color: AppColors.canvasBorder, height: 20),
              buildDataRow(icon: Icons.monetization_on_outlined, label: 'Mata Uang Utama', value: '${profile.currency} (${profile.currency == 'IDR' ? 'Rupiah' : profile.currency})'),
              const Divider(color: AppColors.canvasBorder, height: 20),
              buildDataRow(
                icon: Icons.savings_outlined,
                label: 'Target Pemasukan',
                value: profile.monthlyIncomeTarget != null && profile.monthlyIncomeTarget! > 0
                    ? _currencyFormatter.format(profile.monthlyIncomeTarget)
                    : 'Belum ditentukan',
                valueColor: profile.monthlyIncomeTarget != null && profile.monthlyIncomeTarget! > 0 ? AppColors.neoMint : null,
                isMuted: profile.monthlyIncomeTarget == null || profile.monthlyIncomeTarget! <= 0,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text('STATISTIK FINANSIAL AKUN', style: AppTypography.badgeLabel.copyWith(color: AppColors.textMuted)),
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
              buildDataRow(icon: Icons.account_balance_wallet_outlined, label: 'Total Rekening Terhubung', value: '$walletCount Rekening', valueColor: AppColors.neoCyan),
              const Divider(color: AppColors.canvasBorder, height: 20),
              buildDataRow(icon: Icons.receipt_long_outlined, label: 'Total Transaksi Tercatat', value: '$txCount Transaksi', valueColor: AppColors.neoMint),
              const Divider(color: AppColors.canvasBorder, height: 20),
              buildDataRow(icon: Icons.storage_rounded, label: 'Penyimpanan Data', value: 'SQLite 100% On-Device', valueColor: AppColors.neoChartreuse),
            ],
          ),
        ),
      ],
    );
  }
}
