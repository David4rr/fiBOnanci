import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/formatters/app_currency.dart';
import '../../../data/database/app_database.dart';
import '../../theme/app_colors.dart';

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

  static Widget buildDataRow({
    IconData? icon,
    required String label,
    required String value,
    Color? valueColor,
    bool isMuted = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: valueColor ?? (isMuted ? AppColors.textMuted : AppColors.textWhite),
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasIncome = profile.monthlyIncomeTarget != null && profile.monthlyIncomeTarget! > 0;
    final hasPhone = profile.phone?.isNotEmpty == true;
    final hasOcc = profile.occupation?.isNotEmpty == true;
    final hasBio = profile.bio?.isNotEmpty == true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DATA UMUM & DETAIL AKUN',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: AppColors.textMuted,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        buildDataRow(label: 'Profesi / Pekerjaan', value: hasOcc ? profile.occupation! : '—', isMuted: !hasOcc),
        buildDataRow(label: 'No. Handphone', value: hasPhone ? profile.phone! : '—', isMuted: !hasPhone),
        if (hasBio) buildDataRow(label: 'Bio / Catatan', value: profile.bio!),
        buildDataRow(label: 'Mata Uang Utama', value: '${profile.currency} (${profile.currency == 'IDR' ? 'Rupiah' : profile.currency})'),
        buildDataRow(
          label: 'Target Pemasukan',
          value: hasIncome ? AppCurrency.forCode(profile.currency).format(profile.monthlyIncomeTarget) : '—',
          isMuted: !hasIncome,
        ),
        buildDataRow(label: 'Rekening Terhubung', value: '$walletCount Akun'),
        buildDataRow(label: 'Total Transaksi', value: '$txCount Tercatat'),
      ],
    );
  }
}
