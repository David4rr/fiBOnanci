import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/l10n/locale_notifier.dart';
import '../theme/app_colors.dart';
import 'common/common_widgets.dart';

/// Compact minimalist monthly income & expense summary strip with counting animation.
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
    final l10n = AppL10n.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildCompactFlowRow(
          label: l10n.walletsFlowIn,
          value: monthlyIncome,
          prefix: '+',
          color: AppColors.textIncome,
        ),
        const SizedBox(height: 5),
        _buildCompactFlowRow(
          label: l10n.walletsFlowOut,
          value: monthlyExpense,
          prefix: '-',
          color: AppColors.neoCoral,
        ),
      ],
    );
  }

  Widget _buildCompactFlowRow({
    required String label,
    required double value,
    required String prefix,
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
          child: AnimatedCountingText(
            value: value,
            formatter: (v) => '$prefix${currencyFormatter.format(v)}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
