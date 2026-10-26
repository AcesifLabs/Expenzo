import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/core/api/api_client.dart';
import 'package:expense_tracker/core/api/api_constants.dart';
import 'package:expense_tracker/core/api/token_storage.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/sync/connectivity_service.dart';

class _MockConnectivity extends Mock implements ConnectivityService {}

class _Unauthorized implements HttpClientAdapter {
  final String message;

  _Unauthorized(this.message);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromString(
    jsonEncode({'statusCode': 401, 'message': message}),
    401,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );

  @override
  void close({bool force = false}) {}
}

class _Scripted implements HttpClientAdapter {
  final (int, Object) Function(String? authorization) reply;
  int requests = 0;

  _Scripted(this.reply);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests++;
    final (status, body) = reply(options.headers['Authorization'] as String?);

    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late _MockConnectivity connectivity;
  late HttpClientAdapter originalAdapter;
  late Dio dio;

  setUpAll(() {
    dotenv.loadFromString(envString: 'BACKEND_URL=http://localhost:3000/api');
    dio = ApiClient().dio;
  });

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({'jwt_access_token': 'jwt'});
    connectivity = _MockConnectivity();

    when(() => connectivity.checkNow()).thenAnswer((_) async => false);
    di.getIt.registerSingleton<ConnectivityService>(connectivity);
    originalAdapter = dio.httpClientAdapter;
  });

  tearDown(() async {
    dio.httpClientAdapter = originalAdapter;
    ApiClient.refreshOverride = null;
    await di.getIt.reset();
  });

  test('the deleted-user 401 signs out instead of logging in again', () async {
    dio.httpClientAdapter = _Unauthorized(ApiConstants.deletedUserMessage);

    await expectLater(
      dio.get<Object?>(ApiConstants.health),
      throwsA(isA<DioException>()),
    );

    expect(await TokenStorage.getToken(), isNull);
    verifyNever(() => connectivity.checkNow());
  });

  test('any other 401 still goes to the re-login and keeps the JWT', () async {
    dio.httpClientAdapter = _Unauthorized('Unauthorized');

    await expectLater(
      dio.get<Object?>(ApiConstants.health),
      throwsA(isA<DioException>()),
    );

    expect(await TokenStorage.getToken(), 'jwt');
    verify(() => connectivity.checkNow()).called(1);
  });

  group('refresh and retry', () {
    late int refreshes;

    setUp(() {
      FlutterSecureStorage.setMockInitialValues({
        'jwt_access_token': 'old',
        'last_sync_at': '2026-10-01T00:00:00.000Z',
        'is_first_sync': 'false',
      });
      when(() => connectivity.checkNow()).thenAnswer((_) async => true);
      refreshes = 0;
      ApiClient.refreshOverride = () async {
        refreshes++;
        await TokenStorage.saveToken('new');

        return 'new';
      };
    });

    test('five requests that hit a 401 together share one refresh', () async {
      dio.httpClientAdapter = _Scripted(
        (auth) => auth == 'Bearer new' ? (200, {'ok': true}) : (401, {}),
      );

      final responses = await Future.wait([
        for (var i = 0; i < 5; i++) dio.get<Object?>(ApiConstants.health),
      ]);

      expect(responses.map((r) => r.statusCode), everyElement(200));
      expect(refreshes, 1);
    });

    test(
      'a 401 after a refresh goes to the caller instead of looping',
      () async {
        final server = _Scripted((_) => (401, {}));
        dio.httpClientAdapter = server;

        await expectLater(
          dio.get<Object?>(ApiConstants.health),
          throwsA(isA<DioException>()),
        );

        expect(refreshes, 1);
        expect(server.requests, 2);
      },
    );

    test('a 500 on the retry keeps the sign-in and the sync state', () async {
      dio.httpClientAdapter = _Scripted(
        (auth) => auth == 'Bearer new' ? (500, {}) : (401, {}),
      );

      await expectLater(
        dio.get<Object?>(ApiConstants.health),
        throwsA(
          isA<DioException>().having(
            (e) => e.response?.statusCode,
            'status',
            500,
          ),
        ),
      );

      expect(await TokenStorage.getToken(), 'new');
      expect(await TokenStorage.getLastSyncAt(), '2026-10-01T00:00:00.000Z');
      expect(await TokenStorage.isFirstSync(), isFalse);
    });

    test('a refresh the server rejects drops only the JWT', () async {
      ApiClient.refreshOverride = () async =>
          throw const TokenRefreshRejected();
      dio.httpClientAdapter = _Scripted((_) => (401, {}));

      await expectLater(
        dio.get<Object?>(ApiConstants.health),
        throwsA(isA<DioException>()),
      );

      expect(await TokenStorage.getToken(), isNull);
      expect(await TokenStorage.getLastSyncAt(), '2026-10-01T00:00:00.000Z');
    });

    test('a refresh that times out keeps the JWT', () async {
      ApiClient.refreshOverride = () async =>
          throw DioException.connectionTimeout(
            timeout: const Duration(seconds: 15),
            requestOptions: RequestOptions(),
          );
      dio.httpClientAdapter = _Scripted((_) => (401, {}));

      await expectLater(
        dio.get<Object?>(ApiConstants.health),
        throwsA(isA<DioException>()),
      );

      expect(await TokenStorage.getToken(), 'old');
    });
  });
}
