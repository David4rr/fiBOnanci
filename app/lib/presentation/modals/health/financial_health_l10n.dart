import 'package:flutter/widgets.dart';
import '../../../core/formatters/app_currency.dart';
import '../../../core/l10n/locale_notifier.dart';
import '../../../domain/services/financial_health_service.dart';
import '../../../l10n/app_localizations.dart';

class FinancialHealthL10n {
  static String tierLabel(AppLocalizations l10n, HealthTier tier) => switch (tier) {
    HealthTier.excellent => l10n.healthTierExcellent,
    HealthTier.good => l10n.healthTierGood,
    HealthTier.caution => l10n.healthTierCaution,
    HealthTier.deficit => l10n.healthTierDeficit,
  };

  static String tierHeadline(AppLocalizations l10n, HealthTier tier) => switch (tier) {
    HealthTier.excellent => l10n.healthHeadlineExcellent,
    HealthTier.good => l10n.healthHeadlineGood,
    HealthTier.caution => l10n.healthHeadlineCaution,
    HealthTier.deficit => l10n.healthHeadlineDeficit,
  };

  static FinancialHealthReport localize(BuildContext context, FinancialHealthReport report) {
    final l10n = AppL10n.of(context);
    final fmt = AppCurrency.of(context).format;

    final p1 = _localizeEmergency(l10n, fmt, report.emergencyRunway, report.totalLiquidAssets);
    final p2 = _localizeCommitment(l10n, fmt, report.fixedCommitment);
    final p3 = _localizeSavings(l10n, fmt, report.savingsMargin);
    final p4 = _localizePacing(l10n, fmt, report.spendPacing);

    final recs = <String>[];
    final months = double.tryParse(report.emergencyRunway.displayValue.split(' ').first) ?? 0.0;
    if (months < 3.0) {
      recs.add(l10n.healthRecEmergency(fmt(p1.targetNominal ?? 0)));
    }
    final billsRatio = double.tryParse(report.fixedCommitment.displayValue.replaceAll('%', '')) ?? 0.0;
    if (billsRatio > 35.0) {
      recs.add(l10n.healthRecBills(fmt(p2.currentNominal ?? 0), fmt(p2.targetNominal ?? 0)));
    }
    final savingsPct = double.tryParse(report.savingsMargin.displayValue.replaceAll('%', '')) ?? 0.0;
    if (savingsPct < 10.0) {
      recs.add(l10n.healthRecSavings(fmt(p3.currentNominal ?? 0), fmt(p3.targetNominal ?? 0)));
    }
    if (!p4.isHealthy) {
      recs.add(l10n.healthRecPacing(fmt(p4.currentNominal ?? 0)));
    }
    if (report.recommendations.any((r) => r.contains('belum memiliki Kantong'))) {
      recs.add(l10n.healthRecNoPockets);
    }
    if (recs.isEmpty) {
      recs.add(l10n.healthRecAllGood);
    }

    return FinancialHealthReport(
      overallScore: report.overallScore,
      tier: report.tier,
      emergencyRunway: p1,
      fixedCommitment: p2,
      savingsMargin: p3,
      spendPacing: p4,
      recommendations: recs,
      totalLiquidAssets: report.totalLiquidAssets,
      totalPocketsAmount: report.totalPocketsAmount,
    );
  }

  static HealthPillarMetric _localizeEmergency(AppLocalizations l10n, String Function(double) fmt, HealthPillarMetric m, double liquid) {
    final months = m.displayValue.split(' ').first;
    final hasPocket = m.description.contains('Kantong');
    final cur = m.currentNominal ?? 0;
    final t3 = m.targetNominal ?? 0;
    final t6 = t3 * 2;
    final String rec;
    if (hasPocket) {
      if (cur < t3) {
        rec = l10n.healthRecPillar1PocketLow(fmt(cur), fmt(t3 - cur), fmt(t3));
      } else if (cur < t6) {
        rec = l10n.healthRecPillar1PocketMid(fmt(cur), fmt(t6 - cur), fmt(t6));
      } else {
        rec = l10n.healthRecPillar1PocketFull(fmt(cur), fmt(t6));
      }
    } else {
      rec = liquid < t3
          ? l10n.healthRecPillar1NoPocketLow(fmt(t3), fmt(t3 - liquid))
          : l10n.healthRecPillar1NoPocketOk(fmt(liquid), fmt(t3));
    }
    return HealthPillarMetric(
      title: l10n.healthPillar1Title,
      description: hasPocket ? l10n.healthPillar1DescPocket : l10n.healthPillar1DescNoPocket,
      score: m.score,
      displayValue: l10n.healthPillar1Value(months),
      benchmark: l10n.healthPillar1Bench,
      isHealthy: m.isHealthy,
      allocationRecommendation: rec,
      currentNominal: m.currentNominal,
      targetNominal: m.targetNominal,
    );
  }

  static HealthPillarMetric _localizeCommitment(AppLocalizations l10n, String Function(double) fmt, HealthPillarMetric m) {
    final bills = m.currentNominal ?? 0;
    final maxBills = m.targetNominal ?? 0;
    final ratio = double.tryParse(m.displayValue.replaceAll('%', '')) ?? 0.0;
    final rec = ratio <= 30.0
        ? l10n.healthRecPillar2Ok(fmt(bills), fmt(maxBills))
        : l10n.healthRecPillar2High(fmt(bills), fmt(maxBills), fmt((bills - maxBills).clamp(0, double.infinity)));
    return HealthPillarMetric(
      title: l10n.healthPillar2Title,
      description: l10n.healthPillar2Desc,
      score: m.score,
      displayValue: m.displayValue,
      benchmark: l10n.healthPillar2Bench,
      isHealthy: m.isHealthy,
      allocationRecommendation: rec,
      currentNominal: m.currentNominal,
      targetNominal: m.targetNominal,
    );
  }

  static HealthPillarMetric _localizeSavings(AppLocalizations l10n, String Function(double) fmt, HealthPillarMetric m) {
    final saved = m.currentNominal ?? 0;
    final target = m.targetNominal ?? 0;
    final String rec;
    if (saved >= target) {
      rec = l10n.healthRecPillar3Ok(fmt(saved), fmt(target));
    } else if (saved > 0) {
      rec = l10n.healthRecPillar3Mid(fmt(saved), fmt(target - saved));
    } else {
      rec = l10n.healthRecPillar3Deficit(fmt(target));
    }
    return HealthPillarMetric(
      title: l10n.healthPillar3Title,
      description: l10n.healthPillar3Desc,
      score: m.score,
      displayValue: m.displayValue,
      benchmark: l10n.healthPillar3Bench,
      isHealthy: m.isHealthy,
      allocationRecommendation: rec,
      currentNominal: m.currentNominal,
      targetNominal: m.targetNominal,
    );
  }

  static HealthPillarMetric _localizePacing(AppLocalizations l10n, String Function(double) fmt, HealthPillarMetric m) {
    final daily = m.currentNominal ?? 0;
    final monthly = m.targetNominal ?? 0;
    final String statusLabel;
    final String rec;
    if (m.score >= 90) {
      statusLabel = l10n.healthStatusComfortable;
      rec = l10n.healthRecPillar4Ok(fmt(daily), fmt(monthly));
    } else if (m.score >= 50) {
      statusLabel = l10n.healthStatusCaution;
      rec = l10n.healthRecPillar4Caution(fmt(daily));
    } else {
      statusLabel = l10n.healthStatusDeficit;
      rec = l10n.healthRecPillar4Deficit;
    }
    return HealthPillarMetric(
      title: l10n.healthPillar4Title,
      description: l10n.healthPillar4Desc,
      score: m.score,
      displayValue: statusLabel,
      benchmark: l10n.healthPillar4Bench,
      isHealthy: m.isHealthy,
      allocationRecommendation: rec,
      currentNominal: m.currentNominal,
      targetNominal: m.targetNominal,
    );
  }
}
