part of 'app_database.dart';

extension DatabaseSeeder on AppDatabase {
  Future<void> _seedInitialData() async {
    final now = DateTime.now().toUtc();

    final categoriesSeed = getDefaultCategoriesSeed(now);
    for (final cat in categoriesSeed) {
      await into(categories).insertOnConflictUpdate(cat);
    }

    final walletSeed = getDefaultWalletsSeed(now);
    for (final wallet in walletSeed.wallets) {
      await into(wallets).insert(wallet);
    }
    for (final rule in walletSeed.rules) {
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
}
