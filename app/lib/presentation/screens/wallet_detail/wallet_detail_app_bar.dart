import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../data/database/app_database.dart';
import '../../theme/app_colors.dart';
import 'tactile_hero_card.dart';

class WalletDetailAppBar extends StatelessWidget {
  final WalletEntry wallet;
  final double headerBalanceOpacity;
  final NumberFormat currencyFormatter;

  const WalletDetailAppBar({
    super.key,
    required this.wallet,
    required this.headerBalanceOpacity,
    required this.currencyFormatter,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: EdgeInsets.only(
            top: MediaQuery.paddingOf(context).top + 6,
            bottom: 10,
            left: 16,
            right: 16,
          ),
          decoration: BoxDecoration(
            color: AppColors.canvasBg.withValues(alpha: 0.85),
            border: const Border(bottom: BorderSide(color: AppColors.canvasBorder, width: 0.8)),
          ),
          child: Row(
            children: [
              PressableScale(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.canvasCardSurface,
                    border: Border.all(color: AppColors.canvasBorder, width: 0.8),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textWhite, size: 16),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'Detail Rekening',
                            style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textWhite, letterSpacing: -0.3),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                                border: Border.all(color: AppColors.neoChartreuse.withValues(alpha: 0.35), width: 0.6),
                              ),
                              child: Text(
                                currencyFormatter.format(wallet.balance),
                                style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.neoChartreuse, fontFeatures: const [FontFeature.tabularFigures()]),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 1),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Informasi & Mutasi',
                            style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
