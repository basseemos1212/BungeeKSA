import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class SettingsEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class UpdateNameRequested extends SettingsEvent {
  final String newName;

  UpdateNameRequested(this.newName);

  @override
  List<Object> get props => [newName];
}

class UpdatePasswordRequested extends SettingsEvent {
  final String newPassword;

  UpdatePasswordRequested(this.newPassword);

  @override
  List<Object> get props => [newPassword];
}

class UpdateProfilePictureRequested extends SettingsEvent {
  final String profileImagePath; // Local path of the image

  UpdateProfilePictureRequested(this.profileImagePath);

  @override
  List<Object> get props => [profileImagePath];
}

class UpdatePrivacySetting extends SettingsEvent {
  final bool isPrivate;

  UpdatePrivacySetting(this.isPrivate);

  @override
  List<Object> get props => [isPrivate];
}

class ChangeLanguageRequested extends SettingsEvent {
  final Locale newLocale;

  ChangeLanguageRequested(this.newLocale);

  @override
  List<Object> get props => [newLocale];
}
