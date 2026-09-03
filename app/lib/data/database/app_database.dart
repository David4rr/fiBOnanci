import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import 'seed/default_categories.dart';
import 'seed/default_wallets.dart';
import 'tables/tables.dart';

part 'app_database.g.dart';
part 'database_seeder.dart';
part 'database_queries.dart';
part 'mutations/transaction_mutations.dart';
part 'mutations/wallet_and_pocket_mutations.dart';
part 'mutations/profile_and_rule_mutations.dart';

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
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      await _seedInitialData();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) await m.createTable(pockets);
      if (from < 3) {
        await m.createTable(profiles);
        await _seedDefaultProfile();
      }
      if (from < 4) await m.addColumn(wallets, wallets.accountNumber);
    },
    beforeOpen: (details) async {
      final existingPockets = await customSelect(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='pockets'",
      ).get();
      if (existingPockets.isEmpty) {
        final m = createMigrator();
        await m.createTable(pockets);
      }
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
      final walletColumns = await customSelect("PRAGMA table_info(wallets)").get();
      final hasAccountNumber = walletColumns.any((c) => c.data['name'] == 'account_number');
      if (!hasAccountNumber) {
        final m = createMigrator();
        await m.addColumn(wallets, wallets.accountNumber);
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
}
