import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final String phoneNumber;

  const SignUpRequested(this.email, this.password, this.name, this.phoneNumber);
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested(this.email, this.password);
}

class FetchUserDataRequested extends AuthEvent {
  final String uid;

  const FetchUserDataRequested(this.uid);
}

class LogoutRequested extends AuthEvent {}

class CheckAuthStatusRequested extends AuthEvent {}
