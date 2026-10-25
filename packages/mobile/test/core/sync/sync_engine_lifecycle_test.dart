import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/core/api/api_constants.dart';
import 'package:expense_tracker/core/sync/sync_event.dart';

import 'sync_engine_harness.dart';

Response<dynamic> _pulled() => Response(
  requestOptions: RequestOptions(path: ApiConstants.syncPull),
  data: {'changes': <Object>[], 'serverTime': '2026-10-15T00:00:00.000Z'},
);

void main() {
  late SyncEngineHarness harness;

  setUp(() => harness = SyncEngineHarness()..setUp());

  tearDown(() => harness.tearDown());

  test('two starts at once pull once and listen once', () async {
    final sync = harness.engine();

    await Future.wait([sync.start(), sync.start()]);

    expect(harness.pullCount(), 1);
    verify(() => harness.connectivity.onlineStream).called(1);
  });

  test('off then on in quick succession leaves sync running', () async {
    var enabled = true;
    final sync = harness.engine(isEnabled: () async => enabled);
    await sync.start();
    expect(harness.pullCount(), 1);

    enabled = false;
    final off = sync.applyEnabled(enabled: false);
    enabled = true;
    final on = sync.applyEnabled(enabled: true);
    await Future.wait([off, on]);
    SyncEventBus().trigger();
    await pumpEventQueue();

    // The restart pulled, and the trigger after it pulled again.
    expect(harness.pullCount(), 2);
  });

  test('a start during stop runs after the teardown', () async {
    final order = <String>[];
    final sync = harness.engine(stopTasks: [() async => order.add('stopped')]);
    await sync.start();
    final held = Completer<Response<dynamic>>();
    harness.pullWith(() => held.future);
    final cycle = sync.syncNow();
    await pumpEventQueue();

    final stopping = sync.stop();
    harness.pullWith(() async {
      order.add('pulled');

      return _pulled();
    });
    final starting = sync.start();
    held.complete(_pulled());
    await Future.wait([cycle, stopping, starting]);

    expect(order, ['stopped', 'pulled']);
  });

  test(
    'turning on before the first sync asks for the conflict check',
    () async {
      FlutterSecureStorage.setMockInitialValues({'jwt_access_token': 'token'});
      final sync = harness.engine();
      final asked = <void>[];
      final sub = sync.firstSyncNeeded.listen(asked.add);
      addTearDown(sub.cancel);

      await sync.applyEnabled(enabled: true);
      await pumpEventQueue();

      expect(asked, hasLength(1));
      verifyNever(
        () => harness.dio.get<Object?>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      );
    },
  );

  test('signed out, turning on asks for nothing', () async {
    FlutterSecureStorage.setMockInitialValues({});
    final sync = harness.engine();
    final asked = <void>[];
    final sub = sync.firstSyncNeeded.listen(asked.add);
    addTearDown(sub.cancel);

    await sync.applyEnabled(enabled: true);
    await pumpEventQueue();

    expect(asked, isEmpty);
  });
}
