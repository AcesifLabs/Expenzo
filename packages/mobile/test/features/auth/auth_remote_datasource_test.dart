import 'package:expense_tracker/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthRemoteDatasourceImpl.isDevTokenFallbackAllowed', () {
    test('returns false outside debug mode', () {
      final allowed = AuthRemoteDatasourceImpl.isDevTokenFallbackAllowed(
        isDebugMode: false,
      );

      expect(allowed, isFalse);
    });

    test('returns true in debug mode', () {
      final allowed = AuthRemoteDatasourceImpl.isDevTokenFallbackAllowed(
        isDebugMode: true,
      );

      expect(allowed, isTrue);
    });
  });
}
