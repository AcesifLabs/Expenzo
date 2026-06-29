import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/error/failures.dart';

void main() {
  group('Failure base class', () {
    test('toString includes error code and message', () {
      const failure = ServerFailure(message: 'Server error', statusCode: 500);
      expect(
        failure.toString(),
        'ServerFailure: Server error (statusCode: 500)',
      );
    });

    test('has correct error code', () {
      const failure = ServerFailure(message: 'Error');
      expect(failure.errorCode, 'SERVER_ERROR');
    });

    test('equals based on props', () {
      const f1 = ServerFailure(message: 'Error', statusCode: 500);
      const f2 = ServerFailure(message: 'Error', statusCode: 500);
      expect(f1, f2);
    });

    test('different messages are not equal', () {
      const f1 = ServerFailure(message: 'Error 1');
      const f2 = ServerFailure(message: 'Error 2');
      expect(f1, isNot(f2));
    });
  });

  group('ServerFailure', () {
    test('toString includes statusCode when provided', () {
      const failure = ServerFailure(message: 'Bad request', statusCode: 400);
      expect(
        failure.toString(),
        'ServerFailure: Bad request (statusCode: 400)',
      );
    });

    test('toString handles null statusCode', () {
      const failure = ServerFailure(message: 'Generic error');
      expect(
        failure.toString(),
        'ServerFailure: Generic error (statusCode: null)',
      );
    });
  });

  group('CacheFailure', () {
    test('toString returns correct format', () {
      const failure = CacheFailure(message: 'Data not cached');
      expect(failure.toString(), 'Failure(CACHE_ERROR): Data not cached');
    });
  });

  group('AuthFailure', () {
    test('toString returns correct format', () {
      const failure = AuthFailure(message: 'Invalid credentials');
      expect(failure.toString(), 'Failure(AUTH_ERROR): Invalid credentials');
    });
  });

  group('PermissionFailure', () {
    test('toString returns correct format', () {
      const failure = PermissionFailure(message: 'Permission denied');
      expect(
        failure.toString(),
        'Failure(PERMISSION_ERROR): Permission denied',
      );
    });
  });

  group('NetworkFailure', () {
    test('toString returns correct format', () {
      const failure = NetworkFailure(message: 'Connection lost');
      expect(failure.toString(), 'Failure(NETWORK_ERROR): Connection lost');
    });
  });
}
