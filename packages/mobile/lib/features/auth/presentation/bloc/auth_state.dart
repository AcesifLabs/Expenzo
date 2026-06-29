import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];

  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class Authenticated extends AuthState {
  final User user;

  @override
  List<Object?> get props => [user];

  const Authenticated(this.user);
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class AuthError extends AuthState {
  final String message;
  final bool isUserInitiated;

  @override
  List<Object?> get props => [message, isUserInitiated];

  const AuthError(this.message, {this.isUserInitiated = false});
}

class AuthSyncConflictPending extends AuthState {
  final User user;

  @override
  List<Object?> get props => [user];

  const AuthSyncConflictPending(this.user);
}
