import 'failure_message.dart';
import 'failures.dart';

class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({required this.message, this.statusCode});

  @override
  String toString() =>
      'ServerException: $message${statusCode != null ? ' (statusCode: $statusCode)' : ''}';

  ServerFailure toFailure() =>
      ServerFailure(message: message, statusCode: statusCode);
}

class CacheException implements Exception {
  final String message;

  const CacheException({required this.message});

  @override
  String toString() => 'CacheException: $message';

  CacheFailure toFailure() => CacheFailure(message: message);
}

class AuthException implements Exception {
  final String message;

  const AuthException({required this.message});

  @override
  String toString() => 'AuthException: $message';

  AuthFailure toFailure() => AuthFailure(message: message);
}

class RequiresRecentLoginException implements Exception {
  final String message;

  const RequiresRecentLoginException({required this.message});

  @override
  String toString() => 'RequiresRecentLoginException: $message';

  AuthFailure toFailure() => AuthFailure(
    message: message,
    errorCode: FailureCodes.requiresRecentLogin,
  );
}

class PermissionException implements Exception {
  final String message;

  const PermissionException({required this.message});

  @override
  String toString() => 'PermissionException: $message';

  PermissionFailure toFailure() => PermissionFailure(message: message);
}

class NetworkException implements Exception {
  final String message;

  const NetworkException({required this.message});

  @override
  String toString() => 'NetworkException: $message';

  NetworkFailure toFailure() => NetworkFailure(message: message);
}

class EmptyExportException implements Exception {
  const EmptyExportException();
}

class ReceiptTotalUnreadableException extends FormatException {
  const ReceiptTotalUnreadableException()
    : super('Receipt total is unreadable');
}
