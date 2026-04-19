import 'failures.dart';

class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({required this.message, this.statusCode});

  ServerFailure toFailure() =>
      ServerFailure(message: message, statusCode: statusCode);
}

class CacheException implements Exception {
  final String message;

  const CacheException({required this.message});

  CacheFailure toFailure() => CacheFailure(message: message);
}

class AuthException implements Exception {
  final String message;

  const AuthException({required this.message});

  AuthFailure toFailure() => AuthFailure(message: message);
}

class PermissionException implements Exception {
  final String message;

  const PermissionException({required this.message});

  PermissionFailure toFailure() => PermissionFailure(message: message);
}

class NetworkException implements Exception {
  final String message;

  const NetworkException({required this.message});

  NetworkFailure toFailure() => NetworkFailure(message: message);
}
