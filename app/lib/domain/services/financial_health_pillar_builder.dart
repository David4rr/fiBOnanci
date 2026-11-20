import '../../data/database/app_database.dart';
import 'cashflow_analytics_service.dart';
import 'financial_health_models.dart';
import 'safe_to_spend_service.dart';

/// Builder calculating concrete financial health pillars with explicit Rupiah allocation targets.
class FinancialHealthPillarBuilder {
  static String formatRupiah(double amount) {
    final s = amount.round().abs().toString();
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
      b.write(s[i]);
    }
    return 'Rp ${amount < 0 ? '-' : ''}$b';
  }

  /// PILAR 1: DANA DARURAT (RUNWAY) - 3-6 bulan itu berapa Rupiah dari uang yang dipegang
  static HealthPillarMetric buildEmergencyPillar({
    required double totalLiquidAssets,
    required double emergencyAndRetirementPockets,
    required double monthlyExpenseBenchmark,
    double dedicatedEmergencyPocketAmount = 0.0,
    bool hasEmergencyPocket = false,
  }) {
    final totalEmergencyBuffer = totalLiquidAssets + emergencyAndRetirementPockets;
    final runwayMonths = monthlyExpenseBenchmark > 0 ? (totalEmergencyBuffer / monthlyExpenseBenchmark) : 0.0;

    double score;
    if (runwayMonths >= 6.0) {
      score = 100.0;
    } else if (runwayMonths >= 3.0) {
      score = 70.0 + ((runwayMonths - 3.0) / 3.0) * 30.0;
    } else if (runwayMonths >= 1.0) {
      score = 40.0 + ((runwayMonths - 1.0) / 2.0) * 30.0;
    } else {
      score = (runwayMonths.clamp(0.0, 1.0)) * 40.0;
    }

    final target3Months = monthlyExpenseBenchmark * 3;
    final target6Months = monthlyExpenseBenchmark * 6;

    final String rec;
    if (hasEmergencyPocket) {
      if (dedicatedEmergencyPocketAmount < target3Months) {
        final gap = target3Months - dedicatedEmergencyPocketAmount;
        final fromBal = totalLiquidAssets >= gap ? ' dari rekening (${formatRupiah(totalLiquidAssets)})' : '';
        rec = 'Di Kantong: ${formatRupiah(dedicatedEmergencyPocketAmount)} • Rekomendasi isi ${formatRupiah(gap)}$fromBal menuju 3 bln (${formatRupiah(target3Months)})';
      } else if (dedicatedEmergencyPocketAmount < target6Months) {
        final gap = target6Months - dedicatedEmergencyPocketAmount;
        rec = 'Kantong Darurat (${formatRupiah(dedicatedEmergencyPocketAmount)}) aman 3 bln! • Tambah ${formatRupiah(gap)} menuju 6 bln (${formatRupiah(target6Months)})';
      } else {
        rec = 'Kantong Darurat prima (${formatRupiah(dedicatedEmergencyPocketAmount)})! • Target 6 bln (${formatRupiah(target6Months)}) terpenuhi penuh';
      }
    } else {
      if (totalLiquidAssets < target3Months) {
        final gap = target3Months - totalLiquidAssets;
        rec = 'Target 3 bln: ${formatRupiah(target3Months)} • Rekomendasi buat Kantong Darurat & isi ${formatRupiah(gap)} (saldo ${formatRupiah(totalLiquidAssets)})';
      } else {
        rec = 'Saldo rekening ${formatRupiah(totalLiquidAssets)} cukup 3 bln (${formatRupiah(target3Months)}) • Rekomendasi kunci ke Kantong Darurat agar aman';
      }
    }

    return HealthPillarMetric(
      title: 'Dana Darurat (Runway)',
      description: hasEmergencyPocket ? 'Cadangan di Kantong Darurat & saldo kas' : 'Kemampuan bertahan jika tanpa pemasukan',
      score: score.clamp(0.0, 100.0),
      displayValue: '${runwayMonths.toStringAsFixed(1)} Bulan',
      benchmark: 'Ideal: ≥ 3–6 Bulan',
      isHealthy: runwayMonths >= 3.0,
      allocationRecommendation: rec,
      currentNominal: hasEmergencyPocket ? dedicatedEmergencyPocketAmount : totalEmergencyBuffer,
      targetNominal: target3Months,
    );
  }

  /// PILAR 2: BEBAN TAGIHAN TETAP
  static HealthPillarMetric buildCommitmentPillar({
    required List<SubscriptionEntry> subscriptions,
    required double monthlyIncomeBenchmark,
  }) {
    double totalRecurringBills = 0.0;
    for (final s in subscriptions) {
      totalRecurringBills += s.cost;
    }
    final commitmentRatio = monthlyIncomeBenchmark > 0 ? (totalRecurringBills / monthlyIncomeBenchmark) * 100.0 : 0.0;

    double score;
    if (commitmentRatio <= 20.0) {
      score = 100.0;
    } else if (commitmentRatio <= 35.0) {
      score = 80.0 + ((35.0 - commitmentRatio) / 15.0) * 20.0;
    } else if (commitmentRatio <= 50.0) {
      score = 50.0 + ((50.0 - commitmentRatio) / 15.0) * 30.0;
    } else {
      score = (100.0 - commitmentRatio).clamp(10.0, 50.0);
    }

    final maxIdealBills = monthlyIncomeBenchmark * 0.30;
    final String rec = commitmentRatio <= 30.0
        ? 'Tagihan ${formatRupiah(totalRecurringBills)}/bln • Batas ideal 30%: Maks ${formatRupiah(maxIdealBills)}/bln (Sangat Aman)'
        : 'Tagihan ${formatRupiah(totalRecurringBills)}/bln lewat 30% (${formatRupiah(maxIdealBills)}/bln) • Pangkas ${formatRupiah(totalRecurringBills - maxIdealBills)}';

    return HealthPillarMetric(
      title: 'Beban Tagihan Tetap',
      description: 'Porsi langganan & cicilan dari pemasukan',
      score: score.clamp(0.0, 100.0),
      displayValue: '${commitmentRatio.toStringAsFixed(0)}%',
      benchmark: 'Ideal: ≤ 30%',
      isHealthy: commitmentRatio <= 35.0,
      allocationRecommendation: rec,
      currentNominal: totalRecurringBills,
      targetNominal: maxIdealBills,
    );
  }

  /// PILAR 3: MARGIN TABUNGAN BERSIH
  static HealthPillarMetric buildSavingsPillar({
    required MonthlyCashflow monthlyCashflow,
    required double monthlyIncomeBenchmark,
  }) {
    final netSavings = monthlyCashflow.income - monthlyCashflow.expense;
    final savingsMarginPercent = monthlyIncomeBenchmark > 0 ? (netSavings / monthlyIncomeBenchmark) * 100.0 : 0.0;

    double score;
    if (savingsMarginPercent >= 20.0) {
      score = 100.0;
    } else if (savingsMarginPercent >= 10.0) {
      score = 70.0 + ((savingsMarginPercent - 10.0) / 10.0) * 30.0;
    } else if (savingsMarginPercent >= 0.0) {
      score = 40.0 + (savingsMarginPercent / 10.0) * 30.0;
    } else {
      score = (40.0 + savingsMarginPercent).clamp(0.0, 40.0);
    }

    final targetSavings = monthlyIncomeBenchmark * 0.20;
    final String rec;
    if (netSavings >= targetSavings) {
      rec = 'Tabungan ${formatRupiah(netSavings)}/bln • Target 20% (${formatRupiah(targetSavings)}/bln) tercapai prima!';
    } else if (netSavings > 0) {
      rec = 'Tabungan ${formatRupiah(netSavings)}/bln • Rekomendasi tambah ${formatRupiah(targetSavings - netSavings)}/bln menuju 20%';
    } else {
      rec = 'Arus kas defisit • Rem belanja agar bisa menabung target 20% (${formatRupiah(targetSavings)}/bln)';
    }

    return HealthPillarMetric(
      title: 'Margin Tabungan Bersih',
      description: 'Sisa arus kas yang berhasil disimpan',
      score: score.clamp(0.0, 100.0),
      displayValue: '${savingsMarginPercent.toStringAsFixed(0)}%',
      benchmark: 'Ideal: ≥ 15–20%',
      isHealthy: savingsMarginPercent >= 10.0,
      allocationRecommendation: rec,
      currentNominal: netSavings,
      targetNominal: targetSavings,
    );
  }

  /// PILAR 4: SPEND PACING
  static HealthPillarMetric buildPacingPillar({
    required SafeToSpendMetrics safeToSpend,
  }) {
    double score;
    switch (safeToSpend.healthStatus) {
      case FinancialHealthStatus.comfortable:
        score = 100.0;
        break;
      case FinancialHealthStatus.caution:
        score = 65.0;
        break;
      case FinancialHealthStatus.deficit:
        score = 25.0;
        break;
    }

    final String rec;
    if (safeToSpend.healthStatus == FinancialHealthStatus.comfortable) {
      rec = 'Batas belanja aman ${formatRupiah(safeToSpend.safeToSpendDaily)}/hari • Sisa Safe-to-Spend: ${formatRupiah(safeToSpend.safeToSpendMonthly)}';
    } else if (safeToSpend.healthStatus == FinancialHealthStatus.caution) {
      rec = 'Pacing waspada • Jaga belanja maksimal ${formatRupiah(safeToSpend.safeToSpendDaily)}/hari agar saldo tidak tergerus';
    } else {
      rec = 'Anggaran defisit • Tunda pengeluaran variabel dan dahulukan kebutuhan esensial';
    }

    return HealthPillarMetric(
      title: 'Disiplin Belanja Harian',
      description: 'Kepatuhan pengeluaran terhadap batas aman',
      score: score,
      displayValue: safeToSpend.statusLabel,
      benchmark: 'Target: Sangat Aman',
      isHealthy: safeToSpend.healthStatus == FinancialHealthStatus.comfortable,
      allocationRecommendation: rec,
      currentNominal: safeToSpend.safeToSpendDaily,
      targetNominal: safeToSpend.safeToSpendMonthly,
    );
  }
}
