import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import 'tables/tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Wallets,
  Categories,
  Transactions,
  Subscriptions,
  NotificationRules,
  Pockets,
  Profiles,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      await _seedInitialData();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await m.createTable(pockets);
      }
      if (from < 3) {
        await m.createTable(profiles);
        await _seedDefaultProfile();
      }
    },
    beforeOpen: (details) async {
      // Ensure pockets table exists even if migration was skipped
      final existingPockets = await customSelect(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='pockets'",
      ).get();
      if (existingPockets.isEmpty) {
        final m = createMigrator();
        await m.createTable(pockets);
      }
      // Ensure profiles table exists
      final existingProfiles = await customSelect(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='profiles'",
      ).get();
      if (existingProfiles.isEmpty) {
        final m = createMigrator();
        await m.createTable(profiles);
        await _seedDefaultProfile();
      } else {
        final count = await customSelect(
          "SELECT COUNT(*) as c FROM profiles WHERE is_deleted = 0",
        ).getSingle();
        if ((count.data['c'] as int? ?? 0) == 0) {
          await _seedDefaultProfile();
        }
      }
    },
  );

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'fibonanci.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }

  // ===========================================================================
  // SEED DATA: Categories & Default User Accounts
  // ===========================================================================
  Future<void> _seedInitialData() async {
    final now = DateTime.now().toUtc();

    // 1. Seed Categories from canonical db-schema.md
    final defaultCategories = [
      CategoriesCompanion(
        id: const Value('11111111-1111-4111-8111-111111111101'),
        name: const Value('Makanan & Minuman'),
        type: const Value('expense'),
        iconName: const Value('utensils'),
        colorHex: const Value('#EF4444'),
        createdAt: Value(now),
        updatedAt: Value(now),
        isSynced: const Value(false),
        isDeleted: const Value(false),
      ),
      CategoriesCompanion(
        id: const Value('11111111-1111-4111-8111-111111111102'),
        name: const Value('Transportasi'),
        type: const Value('expense'),
        iconName: const Value('car'),
        colorHex: const Value('#F97316'),
        createdAt: Value(now),
        updatedAt: Value(now),
        isSynced: const Value(false),
        isDeleted: const Value(false),
      ),
      CategoriesCompanion(
        id: const Value('11111111-1111-4111-8111-111111111103'),
        name: const Value('Belanja & Kebutuhan'),
        type: const Value('expense'),
        iconName: const Value('shopping_bag'),
        colorHex: const Value('#F59E0B'),
        createdAt: Value(now),
        updatedAt: Value(now),
        isSynced: const Value(false),
        isDeleted: const Value(false),
      ),
      CategoriesCompanion(
        id: const Value('11111111-1111-4111-8111-111111111104'),
        name: const Value('Tagihan & Utilitas'),
        type: const Value('expense'),
        iconName: const Value('receipt'),
        colorHex: const Value('#3B82F6'),
        createdAt: Value(now),
        updatedAt: Value(now),
        isSynced: const Value(false),
        isDeleted: const Value(false),
      ),
      CategoriesCompanion(
        id: const Value('11111111-1111-4111-8111-111111111105'),
        name: const Value('Hiburan & Langganan'),
        type: const Value('expense'),
        iconName: const Value('film'),
        colorHex: const Value('#8B5CF6'),
        createdAt: Value(now),
        updatedAt: Value(now),
        isSynced: const Value(false),
        isDeleted: const Value(false),
      ),
      CategoriesCompanion(
        id: const Value('11111111-1111-4111-8111-111111111106'),
        name: const Value('Kesehatan'),
        type: const Value('expense'),
        iconName: const Value('heart_pulse'),
        colorHex: const Value('#EC4899'),
        createdAt: Value(now),
        updatedAt: Value(now),
        isSynced: const Value(false),
        isDeleted: const Value(false),
      ),
      CategoriesCompanion(
        id: const Value('11111111-1111-4111-8111-111111111107'),
        name: const Value('Pendidikan & Kursus'),
        type: const Value('expense'),
        iconName: const Value('graduation_cap'),
        colorHex: const Value('#06B6D4'),
        createdAt: Value(now),
        updatedAt: Value(now),
        isSynced: const Value(false),
        isDeleted: const Value(false),
      ),
      CategoriesCompanion(
        id: const Value('11111111-1111-4111-8111-111111111108'),
        name: const Value('Gaji & Pendapatan Pokok'),
        type: const Value('income'),
        iconName: const Value('banknote'),
        colorHex: const Value('#10B981'),
        createdAt: Value(now),
        updatedAt: Value(now),
        isSynced: const Value(false),
        isDeleted: const Value(false),
      ),
      CategoriesCompanion(
        id: const Value('11111111-1111-4111-8111-111111111109'),
        name: const Value('Bonus & Freelance'),
        type: const Value('income'),
        iconName: const Value('sparkles'),
        colorHex: const Value('#14B8A6'),
        createdAt: Value(now),
        updatedAt: Value(now),
        isSynced: const Value(false),
        isDeleted: const Value(false),
      ),
      CategoriesCompanion(
        id: const Value('11111111-1111-4111-8111-111111111110'),
        name: const Value('Investasi & Bunga'),
        type: const Value('income'),
        iconName: const Value('trending_up'),
        colorHex: const Value('#22C55E'),
        createdAt: Value(now),
        updatedAt: Value(now),
        isSynced: const Value(false),
        isDeleted: const Value(false),
      ),
      CategoriesCompanion(
        id: const Value('11111111-1111-4111-8111-111111111111'),
        name: const Value('Transfer Antar Rekening'),
        type: const Value('expense'),
        iconName: const Value('repeat'),
        colorHex: const Value('#64748B'),
        createdAt: Value(now),
        updatedAt: Value(now),
        isSynced: const Value(false),
        isDeleted: const Value(false),
      ),
    ];

    for (final cat in defaultCategories) {
      await into(categories).insertOnConflictUpdate(cat);
    }

    // 2. Seed Default User Wallets (BCA, blu, SeaBank, Mandiri, Jago, OVO)
    const uuid = Uuid();
    final defaultWallets = [
      WalletsCompanion(
        id: Value(uuid.v4()),
        name: const Value('BCA Utama'),
        type: const Value('bank'),
        balance: const Value(2500000.0),
        colorHex: const Value('#0060AF'),
        iconName: const Value('landmark'),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
      WalletsCompanion(
        id: Value(uuid.v4()),
        name: const Value('blu by BCA'),
        type: const Value('bank'),
        balance: const Value(1200000.0),
        colorHex: const Value('#00A4E4'),
        iconName: const Value('credit_card'),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
      WalletsCompanion(
        id: Value(uuid.v4()),
        name: const Value('SeaBank'),
        type: const Value('bank'),
        balance: const Value(850000.0),
        colorHex: const Value('#FF5722'),
        iconName: const Value('shield_check'),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
      WalletsCompanion(
        id: Value(uuid.v4()),
        name: const Value('Livin Mandiri'),
        type: const Value('bank'),
        balance: const Value(3400000.0),
        colorHex: const Value('#002D62'),
        iconName: const Value('building_2'),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
      WalletsCompanion(
        id: Value(uuid.v4()),
        name: const Value('Bank Jago'),
        type: const Value('bank'),
        balance: const Value(950000.0),
        colorHex: const Value('#FF7300'),
        iconName: const Value('sparkles'),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
      WalletsCompanion(
        id: Value(uuid.v4()),
        name: const Value('OVO Cash'),
        type: const Value('ewallet'),
        balance: const Value(350000.0),
        colorHex: const Value('#4C3494'),
        iconName: const Value('smartphone'),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
      WalletsCompanion(
        id: Value(uuid.v4()),
        name: const Value('ShopeePay'),
        type: const Value('ewallet'),
        balance: const Value(19259.0),
        colorHex: const Value('#EE4D2D'),
        iconName: const Value('shopping_bag'),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    ];

    for (final wallet in defaultWallets) {
      await into(wallets).insert(wallet);
    }
    final defaultRules = [
      NotificationRulesCompanion(
        id: Value(uuid.v4()),
        packageName: const Value('com.bca'),
        walletId: defaultWallets[0].id,
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
      NotificationRulesCompanion(
        id: Value(uuid.v4()),
        packageName: const Value('com.bca.mybca'),
        walletId: defaultWallets[0].id,
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
      NotificationRulesCompanion(
        id: Value(uuid.v4()),
        packageName: const Value('com.bcadigital.blu'),
        walletId: defaultWallets[1].id,
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
      NotificationRulesCompanion(
        id: Value(uuid.v4()),
        packageName: const Value('com.seabank.id'),
        walletId: defaultWallets[2].id,
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
      NotificationRulesCompanion(
        id: Value(uuid.v4()),
        packageName: const Value('com.bankmandiri.livin'),
        walletId: defaultWallets[3].id,
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
      NotificationRulesCompanion(
        id: Value(uuid.v4()),
        packageName: const Value('com.bankjago.app'),
        walletId: defaultWallets[4].id,
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
      NotificationRulesCompanion(
        id: Value(uuid.v4()),
        packageName: const Value('ovo.id'),
        walletId: defaultWallets[5].id,
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
      NotificationRulesCompanion(
        id: Value(uuid.v4()),
        packageName: const Value('com.shopee.id'),
        walletId: defaultWallets[6].id,
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    ];
    for (final rule in defaultRules) {
      await into(notificationRules).insert(rule);
    }
    await _seedDefaultProfile();
  }

  Future<void> _seedDefaultProfile() async {
    final now = DateTime.now().toUtc();
    await into(profiles).insert(
      ProfilesCompanion(
        id: const Value('default_profile_1'),
        username: const Value('David'),
        fullName: const Value('David Arrozaqi'),
        email: const Value('david@fibonanci.app'),
        phone: const Value('+62 812-3456-7890'),
        avatarPath: const Value('preset:avatar_1'),
        occupation: const Value('Software Engineer'),
        bio: const Value('Living lean, building offline financial freedom.'),
        currency: const Value('IDR'),
        monthlyIncomeTarget: const Value(15000000.0),
        isActive: const Value(true),
        createdAt: Value(now),
        updatedAt: Value(now),
        isSynced: const Value(false),
        isDeleted: const Value(false),
      ),
      mode: InsertMode.insertOrIgnore,
    );
  }

  // ===========================================================================
  // REACTIVE QUERIES
  // ===========================================================================
  Stream<List<WalletEntry>> watchActiveWallets() {
    return (select(wallets)..where((tbl) => tbl.isDeleted.equals(false))).watch();
  }

  Stream<List<CategoryEntry>> watchActiveCategories() {
    return (select(categories)..where((tbl) => tbl.isDeleted.equals(false))).watch();
  }

  Stream<List<TransactionEntry>> watchRecentTransactions({int limit = 30}) {
    return (select(transactions)
          ..where((tbl) => tbl.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)])
          ..limit(limit))
        .watch();
  }

  Stream<List<SubscriptionEntry>> watchActiveSubscriptions() {
    return (select(subscriptions)
          ..where((tbl) => tbl.isDeleted.equals(false) & tbl.status.equals('active'))
          ..orderBy([(t) => OrderingTerm.asc(t.dueDay)]))
        .watch();
  }

  Stream<List<PocketEntry>> watchActivePockets() {
    return (select(pockets)
          ..where((tbl) => tbl.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .watch();
  }

  Future<List<PocketEntry>> getActivePockets() {
    return (select(pockets)
          ..where((tbl) => tbl.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  Future<void> createPocket(PocketsCompanion pocket) {
    return into(pockets).insert(pocket);
  }

  Future<void> updatePocket(PocketsCompanion pocket) {
    return (update(pockets)..where((t) => t.id.equals(pocket.id.value))).write(pocket);
  }

  Future<void> deletePocket(String pocketId) {
    return (update(pockets)..where((t) => t.id.equals(pocketId))).write(
      PocketsCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  Stream<List<ProfileEntry>> watchProfiles() {
    return (select(profiles)
          ..where((tbl) => tbl.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .watch();
  }

  Future<List<ProfileEntry>> getProfiles() {
    return (select(profiles)
          ..where((tbl) => tbl.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  Future<ProfileEntry?> getActiveProfile() {
    return (select(profiles)
          ..where((tbl) => tbl.isDeleted.equals(false) & tbl.isActive.equals(true))
          ..limit(1))
        .getSingleOrNull();
  }

  Future<void> createProfile(ProfilesCompanion profile) {
    return into(profiles).insert(profile);
  }

  Future<void> updateProfile(ProfilesCompanion profile) {
    return (update(profiles)..where((t) => t.id.equals(profile.id.value))).write(profile);
  }

  Future<void> deleteProfile(String profileId) {
    return transaction(() async {
      final now = DateTime.now().toUtc();
      await (update(profiles)..where((t) => t.id.equals(profileId))).write(
        ProfilesCompanion(
          isDeleted: const Value(true),
          isActive: const Value(false),
          updatedAt: Value(now),
        ),
      );
      // Ensure at least one active profile if any remaining non-deleted profile
      final remaining = await (select(profiles)
            ..where((t) => t.isDeleted.equals(false))
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
          .get();
      if (remaining.isNotEmpty) {
        final hasActive = remaining.any((p) => p.isActive);
        if (!hasActive) {
          await (update(profiles)..where((t) => t.id.equals(remaining.first.id))).write(
            ProfilesCompanion(
              isActive: const Value(true),
              updatedAt: Value(now),
            ),
          );
        }
      } else {
        // Reseed default if all deleted
        await _seedDefaultProfile();
      }
    });
  }

  Future<void> setActiveProfile(String profileId) {
    return transaction(() async {
      final now = DateTime.now().toUtc();
      // Deactivate all
      await (update(profiles)..where((t) => t.isDeleted.equals(false))).write(
        ProfilesCompanion(
          isActive: const Value(false),
          updatedAt: Value(now),
        ),
      );
      // Activate target
      await (update(profiles)..where((t) => t.id.equals(profileId))).write(
        ProfilesCompanion(
          isActive: const Value(true),
          updatedAt: Value(now),
        ),
      );
    });
  }

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

      // Log transaction record for pocket cashflow trend analytics
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

  // ===========================================================================
  // ATOMIC TRANSACTIONS & BALANCE MUTATIONS
  // ===========================================================================
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

        // Deduct source
        await (update(wallets)..where((t) => t.id.equals(walletId))).write(
          WalletsCompanion(
            balance: Value(wallet.balance - amount),
            updatedAt: Value(DateTime.now().toUtc()),
            isSynced: const Value(false),
          ),
        );
        // Credit destination
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

  Future<void> markSubscriptionAsPaid(String subscriptionId) {
    return transaction(() async {
      final sub = await (select(subscriptions)..where((t) => t.id.equals(subscriptionId))).getSingle();
      final now = DateTime.now().toUtc();
      const uuid = Uuid();

      // 1. Update subscription last_paid_date
      await (update(subscriptions)..where((t) => t.id.equals(subscriptionId))).write(
        SubscriptionsCompanion(
          lastPaidDate: Value(now),
          updatedAt: Value(now),
          isSynced: const Value(false),
        ),
      );

      // 2. Log atomic expense transaction & mutate wallet balance
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

  Future<void> updateWalletBalance(String walletId, double newBalance) async {
    await (update(wallets)..where((t) => t.id.equals(walletId))).write(
      WalletsCompanion(
        balance: Value(newBalance),
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


  Future<void> deleteTransactionWithBalanceReversal(String txId) {
    return transaction(() async {
      final tx = await (select(transactions)..where((t) => t.id.equals(txId))).getSingle();
      final now = DateTime.now().toUtc();

      // Soft delete transaction
      await (update(transactions)..where((t) => t.id.equals(txId))).write(
        TransactionsCompanion(
          isDeleted: const Value(true),
          updatedAt: Value(now),
          isSynced: const Value(false),
        ),
      );

      // Revert wallet balance
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

  // ===========================================================================
  // NOTIFICATION RULES & DYNAMIC APP BINDINGS
  // ===========================================================================

  Stream<List<NotificationRuleEntry>> watchNotificationRules() {
    return (select(notificationRules)
          ..where((tbl) => tbl.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  Future<NotificationRuleEntry?> getNotificationRuleForPackage(String packageName) {
    return (select(notificationRules)
          ..where((tbl) => tbl.packageName.equals(packageName) & tbl.isEnabled.equals(true) & tbl.isDeleted.equals(false))
          ..limit(1))
        .getSingleOrNull();
  }

  Future<List<NotificationRuleEntry>> getNotificationRulesForWallet(String walletId) {
    return (select(notificationRules)
          ..where((tbl) => tbl.walletId.equals(walletId) & tbl.isDeleted.equals(false)))
        .get();
  }

  Future<List<String>> getActiveNotificationPackages() async {
    final rules = await (select(notificationRules)
          ..where((tbl) => tbl.isEnabled.equals(true) & tbl.isDeleted.equals(false)))
        .get();
    return rules.map((r) => r.packageName).toSet().toList();
  }

  Future<void> upsertNotificationRule({
    required String walletId,
    required String packageName,
    bool isEnabled = true,
  }) async {
    final now = DateTime.now().toUtc();
    final existing = await (select(notificationRules)
          ..where((tbl) => tbl.packageName.equals(packageName) & tbl.isDeleted.equals(false))
          ..limit(1))
        .getSingleOrNull();

    if (existing != null) {
      await (update(notificationRules)..where((t) => t.id.equals(existing.id))).write(
        NotificationRulesCompanion(
          walletId: Value(walletId),
          isEnabled: Value(isEnabled),
          updatedAt: Value(now),
          isSynced: const Value(false),
        ),
      );
    } else {
      const uuid = Uuid();
      await into(notificationRules).insert(
        NotificationRulesCompanion(
          id: Value(uuid.v4()),
          packageName: Value(packageName),
          walletId: Value(walletId),
          isEnabled: Value(isEnabled),
          createdAt: Value(now),
          updatedAt: Value(now),
          isSynced: const Value(false),
          isDeleted: const Value(false),
        ),
      );
    }
  }

  Future<void> deleteNotificationRulesForWallet(String walletId) {
    final now = DateTime.now().toUtc();
    return (update(notificationRules)..where((t) => t.walletId.equals(walletId))).write(
      NotificationRulesCompanion(
        isDeleted: const Value(true),
        isEnabled: const Value(false),
        updatedAt: Value(now),
        isSynced: const Value(false),
      ),
    );
  }

  Future<void> unbindPackage(String packageName) {
    final now = DateTime.now().toUtc();
    return (update(notificationRules)..where((t) => t.packageName.equals(packageName))).write(
      NotificationRulesCompanion(
        isDeleted: const Value(true),
        isEnabled: const Value(false),
        updatedAt: Value(now),
        isSynced: const Value(false),
      ),
    );
  }
}
