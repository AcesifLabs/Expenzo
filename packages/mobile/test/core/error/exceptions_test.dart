import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/error/failures.dart';

void main() {
  group('ServerException', () {
    test('toString returns formatted message', () {
      final exc = ServerException(message: 'Server error', statusCode: 500);
      expect(exc.toString(), 'ServerException: Server error (statusCode: 500)');
    });

    test('toString without statusCode', () {
      final exc = ServerException(message: 'Server error');
      expect(exc.toString(), 'ServerException: Server error');
    });

    test('toFailure returns ServerFailure', () {
      final exc = ServerException(message: 'Error', statusCode: 400);
      final failure = exc.toFailure();
      expect(failure, isA<ServerFailure>());
      expect(failure.message, 'Error');
      expect(failure.statusCode, 400);
    });
  });

  group('CacheException', () {
    test('toString returns formatted message', () {
      final exc = CacheException(message: 'Cache miss');
      expect(exc.toString(), 'CacheException: Cache miss');
    });

    test('toFailure returns CacheFailure', () {
      final exc = CacheException(message: 'Not found');
      final failure = exc.toFailure();
      expect(failure, isA<CacheFailure>());
      expect(failure.message, 'Not found');
    });
  });

  group('AuthException', () {
    test('toString returns formatted message', () {
      final exc = AuthException(message: 'Unauthorized');
      expect(exc.toString(), 'AuthException: Unauthorized');
    });

    test('toFailure returns AuthFailure', () {
      final exc = AuthException(message: 'Token expired');
      final failure = exc.toFailure();
      expect(failure, isA<AuthFailure>());
      expect(failure.message, 'Token expired');
    });
  });

  group('PermissionException', () {
    test('toString returns formatted message', () {
      final exc = PermissionException(message: 'Access denied');
      expect(exc.toString(), 'PermissionException: Access denied');
    });
  });

  group('NetworkException', () {
    test('toString returns formatted message', () {
      final exc = NetworkException(message: 'No internet');
      expect(exc.toString(), 'NetworkException: No internet');
    });

    test('toFailure returns NetworkFailure', () {
      final exc = NetworkException(message: 'Timeout');
      final failure = exc.toFailure();
      expect(failure, isA<NetworkFailure>());
      expect(failure.message, 'Timeout');
    });
  });
}
