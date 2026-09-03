part of '../app_database.dart';

extension ProfileAndRuleMutations on AppDatabase {
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
        await _seedDefaultProfile();
      }
    });
  }

  Future<void> setActiveProfile(String profileId) {
    return transaction(() async {
      final now = DateTime.now().toUtc();
      await (update(profiles)..where((t) => t.isDeleted.equals(false))).write(
        ProfilesCompanion(
          isActive: const Value(false),
          updatedAt: Value(now),
        ),
      );
      await (update(profiles)..where((t) => t.id.equals(profileId))).write(
        ProfilesCompanion(
          isActive: const Value(true),
          updatedAt: Value(now),
        ),
      );
    });
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
      await into(notificationRules).insert(
        NotificationRulesCompanion(
          id: Value(const Uuid().v4()),
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
}
