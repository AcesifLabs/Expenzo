import 'dart:async';

import 'package:dio/dio.dart';
import 'package:expense_tracker/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('mapExceptionToMessage', () {
    test('DioException connection timeout → network error message', () {
      final e = DioException(
        type: DioExceptionType.connectionTimeout,
        requestOptions: RequestOptions(path: ''),
      );
      final msg = AuthRepositoryImpl.mapExceptionToMessage(e);
      expect(msg, contains('internet connection'));
    });

    test('DioException receive timeout → network error message', () {
      final e = DioException(
        type: DioExceptionType.receiveTimeout,
        requestOptions: RequestOptions(path: ''),
      );
      final msg = AuthRepositoryImpl.mapExceptionToMessage(e);
      expect(msg, contains('internet connection'));
    });

    test('DioException connection error → network error message', () {
      final e = DioException(
        type: DioExceptionType.connectionError,
        requestOptions: RequestOptions(path: ''),
      );
      final msg = AuthRepositoryImpl.mapExceptionToMessage(e);
      expect(msg, contains('internet connection'));
    });

    test('DioException bad response → server error message', () {
      final e = DioException(
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(path: ''),
        response: Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 500,
        ),
      );
      final msg = AuthRepositoryImpl.mapExceptionToMessage(e);
      expect(msg, contains('our end'));
    });

    test('PlatformException sign_in_canceled → cancelled message', () {
      final e = PlatformException(code: 'sign_in_canceled');
      final msg = AuthRepositoryImpl.mapExceptionToMessage(e);
      expect(msg, contains('cancelled'));
    });

    test('PlatformException network_error → network message', () {
      final e = PlatformException(code: 'network_error');
      final msg = AuthRepositoryImpl.mapExceptionToMessage(e);
      expect(msg, contains('Network error'));
    });

    test('PlatformException unknown code → generic auth message', () {
      final e = PlatformException(code: 'unknown_code');
      final msg = AuthRepositoryImpl.mapExceptionToMessage(e);
      expect(msg, contains('Authentication failed'));
    });

    test('TimeoutException → timeout message', () {
      final e = TimeoutException('operation timed out');
      final msg = AuthRepositoryImpl.mapExceptionToMessage(e);
      expect(msg, contains('timed out'));
    });

    test('unknown exception type → generic fallback message', () {
      final e = ArgumentError('bad arg');
      final msg = AuthRepositoryImpl.mapExceptionToMessage(e);
      expect(msg, contains('Something went wrong'));
    });

    test('DioException with SocketException in error → network message', () {
      final e = DioException(
        type: DioExceptionType.unknown,
        error: const FormatException('unexpected format'),
        requestOptions: RequestOptions(path: ''),
      );
      final msg = AuthRepositoryImpl.mapExceptionToMessage(e);

      expect(msg, contains('our end'));
    });
  });
}
