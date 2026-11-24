export 'profile_modal.dart';

import 'package:flutter/material.dart';
import '../../core/formatters/app_currency.dart';
import '../../domain/services/daily_pacing_nudge_service.dart';
import '../../domain/services/safe_to_spend_service.dart';
import '../widgets/common/common_widgets.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

Widget buildCalcRow(String label, String val, Color color, {bool isBold = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(label, style: TextStyle(color: AppColors.textWhite, fontSize: 13, fontWeight: isBold ? FontWeight.bold : FontWeight.normal), overflow: TextOverflow.ellipsis),
        ),
        const SizedBox(width: 8),
        Text(val, style: TextStyle(color: color, fontSize: 14, fontWeight: isBold ? FontWeight.bold : FontWeight.w600, fontFeatures: const [FontFeature.tabularFigures()])),
      ],
    ),
  );
}

class DailyPaceModal {
  static void show(
    BuildContext context,
    SafeToSpendMetrics metrics, {
    double todayExpense = 0.0,
    DateTime? referenceDate,
    int streak = 0,
  }) {
    final currencyFormatter = AppCurrency.read(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.canvasCardSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) {
        final remaining = metrics.safeToSpendDaily - todayExpense;
        final hasNoExpense = todayExpense <= 0;
        final isUnderBudget = remaining >= 0;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ModalGrabHandle(padding: EdgeInsets.only(bottom: 14)),
              ModalHeader(
                title: 'Alokasi Harian (Daily Pace)',
                subtitle: 'Batas belanja harian & ritme anggaran',
                onClose: () => Navigator.pop(ctx),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: hasNoExpense
                      ? AppColors.neoMint.withValues(alpha: 0.12)
                      : (isUnderBudget
                          ? AppColors.neoCyan.withValues(alpha: 0.12)
                          : AppColors.neoCoral.withValues(alpha: 0.12)),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: hasNoExpense
                        ? AppColors.neoMint.withValues(alpha: 0.25)
                        : (isUnderBudget
                            ? AppColors.neoCyan.withValues(alpha: 0.25)
                            : AppColors.neoCoral.withValues(alpha: 0.25)),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      hasNoExpense
                          ? Icons.savings_outlined
                          : (isUnderBudget ? Icons.check_circle_outline_rounded : Icons.info_outline_rounded),
                      color: hasNoExpense
                          ? AppColors.neoMint
                          : (isUnderBudget ? AppColors.neoCyan : AppColors.neoCoral),
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        DailyPacingNudgeService.getDetailedNudge(
                          metrics: metrics,
                          todayExpense: todayExpense,
                          referenceDate: referenceDate,
                          streak: streak,
                        ),
                        style: AppTypography.listSubtitle.copyWith(
                          color: AppColors.textWhite,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.canvasInputSearch, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    buildCalcRow('Sisa Hari Bulan Ini', '${metrics.daysRemainingInMonth} Hari', AppColors.textWhite),
                    Divider(color: AppColors.canvasBorder),
                    buildCalcRow('Batas Aman Belanja / Hari', currencyFormatter.format(metrics.safeToSpendDaily), AppColors.neoCyan, isBold: true),
                    Divider(color: AppColors.canvasBorder),
                    buildCalcRow(
                      'Pengeluaran Hari Ini',
                      currencyFormatter.format(todayExpense),
                      hasNoExpense ? AppColors.textMuted : (isUnderBudget ? AppColors.textIncome : AppColors.neoCoral),
                    ),
                    if (todayExpense > 0) ...[
                      const SizedBox(height: 4),
                      buildCalcRow(
                        isUnderBudget ? 'Sisa Kuota Hari Ini' : 'Melebihi Kuota',
                        currencyFormatter.format(remaining.abs()),
                        isUnderBudget ? AppColors.textIncome : AppColors.neoCoral,
                        isBold: true,
                      ),
                    ],
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
