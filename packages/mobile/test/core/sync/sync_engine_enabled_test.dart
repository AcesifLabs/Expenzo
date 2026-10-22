import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/core/sync/sync_engine.dart';
import 'package:expense_tracker/core/sync/sync_event.dart';

import 'sync_engine_harness.dart';

void main() {
  late SyncEngineHarness harness;
  var enabled = true;

  setUp(() {
    enabled = true;
    harness = SyncEngineHarness()..setUp();
  });

  tearDown(() => harness.tearDown());

  SyncEngine engine() => harness.engine(isEnabled: () async => enabled);

  void expectNoPull() => verifyNever(
    () => harness.dio.get<dynamic>(
      any(),
      queryParameters: any(named: 'queryParameters'),
    ),
  );

  test('start does nothing while off', () async {
    enabled = false;

    await engine().start();

    expectNoPull();
    verifyNever(() => harness.connectivity.onlineStream);
  });

  test('syncNow returns disabled while off', () async {
    enabled = false;

    expect(await engine().syncNow(), SyncRunResult.disabled);
    expectNoPull();
  });

  test('turning off stops a running engine', () async {
    final sync = engine();
    await sync.start();
    final pullsBefore = harness.pullCount();

    enabled = false;
    await sync.applyEnabled(enabled: false);
    SyncEventBus().trigger();
    await pumpEventQueue();

    expectNoPull();
    expect(pullsBefore, 1);
  });

  test('turning on starts the engine and pushes queued changes', () async {
    enabled = false;
    final sync = engine();
    await sync.start();
    await harness.queueChange();

    enabled = true;
    await sync.applyEnabled(enabled: true);

    expect(harness.pullCount(), 1);
    expect(await harness.queue.getUnsyncedCount(), 0);
  });

  test('turning on before the first sync does nothing', () async {
    FlutterSecureStorage.setMockInitialValues({'jwt_access_token': 'token'});

    await engine().applyEnabled(enabled: true);

    expectNoPull();
    verifyNever(
      () => harness.dio.post<dynamic>(any(), data: any(named: 'data')),
    );
  });

  test('resume while off stays idle', () async {
    final sync = engine();
    await sync.pause();
    enabled = false;

    await sync.resume();

    expectNoPull();
  });
}
