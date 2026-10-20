part of '../app_database.dart';

extension TransactionMutations on AppDatabase {
  Future<void> logTransactionWithBalanceMutation({
    required TransactionsCompanion tx,
  }) {
    return transaction(() async {
      final walletId = tx.walletId.value;
      final amount = tx.amount.value;
      final type = tx.type.value;
      final wallet = await (select(wallets)..where((t) => t.id.equals(walletId))).getSingle();
      final toInsert = (tx.profileId.present && tx.profileId.value != null)
          ? tx
          : tx.copyWith(profileId: Value(wallet.profileId));
      await into(transactions).insert(toInsert);
      final now = DateTime.now().toUtc();
      if (type == 'expense' || type == 'transfer') {
        await (update(wallets)..where((t) => t.id.equals(walletId))).write(
          WalletsCompanion(balance: Value(wallet.balance - amount), updatedAt: Value(now), isSynced: const Value(false)),
        );
        final destId = tx.destinationWalletId.present ? tx.destinationWalletId.value : null;
        if (type == 'transfer' && destId != null && destId != walletId) {
          final destWallet = await (select(wallets)..where((t) => t.id.equals(destId))).getSingleOrNull();
          if (destWallet != null) {
            await (update(wallets)..where((t) => t.id.equals(destId))).write(
              WalletsCompanion(balance: Value(destWallet.balance + amount), updatedAt: Value(now), isSynced: const Value(false)),
            );
          }
        }
      } else if (type == 'income') {
        await (update(wallets)..where((t) => t.id.equals(walletId))).write(
          WalletsCompanion(balance: Value(wallet.balance + amount), updatedAt: Value(now), isSynced: const Value(false)),
        );
      }
    });
  }

  Future<PocketEntry?> _findLinkedPocket(TransactionEntry tx) async {
    final ref = tx.externalRef;
    if (ref != null && ref.startsWith('pocket_') && !ref.startsWith('pocket_close_')) {
      final id = ref.substring('pocket_'.length);
      return (select(pockets)..where((p) => p.id.equals(id) & p.isDeleted.equals(false))).getSingleOrNull();
    }
    final note = tx.notes ?? '';
    if (!note.contains('Kantong ')) return null;
    final active = await (select(pockets)..where((p) => p.isDeleted.equals(false))).get();
    return active.where((p) => note.contains('Kantong ${p.name}')).firstOrNull;
  }

  Future<void> _adjustLinkedPocket(TransactionEntry tx, DateTime now, {required bool isRevert, double? overrideAmount}) async {
    final pocket = await _findLinkedPocket(tx);
    if (pocket == null) return;
    final amt = overrideAmount ?? tx.amount;
    final isDeposit = tx.type == 'transfer' || (tx.notes ?? '').startsWith('Setoran ke Kantong');
    final delta = isDeposit ? (isRevert ? -amt : amt) : (isRevert ? amt : -amt);
    final next = (pocket.currentAmount + delta).clamp(0.0, double.infinity);
    await (update(pockets)..where((p) => p.id.equals(pocket.id))).write(
      PocketsCompanion(currentAmount: Value(next), updatedAt: Value(now), isSynced: const Value(false)),
    );
  }

  Future<void> deleteTransactionWithBalanceReversal(String txId) {
    return transaction(() async {
      final tx = await (select(transactions)..where((t) => t.id.equals(txId))).getSingle();
      final now = DateTime.now().toUtc();
      await (update(transactions)..where((t) => t.id.equals(txId))).write(
        TransactionsCompanion(isDeleted: const Value(true), updatedAt: Value(now), isSynced: const Value(false)),
      );

      final wallet = await (select(wallets)..where((t) => t.id.equals(tx.walletId))).getSingleOrNull();
      if (wallet != null) {
        if (tx.type == 'expense' || tx.type == 'transfer') {
          await (update(wallets)..where((t) => t.id.equals(tx.walletId))).write(
            WalletsCompanion(balance: Value(wallet.balance + tx.amount), updatedAt: Value(now), isSynced: const Value(false)),
          );
          if (tx.type == 'transfer' && tx.destinationWalletId != null && tx.destinationWalletId != tx.walletId) {
            final dest = await (select(wallets)..where((t) => t.id.equals(tx.destinationWalletId!))).getSingleOrNull();
            if (dest != null) {
              await (update(wallets)..where((t) => t.id.equals(dest.id))).write(
                WalletsCompanion(balance: Value(dest.balance - tx.amount), updatedAt: Value(now), isSynced: const Value(false)),
              );
            }
          }
        } else if (tx.type == 'income') {
          await (update(wallets)..where((t) => t.id.equals(tx.walletId))).write(
            WalletsCompanion(balance: Value(wallet.balance - tx.amount), updatedAt: Value(now), isSynced: const Value(false)),
          );
        }
      }
      await _reverseCrossProfileSibling(tx, now);
      await _adjustLinkedPocket(tx, now, isRevert: true);
      if (tx.externalRef != null && tx.externalRef!.startsWith('sub_')) {
        final subId = tx.externalRef!.substring(4);
        final sub = await (select(subscriptions)..where((s) => s.id.equals(subId) & s.isDeleted.equals(false))).getSingleOrNull();
        if (sub != null) {
          final nextPaid = (sub.paidCycles - 1).clamp(0, 9999);
          await (update(subscriptions)..where((s) => s.id.equals(sub.id))).write(
            SubscriptionsCompanion(paidCycles: Value(nextPaid), lastPaidDate: const Value(null), status: const Value('active'), updatedAt: Value(now), isSynced: const Value(false)),
          );
        }
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

      final oldWallet = await (select(wallets)..where((t) => t.id.equals(oldTx.walletId))).getSingleOrNull();
      if (oldWallet != null) {
        if (oldTx.type == 'expense' || oldTx.type == 'transfer') {
          await (update(wallets)..where((t) => t.id.equals(oldTx.walletId))).write(
            WalletsCompanion(balance: Value(oldWallet.balance + oldTx.amount), updatedAt: Value(now), isSynced: const Value(false)),
          );
          if (oldTx.type == 'transfer' && oldTx.destinationWalletId != null && oldTx.destinationWalletId != oldTx.walletId) {
            final oldDest = await (select(wallets)..where((t) => t.id.equals(oldTx.destinationWalletId!))).getSingleOrNull();
            if (oldDest != null) {
              await (update(wallets)..where((t) => t.id.equals(oldDest.id))).write(
                WalletsCompanion(balance: Value(oldDest.balance - oldTx.amount), updatedAt: Value(now), isSynced: const Value(false)),
              );
            }
          }
        } else if (oldTx.type == 'income') {
          await (update(wallets)..where((t) => t.id.equals(oldTx.walletId))).write(
            WalletsCompanion(balance: Value(oldWallet.balance - oldTx.amount), updatedAt: Value(now), isSynced: const Value(false)),
          );
        }
      }
      await _adjustLinkedPocket(oldTx, now, isRevert: true);

      final targetWallet = await (select(wallets)..where((t) => t.id.equals(newWalletId))).getSingle();
      if (newType == 'expense' || newType == 'transfer') {
        await (update(wallets)..where((t) => t.id.equals(newWalletId))).write(
          WalletsCompanion(balance: Value(targetWallet.balance - newAmount), updatedAt: Value(now), isSynced: const Value(false)),
        );
        if (newType == 'transfer' && newDestinationWalletId != null && newDestinationWalletId != newWalletId) {
          final newDest = await (select(wallets)..where((t) => t.id.equals(newDestinationWalletId))).getSingleOrNull();
          if (newDest != null) {
            await (update(wallets)..where((t) => t.id.equals(newDest.id))).write(
              WalletsCompanion(balance: Value(newDest.balance + newAmount), updatedAt: Value(now), isSynced: const Value(false)),
            );
          }
        }
      } else if (newType == 'income') {
        await (update(wallets)..where((t) => t.id.equals(newWalletId))).write(
          WalletsCompanion(balance: Value(targetWallet.balance + newAmount), updatedAt: Value(now), isSynced: const Value(false)),
        );
      }
      final updatedTx = oldTx.copyWith(
        walletId: newWalletId,
        amount: newAmount,
        type: newType,
        destinationWalletId: Value(newType == 'transfer' ? newDestinationWalletId : null),
        notes: Value(newNotes),
      );
      await _adjustLinkedPocket(updatedTx, now, isRevert: false, overrideAmount: newAmount);

      await (update(transactions)..where((t) => t.id.equals(txId))).write(
        TransactionsCompanion(
          profileId: Value(targetWallet.profileId),
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
