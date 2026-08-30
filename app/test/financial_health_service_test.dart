import 'package:fibonanci_app/data/database/app_database.dart';
import 'package:fibonanci_app/domain/services/cashflow_analytics_service.dart';
import 'package:fibonanci_app/domain/services/financial_health_service.dart';
import 'package:fibonanci_app/domain/services/safe_to_spend_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FinancialHealthService Unit Tests', () {
    final fixedNow = DateTime(2026, 8, 30);

    final mockWallets = [
      WalletEntry(
        id: 'w1',
        name: 'BCA Utama',
        type: 'bank',
        currency: 'IDR',
        balance: 15000000.0, // 15 Juta
        colorHex: '#005E54',
        iconName: 'bank',
        createdAt: fixedNow,
        updatedAt: fixedNow,
        isSynced: false,
        isDeleted: false,
      ),
    ];

    final mockSubscriptions = [
      SubscriptionEntry(
        id: 's1',
        walletId: 'w1',
        categoryId: 'c1',
        title: 'Kost Bulanan',
        cost: 1500000.0, // 1.5 Juta
        billingCycle: 'monthly',
        dueDay: 1,
        autoDeduct: false,
        status: 'active',
        lastPaidDate: null,
        createdAt: fixedNow,
        updatedAt: fixedNow,
        isSynced: false,
        isDeleted: false,
      ),
    ];

    test('Computes excellent health tier when runway and savings margin are strong', () {
      final pockets = [
        PocketEntry(
          id: 'p1',
          name: 'Dana Darurat',
          type: 'emergency',
          targetAmount: 20000000.0,
          currentAmount: 10000000.0, // 10 Juta
          colorHex: '#7DF24E',
          iconName: 'emergency',
          targetDate: null,
          linkedWalletId: 'w1',
          notes: null,
          createdAt: fixedNow,
          updatedAt: fixedNow,
          isSynced: false,
          isDeleted: false,
        ),
      ];

      const monthlyCashflow = MonthlyCashflow(
        income: 10000000.0,  // 10 Juta
        expense: 3000000.0,  // 3 Juta (70% savings margin)
      );

      final safeToSpend = SafeToSpendService.calculate(
        wallets: mockWallets,
        subscriptions: mockSubscriptions,
        referenceDate: fixedNow,
      );

      final report = FinancialHealthService.evaluate(
        wallets: mockWallets,
        pockets: pockets,
        subscriptions: mockSubscriptions,
        monthlyCashflow: monthlyCashflow,
        safeToSpend: safeToSpend,
        referenceDate: fixedNow,
      );

      expect(report.tier, anyOf(HealthTier.excellent, HealthTier.good));
      expect(report.overallScore, greaterThanOrEqualTo(80));
      expect(report.emergencyRunway.isHealthy, isTrue);
      expect(report.fixedCommitment.isHealthy, isTrue);
      expect(report.savingsMargin.isHealthy, isTrue);
      expect(report.totalPocketsAmount, 10000000.0);
    });

    test('Computes deficit health tier when bills exceed income and no emergency runway', () {
      final emptyWallets = [
        WalletEntry(
          id: 'w2',
          name: 'Dompet Kering',
          type: 'ewallet',
          currency: 'IDR',
          balance: 100000.0, // 100k
          colorHex: '#EF4444',
          iconName: 'wallet',
          createdAt: fixedNow,
          updatedAt: fixedNow,
          isSynced: false,
          isDeleted: false,
        ),
      ];

      final heavySubscriptions = [
        SubscriptionEntry(
          id: 's2',
          walletId: 'w2',
          categoryId: 'c1',
          title: 'Cicilan Mobil & Pinjol',
          cost: 5000000.0, // 5 Juta
          billingCycle: 'monthly',
          dueDay: 5,
          autoDeduct: false,
          status: 'active',
          lastPaidDate: null,
          createdAt: fixedNow,
          updatedAt: fixedNow,
          isSynced: false,
          isDeleted: false,
        ),
      ];

      const cashflowDeficit = MonthlyCashflow(
        income: 2000000.0,  // 2 Juta
        expense: 4500000.0, // 4.5 Juta (Defisit berat)
      );

      final safeToSpend = SafeToSpendService.calculate(
        wallets: emptyWallets,
        subscriptions: heavySubscriptions,
        referenceDate: fixedNow,
      );

      final report = FinancialHealthService.evaluate(
        wallets: emptyWallets,
        pockets: const [],
        subscriptions: heavySubscriptions,
        monthlyCashflow: cashflowDeficit,
        safeToSpend: safeToSpend,
        referenceDate: fixedNow,
      );

      expect(report.tier, anyOf(HealthTier.caution, HealthTier.deficit));
      expect(report.overallScore, lessThan(60));
      expect(report.emergencyRunway.isHealthy, isFalse);
      expect(report.recommendations, isNotEmpty);
    });
  });
}
