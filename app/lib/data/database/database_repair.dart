part of 'app_database.dart';

extension DatabaseRepair on AppDatabase {
  Future<void> repairAndMigrateProfiles() async {
    final davidProfile = await customSelect(
      "SELECT id FROM profiles WHERE email = 'david@fibonanci.app' OR id = 'default_profile_1' ORDER BY CASE WHEN email = 'david@fibonanci.app' THEN 0 ELSE 1 END, created_at ASC LIMIT 1",
    ).getSingleOrNull();

    final davidId = davidProfile != null ? davidProfile.data['id'] as String : 'default_profile_1';

    await customStatement("UPDATE wallets SET profile_id = ? WHERE profile_id IS NULL", [davidId]);
    await customStatement("UPDATE transactions SET profile_id = ? WHERE profile_id IS NULL", [davidId]);
    await customStatement("UPDATE subscriptions SET profile_id = ? WHERE profile_id IS NULL", [davidId]);
    await customStatement("UPDATE pockets SET profile_id = ? WHERE profile_id IS NULL", [davidId]);
    await customStatement("UPDATE notification_rules SET profile_id = ? WHERE profile_id IS NULL", [davidId]);

    if (davidProfile != null) {
      final davidWallets = await customSelect(
        "SELECT COUNT(*) as c FROM wallets WHERE profile_id = ? AND is_deleted = 0",
        variables: [Variable.withString(davidId)],
      ).getSingle();
      final count = davidWallets.data['c'] as int? ?? 0;
      if (count == 0) {
        await customStatement(
          "UPDATE wallets SET profile_id = ? WHERE name IN ('BCA Utama', 'blu by BCA', 'SeaBank', 'Livin Mandiri', 'Bank Jago', 'OVO Cash', 'ShopeePay', 'Bank Jago (Kantong Utama)', 'Bibit Reksadana', 'GoPay', 'Dompet Tunai')",
          [davidId],
        );
        await customStatement(
          "UPDATE transactions SET profile_id = ? WHERE wallet_id IN (SELECT id FROM wallets WHERE profile_id = ?)",
          [davidId, davidId],
        );
        await customStatement(
          "UPDATE subscriptions SET profile_id = ? WHERE wallet_id IN (SELECT id FROM wallets WHERE profile_id = ?)",
          [davidId, davidId],
        );
        await customStatement(
          "UPDATE pockets SET profile_id = ? WHERE linked_wallet_id IN (SELECT id FROM wallets WHERE profile_id = ?)",
          [davidId, davidId],
        );
        await customStatement(
          "UPDATE notification_rules SET profile_id = ? WHERE wallet_id IN (SELECT id FROM wallets WHERE profile_id = ?)",
          [davidId, davidId],
        );
      }
    }

    final allProfiles = await customSelect("SELECT id, username FROM profiles ORDER BY created_at ASC").get();
    final seen = <String>{};
    for (final p in allProfiles) {
      final pid = p.data['id'] as String;
      var uname = (p.data['username'] as String? ?? '').trim().replaceAll('@', '');
      if (uname.isEmpty) uname = 'user';
      final lower = uname.toLowerCase();
      if (seen.contains(lower)) {
        var counter = 2;
        var uniqueUname = '${uname}_$counter';
        while (seen.contains(uniqueUname.toLowerCase())) {
          counter++;
          uniqueUname = '${uname}_$counter';
        }
        seen.add(uniqueUname.toLowerCase());
        await customStatement("UPDATE profiles SET username = ? WHERE id = ?", [uniqueUname, pid]);
      } else {
        seen.add(lower);
        if (uname != (p.data['username'] as String? ?? '')) {
          await customStatement("UPDATE profiles SET username = ? WHERE id = ?", [uname, pid]);
        }
      }
    }
  }

  Future<void> restoreJsonBackup(Map<String, dynamic> data) {
    return transaction(() async {
      for (final item in (data['profiles'] as List? ?? const [])) {
        if (item is Map<String, dynamic>) {
          await into(profiles).insertOnConflictUpdate(ProfileEntry.fromJson(item));
        }
      }
      for (final item in (data['categories'] as List? ?? const [])) {
        if (item is Map<String, dynamic>) {
          await into(categories).insertOnConflictUpdate(CategoryEntry.fromJson(item));
        }
      }
      for (final item in (data['wallets'] as List? ?? const [])) {
        if (item is Map<String, dynamic>) {
          final m = Map<String, dynamic>.from(item);
          m.putIfAbsent('type', () => 'bank');
          m.putIfAbsent('currency', () => 'IDR');
          m.putIfAbsent('colorHex', () => '#0066AE');
          m.putIfAbsent('iconName', () => 'account_balance');
          m.putIfAbsent('createdAt', () => DateTime.now().toIso8601String());
          m.putIfAbsent('updatedAt', () => DateTime.now().toIso8601String());
          m.putIfAbsent('isSynced', () => false);
          m.putIfAbsent('isDeleted', () => false);
          await into(wallets).insertOnConflictUpdate(WalletEntry.fromJson(m));
        }
      }
      for (final item in (data['pockets'] as List? ?? const [])) {
        if (item is Map<String, dynamic>) {
          await into(pockets).insertOnConflictUpdate(PocketEntry.fromJson(item));
        }
      }
      for (final item in (data['subscriptions'] as List? ?? const [])) {
        if (item is Map<String, dynamic>) {
          final m = Map<String, dynamic>.from(item);
          if (!m.containsKey('nextDueDate') || m['nextDueDate'] == null) {
            final serializer = driftRuntimeOptions.defaultSerializer;
            final migrated = SubscriptionScheduleService.migrateLegacyNextDueDate(
              dueDay: serializer.fromJson<int>(m['dueDay']),
              billingCycle: serializer.fromJson<String>(m['billingCycle']),
              createdAt: serializer.fromJson<DateTime>(m['createdAt']),
              lastPaidDate: serializer.fromJson<DateTime?>(m['lastPaidDate']),
            );
            m['nextDueDate'] = serializer.toJson<DateTime>(migrated);
          }
          await into(subscriptions).insertOnConflictUpdate(SubscriptionEntry.fromJson(m));
        }
      }
      for (final item in (data['transactions'] as List? ?? const [])) {
        if (item is Map<String, dynamic>) {
          await into(transactions).insertOnConflictUpdate(TransactionEntry.fromJson(item));
        }
      }
    });
  }

  Future<void> migrateSubscriptionsToV7(Migrator m) async {
    final subCols = await customSelect("PRAGMA table_info(subscriptions)").get();
    if (!subCols.any((c) => c.data['name'] == 'next_due_date')) {
      await customStatement('ALTER TABLE subscriptions ADD COLUMN next_due_date INTEGER');
    }
    final rows = await customSelect(
      "SELECT id, due_day, billing_cycle, last_paid_date, created_at FROM subscriptions WHERE next_due_date IS NULL",
    ).get();
    for (final row in rows) {
      final id = row.data['id'] as String;
      final dueDay = row.data['due_day'] as int;
      final billingCycle = row.data['billing_cycle'] as String;
      final createdAt = typeMapping.read(DriftSqlType.dateTime, row.data['created_at'])!;
      final lastPaidDate = typeMapping.read(DriftSqlType.dateTime, row.data['last_paid_date']);
      final nextDue = SubscriptionScheduleService.migrateLegacyNextDueDate(
        dueDay: dueDay,
        billingCycle: billingCycle,
        createdAt: createdAt,
        lastPaidDate: lastPaidDate,
      );
      await customUpdate(
        "UPDATE subscriptions SET next_due_date = ? WHERE id = ?",
        variables: [Variable.withDateTime(nextDue), Variable.withString(id)],
        updates: {subscriptions},
      );
    }
    await m.alterTable(TableMigration(subscriptions));
  }
}
