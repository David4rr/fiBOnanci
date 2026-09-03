part of '../finance_repository.dart';

mixin DriftPocketRepository on DriftRepoBase {
  Stream<List<PocketEntry>> watchPockets() => db.watchActivePockets();

  Future<List<PocketEntry>> getPockets() => db.getActivePockets();

  Future<void> addPocket({
    required String name,
    required String type,
    double? targetAmount,
    double initialAmount = 0.0,
    required String colorHex,
    required String iconName,
    DateTime? targetDate,
    String? linkedWalletId,
    String? notes,
  }) async {
    final now = DateTime.now().toUtc();
    final pocketId = uuid.v4();
    await db.createPocket(
      PocketsCompanion(
        id: drift.Value(pocketId),
        name: drift.Value(name),
        type: drift.Value(type),
        targetAmount: drift.Value(targetAmount),
        currentAmount: drift.Value(initialAmount),
        colorHex: drift.Value(colorHex),
        iconName: drift.Value(iconName),
        targetDate: drift.Value(targetDate),
        linkedWalletId: drift.Value(linkedWalletId),
        notes: drift.Value(notes),
        createdAt: drift.Value(now),
        updatedAt: drift.Value(now),
      ),
    );

    if (initialAmount > 0) {
      String? effectiveWalletId = linkedWalletId;
      if (effectiveWalletId == null) {
        final existingWallets = await (db.select(db.wallets)..where((t) => t.isDeleted.equals(false))).get();
        if (existingWallets.isNotEmpty) {
          effectiveWalletId = existingWallets.first.id;
        }
      }

      if (effectiveWalletId != null) {
        await db.into(db.transactions).insert(
          TransactionsCompanion(
            id: drift.Value(uuid.v4()),
            walletId: drift.Value(effectiveWalletId),
            categoryId: const drift.Value('11111111-1111-4111-8111-111111111111'),
            amount: drift.Value(initialAmount),
            type: const drift.Value('transfer'),
            notes: drift.Value('Setoran ke Kantong $name (Awal)'),
            transactionDate: drift.Value(now),
            createdAt: drift.Value(now),
            updatedAt: drift.Value(now),
            isSynced: const drift.Value(false),
          ),
        );
      }
    }
  }

  Future<void> updatePocket({
    required String pocketId,
    required String name,
    required String type,
    double? targetAmount,
    required String colorHex,
    required String iconName,
    DateTime? targetDate,
    String? linkedWalletId,
    String? notes,
  }) {
    final now = DateTime.now().toUtc();
    return db.updatePocket(
      PocketsCompanion(
        id: drift.Value(pocketId),
        name: drift.Value(name),
        type: drift.Value(type),
        targetAmount: drift.Value(targetAmount),
        colorHex: drift.Value(colorHex),
        iconName: drift.Value(iconName),
        targetDate: drift.Value(targetDate),
        linkedWalletId: drift.Value(linkedWalletId),
        notes: drift.Value(notes),
        updatedAt: drift.Value(now),
        isSynced: const drift.Value(false),
      ),
    );
  }

  Future<void> deletePocket(String pocketId) => db.deletePocket(pocketId);

  Future<void> transferPocketFunds({
    required String pocketId,
    required String walletId,
    required double amount,
    required bool isDepositToPocket,
    String? notes,
  }) => db.transferPocketFunds(
    pocketId: pocketId,
    walletId: walletId,
    amount: amount,
    isDepositToPocket: isDepositToPocket,
    notes: notes,
  );
}
