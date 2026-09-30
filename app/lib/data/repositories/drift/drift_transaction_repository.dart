part of '../finance_repository.dart';

mixin DriftTransactionRepository on DriftRepoBase {
  Stream<List<TransactionEntry>> watchRecentTransactions({String? profileId, int limit = 50}) =>
      db.watchRecentTransactions(profileId: profileId, limit: limit);

  Future<List<TransactionEntry>> getTransactions({String? profileId, int limit = 50}) {
    final q = db.select(db.transactions)
      ..where((t) => t.isDeleted.equals(false) & db.profileFilter(t.profileId, profileId));
    return (q
          ..orderBy([(t) => drift.OrderingTerm.desc(t.transactionDate)])
          ..limit(limit))
        .get();
  }

  Future<void> addTransaction({
    required String walletId,
    required String categoryId,
    required double amount,
    required String type,
    String? destinationWalletId,
    String? notes,
    DateTime? transactionDate,
    String source = 'manual',
    String? externalRef,
    String? profileId,
  }) async {
    final now = DateTime.now().toUtc();
    final wallet = await (db.select(db.wallets)..where((t) => t.id.equals(walletId))).getSingleOrNull();
    final effProfileId = profileId ?? wallet?.profileId ?? (await db.getActiveProfile())?.id ?? 'default_profile_1';
    return db.logTransactionWithBalanceMutation(
      tx: TransactionsCompanion(
        id: drift.Value(uuid.v4()),
        walletId: drift.Value(walletId),
        profileId: drift.Value(effProfileId),
        categoryId: drift.Value(categoryId),
        amount: drift.Value(amount),
        type: drift.Value(type),
        destinationWalletId: destinationWalletId != null ? drift.Value(destinationWalletId) : const drift.Value(null),
        notes: notes != null && notes.isNotEmpty ? drift.Value(notes) : const drift.Value(null),
        transactionDate: drift.Value((transactionDate ?? now).toUtc()),
        source: drift.Value(source),
        externalRef: externalRef != null ? drift.Value(externalRef) : const drift.Value(null),
        createdAt: drift.Value(now),
        updatedAt: drift.Value(now),
      ),
    );
  }

  Future<void> updateTransaction({
    required String transactionId,
    required String newWalletId,
    required double newAmount,
    required String newType,
    required String newCategoryId,
    String? newDestinationWalletId,
    String? newNotes,
  }) {
    return db.updateTransactionWithWalletReassignment(
      txId: transactionId,
      newWalletId: newWalletId,
      newAmount: newAmount,
      newType: newType,
      newCategoryId: newCategoryId,
      newDestinationWalletId: newDestinationWalletId,
      newNotes: newNotes,
    );
  }

  Future<void> deleteTransaction(String transactionId) {
    return db.deleteTransactionWithBalanceReversal(transactionId);
  }
}
