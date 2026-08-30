import 'package:drift/native.dart';
import 'package:fibonanci_app/data/database/app_database.dart';
import 'package:fibonanci_app/data/repositories/finance_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late DriftFinanceRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = DriftFinanceRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('Pocket creation, atomic transfer to pocket, withdrawal, and deletion', () async {
    final wallets = await db.select(db.wallets).get();
    final bca = wallets.firstWhere((w) => w.name == 'BCA Utama');
    final initialBcaBalance = bca.balance; // Default 12,500,000

    // 1. Create a Pocket "Masa Tua" with initialAmount = 0
    await repository.addPocket(
      name: 'Masa Tua & Pensiun',
      type: 'retirement',
      targetAmount: 100000000.0, // 100 Juta
      initialAmount: 0.0,
      colorHex: '#D4F442',
      iconName: 'retirement',
      linkedWalletId: bca.id,
    );

    var pockets = await repository.getPockets();
    expect(pockets.length, 1);
    final pocket = pockets.first;
    expect(pocket.name, 'Masa Tua & Pensiun');
    expect(pocket.currentAmount, 0.0);
    expect(pocket.targetAmount, 100000000.0);

    // 2. Transfer 2,000,000 from BCA to Pocket atomically
    await repository.transferPocketFunds(
      pocketId: pocket.id,
      walletId: bca.id,
      amount: 2000000.0,
      isDepositToPocket: true,
      notes: 'Sisihkan tabungan pensiun',
    );

    // Verify wallet decreased and pocket increased
    final updatedBca = await (db.select(db.wallets)..where((w) => w.id.equals(bca.id))).getSingle();
    final updatedPocket = await (db.select(db.pockets)..where((p) => p.id.equals(pocket.id))).getSingle();

    expect(updatedBca.balance, initialBcaBalance - 2000000.0);
    expect(updatedPocket.currentAmount, 2000000.0);

    // 3. Withdraw 500,000 from Pocket back to BCA
    await repository.transferPocketFunds(
      pocketId: pocket.id,
      walletId: bca.id,
      amount: 500000.0,
      isDepositToPocket: false,
      notes: 'Tarik darurat',
    );

    final withdrawnBca = await (db.select(db.wallets)..where((w) => w.id.equals(bca.id))).getSingle();
    final withdrawnPocket = await (db.select(db.pockets)..where((p) => p.id.equals(pocket.id))).getSingle();

    expect(withdrawnBca.balance, initialBcaBalance - 1500000.0);
    expect(withdrawnPocket.currentAmount, 1500000.0);

    // 4. Soft delete pocket
    await repository.deletePocket(pocket.id);
    pockets = await repository.getPockets();
    expect(pockets.isEmpty, isTrue);

    // Verify row still exists in raw DB with isDeleted = true
    final rawPockets = await db.select(db.pockets).get();
    expect(rawPockets.length, 1);
    expect(rawPockets.first.isDeleted, isTrue);
  });
}
