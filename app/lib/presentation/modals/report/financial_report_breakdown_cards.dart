import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../domain/services/financial_report_service.dart';
import '../../theme/app_colors.dart';
import 'category_donut_chart.dart';

class FinancialReportBreakdownCards extends StatelessWidget {
  final FinancialReportData data;

  const FinancialReportBreakdownCards({super.key, required this.data});

  static final _fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  Widget build(BuildContext context) {
    final wallets = data.walletBreakdown;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'POSISI ASET & KEWAJIBAN',
                style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 0.6),
              ),
              const SizedBox(height: 12),
              _buildAssetRow('Total Kekayaan Bersih', _fmt.format(data.totalNetWorth), AppColors.textWhite, isBold: true),
              Divider(color: Colors.white.withValues(alpha: 0.06), height: 20),
              _buildAssetRow('Saldo Rekening Aktif', _fmt.format(data.totalWalletBalance), AppColors.textWhite),
              const SizedBox(height: 8),
              _buildAssetRow('Dana Kantong Tabungan', _fmt.format(data.totalPocketBalance), AppColors.textMuted),
              const SizedBox(height: 8),
              _buildAssetRow('Komitmen Tagihan Bulanan', _fmt.format(data.monthlyCommittedBills), AppColors.neoCoral),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AKTIVITAS PER REKENING',
                style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 0.6),
              ),
              const SizedBox(height: 8),
              if (wallets.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: Text('Belum ada rekening aktif', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textMuted))),
                )
              else
                ...wallets.map(_buildWalletRow),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAssetRow(String label, String value, Color valueColor, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: isBold ? AppColors.textWhite : AppColors.textMuted, fontWeight: isBold ? FontWeight.w600 : FontWeight.w400),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(fontSize: isBold ? 13.5 : 12.5, fontWeight: isBold ? FontWeight.w700 : FontWeight.w600, color: valueColor, fontFeatures: const [FontFeature.tabularFigures()]),
          ),
        ),
      ],
    );
  }

  Widget _buildWalletRow(WalletReportItem w) {
    final dotColor = CategoryDonutChart.resolveSliceColor(w.colorHex, false, 1);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(width: 7, height: 7, decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(w.name, style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textWhite)),
                Text(_fmt.format(w.balance), style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textMuted, fontFeatures: const [FontFeature.tabularFigures()])),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('+${_fmt.format(w.income)}', style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.neoMint, fontFeatures: const [FontFeature.tabularFigures()])),
              const SizedBox(height: 2),
              Text('-${_fmt.format(w.expense)}', style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.neoCoral, fontFeatures: const [FontFeature.tabularFigures()])),
            ],
          ),
        ],
      ),
    );
  }
}
