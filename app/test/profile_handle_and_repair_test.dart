import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:fibonanci_app/data/database/app_database.dart';
import 'package:fibonanci_app/data/repositories/finance_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Profile Handle Uniqueness & Data Repair Tests', () {
    late AppDatabase db;
    late DriftFinanceRepository repo;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repo = DriftFinanceRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('Rejects duplicate username and strips @ symbol', () async {
      final profiles = await repo.getProfiles();
      expect(profiles, isNotEmpty);
      final defaultProfile = profiles.first;
      expect(defaultProfile.username, 'David');

      // Attempt adding profile with same username (case insensitive)
      expect(
        () => repo.addProfile(username: 'david', fullName: 'David Two'),
        throwsA(isA<ArgumentError>()),
      );

      // Attempt adding profile with @ prefix matching existing username
      expect(
        () => repo.addProfile(username: '@David', fullName: 'David Three'),
        throwsA(isA<ArgumentError>()),
      );

      // Successfully add unique handle
      await repo.addProfile(
        username: '@david_bisnis',
        fullName: 'David Bisnis',
        email: 'bisnis@fibonanci.app',
      );

      final updated = await repo.getProfiles();
      final biz = updated.firstWhere((p) => p.username == 'david_bisnis');
      expect(biz.username, 'david_bisnis');
    });

    test('repairAndMigrateProfiles reassigns seed data to david@fibonanci.app', () async {
      final profiles = await repo.getProfiles();
      final david = profiles.firstWhere((p) => p.email == 'david@fibonanci.app');

      // Simulate a scenario where seed wallets were mistakenly assigned to another profile
      await repo.addProfile(username: 'other_user', fullName: 'Other');
      final other = (await repo.getProfiles()).firstWhere((p) => p.username == 'other_user');

      await db.customStatement(
        "UPDATE wallets SET profile_id = ? WHERE profile_id = ?",
        [other.id, david.id],
      );

      var davidWallets = await repo.getWallets(profileId: david.id);
      expect(davidWallets, isEmpty);

      // Run repair
      await db.repairAndMigrateProfiles();

      // David should have his wallets restored
      davidWallets = await repo.getWallets(profileId: david.id);
      expect(davidWallets.length, 7);
      expect(davidWallets.any((w) => w.name == 'BCA Utama'), isTrue);
    });

    test('repairAndMigrateProfiles deduplicates duplicate usernames in SQLite', () async {
      // Force insert duplicate usernames directly into table
      final now = DateTime.now().toUtc();
      await db.into(db.profiles).insert(
        ProfilesCompanion(
          id: const Value('dup_1'),
          username: const Value('clone_user'),
          fullName: const Value('Clone 1'),
          isActive: const Value(false),
          createdAt: Value(now),
          updatedAt: Value(now),
          isSynced: const Value(false),
          isDeleted: const Value(false),
        ),
      );
      await db.into(db.profiles).insert(
        ProfilesCompanion(
          id: const Value('dup_2'),
          username: const Value('clone_user'),
          fullName: const Value('Clone 2'),
          isActive: const Value(false),
          createdAt: Value(now),
          updatedAt: Value(now),
          isSynced: const Value(false),
          isDeleted: const Value(false),
        ),
      );

      await db.repairAndMigrateProfiles();

      final profiles = await repo.getProfiles();
      final dup1 = profiles.firstWhere((p) => p.id == 'dup_1');
      final dup2 = profiles.firstWhere((p) => p.id == 'dup_2');

      expect(dup1.username, 'clone_user');
      expect(dup2.username, 'clone_user_2');
    });
  });
}
