import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final String errorCode;

  const Failure({required this.message, required this.errorCode});

  @override
  List<Object> get props => [message, errorCode];
}

class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure({
    required super.message,
    super.errorCode = 'SERVER_ERROR',
    this.statusCode,
  });

  @override
  List<Object> get props => [message, errorCode, statusCode ?? 0];
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message, super.errorCode = 'CACHE_ERROR'});
}

class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.errorCode = 'AUTH_ERROR'});
}

class PermissionFailure extends Failure {
  const PermissionFailure({
    required super.message,
    super.errorCode = 'PERMISSION_ERROR',
  });
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.message,
    super.errorCode = 'NETWORK_ERROR',
  });
}
