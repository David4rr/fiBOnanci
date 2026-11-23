import 'package:flutter_test/flutter_test.dart';

import 'package:fibonanci_app/domain/services/multi_vector_insight_engine.dart';

void main() {
  group('MultiVectorInsightEngine Unit Tests', () {
    test('accurately resolves spend velocity across ratio tiers', () {
      expect(
        MultiVectorInsightEngine.resolveVelocity(dailySafePace: 100000, dayExpense: 0),
        SpendVelocity.zeroSpend,
      );
      expect(
        MultiVectorInsightEngine.resolveVelocity(dailySafePace: 100000, dayExpense: 25000),
        SpendVelocity.conservative,
      );
      expect(
        MultiVectorInsightEngine.resolveVelocity(dailySafePace: 100000, dayExpense: 60000),
        SpendVelocity.moderate,
      );
      expect(
        MultiVectorInsightEngine.resolveVelocity(dailySafePace: 100000, dayExpense: 90000),
        SpendVelocity.nearLimit,
      );
      expect(
        MultiVectorInsightEngine.resolveVelocity(dailySafePace: 100000, dayExpense: 150000),
        SpendVelocity.overLimit,
      );
      expect(
        MultiVectorInsightEngine.resolveVelocity(dailySafePace: 100000, dayExpense: 50000, isDeficit: true),
        SpendVelocity.deficit,
      );
      expect(
        MultiVectorInsightEngine.resolveVelocity(dailySafePace: 0, dayExpense: 0),
        SpendVelocity.deficit,
      );
    });

    test('accurately resolves month phase and streak tier', () {
      expect(MultiVectorInsightEngine.resolvePhase(DateTime(2026, 11, 5)), MonthPhase.early);
      expect(MultiVectorInsightEngine.resolvePhase(DateTime(2026, 11, 15)), MonthPhase.mid);
      expect(MultiVectorInsightEngine.resolvePhase(DateTime(2026, 11, 28)), MonthPhase.latePhase);

      expect(MultiVectorInsightEngine.resolveStreakTier(0), StreakTier.starter);
      expect(MultiVectorInsightEngine.resolveStreakTier(1), StreakTier.starter);
      expect(MultiVectorInsightEngine.resolveStreakTier(3), StreakTier.building);
      expect(MultiVectorInsightEngine.resolveStreakTier(7), StreakTier.solid);
      expect(MultiVectorInsightEngine.resolveStreakTier(14), StreakTier.master);
    });

    test('accurately resolves weekday vs weekend context', () {
      // 2026-11-23 is Monday (weekday)
      expect(MultiVectorInsightEngine.resolveDayContext(DateTime(2026, 11, 23)), DayContext.weekday);
      // 2026-11-27 is Friday (weekend context)
      expect(MultiVectorInsightEngine.resolveDayContext(DateTime(2026, 11, 27)), DayContext.weekend);
      // 2026-11-28 is Saturday (weekend context)
      expect(MultiVectorInsightEngine.resolveDayContext(DateTime(2026, 11, 28)), DayContext.weekend);
      // 2026-11-29 is Sunday (weekend context)
      expect(MultiVectorInsightEngine.resolveDayContext(DateTime(2026, 11, 29)), DayContext.weekend);
    });

    test('generates rich, natural, non-empty insights across financial states', () {
      final r1 = MultiVectorInsightEngine.generate(
        dailySafePace: 500000,
        dayExpense: 0,
        streak: 5,
        date: DateTime(2026, 11, 5),
      );
      expect(r1.text.isNotEmpty, isTrue);
      expect(r1.velocity, SpendVelocity.zeroSpend);
      expect(r1.phase, MonthPhase.early);

      final r2 = MultiVectorInsightEngine.generate(
        dailySafePace: 500000,
        dayExpense: 120000,
        streak: 2,
        date: DateTime(2026, 11, 15),
      );
      expect(r2.text.isNotEmpty, isTrue);
      expect(r2.velocity, SpendVelocity.conservative);
      expect(r2.phase, MonthPhase.mid);

      final r3 = MultiVectorInsightEngine.generate(
        dailySafePace: 500000,
        dayExpense: 600000,
        streak: 0,
        date: DateTime(2026, 11, 28),
      );
      expect(r3.text.isNotEmpty, isTrue);
      expect(r3.velocity, SpendVelocity.overLimit);
      expect(r3.phase, MonthPhase.latePhase);
    });

    test('generates dynamic compact phrases (<35 chars) that rotate across phases and velocities', () {
      final cEarly = MultiVectorInsightEngine.generateCompact(
        dailySafePace: 200000,
        dayExpense: 0,
        streak: 1,
        date: DateTime(2026, 11, 3),
      );
      expect(cEarly.isNotEmpty, isTrue);
      expect(cEarly.length, lessThanOrEqualTo(35));

      final cMid = MultiVectorInsightEngine.generateCompact(
        dailySafePace: 200000,
        dayExpense: 0,
        streak: 5,
        date: DateTime(2026, 11, 15),
      );
      expect(cMid.isNotEmpty, isTrue);
      expect(cMid.length, lessThanOrEqualTo(35));

      final cLate = MultiVectorInsightEngine.generateCompact(
        dailySafePace: 200000,
        dayExpense: 0,
        streak: 10,
        date: DateTime(2026, 11, 28),
      );
      expect(cLate.isNotEmpty, isTrue);
      expect(cLate.length, lessThanOrEqualTo(35));

      final cOver = MultiVectorInsightEngine.generateCompact(
        dailySafePace: 200000,
        dayExpense: 350000,
        streak: 0,
        date: DateTime(2026, 11, 20),
      );
      expect(cOver.isNotEmpty, isTrue);
      expect(cOver, isNot(equals('Disiplin hari ini, tenang esok hari')));
    });
  });
}
