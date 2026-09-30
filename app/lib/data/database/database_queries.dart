part of 'app_database.dart';

extension DatabaseQueries on AppDatabase {
  Expression<bool> profileFilter(GeneratedColumn<String> col, String? profileId) {
    if (profileId == null) return const Constant(true);
    return profileId == 'default_profile_1' ? (col.equals(profileId) | col.isNull()) : col.equals(profileId);
  }

  Stream<List<WalletEntry>> watchActiveWallets({String? profileId}) {
    final q = select(wallets)..where((t) => t.isDeleted.equals(false) & profileFilter(t.profileId, profileId));
    return q.watch();
  }

  Stream<List<CategoryEntry>> watchActiveCategories() {
    return (select(categories)..where((tbl) => tbl.isDeleted.equals(false))).watch();
  }

  Stream<List<TransactionEntry>> watchRecentTransactions({String? profileId, int limit = 30}) {
    final q = select(transactions)..where((t) => t.isDeleted.equals(false) & profileFilter(t.profileId, profileId));
    return (q
          ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)])
          ..limit(limit))
        .watch();
  }

  Stream<List<SubscriptionEntry>> watchActiveSubscriptions({String? profileId}) {
    final q = select(subscriptions)
      ..where((t) => t.isDeleted.equals(false) & t.status.isNotValue('cancelled') & profileFilter(t.profileId, profileId));
    return (q..orderBy([(t) => OrderingTerm.asc(t.dueDay)])).watch();
  }

  Stream<List<PocketEntry>> watchActivePockets({String? profileId}) {
    final q = select(pockets)..where((t) => t.isDeleted.equals(false) & profileFilter(t.profileId, profileId));
    return (q..orderBy([(t) => OrderingTerm.asc(t.createdAt)])).watch();
  }

  Future<List<PocketEntry>> getActivePockets({String? profileId}) {
    final q = select(pockets)..where((t) => t.isDeleted.equals(false) & profileFilter(t.profileId, profileId));
    return (q..orderBy([(t) => OrderingTerm.asc(t.createdAt)])).get();
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

  Stream<List<NotificationRuleEntry>> watchNotificationRules({String? profileId}) {
    final q = select(notificationRules)..where((t) => t.isDeleted.equals(false) & profileFilter(t.profileId, profileId));
    return (q..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).watch();
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
