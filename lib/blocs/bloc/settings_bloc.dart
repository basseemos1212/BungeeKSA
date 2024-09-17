import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../events/settings_events.dart';
import '../states/settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  SettingsBloc() : super(SettingsInitial()) {
    on<UpdateNameRequested>(_onUpdateNameRequested);
    on<UpdatePasswordRequested>(_onUpdatePasswordRequested);
    on<UpdateProfilePictureRequested>(_onUpdateProfilePictureRequested);
    on<UpdatePrivacySetting>(_onUpdatePrivacySetting);
    on<ChangeLanguageRequested>(_onChangeLanguageRequested);
  }

  Future<void> _onUpdateNameRequested(UpdateNameRequested event, Emitter<SettingsState> emit) async {
    emit(SettingsLoading());
    try {
      final user = _auth.currentUser;
      await _firestore.collection('users').doc(user?.uid).update({'name': event.newName});
      emit(SettingsSuccess('Name updated successfully'));
    } catch (e) {
      emit(SettingsFailure('Failed to update name: $e'));
    }
  }

  Future<void> _onUpdatePasswordRequested(UpdatePasswordRequested event, Emitter<SettingsState> emit) async {
    emit(SettingsLoading());
    try {
      await _auth.currentUser?.updatePassword(event.newPassword);
      emit(SettingsSuccess('Password updated successfully'));
    } catch (e) {
      emit(SettingsFailure('Failed to update password: $e'));
    }
  }

  Future<void> _onUpdateProfilePictureRequested(UpdateProfilePictureRequested event, Emitter<SettingsState> emit) async {
    emit(SettingsLoading());
    try {
      final user = _auth.currentUser;
      if (user == null) {
        emit(SettingsFailure('User is not authenticated.'));
        return;
      }

      final File profileImage = File(event.profileImagePath); // Local image file path
      final storageRef = _storage.ref().child('profile_pictures/${user.uid}.jpg');
      final uploadTask = storageRef.putFile(profileImage);

      // Get the download URL after the file is uploaded
      final TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await taskSnapshot.ref.getDownloadURL();

      // Update Firestore with the new profile picture URL
      await _firestore.collection('users').doc(user.uid).update({'profileImageUrl': downloadUrl});

      emit(ProfileImageUpdated(downloadUrl)); // Emit new image URL
    } catch (e) {
      emit(SettingsFailure('Failed to update profile picture: $e'));
    }
  }

  Future<void> _onUpdatePrivacySetting(UpdatePrivacySetting event, Emitter<SettingsState> emit) async {
    emit(SettingsLoading());
    try {
      final user = _auth.currentUser;
      await _firestore.collection('users').doc(user?.uid).update({'isPrivate': event.isPrivate});
      emit(SettingsSuccess('Privacy setting updated successfully'));
    } catch (e) {
      emit(SettingsFailure('Failed to update privacy settings: $e'));
    }
  }

  Future<void> _onChangeLanguageRequested(ChangeLanguageRequested event, Emitter<SettingsState> emit) async {
    emit(SettingsLoading());
    try {
      // Logic to change language
      emit(LanguageChangedState(event.newLocale));
    } catch (e) {
      emit(SettingsFailure('Failed to change language: $e'));
    }
  }
}
