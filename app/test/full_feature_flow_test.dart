import 'package:drift/native.dart';
import 'package:fibonanci_app/core/notification_parser/notification_parser.dart';
import 'package:fibonanci_app/data/database/app_database.dart';
import 'package:fibonanci_app/domain/services/safe_to_spend_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('End-to-End Offline Finance Flow: Transaction, Subscription & Safe-to-Spend', () async {
    final wallets = await db.select(db.wallets).get();
    final bca = wallets.firstWhere((w) => w.name == 'BCA Utama');
    final initialBca = bca.balance;

    // 1. Initial State: Compute baseline Safe-to-Spend
    var activeWallets = await db.select(db.wallets).get();
    var activeSubs = await db.select(db.subscriptions).get();
    var metrics = SafeToSpendService.calculate(wallets: activeWallets, subscriptions: activeSubs);
    final baselineSafeToSpend = metrics.safeToSpendMonthly;

    // 2. User logs an expense of Rp 150,000 (Makan Malam)
    const uuid = Uuid();
    final now = DateTime.now().toUtc();
    final foodCat = (await db.select(db.categories).get()).firstWhere((c) => c.name.contains('Makanan'));

    await db.logTransactionWithBalanceMutation(
      tx: TransactionsCompanion(
        id: drift.Value(uuid.v4()),
        walletId: drift.Value(bca.id),
        categoryId: drift.Value(foodCat.id),
        amount: const drift.Value(150000.0),
        type: const drift.Value('expense'),
        notes: const drift.Value('Makan Malam'),
        transactionDate: drift.Value(now),
        createdAt: drift.Value(now),
        updatedAt: drift.Value(now),
      ),
    );

    // Verify balance & Safe-to-Spend dropped by 150,000
    activeWallets = await db.select(db.wallets).get();
    final updatedBca = activeWallets.firstWhere((w) => w.id == bca.id);
    expect(updatedBca.balance, initialBca - 150000.0);

    metrics = SafeToSpendService.calculate(wallets: activeWallets, subscriptions: activeSubs);
    expect(metrics.safeToSpendMonthly, baselineSafeToSpend - 150000.0);

    // 3. User adds a recurring bill (Netflix Rp 186,000)
    final subId = uuid.v4();
    await db.into(db.subscriptions).insert(
      SubscriptionsCompanion(
        id: drift.Value(subId),
        walletId: drift.Value(bca.id),
        categoryId: drift.Value(foodCat.id),
        title: const drift.Value('Netflix Premium'),
        cost: const drift.Value(186000.0),
        billingCycle: const drift.Value('monthly'),
        dueDay: const drift.Value(15),
        autoDeduct: const drift.Value(false),
        status: const drift.Value('active'),
        createdAt: drift.Value(now),
        updatedAt: drift.Value(now),
      ),
    );

    // Safe-to-Spend drops by 186,000 because of committed pending bill
    activeSubs = await db.select(db.subscriptions).get();
    metrics = SafeToSpendService.calculate(wallets: activeWallets, subscriptions: activeSubs);
    expect(metrics.pendingBills, 186000.0);
    expect(metrics.safeToSpendMonthly, baselineSafeToSpend - 150000.0 - 186000.0);

    // 4. User marks Netflix as PAID
    await db.markSubscriptionAsPaid(subId);

    activeWallets = await db.select(db.wallets).get();
    activeSubs = await db.select(db.subscriptions).get();
    metrics = SafeToSpendService.calculate(wallets: activeWallets, subscriptions: activeSubs);

    // Pending bill is now 0 (paid), balance deducted by 186,000
    expect(metrics.pendingBills, 0.0);
    expect(metrics.safeToSpendMonthly, baselineSafeToSpend - 150000.0 - 186000.0);

    // 5. On-Device Notification Parsing: BCA QRIS alert simulation
    final parsed = NotificationParser.parse(
      packageName: 'com.bca',
      title: 'BCA mobile',
      body: 'Pembayaran QR sebesar Rp 35.000 di Kopi Kenangan berhasil.',
    );
    expect(parsed, isNotNull);

    await db.logTransactionWithBalanceMutation(
      tx: TransactionsCompanion(
        id: drift.Value(uuid.v4()),
        walletId: drift.Value(bca.id),
        categoryId: drift.Value(foodCat.id),
        amount: drift.Value(parsed!.amount),
        type: drift.Value(parsed.type),
        notes: drift.Value(parsed.counterparty),
        source: const drift.Value('notification_auto'),
        transactionDate: drift.Value(now),
        createdAt: drift.Value(now),
        updatedAt: drift.Value(now),
      ),
    );

    final finalBca = (await db.select(db.wallets).get()).firstWhere((w) => w.id == bca.id);
    expect(finalBca.balance, initialBca - 150000.0 - 186000.0 - 35000.0);
  });
}
