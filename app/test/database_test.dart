import 'package:drift/native.dart';
import 'package:drift/drift.dart';
import 'package:fibonanci_app/data/database/app_database.dart';
import 'package:fibonanci_app/data/repositories/finance_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('Database seeds initial categories and default wallets on creation', () async {
    final categories = await db.select(db.categories).get();
    expect(categories.length, 11);
    expect(categories.any((c) => c.name == 'Makanan & Minuman'), isTrue);
    expect(categories.any((c) => c.name == 'Gaji & Pendapatan Pokok'), isTrue);

    final wallets = await db.select(db.wallets).get();
    expect(wallets.length, 7);
    expect(wallets.any((w) => w.name == 'BCA Utama'), isTrue);
    expect(wallets.any((w) => w.name == 'blu by BCA'), isTrue);
    expect(wallets.any((w) => w.name == 'SeaBank'), isTrue);
    expect(wallets.any((w) => w.name == 'Livin Mandiri'), isTrue);
    expect(wallets.any((w) => w.name == 'Bank Jago'), isTrue);
    expect(wallets.any((w) => w.name == 'OVO Cash'), isTrue);
    expect(wallets.any((w) => w.name == 'ShopeePay'), isTrue);
  });

  test('Atomic transaction updates wallet balance accurately', () async {
    final wallets = await db.select(db.wallets).get();
    final bca = wallets.firstWhere((w) => w.name == 'BCA Utama');
    final initialBalance = bca.balance;

    final categories = await db.select(db.categories).get();
    final foodCat = categories.firstWhere((c) => c.name == 'Makanan & Minuman');

    const uuid = Uuid();
    final now = DateTime.now().toUtc();

    // 1. Log expense: Rp 50,000
    await db.logTransactionWithBalanceMutation(
      tx: TransactionsCompanion(
        id: Value(uuid.v4()),
        walletId: Value(bca.id),
        categoryId: Value(foodCat.id),
        amount: const Value(50000.0),
        type: const Value('expense'),
        transactionDate: Value(now),
        notes: const Value('Makan Siang'),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );

    final updatedBca = await (db.select(db.wallets)..where((w) => w.id.equals(bca.id))).getSingle();
    expect(updatedBca.balance, initialBalance - 50000.0);
  });

  test('Atomic transfer correctly debits source and credits destination', () async {
    final wallets = await db.select(db.wallets).get();
    final bca = wallets.firstWhere((w) => w.name == 'BCA Utama');
    final ovo = wallets.firstWhere((w) => w.name == 'OVO Cash');

    final bcaStart = bca.balance;
    final ovoStart = ovo.balance;

    final categories = await db.select(db.categories).get();
    final transferCat = categories.firstWhere((c) => c.name == 'Transfer Antar Rekening');

    const uuid = Uuid();
    final now = DateTime.now().toUtc();

    // Transfer Rp 100,000 from BCA to OVO
    await db.logTransactionWithBalanceMutation(
      tx: TransactionsCompanion(
        id: Value(uuid.v4()),
        walletId: Value(bca.id),
        categoryId: Value(transferCat.id),
        amount: const Value(100000.0),
        type: const Value('transfer'),
        destinationWalletId: Value(ovo.id),
        transactionDate: Value(now),
        notes: const Value('Top Up OVO dari BCA'),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );

    final bcaAfter = await (db.select(db.wallets)..where((w) => w.id.equals(bca.id))).getSingle();
    final ovoAfter = await (db.select(db.wallets)..where((w) => w.id.equals(ovo.id))).getSingle();

    expect(bcaAfter.balance, bcaStart - 100000.0);
    expect(ovoAfter.balance, ovoStart + 100000.0);
  });

  test('Pocket initial deposit deducts bank balance and deleting transaction reverses wallet and pocket balances', () async {
    final repo = DriftFinanceRepository(db);
    final wallets = await db.select(db.wallets).get();
    final bca = wallets.firstWhere((w) => w.name == 'BCA Utama');
    await db.updateWalletBalance(bca.id, 1000000.0);

    await repo.addPocket(
      name: 'Dana Darurat',
      type: 'emergency',
      initialAmount: 250000.0,
      colorHex: '#C5F441',
      iconName: 'flag',
      linkedWalletId: bca.id,
    );

    final bcaAfterPocket = await (db.select(db.wallets)..where((w) => w.id.equals(bca.id))).getSingle();
    expect(bcaAfterPocket.balance, 750000.0);
    final pocketsAfterCreate = await repo.getPockets();
    expect(pocketsAfterCreate.single.currentAmount, 250000.0);

    final txs = await repo.getTransactions();
    final pocketTx = txs.firstWhere((t) => (t.notes ?? '').contains('Dana Darurat'));
    await repo.deleteTransaction(pocketTx.id);

    final bcaAfterDelete = await (db.select(db.wallets)..where((w) => w.id.equals(bca.id))).getSingle();
    expect(bcaAfterDelete.balance, 1000000.0);
    final pocketsAfterDelete = await repo.getPockets();
    expect(pocketsAfterDelete.single.currentAmount, 0.0);
  });

  test('Transfer edit, wallet swap, and deletion maintain exact source and destination balances', () async {
    final repo = DriftFinanceRepository(db);
    final wallets = await db.select(db.wallets).get();
    final bca = wallets.firstWhere((w) => w.name == 'BCA Utama');
    final ovo = wallets.firstWhere((w) => w.name == 'OVO Cash');
    await db.updateWalletBalance(bca.id, 1000000.0);
    await db.updateWalletBalance(ovo.id, 200000.0);

    await repo.addTransaction(
      walletId: bca.id,
      destinationWalletId: ovo.id,
      categoryId: '11111111-1111-4111-8111-111111111111',
      amount: 150000.0,
      type: 'transfer',
      notes: 'Topup OVO',
    );

    var bcaNow = await (db.select(db.wallets)..where((w) => w.id.equals(bca.id))).getSingle();
    var ovoNow = await (db.select(db.wallets)..where((w) => w.id.equals(ovo.id))).getSingle();
    expect(bcaNow.balance, 850000.0);
    expect(ovoNow.balance, 350000.0);

    // Edit transfer amount from 150k to 250k and swap direction (OVO -> BCA)
    final tx = (await repo.getTransactions()).firstWhere((t) => t.notes == 'Topup OVO');
    await repo.updateTransaction(
      transactionId: tx.id,
      newWalletId: ovo.id,
      newDestinationWalletId: bca.id,
      newAmount: 50000.0,
      newType: 'transfer',
      newCategoryId: '11111111-1111-4111-8111-111111111111',
      newNotes: 'Balik ke BCA',
    );

    bcaNow = await (db.select(db.wallets)..where((w) => w.id.equals(bca.id))).getSingle();
    ovoNow = await (db.select(db.wallets)..where((w) => w.id.equals(ovo.id))).getSingle();
    expect(bcaNow.balance, 1050000.0);
    expect(ovoNow.balance, 150000.0);

    // Delete the transfer -> both wallets return to original 1,000,000 and 200,000
    await repo.deleteTransaction(tx.id);
    bcaNow = await (db.select(db.wallets)..where((w) => w.id.equals(bca.id))).getSingle();
    ovoNow = await (db.select(db.wallets)..where((w) => w.id.equals(ovo.id))).getSingle();
    expect(bcaNow.balance, 1000000.0);
    expect(ovoNow.balance, 200000.0);
  });

  test('Paying subscription with discount deducts actualAmount and deleting subscription refunds wallet balance', () async {
    final repo = DriftFinanceRepository(db);
    final wallets = await db.select(db.wallets).get();
    final bca = wallets.firstWhere((w) => w.name == 'BCA Utama');
    await db.updateWalletBalance(bca.id, 1000000.0);

    await repo.addSubscription(
      title: 'Spotify Family',
      cost: 100000.0,
      dueDay: 15,
      walletId: bca.id,
      categoryId: '11111111-1111-4111-8111-111111111111',
    );
    final sub = (await repo.getSubscriptions()).firstWhere((s) => s.title == 'Spotify Family');

    // Pay with 20% discount (actualAmount: 80000)
    await repo.markSubscriptionAsPaid(sub.id, actualAmount: 80000.0);
    var bcaNow = await (db.select(db.wallets)..where((w) => w.id.equals(bca.id))).getSingle();
    expect(bcaNow.balance, 920000.0);

    // Delete subscription -> refunds 80,000 back to BCA Utama and soft-deletes payment tx
    await repo.deleteSubscription(sub.id);
    bcaNow = await (db.select(db.wallets)..where((w) => w.id.equals(bca.id))).getSingle();
    expect(bcaNow.balance, 1000000.0);
    final remainingTxs = await repo.getTransactions();
    expect(remainingTxs.where((t) => (t.notes ?? '').contains('Spotify Family')), isEmpty);
  });
}
