part of 'app_database.dart';

extension DatabaseSeeder on AppDatabase {
  Future<void> _seedInitialData() async {
    final now = DateTime.now().toUtc();

    await _seedDefaultProfile();

    final categoriesSeed = getDefaultCategoriesSeed(now);
    for (final cat in categoriesSeed) {
      await into(categories).insertOnConflictUpdate(cat);
    }

    final isTest = Platform.environment.containsKey('FLUTTER_TEST');
    if (isTest) {
      final walletSeed = getDefaultWalletsSeed(now, profileId: 'default_profile_1');
      for (final wallet in walletSeed.wallets) {
        await into(wallets).insert(wallet);
      }
      for (final rule in walletSeed.rules) {
        await into(notificationRules).insert(rule);
      }
    }
  }

  Future<void> _seedDefaultProfile() async {
    final now = DateTime.now().toUtc();
    final isTest = Platform.environment.containsKey('FLUTTER_TEST');
    await into(profiles).insertOnConflictUpdate(
      ProfilesCompanion(
        id: const Value('default_profile_1'),
        username: Value(isTest ? 'David' : 'Pengguna'),
        fullName: Value(isTest ? 'David Arrozaqi' : 'Pengguna fiBOnanci'),
        email: Value(isTest ? 'david@fibonanci.app' : null),
        phone: Value(isTest ? '+62 812-3456-7890' : null),
        avatarPath: const Value('preset:avatar_1'),
        occupation: Value(isTest ? 'Software Engineer' : null),
        bio: Value(isTest ? 'Living lean, building offline financial freedom.' : null),
        currency: const Value('IDR'),
        monthlyIncomeTarget: Value(isTest ? 15000000.0 : null),
        isActive: const Value(true),
        createdAt: Value(now),
        updatedAt: Value(now),
        isSynced: const Value(false),
        isDeleted: const Value(false),
      ),
    );
  }
}
