import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final String errorCode;

  @override
  List<Object> get props => [message, errorCode];

  const Failure({required this.message, required this.errorCode});

  @override
  String toString() => 'Failure($errorCode): $message';
}

class ServerFailure extends Failure {
  final int? statusCode;

  @override
  List<Object> get props => [message, errorCode, statusCode ?? 0];

  const ServerFailure({
    required super.message,
    super.errorCode = 'SERVER_ERROR',
    this.statusCode,
  });

  @override
  String toString() => 'ServerFailure: $message (statusCode: $statusCode)';
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
