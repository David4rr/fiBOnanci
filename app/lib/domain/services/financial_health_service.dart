import '../../data/database/app_database.dart';
import 'cashflow_analytics_service.dart';
import 'financial_health_models.dart';
import 'financial_health_pillar_builder.dart';
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
    double? monthlyIncomeTarget,
  }) {
    double totalLiquidAssets = 0.0;
    for (final w in wallets) {
      totalLiquidAssets += w.balance;
    }

    double totalPocketsAmount = 0.0;
    double emergencyAndRetirementPockets = 0.0;
    double dedicatedEmergencyPocketAmount = 0.0;
    bool hasEmergencyPocket = false;
    for (final p in pockets) {
      totalPocketsAmount += p.currentAmount;
      if (p.type == 'emergency' || p.type == 'retirement' || p.type == 'savings') {
        emergencyAndRetirementPockets += p.currentAmount;
      }
      if (p.type == 'emergency') {
        dedicatedEmergencyPocketAmount += p.currentAmount;
        hasEmergencyPocket = true;
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
      monthlyIncomeBenchmark = (monthlyIncomeTarget != null && monthlyIncomeTarget > 0)
          ? monthlyIncomeTarget
          : (monthlyExpenseBenchmark > 0 ? monthlyExpenseBenchmark : 1000000.0);
    }

    final emergencyPillar = FinancialHealthPillarBuilder.buildEmergencyPillar(
      totalLiquidAssets: totalLiquidAssets,
      emergencyAndRetirementPockets: emergencyAndRetirementPockets,
      monthlyExpenseBenchmark: monthlyExpenseBenchmark,
      dedicatedEmergencyPocketAmount: dedicatedEmergencyPocketAmount,
      hasEmergencyPocket: hasEmergencyPocket,
    );

    final commitmentPillar = FinancialHealthPillarBuilder.buildCommitmentPillar(
      subscriptions: subscriptions,
      monthlyIncomeBenchmark: monthlyIncomeBenchmark,
    );

    final savingsPillar = FinancialHealthPillarBuilder.buildSavingsPillar(
      monthlyCashflow: monthlyCashflow,
      monthlyIncomeBenchmark: monthlyIncomeBenchmark,
    );

    final pacingPillar = FinancialHealthPillarBuilder.buildPacingPillar(
      safeToSpend: safeToSpend,
    );

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

    final double runwayMonths = monthlyExpenseBenchmark > 0
        ? ((totalLiquidAssets + emergencyAndRetirementPockets) / monthlyExpenseBenchmark)
        : 0.0;
    final double totalRecurringBills = commitmentPillar.currentNominal ?? 0.0;
    final double commitmentRatio = monthlyIncomeBenchmark > 0
        ? (totalRecurringBills / monthlyIncomeBenchmark) * 100.0
        : 0.0;
    final double netSavings = savingsPillar.currentNominal ?? 0.0;
    final double savingsMarginPercent = monthlyIncomeBenchmark > 0
        ? (netSavings / monthlyIncomeBenchmark) * 100.0
        : 0.0;

    final recs = FinancialHealthRecommendations.generate(
      runwayMonths: runwayMonths,
      commitmentRatio: commitmentRatio,
      savingsMarginPercent: savingsMarginPercent,
      safeToSpend: safeToSpend,
      pockets: pockets,
      totalLiquidAssets: totalLiquidAssets,
      targetEmergency3Months: monthlyExpenseBenchmark * 3,
      currentEmergencyBuffer: totalLiquidAssets + emergencyAndRetirementPockets,
      totalRecurringBills: totalRecurringBills,
      maxIdealBills: monthlyIncomeBenchmark * 0.30,
      netSavings: netSavings,
      targetSavings: monthlyIncomeBenchmark * 0.20,
      hasEmergencyPocket: hasEmergencyPocket,
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
