enum SpendVelocity {
  zeroSpend,
  conservative,
  moderate,
  nearLimit,
  overLimit,
  deficit,
}

enum MonthPhase {
  early,
  mid,
  latePhase,
}

enum StreakTier {
  starter,
  building,
  solid,
  master,
}

enum DayContext {
  weekday,
  weekend,
}

class DailyInsightResult {
  final String text;
  final SpendVelocity velocity;
  final MonthPhase phase;
  final StreakTier streakTier;
  final DayContext dayContext;

  const DailyInsightResult({
    required this.text,
    required this.velocity,
    required this.phase,
    required this.streakTier,
    required this.dayContext,
  });
}
