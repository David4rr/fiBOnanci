part of '../finance_repository.dart';

mixin DriftTransactionRepository on DriftRepoBase {
  Stream<List<TransactionEntry>> watchRecentTransactions({int limit = 50}) =>
      db.watchRecentTransactions(limit: limit);

  Future<List<TransactionEntry>> getTransactions({int limit = 50}) =>
      (db.select(db.transactions)
            ..where((t) => t.isDeleted.equals(false))
            ..orderBy([(t) => drift.OrderingTerm.desc(t.transactionDate)])
            ..limit(limit))
          .get();

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
  }) {
    final now = DateTime.now().toUtc();
    return db.logTransactionWithBalanceMutation(
      tx: TransactionsCompanion(
        id: drift.Value(uuid.v4()),
        walletId: drift.Value(walletId),
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
