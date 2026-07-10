import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthRemoteDatasource security', () {
    test('ServerException carries message', () {
      final e = ServerException(message: 'test error');
      expect(e.message, 'test error');
      expect(e.statusCode, isNull);
      expect(e.toString(), contains('test error'));
    });

    test('ServerException with statusCode', () {
      final e = ServerException(message: 'not found', statusCode: 404);
      expect(e.message, 'not found');
      expect(e.statusCode, 404);
      expect(e.toString(), contains('404'));
    });
  });
}
