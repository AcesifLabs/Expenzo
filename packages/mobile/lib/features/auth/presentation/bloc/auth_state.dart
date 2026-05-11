import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class Authenticated extends AuthState {
  final User user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class AuthError extends AuthState {
  final String message;
  final bool isUserInitiated;

  const AuthError(this.message, {this.isUserInitiated = false});

  @override
  List<Object?> get props => [message, isUserInitiated];
}

class AuthSyncConflictPending extends AuthState {
  final User user;
  const AuthSyncConflictPending(this.user);

  @override
  List<Object?> get props => [user];
}
