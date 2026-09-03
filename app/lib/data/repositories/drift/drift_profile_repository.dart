part of '../finance_repository.dart';

mixin DriftProfileRepository on DriftRepoBase {
  Stream<List<ProfileEntry>> watchProfiles() => db.watchProfiles();

  Future<List<ProfileEntry>> getProfiles() => db.getProfiles();

  Future<ProfileEntry?> getActiveProfile() => db.getActiveProfile();

  Future<void> addProfile({
    required String username,
    required String fullName,
    String? email,
    String? phone,
    String? avatarPath,
    String? occupation,
    String? bio,
    String currency = 'IDR',
    double? monthlyIncomeTarget,
    bool setActive = false,
  }) async {
    final now = DateTime.now().toUtc();
    final profileId = uuid.v4();
    if (setActive) {
      final activeList = await db.getProfiles();
      for (final p in activeList) {
        if (p.isActive) {
          await db.updateProfile(ProfilesCompanion(
            id: drift.Value(p.id),
            isActive: const drift.Value(false),
            updatedAt: drift.Value(now),
          ));
        }
      }
    }
    await db.createProfile(
      ProfilesCompanion(
        id: drift.Value(profileId),
        username: drift.Value(username),
        fullName: drift.Value(fullName),
        email: drift.Value(email),
        phone: drift.Value(phone),
        avatarPath: drift.Value(avatarPath ?? 'preset:avatar_1'),
        occupation: drift.Value(occupation),
        bio: drift.Value(bio),
        currency: drift.Value(currency),
        monthlyIncomeTarget: drift.Value(monthlyIncomeTarget),
        isActive: drift.Value(setActive),
        createdAt: drift.Value(now),
        updatedAt: drift.Value(now),
        isSynced: const drift.Value(false),
        isDeleted: const drift.Value(false),
      ),
    );
  }

  Future<void> updateProfile({
    required String profileId,
    required String username,
    required String fullName,
    String? email,
    String? phone,
    String? avatarPath,
    String? occupation,
    String? bio,
    String currency = 'IDR',
    double? monthlyIncomeTarget,
  }) {
    final now = DateTime.now().toUtc();
    return db.updateProfile(
      ProfilesCompanion(
        id: drift.Value(profileId),
        username: drift.Value(username),
        fullName: drift.Value(fullName),
        email: drift.Value(email),
        phone: drift.Value(phone),
        avatarPath: drift.Value(avatarPath),
        occupation: drift.Value(occupation),
        bio: drift.Value(bio),
        currency: drift.Value(currency),
        monthlyIncomeTarget: drift.Value(monthlyIncomeTarget),
        updatedAt: drift.Value(now),
        isSynced: const drift.Value(false),
      ),
    );
  }

  Future<void> deleteProfile(String profileId) => db.deleteProfile(profileId);

  Future<void> setActiveProfile(String profileId) => db.setActiveProfile(profileId);
}
