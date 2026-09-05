import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../data/database/app_database.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class WalletDetailAppBar extends StatelessWidget {
  final WalletEntry wallet;
  final double headerBalanceOpacity;
  final NumberFormat currencyFormatter;
  final VoidCallback? onDismiss;

  const WalletDetailAppBar({
    super.key,
    required this.wallet,
    required this.headerBalanceOpacity,
    required this.currencyFormatter,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detail Rekening',
                      style: AppTypography.modalTitle,
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'Informasi & Mutasi',
                            style: AppTypography.modalSubtitle,
                          ),
                        ),
                        if (headerBalanceOpacity > 0.1) ...[
                          const SizedBox(width: 8),
                          Opacity(
                            opacity: headerBalanceOpacity,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.neoChartreuse.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: AppColors.neoChartreuse.withValues(alpha: 0.35),
                                  width: 0.6,
                                ),
                              ),
                              child: Text(
                                currencyFormatter.format(wallet.balance),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.neoChartreuse,
                                  fontFeatures: const [FontFeature.tabularFigures()],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                key: const ValueKey('wallet_detail_dismiss_button'),
                onPressed: onDismiss ?? () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 28,
                  color: AppColors.textWhite,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
