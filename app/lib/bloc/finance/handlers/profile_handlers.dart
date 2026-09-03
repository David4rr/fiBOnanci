part of '../finance_bloc.dart';

extension ProfileBlocHandlers on FinanceBloc {
  Future<void> handleAddProfile(AddProfileEvent event, Emitter<FinanceState> emit) async {
    try {
      await repository.addProfile(
        username: event.username,
        fullName: event.fullName,
        email: event.email,
        phone: event.phone,
        avatarPath: event.avatarPath,
        occupation: event.occupation,
        bio: event.bio,
        currency: event.currency,
        monthlyIncomeTarget: event.monthlyIncomeTarget,
        setActive: event.setActive,
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Gagal menambah profil: $e'));
    }
  }

  Future<void> handleUpdateProfile(UpdateProfileEvent event, Emitter<FinanceState> emit) async {
    try {
      await repository.updateProfile(
        profileId: event.profileId,
        username: event.username,
        fullName: event.fullName,
        email: event.email,
        phone: event.phone,
        avatarPath: event.avatarPath,
        occupation: event.occupation,
        bio: event.bio,
        currency: event.currency,
        monthlyIncomeTarget: event.monthlyIncomeTarget,
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Gagal memperbarui profil: $e'));
    }
  }

  Future<void> handleDeleteProfile(DeleteProfileEvent event, Emitter<FinanceState> emit) async {
    try {
      await repository.deleteProfile(event.profileId);
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Gagal menghapus profil: $e'));
    }
  }

  Future<void> handleSetActiveProfile(SetActiveProfileEvent event, Emitter<FinanceState> emit) async {
    try {
      await repository.setActiveProfile(event.profileId);
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Gagal mengganti profil aktif: $e'));
    }
  }
}
