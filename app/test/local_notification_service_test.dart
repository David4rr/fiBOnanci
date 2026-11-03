import 'package:flutter_test/flutter_test.dart';
import 'package:fibonanci_app/core/notifications/local_notification_service.dart';
import 'package:fibonanci_app/data/database/app_database.dart';

void main() {
  group('LocalNotificationService Tests', () {
    test('uninitialized service safely returns without crashing', () async {
      final service = LocalNotificationService.instance;
      expect(service.isInitialized, isFalse);

      final now = DateTime.now();
      final sub = SubscriptionEntry(
        id: 'test-sub-1',
        walletId: 'w-1',
        categoryId: 'c-1',
        title: 'Netflix',
        cost: 186000,
        billingCycle: 'monthly',
        dueDay: 20,
        autoDeduct: false,
        status: 'active',
        isInstallment: false,
        paidCycles: 0,
        createdAt: now,
        updatedAt: now,
        isSynced: false,
        isDeleted: false,
      );

      // Should safely no-op when not initialized
      await service.scheduleSubscriptionReminders(sub);
      await service.cancelSubscriptionReminders('test-sub-1');
      await service.syncAllSubscriptionReminders([sub]);
      await service.showInstantReceipt(
        id: 1234,
        title: 'Test',
        body: 'Test Body',
      );
    });

    test('isInitializedForTest toggle can be controlled', () {
      final service = LocalNotificationService.instance;
      service.isInitializedForTest = true;
      expect(service.isInitialized, isTrue);

      service.isInitializedForTest = false;
      expect(service.isInitialized, isFalse);
    });
  });
}
