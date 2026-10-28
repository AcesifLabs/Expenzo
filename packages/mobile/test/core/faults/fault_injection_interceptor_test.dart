import 'dart:math';

import 'package:dio/dio.dart';
import 'package:expense_tracker/core/api/fault_injection_interceptor.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  Dio dioWith(FaultInjectionInterceptor faults) {
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
      ..interceptors.add(faults);
    DioAdapter(dio: dio).onGet('/ping', (server) => server.reply(200, 'ok'));

    return dio;
  }

  test('reads the define', () {
    final faults = FaultInjectionInterceptor.parse(
      'latency:2000, error_rate:0.3,status:503,unknown:1',
    );

    expect(faults.latency, const Duration(seconds: 2));
    expect(faults.errorRate, 0.3);
    expect(faults.status, 503);
  });

  test('a rate outside 0 to 1 is clamped', () {
    expect(FaultInjectionInterceptor.parse('error_rate:7').errorRate, 1);
  });

  test('no define means no interceptor', () {
    expect(FaultInjectionInterceptor.fromEnvironment(), isNull);
  });

  test('every request fails with the status at rate 1', () async {
    final dio = dioWith(FaultInjectionInterceptor(errorRate: 1, status: 503));

    await expectLater(
      dio.get<Object?>('/ping'),
      throwsA(
        isA<DioException>().having(
          (e) => e.response?.statusCode,
          'status',
          503,
        ),
      ),
    );
  });

  test('status 0 fails as no connection', () async {
    final dio = dioWith(FaultInjectionInterceptor(errorRate: 1, status: 0));

    await expectLater(
      dio.get<Object?>('/ping'),
      throwsA(
        isA<DioException>().having(
          (e) => e.type,
          'type',
          DioExceptionType.connectionError,
        ),
      ),
    );
  });

  test('requests pass at rate 0', () async {
    final dio = dioWith(FaultInjectionInterceptor(random: Random(1)));

    expect((await dio.get<Object?>('/ping')).data, 'ok');
  });

  test('latency holds each request back', () {
    fakeAsync((time) {
      final dio = dioWith(
        FaultInjectionInterceptor(latency: const Duration(seconds: 2)),
      );
      Object? data;
      dio.get<Object?>('/ping').then((r) => data = r.data);

      time.elapse(const Duration(milliseconds: 1999));
      expect(data, isNull);
      time.elapse(const Duration(milliseconds: 2));
      expect(data, 'ok');
    });
  });
}
