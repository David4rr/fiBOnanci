part of '../app_database.dart';

extension WalletAndPocketMutations on AppDatabase {
  Future<void> transferPocketFunds({
    required String pocketId,
    required String walletId,
    required double amount,
    required bool isDepositToPocket,
    String? notes,
  }) {
    return transaction(() async {
      final now = DateTime.now().toUtc();
      final pocket = await (select(pockets)..where((t) => t.id.equals(pocketId))).getSingle();
      final wallet = await (select(wallets)..where((t) => t.id.equals(walletId))).getSingle();

      if (isDepositToPocket) {
        await (update(wallets)..where((t) => t.id.equals(walletId))).write(
          WalletsCompanion(
            balance: Value(wallet.balance - amount),
            updatedAt: Value(now),
            isSynced: const Value(false),
          ),
        );
        await (update(pockets)..where((t) => t.id.equals(pocketId))).write(
          PocketsCompanion(
            currentAmount: Value(pocket.currentAmount + amount),
            updatedAt: Value(now),
            isSynced: const Value(false),
          ),
        );
      } else {
        await (update(pockets)..where((t) => t.id.equals(pocketId))).write(
          PocketsCompanion(
            currentAmount: Value(pocket.currentAmount - amount),
            updatedAt: Value(now),
            isSynced: const Value(false),
          ),
        );
        await (update(wallets)..where((t) => t.id.equals(walletId))).write(
          WalletsCompanion(
            balance: Value(wallet.balance + amount),
            updatedAt: Value(now),
            isSynced: const Value(false),
          ),
        );
      }

      await into(transactions).insert(
        TransactionsCompanion(
          id: Value(const Uuid().v4()),
          walletId: Value(walletId),
          categoryId: const Value('11111111-1111-4111-8111-111111111111'),
          amount: Value(amount),
          type: Value(isDepositToPocket ? 'transfer' : 'income'),
          notes: Value(
            notes ??
                (isDepositToPocket
                    ? 'Setoran ke Kantong ${pocket.name}'
                    : 'Penarikan dari Kantong ${pocket.name}'),
          ),
          transactionDate: Value(now),
          createdAt: Value(now),
          updatedAt: Value(now),
          isSynced: const Value(false),
        ),
      );
    });
  }

  Future<void> markSubscriptionAsPaid(String subscriptionId) {
    return transaction(() async {
      final sub = await (select(subscriptions)..where((t) => t.id.equals(subscriptionId))).getSingle();
      final now = DateTime.now().toUtc();
      const uuid = Uuid();

      await (update(subscriptions)..where((t) => t.id.equals(subscriptionId))).write(
        SubscriptionsCompanion(
          lastPaidDate: Value(now),
          updatedAt: Value(now),
          isSynced: const Value(false),
        ),
      );

      await logTransactionWithBalanceMutation(
        tx: TransactionsCompanion(
          id: Value(uuid.v4()),
          walletId: Value(sub.walletId),
          categoryId: Value(sub.categoryId),
          amount: Value(sub.cost),
          type: const Value('expense'),
          notes: Value('Pembayaran Tagihan: ${sub.title}'),
          transactionDate: Value(now),
          source: const Value('subscription_recurring'),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );
    });
  }

  Future<void> updateWalletBalance(
    String walletId,
    double newBalance, {
    Value<String?> accountNumber = const Value.absent(),
  }) async {
    await (update(wallets)..where((t) => t.id.equals(walletId))).write(
      WalletsCompanion(
        balance: Value(newBalance),
        accountNumber: accountNumber,
        updatedAt: Value(DateTime.now().toUtc()),
        isSynced: const Value(false),
      ),
    );
  }

  Future<void> deleteWallet(String walletId) {
    return transaction(() async {
      final now = DateTime.now().toUtc();
      await (update(wallets)..where((t) => t.id.equals(walletId))).write(
        WalletsCompanion(
          isDeleted: const Value(true),
          updatedAt: Value(now),
          isSynced: const Value(false),
        ),
      );
      await (update(notificationRules)..where((t) => t.walletId.equals(walletId))).write(
        NotificationRulesCompanion(
          isEnabled: const Value(false),
          isDeleted: const Value(true),
          updatedAt: Value(now),
          isSynced: const Value(false),
        ),
      );
    });
  }
}
