import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];

  const AuthEvent();
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class SignInWithGoogleRequested extends AuthEvent {
  const SignInWithGoogleRequested();
}

class SignOutRequested extends AuthEvent {
  const SignOutRequested();
}

class FirstSyncRequested extends AuthEvent {
  const FirstSyncRequested();
}
