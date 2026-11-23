import 'multi_vector_insight_engine.dart';
import 'safe_to_spend_service.dart';

/// Pure domain service that generates psychologically persuasive, natural copywriting
/// for daily allowance and pacing, powered by the MultiVectorInsightEngine.
class DailyPacingNudgeService {
  /// Generates short, dynamic, multi-vector financial nudges for the Bento card.
  /// Evaluates velocity, timeline phase, streak, and temporal context without rigid templates.
  static String getCompactSubtitle({
    required SafeToSpendMetrics metrics,
    required double todayExpense,
    DateTime? referenceDate,
    int streak = 0,
  }) {
    final dailyQuota = metrics.safeToSpendDaily;
    final isDeficit = metrics.healthStatus == FinancialHealthStatus.deficit || dailyQuota <= 0;

    return MultiVectorInsightEngine.generateCompact(
      dailySafePace: dailyQuota,
      dayExpense: todayExpense,
      streak: streak,
      date: referenceDate,
      isDeficit: isDeficit,
    );
  }

  /// Generates in-depth psychological coaching for the Daily Pace modal.
  static String getDetailedNudge({
    required SafeToSpendMetrics metrics,
    required double todayExpense,
    DateTime? referenceDate,
    int streak = 0,
  }) {
    final dailyQuota = metrics.safeToSpendDaily;
    final isDeficit = metrics.healthStatus == FinancialHealthStatus.deficit || dailyQuota <= 0;

    return MultiVectorInsightEngine.generate(
      dailySafePace: dailyQuota,
      dayExpense: todayExpense,
      streak: streak,
      date: referenceDate,
      isDeficit: isDeficit,
    ).text;
  }
}
