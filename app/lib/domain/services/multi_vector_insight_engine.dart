import 'insight/insight_compact_corpus.dart';
import 'insight/insight_corpus.dart';
import 'insight/insight_models.dart';

export 'insight/insight_compact_corpus.dart';
export 'insight/insight_models.dart';

class MultiVectorInsightEngine {
  static SpendVelocity resolveVelocity({
    required double dailySafePace,
    required double dayExpense,
    bool isDeficit = false,
  }) {
    if (isDeficit || dailySafePace <= 0) return SpendVelocity.deficit;
    if (dayExpense <= 0) return SpendVelocity.zeroSpend;

    final ratio = dayExpense / dailySafePace;
    if (ratio <= 0.35) return SpendVelocity.conservative;
    if (ratio <= 0.75) return SpendVelocity.moderate;
    if (ratio <= 1.0) return SpendVelocity.nearLimit;
    return SpendVelocity.overLimit;
  }

  static MonthPhase resolvePhase(DateTime date) {
    final day = date.day;
    if (day <= 10) return MonthPhase.early;
    if (day <= 20) return MonthPhase.mid;
    return MonthPhase.latePhase;
  }

  static StreakTier resolveStreakTier(int streak) {
    if (streak <= 1) return StreakTier.starter;
    if (streak <= 4) return StreakTier.building;
    if (streak <= 9) return StreakTier.solid;
    return StreakTier.master;
  }

  static DayContext resolveDayContext(DateTime date) {
    final wd = date.weekday; // 1 = Mon ... 7 = Sun
    if (wd >= 5) return DayContext.weekend;
    return DayContext.weekday;
  }

  static DailyInsightResult generate({
    required double dailySafePace,
    required double dayExpense,
    int streak = 0,
    DateTime? date,
    bool isDeficit = false,
  }) {
    final ref = date ?? DateTime.now();
    final velocity = resolveVelocity(
      dailySafePace: dailySafePace,
      dayExpense: dayExpense,
      isDeficit: isDeficit,
    );
    final phase = resolvePhase(ref);
    final streakTier = resolveStreakTier(streak);
    final dayContext = resolveDayContext(ref);

    final text = InsightCorpus.selectPhrase(
      velocity: velocity,
      phase: phase,
      streakTier: streakTier,
      dayContext: dayContext,
      date: ref,
      streak: streak,
    );

    return DailyInsightResult(
      text: text,
      velocity: velocity,
      phase: phase,
      streakTier: streakTier,
      dayContext: dayContext,
    );
  }

  static String generateCompact({
    required double dailySafePace,
    required double dayExpense,
    int streak = 0,
    DateTime? date,
    bool isDeficit = false,
  }) {
    final ref = date ?? DateTime.now();
    final velocity = resolveVelocity(
      dailySafePace: dailySafePace,
      dayExpense: dayExpense,
      isDeficit: isDeficit,
    );
    final phase = resolvePhase(ref);
    final streakTier = resolveStreakTier(streak);
    final dayContext = resolveDayContext(ref);

    return InsightCompactCorpus.selectPhrase(
      velocity: velocity,
      phase: phase,
      streakTier: streakTier,
      dayContext: dayContext,
      date: ref,
      streak: streak,
    );
  }
}
