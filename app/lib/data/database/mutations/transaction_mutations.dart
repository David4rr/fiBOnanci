part of '../app_database.dart';

extension TransactionMutations on AppDatabase {
  Future<void> logTransactionWithBalanceMutation({
    required TransactionsCompanion tx,
  }) {
    return transaction(() async {
      await into(transactions).insert(tx);

      final walletId = tx.walletId.value;
      final amount = tx.amount.value;
      final type = tx.type.value;

      final wallet = await (select(wallets)..where((t) => t.id.equals(walletId))).getSingle();

      if (type == 'expense') {
        await (update(wallets)..where((t) => t.id.equals(walletId))).write(
          WalletsCompanion(
            balance: Value(wallet.balance - amount),
            updatedAt: Value(DateTime.now().toUtc()),
            isSynced: const Value(false),
          ),
        );
      } else if (type == 'income') {
        await (update(wallets)..where((t) => t.id.equals(walletId))).write(
          WalletsCompanion(
            balance: Value(wallet.balance + amount),
            updatedAt: Value(DateTime.now().toUtc()),
            isSynced: const Value(false),
          ),
        );
      } else if (type == 'transfer' && tx.destinationWalletId.value != null) {
        final destId = tx.destinationWalletId.value!;
        final destWallet = await (select(wallets)..where((t) => t.id.equals(destId))).getSingle();

        await (update(wallets)..where((t) => t.id.equals(walletId))).write(
          WalletsCompanion(
            balance: Value(wallet.balance - amount),
            updatedAt: Value(DateTime.now().toUtc()),
            isSynced: const Value(false),
          ),
        );
        await (update(wallets)..where((t) => t.id.equals(destId))).write(
          WalletsCompanion(
            balance: Value(destWallet.balance + amount),
            updatedAt: Value(DateTime.now().toUtc()),
            isSynced: const Value(false),
          ),
        );
      }
    });
  }

  Future<void> deleteTransactionWithBalanceReversal(String txId) {
    return transaction(() async {
      final tx = await (select(transactions)..where((t) => t.id.equals(txId))).getSingle();
      final now = DateTime.now().toUtc();

      await (update(transactions)..where((t) => t.id.equals(txId))).write(
        TransactionsCompanion(
          isDeleted: const Value(true),
          updatedAt: Value(now),
          isSynced: const Value(false),
        ),
      );

      final wallet = await (select(wallets)..where((t) => t.id.equals(tx.walletId))).getSingle();
      if (tx.type == 'expense') {
        await (update(wallets)..where((t) => t.id.equals(tx.walletId))).write(
          WalletsCompanion(
            balance: Value(wallet.balance + tx.amount),
            updatedAt: Value(now),
            isSynced: const Value(false),
          ),
        );
      } else if (tx.type == 'income') {
        await (update(wallets)..where((t) => t.id.equals(tx.walletId))).write(
          WalletsCompanion(
            balance: Value(wallet.balance - tx.amount),
            updatedAt: Value(now),
            isSynced: const Value(false),
          ),
        );
      }
    });
  }

  Future<void> updateTransactionWithWalletReassignment({
    required String txId,
    required String newWalletId,
    required double newAmount,
    required String newType,
    required String newCategoryId,
    String? newDestinationWalletId,
    String? newNotes,
  }) {
    return transaction(() async {
      final oldTx = await (select(transactions)..where((t) => t.id.equals(txId))).getSingle();
      final now = DateTime.now().toUtc();

      // 1. Revert balance on old wallet
      final oldWallet = await (select(wallets)..where((t) => t.id.equals(oldTx.walletId))).getSingle();
      if (oldTx.type == 'expense') {
        await (update(wallets)..where((t) => t.id.equals(oldTx.walletId))).write(
          WalletsCompanion(
            balance: Value(oldWallet.balance + oldTx.amount),
            updatedAt: Value(now),
            isSynced: const Value(false),
          ),
        );
      } else if (oldTx.type == 'income') {
        await (update(wallets)..where((t) => t.id.equals(oldTx.walletId))).write(
          WalletsCompanion(
            balance: Value(oldWallet.balance - oldTx.amount),
            updatedAt: Value(now),
            isSynced: const Value(false),
          ),
        );
      } else if (oldTx.type == 'transfer' && oldTx.destinationWalletId != null) {
        await (update(wallets)..where((t) => t.id.equals(oldTx.walletId))).write(
          WalletsCompanion(
            balance: Value(oldWallet.balance + oldTx.amount),
            updatedAt: Value(now),
            isSynced: const Value(false),
          ),
        );
        final oldDest = await (select(wallets)..where((t) => t.id.equals(oldTx.destinationWalletId!))).getSingle();
        await (update(wallets)..where((t) => t.id.equals(oldTx.destinationWalletId!))).write(
          WalletsCompanion(
            balance: Value(oldDest.balance - oldTx.amount),
            updatedAt: Value(now),
            isSynced: const Value(false),
          ),
        );
      }

      // 2. Apply balance on new wallet
      final targetWallet = await (select(wallets)..where((t) => t.id.equals(newWalletId))).getSingle();
      if (newType == 'expense') {
        await (update(wallets)..where((t) => t.id.equals(newWalletId))).write(
          WalletsCompanion(
            balance: Value(targetWallet.balance - newAmount),
            updatedAt: Value(now),
            isSynced: const Value(false),
          ),
        );
      } else if (newType == 'income') {
        await (update(wallets)..where((t) => t.id.equals(newWalletId))).write(
          WalletsCompanion(
            balance: Value(targetWallet.balance + newAmount),
            updatedAt: Value(now),
            isSynced: const Value(false),
          ),
        );
      } else if (newType == 'transfer' && newDestinationWalletId != null) {
        await (update(wallets)..where((t) => t.id.equals(newWalletId))).write(
          WalletsCompanion(
            balance: Value(targetWallet.balance - newAmount),
            updatedAt: Value(now),
            isSynced: const Value(false),
          ),
        );
        final newDest = await (select(wallets)..where((t) => t.id.equals(newDestinationWalletId))).getSingle();
        await (update(wallets)..where((t) => t.id.equals(newDestinationWalletId))).write(
          WalletsCompanion(
            balance: Value(newDest.balance + newAmount),
            updatedAt: Value(now),
            isSynced: const Value(false),
          ),
        );
      }

      // 3. Update transaction row
      await (update(transactions)..where((t) => t.id.equals(txId))).write(
        TransactionsCompanion(
          walletId: Value(newWalletId),
          categoryId: Value(newCategoryId),
          amount: Value(newAmount),
          type: Value(newType),
          destinationWalletId: newType == 'transfer' ? Value(newDestinationWalletId) : const Value(null),
          notes: Value(newNotes),
          updatedAt: Value(now),
          isSynced: const Value(false),
        ),
      );
    });
  }
}
