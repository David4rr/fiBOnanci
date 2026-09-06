import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

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

  static final _currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static Widget buildDataRow({
    IconData? icon,
    required String label,
    required String value,
    Color? valueColor,
    bool isMuted = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
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
    final hasEmail = profile.email?.isNotEmpty == true;
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
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.carbonBlack,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            children: [
              buildDataRow(label: 'Profesi / Pekerjaan', value: hasOcc ? profile.occupation! : '—', isMuted: !hasOcc),
              Divider(color: Colors.white.withValues(alpha: 0.04), height: 1),
              buildDataRow(label: 'Email', value: hasEmail ? profile.email! : '—', isMuted: !hasEmail),
              Divider(color: Colors.white.withValues(alpha: 0.04), height: 1),
              buildDataRow(label: 'No. Handphone', value: hasPhone ? profile.phone! : '—', isMuted: !hasPhone),
              if (hasBio) ...[
                Divider(color: Colors.white.withValues(alpha: 0.04), height: 1),
                buildDataRow(label: 'Bio / Catatan', value: profile.bio!),
              ],
              Divider(color: Colors.white.withValues(alpha: 0.04), height: 1),
              buildDataRow(label: 'Mata Uang Utama', value: '${profile.currency} (${profile.currency == 'IDR' ? 'Rupiah' : profile.currency})'),
              Divider(color: Colors.white.withValues(alpha: 0.04), height: 1),
              buildDataRow(
                label: 'Target Pemasukan',
                value: hasIncome ? _currencyFormatter.format(profile.monthlyIncomeTarget) : '—',
                isMuted: !hasIncome,
              ),
              Divider(color: Colors.white.withValues(alpha: 0.04), height: 1),
              buildDataRow(label: 'Rekening Terhubung', value: '$walletCount Akun'),
              Divider(color: Colors.white.withValues(alpha: 0.04), height: 1),
              buildDataRow(label: 'Total Transaksi', value: '$txCount Tercatat'),
            ],
          ),
        ),
      ],
    );
  }
}
