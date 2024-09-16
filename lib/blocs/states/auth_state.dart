import 'package:equatable/equatable.dart';
import 'package:bungee_ksa/data/user_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final String message;
  const AuthSuccess({required this.message});
}

class AuthFailure extends AuthState {
  final String error;
  const AuthFailure({required this.error});
}

class UserDataSuccess extends AuthState {
  final UserModel user;
  const UserDataSuccess(this.user);
}

class UserDataFailure extends AuthState {
  final String error;
  const UserDataFailure(this.error);
}

class AuthLoggedOut extends AuthState {}
