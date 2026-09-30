import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../domain/services/safe_to_spend_service.dart';
import '../../../domain/services/financial_health_service.dart';
import '../../theme/app_colors.dart';
import '../financial_health_modal.dart';
import 'profile_card_painters.dart';

class ProfileActiveCardBody extends StatelessWidget {
  final SafeToSpendMetrics metrics;
  final FinancialHealthReport healthReport;
  final int wallets;
  final int txs;
  final int subs;
  final String burnFormatted;
  final int healthScore;
  final VoidCallback? onHealthDetails;

  const ProfileActiveCardBody({
    super.key,
    required this.metrics,
    required this.healthReport,
    required this.wallets,
    required this.txs,
    required this.subs,
    required this.burnFormatted,
    required this.healthScore,
    this.onHealthDetails,
  });

  Widget _buildStat(IconData icon, String val, String unit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.neoChartreuse, size: 14.5),
            const SizedBox(width: 4),
            Text(
              val,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        Text(
          unit,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AppColors.textMuted,
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
        const SizedBox(height: 12),
        ProfileFinancialTimelinePill(
          realBalance: metrics.totalRealBalance,
          pendingBills: metrics.pendingBills,
          safeToSpend: metrics.safeToSpendMonthly,
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        burnFormatted,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFEEEEEE),
                          letterSpacing: -0.8,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CustomPaint(size: Size(15, 14), painter: FinancialShieldPainter()),
                      const SizedBox(height: 2),
                      Text('Aman', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white)),
                      Text('Harian', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w500, color: AppColors.textMuted)),
                    ],
                  ),
                ],
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onHealthDetails ?? () => FinancialHealthModal.show(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '$healthScore',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        'SKOR',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  SizedBox(
                    width: 64,
                    height: 24,
                    child: CustomPaint(
                      painter: ProfileWaveChartPainter(
                        scores: [
                          healthReport.emergencyRunway.score,
                          healthReport.fixedCommitment.score,
                          healthReport.savingsMargin.score,
                          healthReport.spendPacing.score,
                          healthScore.toDouble(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildStat(Icons.account_balance_wallet_outlined, '$wallets', 'Rekening'),
            _buildStat(Icons.swap_horiz_rounded, '$txs', 'Transaksi'),
            _buildStat(Icons.event_repeat_rounded, '$subs', 'Tagihan Rutin'),
          ],
        ),
      ],
    );
  }
}
