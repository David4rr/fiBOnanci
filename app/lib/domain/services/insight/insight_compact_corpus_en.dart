import 'insight_models.dart';

class InsightCompactCorpusEn {
  static const Map<SpendVelocity, List<String>> compactPhrases = {
    SpendVelocity.zeroSpend: [
      'Budget intact, cashflow safe',
      'Full discipline, limit untouched',
      'Calm cashflow, balance safe',
      'Zero spend, pace preserved',
      'Strong defense, zero leaks',
    ],
    SpendVelocity.conservative: [
      'Measured spend, safe margin',
      'Essentials only, pace intact',
      'Frugal spend, cashflow safe',
      'Wise spending, savings safe',
      'Clean habits, ample margin',
    ],
    SpendVelocity.moderate: [
      'Balanced spend, on plan',
      'Steady pace, watch extras',
      'Daily cashflow under control',
      'Balanced & safe spending',
      'Proportional pace maintained',
    ],
    SpendVelocity.nearLimit: [
      'Near limit, slow down spend',
      'Thin margin, hold impulse',
      'Rest your wallet tonight',
      'Protect cash for tomorrow',
      'Almost capped, essentials only',
    ],
    SpendVelocity.overLimit: [
      'Over budget, ease up tomorrow',
      'Limit exceeded, reset pace',
      'Pause flexible spend tomorrow',
      'Review extras, recover next',
      'Lock wallet, protect trend',
    ],
    SpendVelocity.deficit: [
      'Budget deficit, pause extras',
      'Essentials only, guard cash',
      'Tight cashflow, hold spend',
      'Rebuild core liquidity',
    ],
  };

  static const Map<MonthPhase, List<String>> phaseSpecificZeroSpend = {
    MonthPhase.early: [
      'Clean month start, cash intact',
      'Solid base, limit untouched',
      'Calm start, zero leaks',
      'Early budget safely intact',
    ],
    MonthPhase.mid: [
      'Mid-month pace well kept',
      'Tested discipline, cash safe',
      'Steady frugal pace kept',
      'Defense intact, solid buffer',
    ],
    MonthPhase.latePhase: [
      'Lock in month-end surplus',
      'High discipline, safe runway',
      'Few days left, solid cash',
      'Clean finish, frugal month',
    ],
  };

  static const List<String> weekendZeroSpend = [
    'Chill weekend, wallet safe',
    'Frugal & calm weekend',
    'Disciplined weekend, intact',
  ];
}
