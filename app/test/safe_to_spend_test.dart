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

    test('Flexible Wallet Selection: calculates Safe-to-Spend using only designated spending wallets', () {
      final bca = WalletEntry(
        id: 'w_bca',
        name: 'BCA Utama',
        type: 'bank',
        currency: 'IDR',
        balance: 3000000.0,
        colorHex: '#10B981',
        iconName: 'wallet',
        createdAt: now,
        updatedAt: now,
        isSynced: false,
        isDeleted: false,
      );
      final seaBank = WalletEntry(
        id: 'w_seabank',
        name: 'SeaBank Tabungan',
        type: 'bank',
        currency: 'IDR',
        balance: 10000000.0,
        colorHex: '#FF5722',
        iconName: 'shield',
        createdAt: now,
        updatedAt: now,
        isSynced: false,
        isDeleted: false,
      );
      final gopay = WalletEntry(
        id: 'w_gopay',
        name: 'GoPay',
        type: 'ewallet',
        currency: 'IDR',
        balance: 500000.0,
        colorHex: '#00AED6',
        iconName: 'smartphone',
        createdAt: now,
        updatedAt: now,
        isSynced: false,
        isDeleted: false,
      );

      final netflixBca = SubscriptionEntry(
        id: 's_netflix',
        walletId: 'w_bca',
        categoryId: 'c1',
        title: 'Netflix',
        cost: 186000.0,
        billingCycle: 'monthly',
        dueDay: 15,
        autoDeduct: true,
        status: 'active',
        lastPaidDate: null,
        createdAt: now,
        updatedAt: now,
        isSynced: false,
        isDeleted: false,
      );
      final insuranceSeaBank = SubscriptionEntry(
        id: 's_insurance',
        walletId: 'w_seabank',
        categoryId: 'c2',
        title: 'Asuransi Jiwa',
        cost: 1000000.0,
        billingCycle: 'monthly',
        dueDay: 20,
        autoDeduct: false,
        status: 'active',
        lastPaidDate: null,
        createdAt: now,
        updatedAt: now,
        isSynced: false,
        isDeleted: false,
      );

      final allWallets = [bca, seaBank, gopay];
      final allSubs = [netflixBca, insuranceSeaBank];

      // Scenario A: User selects only BCA + GoPay for daily spending
      final customMetrics = SafeToSpendService.calculate(
        wallets: allWallets,
        subscriptions: allSubs,
        selectedWalletIds: {'w_bca', 'w_gopay'},
        referenceDate: now,
      );

      expect(customMetrics.isAllWallets, false);
      expect(customMetrics.selectedWalletsCount, 2);
      expect(customMetrics.totalRealBalance, 3500000.0); // 3M + 500k
      expect(customMetrics.pendingBills, 186000.0); // Only Netflix (Asuransi excluded because it's funded by SeaBank)
      expect(customMetrics.safeToSpendMonthly, 3314000.0);

      // Scenario B: User selects All Wallets
      final allMetrics = SafeToSpendService.calculate(
        wallets: allWallets,
        subscriptions: allSubs,
        selectedWalletIds: null, // or empty
        referenceDate: now,
      );

      expect(allMetrics.isAllWallets, true);
      expect(allMetrics.selectedWalletsCount, 3);
      expect(allMetrics.totalRealBalance, 13500000.0);
      expect(allMetrics.pendingBills, 1186000.0);
      expect(allMetrics.safeToSpendMonthly, 12314000.0);
    });
  });
}
