import 'package:equatable/equatable.dart';

abstract class SettingsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsSuccess extends SettingsState {
  final String message;

  SettingsSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class SettingsFailure extends SettingsState {
  final String error;

  SettingsFailure(this.error);

  @override
  List<Object?> get props => [error];
}

class ProfileImageUpdated extends SettingsState {
  final String profileImageUrl;

  ProfileImageUpdated(this.profileImageUrl);

  @override
  List<Object?> get props => [profileImageUrl];
}
