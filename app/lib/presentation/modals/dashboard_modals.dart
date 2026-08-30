import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../bloc/finance/finance_bloc.dart';
import '../../bloc/finance/finance_state.dart';
import '../../data/database/app_database.dart';
import '../../domain/services/financial_health_service.dart';
import '../../domain/services/safe_to_spend_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'budgeting_insights_modal.dart';
import 'financial_health_modal.dart';

Widget buildCalcRow(String label, String val, Color color, {bool isBold = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: AppColors.textWhite,
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          val,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    ),
  );
}

class WalletsListModal {
  static void show(BuildContext context, List<WalletEntry> wallets) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.canvasCardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textSubtle,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text('Rincian Saldo Rekening', style: AppTypography.sectionTitle),
              const SizedBox(height: 14),
              for (final w in wallets)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(int.parse(w.colorHex.replaceFirst('#', '0xFF'))),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(w.name, style: AppTypography.listTitle),
                      const Spacer(),
                      Text('Rp ${w.balance.toStringAsFixed(0)}', style: AppTypography.listAmount),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

class BillsListModal {
  static void show(BuildContext context, List<SubscriptionEntry> subscriptions) {
    BudgetingInsightsModal.show(context, subscriptions: subscriptions);
  }
}

class DailyPaceModal {
  static void show(BuildContext context, SafeToSpendMetrics metrics) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.canvasCardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textSubtle,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text('Alokasi Harian (Daily Pace)', style: AppTypography.sectionTitle),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.canvasInputSearch,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    buildCalcRow(
                      'Sisa Hari Bulan Ini',
                      '${metrics.daysRemainingInMonth} Hari',
                      AppColors.textWhite,
                    ),
                    const Divider(color: AppColors.canvasBorder),
                    buildCalcRow(
                      'Batas Aman Belanja / Hari',
                      'Rp ${metrics.safeToSpendDaily.toStringAsFixed(0)}',
                      AppColors.neoCyan,
                      isBold: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Menjaga belanja rata-rata harian Anda di bawah angka ini akan menjamin keuangan tetap surplus hingga akhir bulan.',
                style: AppTypography.listSubtitle,
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

class ProfileModal {
  static void show(BuildContext context, {required int walletCount, required int txCount}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.canvasCardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.textSubtle,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF1E212D),
                      ),
                      child: const Icon(Icons.person, color: AppColors.textWhite, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('David Arrozaqi', style: AppTypography.heroGreeting.copyWith(fontSize: 20)),
                        Text('Akun Lokal Offline-First', style: AppTypography.listSubtitle),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // AUDIT KESEHATAN FINANSIAL (HEALTHY FINANCE CHECK)
                BlocBuilder<FinanceBloc, FinanceState>(
                  builder: (context, state) {
                    final report = state.healthReport;
                    final Color tierColor = switch (report.tier) {
                      HealthTier.excellent => AppColors.neoMint,
                      HealthTier.good => AppColors.neoChartreuse,
                      HealthTier.caution => const Color(0xFFFBBF24),
                      HealthTier.deficit => const Color(0xFFEF4444),
                    };

                    return Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: tierColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: tierColor.withValues(alpha: 0.35)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: tierColor,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'AUDIT KESEHATAN FINANSIAL',
                                    style: AppTypography.badgeLabel.copyWith(color: tierColor),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: tierColor.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  report.tierLabel.toUpperCase(),
                                  style: TextStyle(
                                    color: tierColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Container(
                                width: 54,
                                height: 54,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: tierColor.withValues(alpha: 0.15),
                                  border: Border.all(color: tierColor, width: 2.5),
                                ),
                                child: Center(
                                  child: Text(
                                    '${report.overallScore}',
                                    style: AppTypography.heroGreeting.copyWith(
                                      fontSize: 20,
                                      color: tierColor,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      report.tierHeadline,
                                      style: AppTypography.listTitle.copyWith(fontSize: 14),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      'Dana Darurat: ${report.emergencyRunway.displayValue} • Tagihan: ${report.fixedCommitment.displayValue}',
                                      style: AppTypography.listSubtitle.copyWith(fontSize: 11.5),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(ctx).pop();
                              FinancialHealthModal.show(context);
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: tierColor,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Buka Hasil Audit Lengkap',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: AppColors.canvasBg,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(Icons.arrow_forward_rounded, color: AppColors.canvasBg, size: 16),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.canvasInputSearch,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      buildCalcRow('Total Rekening Terhubung', '$walletCount Akun', AppColors.textWhite),
                      const Divider(color: AppColors.canvasBorder),
                      buildCalcRow('Total Transaksi Tercatat', '$txCount Transaksi', AppColors.textWhite),
                      const Divider(color: AppColors.canvasBorder),
                      buildCalcRow('Status Database', 'SQLite Aktif (Offline)', AppColors.neoMint),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}
