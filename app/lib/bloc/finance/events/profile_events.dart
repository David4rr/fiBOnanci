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

class OnboardNewProfileEvent extends FinanceEvent {
  final String username;
  final String fullName;
  final String? occupation;
  final double? monthlyIncomeTarget;
  final String? avatarPath;
  final String currency;
  final String walletName;
  final String walletType;
  final double initialBalance;
  final String colorHex;
  final String iconName;
  final bool createInitialTransaction;

  const OnboardNewProfileEvent({
    required this.username,
    required this.fullName,
    this.occupation,
    this.monthlyIncomeTarget,
    this.avatarPath,
    this.currency = 'IDR',
    required this.walletName,
    required this.walletType,
    required this.initialBalance,
    required this.colorHex,
    required this.iconName,
    this.createInitialTransaction = false,
  });
}
