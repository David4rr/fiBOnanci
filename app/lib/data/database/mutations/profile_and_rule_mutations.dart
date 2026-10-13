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
      final wipeAll = remaining.isEmpty;
      await (update(wallets)..where((t) => wipeAll ? t.isDeleted.equals(false) : profileFilter(t.profileId, profileId))).write(
        WalletsCompanion(balance: const Value(0.0), isDeleted: const Value(true), updatedAt: Value(now), isSynced: const Value(false)),
      );
      await (update(transactions)..where((t) => wipeAll ? t.isDeleted.equals(false) : profileFilter(t.profileId, profileId))).write(
        TransactionsCompanion(isDeleted: const Value(true), updatedAt: Value(now), isSynced: const Value(false)),
      );
      await (update(subscriptions)..where((t) => wipeAll ? t.isDeleted.equals(false) : profileFilter(t.profileId, profileId))).write(
        SubscriptionsCompanion(isDeleted: const Value(true), updatedAt: Value(now), isSynced: const Value(false)),
      );
      await (update(pockets)..where((t) => wipeAll ? t.isDeleted.equals(false) : profileFilter(t.profileId, profileId))).write(
        PocketsCompanion(currentAmount: const Value(0.0), isDeleted: const Value(true), updatedAt: Value(now), isSynced: const Value(false)),
      );
      await (update(notificationRules)..where((t) => wipeAll ? t.isDeleted.equals(false) : profileFilter(t.profileId, profileId))).write(
        NotificationRulesCompanion(isEnabled: const Value(false), isDeleted: const Value(true), updatedAt: Value(now), isSynced: const Value(false)),
      );
      if (remaining.isNotEmpty) {
        if (!remaining.any((p) => p.isActive)) {
          await (update(profiles)..where((t) => t.id.equals(remaining.first.id))).write(
            ProfilesCompanion(isActive: const Value(true), updatedAt: Value(now)),
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
    String? profileId,
  }) async {
    final now = DateTime.now().toUtc();
    final wallet = await (select(wallets)..where((t) => t.id.equals(walletId))).getSingleOrNull();
    final effProfileId = profileId ?? wallet?.profileId;
    final aliases = expandPackageAliases(packageName).toList();
    await (update(notificationRules)
          ..where((t) => t.walletId.equals(walletId) & t.packageName.isNotIn(aliases) & t.isDeleted.equals(false)))
        .write(
      NotificationRulesCompanion(
        isEnabled: const Value(false),
        isDeleted: const Value(true),
        updatedAt: Value(now),
        isSynced: const Value(false),
      ),
    );
    final existing = await (select(notificationRules)
          ..where((tbl) => tbl.packageName.isIn(aliases) & tbl.isDeleted.equals(false))
          ..limit(1))
        .getSingleOrNull();
    if (existing != null) {
      await (update(notificationRules)..where((t) => t.id.equals(existing.id))).write(
        NotificationRulesCompanion(
          packageName: Value(packageName),
          walletId: Value(walletId),
          profileId: Value(effProfileId),
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
          profileId: Value(effProfileId),
          isEnabled: Value(isEnabled),
          createdAt: Value(now),
          updatedAt: Value(now),
          isSynced: const Value(false),
          isDeleted: const Value(false),
        ),
      );
    }
  }

  Future<void> createCategory({
    required String name,
    required String type,
    required String iconName,
    required String colorHex,
  }) {
    final now = DateTime.now().toUtc();
    return into(categories).insert(
      CategoriesCompanion(
        id: Value(const Uuid().v4()),
        name: Value(name.trim()),
        type: Value(type),
        iconName: Value(iconName),
        colorHex: Value(colorHex),
        createdAt: Value(now),
        updatedAt: Value(now),
        isSynced: const Value(false),
        isDeleted: const Value(false),
      ),
    );
  }

  Future<void> softDeleteCategory(String categoryId) {
    final now = DateTime.now().toUtc();
    return (update(categories)..where((t) => t.id.equals(categoryId))).write(
      CategoriesCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(now),
        isSynced: const Value(false),
      ),
    );
  }

  Future<void> clearProfileTransactions(String profileId) {
    return transaction(() async {
      final now = DateTime.now().toUtc();
      await (update(transactions)..where((t) => profileFilter(t.profileId, profileId) & t.isDeleted.equals(false))).write(
        TransactionsCompanion(
          isDeleted: const Value(true),
          updatedAt: Value(now),
          isSynced: const Value(false),
        ),
      );
      await (update(wallets)..where((t) => profileFilter(t.profileId, profileId) & t.isDeleted.equals(false))).write(
        WalletsCompanion(balance: const Value(0.0), updatedAt: Value(now), isSynced: const Value(false)),
      );
      await (update(pockets)..where((t) => profileFilter(t.profileId, profileId) & t.isDeleted.equals(false))).write(
        PocketsCompanion(currentAmount: const Value(0.0), updatedAt: Value(now), isSynced: const Value(false)),
      );
    });
  }
}
