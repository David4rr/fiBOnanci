import '../../data/database/app_database.dart';
import 'cashflow_analytics_service.dart';
import 'financial_health_models.dart';
import 'financial_health_recommendations.dart';
import 'safe_to_spend_service.dart';

export 'financial_health_models.dart';

/// Pure Dart domain engine for comprehensive personal finance health diagnostics.
class FinancialHealthService {
  /// Evaluates financial health based on liquid assets, pockets, recurring bills,
  /// cashflow trends, and safe-to-spend pacing.
  static FinancialHealthReport evaluate({
    required List<WalletEntry> wallets,
    required List<PocketEntry> pockets,
    required List<SubscriptionEntry> subscriptions,
    required MonthlyCashflow monthlyCashflow,
    required SafeToSpendMetrics safeToSpend,
    DateTime? referenceDate,
  }) {
    double totalLiquidAssets = 0.0;
    for (final w in wallets) {
      totalLiquidAssets += w.balance;
    }

    double totalPocketsAmount = 0.0;
    double emergencyAndRetirementPockets = 0.0;
    for (final p in pockets) {
      totalPocketsAmount += p.currentAmount;
      if (p.type == 'emergency' || p.type == 'retirement' || p.type == 'savings') {
        emergencyAndRetirementPockets += p.currentAmount;
      }
    }

    double monthlyExpenseBenchmark = monthlyCashflow.expense;
    if (monthlyExpenseBenchmark <= 0) {
      double subSum = 0.0;
      for (final s in subscriptions) {
        subSum += s.cost;
      }
      monthlyExpenseBenchmark = subSum > 0 ? subSum : 1000000.0;
    }

    double monthlyIncomeBenchmark = monthlyCashflow.income;
    if (monthlyIncomeBenchmark <= 0) {
      monthlyIncomeBenchmark = monthlyExpenseBenchmark > 0 ? monthlyExpenseBenchmark : 1000000.0;
    }

    // PILAR 1: EMERGENCY RUNWAY (30%)
    final double totalEmergencyBuffer = totalLiquidAssets + emergencyAndRetirementPockets;
    final double runwayMonths = monthlyExpenseBenchmark > 0
        ? (totalEmergencyBuffer / monthlyExpenseBenchmark)
        : 0.0;

    double emergencyScore;
    if (runwayMonths >= 6.0) {
      emergencyScore = 100.0;
    } else if (runwayMonths >= 3.0) {
      emergencyScore = 70.0 + ((runwayMonths - 3.0) / 3.0) * 30.0;
    } else if (runwayMonths >= 1.0) {
      emergencyScore = 40.0 + ((runwayMonths - 1.0) / 2.0) * 30.0;
    } else {
      emergencyScore = (runwayMonths.clamp(0.0, 1.0)) * 40.0;
    }

    final emergencyPillar = HealthPillarMetric(
      title: 'Dana Darurat (Runway)',
      description: 'Kemampuan bertahan jika tanpa pemasukan',
      score: emergencyScore.clamp(0.0, 100.0),
      displayValue: '${runwayMonths.toStringAsFixed(1)} Bulan',
      benchmark: 'Ideal: ≥ 3–6 Bulan',
      isHealthy: runwayMonths >= 3.0,
    );

    // PILAR 2: FIXED COMMITMENT RATIO (25%)
    double totalRecurringBills = 0.0;
    for (final s in subscriptions) {
      totalRecurringBills += s.cost;
    }

    final double commitmentRatio = monthlyIncomeBenchmark > 0
        ? (totalRecurringBills / monthlyIncomeBenchmark) * 100.0
        : 0.0;

    double commitmentScore;
    if (commitmentRatio <= 20.0) {
      commitmentScore = 100.0;
    } else if (commitmentRatio <= 35.0) {
      commitmentScore = 80.0 + ((35.0 - commitmentRatio) / 15.0) * 20.0;
    } else if (commitmentRatio <= 50.0) {
      commitmentScore = 50.0 + ((50.0 - commitmentRatio) / 15.0) * 30.0;
    } else {
      commitmentScore = (100.0 - commitmentRatio).clamp(10.0, 50.0);
    }

    final commitmentPillar = HealthPillarMetric(
      title: 'Beban Tagihan Tetap',
      description: 'Porsi langganan & cicilan dari pemasukan',
      score: commitmentScore.clamp(0.0, 100.0),
      displayValue: '${commitmentRatio.toStringAsFixed(0)}%',
      benchmark: 'Ideal: ≤ 30%',
      isHealthy: commitmentRatio <= 35.0,
    );

    // PILAR 3: NET SAVINGS MARGIN (25%)
    final double netSavings = monthlyCashflow.income - monthlyCashflow.expense;
    final double savingsMarginPercent = monthlyIncomeBenchmark > 0
        ? (netSavings / monthlyIncomeBenchmark) * 100.0
        : 0.0;

    double savingsScore;
    if (savingsMarginPercent >= 20.0) {
      savingsScore = 100.0;
    } else if (savingsMarginPercent >= 10.0) {
      savingsScore = 70.0 + ((savingsMarginPercent - 10.0) / 10.0) * 30.0;
    } else if (savingsMarginPercent >= 0.0) {
      savingsScore = 40.0 + (savingsMarginPercent / 10.0) * 30.0;
    } else {
      savingsScore = (40.0 + savingsMarginPercent).clamp(0.0, 40.0);
    }

    final savingsPillar = HealthPillarMetric(
      title: 'Margin Tabungan Bersih',
      description: 'Sisa arus kas yang berhasil disimpan',
      score: savingsScore.clamp(0.0, 100.0),
      displayValue: '${savingsMarginPercent.toStringAsFixed(0)}%',
      benchmark: 'Ideal: ≥ 15–20%',
      isHealthy: savingsMarginPercent >= 10.0,
    );

    // PILAR 4: SPEND PACING (20%)
    double pacingScore;
    switch (safeToSpend.healthStatus) {
      case FinancialHealthStatus.comfortable:
        pacingScore = 100.0;
        break;
      case FinancialHealthStatus.caution:
        pacingScore = 65.0;
        break;
      case FinancialHealthStatus.deficit:
        pacingScore = 25.0;
        break;
    }

    final pacingPillar = HealthPillarMetric(
      title: 'Disiplin Belanja Harian',
      description: 'Kepatuhan pengeluaran terhadap batas aman',
      score: pacingScore,
      displayValue: safeToSpend.statusLabel,
      benchmark: 'Target: Sangat Aman',
      isHealthy: safeToSpend.healthStatus == FinancialHealthStatus.comfortable,
    );

    // WEIGHTED OVERALL SCORE
    final double weightedScore = (0.30 * emergencyPillar.score) +
        (0.25 * commitmentPillar.score) +
        (0.25 * savingsPillar.score) +
        (0.20 * pacingPillar.score);

    final int overallScore = weightedScore.round().clamp(0, 100);

    final HealthTier tier;
    if (overallScore >= 85) {
      tier = HealthTier.excellent;
    } else if (overallScore >= 70) {
      tier = HealthTier.good;
    } else if (overallScore >= 50) {
      tier = HealthTier.caution;
    } else {
      tier = HealthTier.deficit;
    }

    final recs = FinancialHealthRecommendations.generate(
      runwayMonths: runwayMonths,
      commitmentRatio: commitmentRatio,
      savingsMarginPercent: savingsMarginPercent,
      safeToSpend: safeToSpend,
      pockets: pockets,
    );

    return FinancialHealthReport(
      overallScore: overallScore,
      tier: tier,
      emergencyRunway: emergencyPillar,
      fixedCommitment: commitmentPillar,
      savingsMargin: savingsPillar,
      spendPacing: pacingPillar,
      recommendations: recs,
      totalLiquidAssets: totalLiquidAssets,
      totalPocketsAmount: totalPocketsAmount,
    );
  }
}
