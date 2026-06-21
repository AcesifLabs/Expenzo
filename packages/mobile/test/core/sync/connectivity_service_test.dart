import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';
import 'package:expense_tracker/core/api/api_client.dart';
import 'package:expense_tracker/core/sync/connectivity_service.dart';

class MockConnectivity extends Mock implements Connectivity {}

class MockDio extends Mock implements Dio {}

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockConnectivity mockConnectivity;
  late MockApiClient mockApiClient;
  late MockDio mockDio;
  late ConnectivityService service;

  setUpAll(() async {
    await dotenv.load(isOptional: true);
  });

  setUp(() {
    mockConnectivity = MockConnectivity();
    mockApiClient = MockApiClient();
    mockDio = MockDio();
    when(() => mockApiClient.dio).thenReturn(mockDio);
    service = ConnectivityService(
      connectivity: mockConnectivity,
      apiClient: mockApiClient,
    );
  });

  group('onlineStream', () {
    test(
      'gracefully handles platform errors without crashing the stream',
      () async {
        when(() => mockConnectivity.onConnectivityChanged).thenAnswer(
          (_) =>
              Stream<List<ConnectivityResult>>.error(Exception('test error')),
        );

        // The stream should not emit an error event — handleError swallows it.
        // Since no data follows the error, the stream completes quietly.
        await expectLater(service.onlineStream, emitsDone);
      },
    );

    test(
      'emits false when connectivity result is none',
      () async {
        when(() => mockConnectivity.onConnectivityChanged).thenAnswer(
          (_) => Stream<List<ConnectivityResult>>.value(
            [ConnectivityResult.none],
          ),
        );

        // _checkConnectivity sees [none] and returns false immediately
        // without calling the health check endpoint.
        await expectLater(service.onlineStream, emits(false));
      },
    );

    test(
      'recovers and processes subsequent data after a stream error',
      () async {
        final controller = StreamController<List<ConnectivityResult>>();
        when(() => mockConnectivity.onConnectivityChanged).thenAnswer(
          (_) => controller.stream,
        );

        // First send an error, then valid data
        controller.addError(Exception('transient error'));
        controller.add([ConnectivityResult.none]);

        // Error is swallowed by handleError; the none event triggers
        // _checkConnectivity which returns false without hitting health check.
        await expectLater(service.onlineStream, emits(false));

        await controller.close();
      },
    );
  });

  group('checkNow', () {
    test(
      'returns last known state when checkConnectivity throws',
      () async {
        when(() => mockConnectivity.checkConnectivity()).thenThrow(
          Exception('platform error'),
        );

        final result = await service.checkNow();

        // Default _isOnline is false; returns that instead of throwing.
        expect(result, false);
      },
    );

    test(
      'does not throw when checkConnectivity succeeds',
      () async {
        when(() => mockConnectivity.checkConnectivity()).thenAnswer(
          (_) async => [ConnectivityResult.wifi],
        );

        // The health check inside _checkConnectivity will fail (no server),
        // so the result will be false — but the point is no exception
        // propagates from checkNow().
        final result = await service.checkNow();
        expect(result, false);
      },
    );
  });
}