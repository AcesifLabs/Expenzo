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

/// Answers every request with a 401 carrying [message].
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
    // Offline, so a refresh attempt stops right after the check.
    when(() => connectivity.checkNow()).thenAnswer((_) async => false);
    di.getIt.registerSingleton<ConnectivityService>(connectivity);
    originalAdapter = dio.httpClientAdapter;
  });

  tearDown(() async {
    dio.httpClientAdapter = originalAdapter;
    await di.getIt.reset();
  });

  test('the deleted-user 401 signs out instead of logging in again', () async {
    dio.httpClientAdapter = _Unauthorized(ApiConstants.deletedUserMessage);

    await expectLater(
      dio.get<dynamic>(ApiConstants.records),
      throwsA(isA<DioException>()),
    );

    expect(await TokenStorage.getToken(), isNull);
    verifyNever(() => connectivity.checkNow());
  });

  test('any other 401 still goes to the re-login and keeps the JWT', () async {
    dio.httpClientAdapter = _Unauthorized('Unauthorized');

    await expectLater(
      dio.get<dynamic>(ApiConstants.records),
      throwsA(isA<DioException>()),
    );

    expect(await TokenStorage.getToken(), 'jwt');
    verify(() => connectivity.checkNow()).called(1);
  });
}
