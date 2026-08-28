import 'package:drift/native.dart';
import 'package:drift/drift.dart';
import 'package:fibonanci_app/data/database/app_database.dart';
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
}
