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
}
