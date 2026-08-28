import 'package:fibonanci_app/data/database/app_database.dart';
import 'package:fibonanci_app/domain/services/safe_to_spend_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SafeToSpendService Unit Tests', () {
    final now = DateTime(2026, 8, 28); // August has 31 days -> 4 days remaining (28, 29, 30, 31)

    test('Computes Comfortable status when buffer >= 30%', () {
      final wallets = [
        WalletEntry(
          id: 'w1',
          name: 'BCA Utama',
          type: 'bank',
          currency: 'IDR',
          balance: 10000000.0,
          colorHex: '#0060AF',
          iconName: 'landmark',
          createdAt: now,
          updatedAt: now,
          isSynced: false,
          isDeleted: false,
        ),
      ];

      final subscriptions = [
        SubscriptionEntry(
          id: 's1',
          walletId: 'w1',
          categoryId: 'c1',
          title: 'Internet Indihome',
          cost: 450000.0,
          billingCycle: 'monthly',
          dueDay: 30,
          autoDeduct: false,
          status: 'active',
          lastPaidDate: null, // Unpaid
          createdAt: now,
          updatedAt: now,
          isSynced: false,
          isDeleted: false,
        ),
      ];

      final metrics = SafeToSpendService.calculate(
        wallets: wallets,
        subscriptions: subscriptions,
        referenceDate: now,
      );

      expect(metrics.totalRealBalance, 10000000.0);
      expect(metrics.pendingBills, 450000.0);
      expect(metrics.safeToSpendMonthly, 9550000.0);
      expect(metrics.daysRemainingInMonth, 4);
      expect(metrics.safeToSpendDaily, 9550000.0 / 4);
      expect(metrics.healthStatus, FinancialHealthStatus.comfortable);
    });

    test('Computes Deficit status when pending bills exceed real balance', () {
      final wallets = [
        WalletEntry(
          id: 'w1',
          name: 'BCA Utama',
          type: 'bank',
          currency: 'IDR',
          balance: 300000.0,
          colorHex: '#0060AF',
          iconName: 'landmark',
          createdAt: now,
          updatedAt: now,
          isSynced: false,
          isDeleted: false,
        ),
      ];

      final subscriptions = [
        SubscriptionEntry(
          id: 's1',
          walletId: 'w1',
          categoryId: 'c1',
          title: 'Cicilan Gadget',
          cost: 1500000.0,
          billingCycle: 'monthly',
          dueDay: 29,
          autoDeduct: true,
          status: 'active',
          lastPaidDate: null,
          createdAt: now,
          updatedAt: now,
          isSynced: false,
          isDeleted: false,
        ),
      ];

      final metrics = SafeToSpendService.calculate(
        wallets: wallets,
        subscriptions: subscriptions,
        referenceDate: now,
      );

      expect(metrics.safeToSpendMonthly, -1200000.0);
      expect(metrics.safeToSpendDaily, 0.0);
      expect(metrics.healthStatus, FinancialHealthStatus.deficit);
    });

    test('Ignores already paid subscriptions in current cycle', () {
      final wallets = [
        WalletEntry(
          id: 'w1',
          name: 'SeaBank',
          type: 'bank',
          currency: 'IDR',
          balance: 2000000.0,
          colorHex: '#FF5722',
          iconName: 'shield',
          createdAt: now,
          updatedAt: now,
          isSynced: false,
          isDeleted: false,
        ),
      ];

      final subscriptions = [
        SubscriptionEntry(
          id: 's1',
          walletId: 'w1',
          categoryId: 'c1',
          title: 'Spotify Premium',
          cost: 55000.0,
          billingCycle: 'monthly',
          dueDay: 10,
          autoDeduct: false,
          status: 'active',
          lastPaidDate: DateTime(2026, 8, 10), // Paid this month!
          createdAt: now,
          updatedAt: now,
          isSynced: false,
          isDeleted: false,
        ),
      ];

      final metrics = SafeToSpendService.calculate(
        wallets: wallets,
        subscriptions: subscriptions,
        referenceDate: now,
      );

      expect(metrics.pendingBills, 0.0);
      expect(metrics.safeToSpendMonthly, 2000000.0);
      expect(metrics.healthStatus, FinancialHealthStatus.comfortable);
    });
  });
}
