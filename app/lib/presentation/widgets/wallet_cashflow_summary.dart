import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import 'common/peekable_balance_text.dart';

/// Compact minimalist monthly income & expense summary strip.
class WalletCashflowSummary extends StatelessWidget {
  final double monthlyIncome;
  final double monthlyExpense;
  final NumberFormat currencyFormatter;

  const WalletCashflowSummary({
    super.key,
    required this.monthlyIncome,
    required this.monthlyExpense,
    required this.currencyFormatter,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildCompactFlowRow(
          label: 'Masuk',
          amount: '+${currencyFormatter.format(monthlyIncome)}',
          color: AppColors.neoMint,
        ),
        const SizedBox(height: 5),
        _buildCompactFlowRow(
          label: 'Keluar',
          amount: '-${currencyFormatter.format(monthlyExpense)}',
          color: AppColors.neoCoral,
        ),
      ],
    );
  }

  Widget _buildCompactFlowRow({
    required String label,
    required String amount,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10.5,
            fontWeight: FontWeight.w500,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: PeekableBalanceText(
            text: amount,
            iconSize: 12,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: color,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ],
    );
  }
}
