part of '../app_database.dart';

extension CrossProfileMutations on AppDatabase {
  Future<void> logCrossProfileTransferMutation({
    required String sourceWalletId,
    required String destinationWalletId,
    required double amount,
    String? notes,
    DateTime? transactionDate,
    String source = 'manual',
  }) {
    return transaction(() async {
      if (amount <= 0) {
        throw ArgumentError('Nominal transfer harus lebih besar dari 0');
      }
      const uuid = Uuid();
      final now = DateTime.now().toUtc();
      final txDate = (transactionDate ?? now).toUtc();

      final sourceWallet = await (select(wallets)..where((t) => t.id.equals(sourceWalletId))).getSingleOrNull();
      final destWallet = await (select(wallets)..where((t) => t.id.equals(destinationWalletId))).getSingleOrNull();

      if (sourceWallet == null) {
        throw StateError('Rekening asal tidak ditemukan');
      }
      if (destWallet == null) {
        throw StateError('Rekening tujuan tidak ditemukan');
      }

      final sourceProfileId = sourceWallet.profileId;
      final destProfileId = destWallet.profileId;

      await (update(wallets)..where((t) => t.id.equals(sourceWalletId))).write(
        WalletsCompanion(
          balance: Value(sourceWallet.balance - amount),
          updatedAt: Value(now),
          isSynced: const Value(false),
        ),
      );

      await (update(wallets)..where((t) => t.id.equals(destinationWalletId))).write(
        WalletsCompanion(
          balance: Value(destWallet.balance + amount),
          updatedAt: Value(now),
          isSynced: const Value(false),
        ),
      );

      ProfileEntry? sourceProfile;
      ProfileEntry? destProfile;
      if (sourceProfileId != null) {
        sourceProfile = await (select(profiles)..where((p) => p.id.equals(sourceProfileId))).getSingleOrNull();
      }
      if (destProfileId != null) {
        destProfile = await (select(profiles)..where((p) => p.id.equals(destProfileId))).getSingleOrNull();
      }

      final sourceProfileName = sourceProfile?.username ?? 'Profil Pribadi';
      final destProfileName = destProfile?.username ?? 'Profil Tujuan';

      final pairId = uuid.v4();
      final transferRef = 'cross_profile_$pairId';
      const transferCatId = '11111111-1111-4111-8111-111111111111';
      final cleanNote = (notes != null && notes.trim().isNotEmpty) ? ' • ${notes.trim()}' : '';

      final outNote = 'Transfer ke $destProfileName (${destWallet.name})$cleanNote';
      await into(transactions).insert(
        TransactionsCompanion(
          id: Value(uuid.v4()),
          walletId: Value(sourceWallet.id),
          destinationWalletId: Value(destWallet.id),
          profileId: Value(sourceProfileId),
          categoryId: const Value(transferCatId),
          amount: Value(amount),
          type: const Value('expense'),
          notes: Value(outNote),
          transactionDate: Value(txDate),
          source: Value(source),
          externalRef: Value(transferRef),
          createdAt: Value(now),
          updatedAt: Value(now),
          isSynced: const Value(false),
          isDeleted: const Value(false),
        ),
      );

      final inNote = 'Transfer masuk dari $sourceProfileName (${sourceWallet.name})$cleanNote';
      await into(transactions).insert(
        TransactionsCompanion(
          id: Value(uuid.v4()),
          walletId: Value(destWallet.id),
          destinationWalletId: Value(sourceWallet.id),
          profileId: Value(destProfileId),
          categoryId: const Value(transferCatId),
          amount: Value(amount),
          type: const Value('income'),
          notes: Value(inNote),
          transactionDate: Value(txDate),
          source: Value(source),
          externalRef: Value(transferRef),
          createdAt: Value(now),
          updatedAt: Value(now),
          isSynced: const Value(false),
          isDeleted: const Value(false),
        ),
      );
    });
  }

  Future<void> _reverseCrossProfileSibling(TransactionEntry tx, DateTime now) async {
    if (tx.externalRef == null || !tx.externalRef!.startsWith('cross_profile_')) return;
    final pair = await (select(transactions)..where((t) => t.externalRef.equals(tx.externalRef!) & t.id.equals(tx.id).not() & t.isDeleted.equals(false))).getSingleOrNull();
    if (pair == null) return;
    await (update(transactions)..where((t) => t.id.equals(pair.id))).write(
      TransactionsCompanion(isDeleted: const Value(true), updatedAt: Value(now), isSynced: const Value(false)),
    );
    final pw = await (select(wallets)..where((t) => t.id.equals(pair.walletId))).getSingleOrNull();
    if (pw != null) {
      final nextBal = pair.type == 'income' ? pw.balance - pair.amount : pw.balance + pair.amount;
      await (update(wallets)..where((t) => t.id.equals(pair.walletId))).write(
        WalletsCompanion(balance: Value(nextBal), updatedAt: Value(now), isSynced: const Value(false)),
      );
    }
  }
}
