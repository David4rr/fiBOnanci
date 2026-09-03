part of '../finance_event.dart';

class AddProfileEvent extends FinanceEvent {
  final String username;
  final String fullName;
  final String? email;
  final String? phone;
  final String? avatarPath;
  final String? occupation;
  final String? bio;
  final String currency;
  final double? monthlyIncomeTarget;
  final bool setActive;

  const AddProfileEvent({
    required this.username,
    required this.fullName,
    this.email,
    this.phone,
    this.avatarPath,
    this.occupation,
    this.bio,
    this.currency = 'IDR',
    this.monthlyIncomeTarget,
    this.setActive = false,
  });
}

class UpdateProfileEvent extends FinanceEvent {
  final String profileId;
  final String username;
  final String fullName;
  final String? email;
  final String? phone;
  final String? avatarPath;
  final String? occupation;
  final String? bio;
  final String currency;
  final double? monthlyIncomeTarget;

  const UpdateProfileEvent({
    required this.profileId,
    required this.username,
    required this.fullName,
    this.email,
    this.phone,
    this.avatarPath,
    this.occupation,
    this.bio,
    this.currency = 'IDR',
    this.monthlyIncomeTarget,
  });
}

class DeleteProfileEvent extends FinanceEvent {
  final String profileId;

  const DeleteProfileEvent(this.profileId);
}

class SetActiveProfileEvent extends FinanceEvent {
  final String profileId;

  const SetActiveProfileEvent(this.profileId);
}
