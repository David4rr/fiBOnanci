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
          profileId: Value(pocket.profileId ?? wallet.profileId),
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
          externalRef: Value('pocket_${pocket.id}'),
          transactionDate: Value(now),
          createdAt: Value(now),
          updatedAt: Value(now),
          isSynced: const Value(false),
        ),
      );
    });
  }

  Future<void> markSubscriptionAsPaid(String subscriptionId, {double? actualAmount}) {
    return transaction(() async {
      final sub = await (select(subscriptions)..where((t) => t.id.equals(subscriptionId))).getSingle();
      final now = DateTime.now().toUtc();
      const uuid = Uuid();
      final effectiveCost = (actualAmount != null && actualAmount >= 0) ? actualAmount : sub.cost;

      final isInstallment = sub.isInstallment;
      final newPaidCycles = sub.paidCycles + 1;
      final isComplete = isInstallment && sub.totalCycles != null && newPaidCycles >= sub.totalCycles!;
      final newStatus = isComplete ? 'completed' : sub.status;

      await (update(subscriptions)..where((t) => t.id.equals(subscriptionId))).write(
        SubscriptionsCompanion(
          lastPaidDate: Value(now),
          paidCycles: Value(newPaidCycles),
          status: Value(newStatus),
          updatedAt: Value(now),
          isSynced: const Value(false),
        ),
      );

      final baseNote = isInstallment && sub.totalCycles != null
          ? 'Pembayaran Cicilan ($newPaidCycles/${sub.totalCycles}): ${sub.title}'
          : 'Pembayaran Tagihan: ${sub.title}';
      final txNotes = (effectiveCost - sub.cost).abs() > 0.01
          ? '$baseNote (Diskon/Penyesuaian dari ${sub.cost.toInt()})'
          : baseNote;

      await logTransactionWithBalanceMutation(
        tx: TransactionsCompanion(
          id: Value(uuid.v4()),
          profileId: Value(sub.profileId),
          walletId: Value(sub.walletId),
          categoryId: Value(sub.categoryId),
          amount: Value(effectiveCost),
          type: const Value('expense'),
          notes: Value(txNotes),
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

  Future<void> deletePocket(String pocketId) {
    return transaction(() async {
      final now = DateTime.now().toUtc();
      final pocket = await (select(pockets)..where((t) => t.id.equals(pocketId))).getSingleOrNull();
      if (pocket == null) return;

      if (pocket.currentAmount > 0) {
        final activeWallets = await (select(wallets)..where((w) => w.isDeleted.equals(false))).get();
        final targetWallet = activeWallets.where((w) => w.id == pocket.linkedWalletId).firstOrNull ??
            activeWallets.where((w) => w.profileId == pocket.profileId).firstOrNull ??
            activeWallets.firstOrNull;
        if (targetWallet != null) {
          await (update(wallets)..where((w) => w.id.equals(targetWallet.id))).write(
            WalletsCompanion(balance: Value(targetWallet.balance + pocket.currentAmount), updatedAt: Value(now), isSynced: const Value(false)),
          );
          await into(transactions).insert(
            TransactionsCompanion(
              id: Value(const Uuid().v4()),
              profileId: Value(pocket.profileId ?? targetWallet.profileId),
              walletId: Value(targetWallet.id),
              categoryId: const Value('11111111-1111-4111-8111-111111111111'),
              amount: Value(pocket.currentAmount),
              type: const Value('income'),
              notes: Value('Penarikan dari Kantong ${pocket.name} (Penutupan)'),
              externalRef: Value('pocket_close_${pocket.id}'),
              transactionDate: Value(now),
              createdAt: Value(now),
              updatedAt: Value(now),
              isSynced: const Value(false),
            ),
          );
        }
      }

      await (update(pockets)..where((t) => t.id.equals(pocketId))).write(
        PocketsCompanion(currentAmount: const Value(0.0), isDeleted: const Value(true), updatedAt: Value(now), isSynced: const Value(false)),
      );
    });
  }
}
