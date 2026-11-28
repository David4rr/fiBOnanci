import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/formatters/app_currency.dart';
import '../../../domain/services/financial_report_service.dart';
import '../../../core/l10n/locale_notifier.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/common_widgets.dart';
import 'category_donut_chart.dart';

class FinancialReportBreakdownCards extends StatelessWidget {
  final FinancialReportData data;

  const FinancialReportBreakdownCards({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final fmt = AppCurrency.of(context);
    final wallets = data.walletBreakdown;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.surfaceSubtle,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.reportAssetsTitle,
                style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 0.6),
              ),
              const SizedBox(height: 12),
              _buildAssetRow(l10n.reportTotalNetWorth, data.totalNetWorth, fmt.format, AppColors.textWhite, isBold: true),
              Divider(color: AppColors.dividerSubtle, height: 20),
              _buildAssetRow(l10n.reportActiveWalletBalance, data.totalWalletBalance, fmt.format, AppColors.textWhite),
              const SizedBox(height: 8),
              _buildAssetRow(l10n.reportPocketBalance, data.totalPocketBalance, fmt.format, AppColors.textMuted),
              const SizedBox(height: 8),
              _buildAssetRow(l10n.reportCommittedBills, data.monthlyCommittedBills, fmt.format, AppColors.neoCoral),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.surfaceSubtle,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.reportWalletActivityTitle,
                style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 0.6),
              ),
              const SizedBox(height: 8),
              if (wallets.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: Text(l10n.reportEmptyWallets, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textMuted))),
                )
              else
                ...wallets.map((w) => _buildWalletRow(w, fmt.format)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAssetRow(
    String label,
    double value,
    String Function(double) formatFn,
    Color valueColor, {
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              color: isBold ? AppColors.textWhite : AppColors.textMuted,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: AnimatedCountingText(
            value: value,
            formatter: formatFn,
            style: GoogleFonts.plusJakartaSans(
              fontSize: isBold ? 13.5 : 12.5,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWalletRow(WalletReportItem w, String Function(double) formatFn) {
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
                AnimatedCountingText(
                  value: w.balance,
                  formatter: formatFn,
                  style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AnimatedCountingText(
                value: w.income,
                formatter: (v) => '+${formatFn(v)}',
                style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textIncome),
              ),
              const SizedBox(height: 2),
              AnimatedCountingText(
                value: w.expense,
                formatter: (v) => '-${formatFn(v)}',
                style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.neoCoral),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
