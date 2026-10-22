import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/core/api/api_constants.dart';
import 'package:expense_tracker/core/sync/sync_engine.dart';

import 'sync_engine_harness.dart';

void main() {
  late SyncEngineHarness harness;

  setUp(() => harness = SyncEngineHarness());

  tearDown(() => harness.tearDown());

  void expectNoRequests() {
    verifyNever(
      () => harness.dio.get<dynamic>(
        any(),
        queryParameters: any(named: 'queryParameters'),
      ),
    );
    verifyNever(
      () => harness.dio.post<dynamic>(any(), data: any(named: 'data')),
    );
  }

  test('signed out returns signedOut without requests', () async {
    harness.setUp(signedIn: false);

    expect(await harness.engine().syncNow(), SyncRunResult.signedOut);
    expectNoRequests();
  });

  test('before the first sync returns firstSyncPending', () async {
    harness.setUp(firstSyncDone: false);

    expect(await harness.engine().syncNow(), SyncRunResult.firstSyncPending);
    expectNoRequests();
  });

  test('paused returns disabled without requests', () async {
    harness.setUp();
    final sync = harness.engine();
    await sync.pause();

    expect(await sync.syncNow(), SyncRunResult.disabled);
    expectNoRequests();
  });

  test('offline returns offline without requests', () async {
    harness.setUp();
    harness.online(false);

    expect(await harness.engine().syncNow(), SyncRunResult.offline);
    expectNoRequests();
  });

  test('a clean cycle returns success', () async {
    harness.setUp();
    final sync = harness.engine();
    await sync.start();
    await harness.queueChange();

    expect(await sync.syncNow(), SyncRunResult.success);
    expect(await harness.queue.getUnsyncedCount(), 0);
  });

  test('a pull error returns failed', () async {
    harness.setUp();
    final sync = harness.engine();
    await sync.start();
    harness.pullThrows();

    expect(await sync.syncNow(), SyncRunResult.failed);
  });

  test('concurrent calls share the running cycle', () async {
    harness.setUp();
    final sync = harness.engine();
    await sync.start();
    final pull = Completer<Response<dynamic>>();
    harness.pullWith(() => pull.future);

    final first = sync.syncNow();
    await pumpEventQueue();
    final second = sync.syncNow();
    await pumpEventQueue();
    harness.pullReturns();
    pull.complete(
      Response(
        requestOptions: RequestOptions(path: ApiConstants.syncPull),
        data: {'changes': [], 'serverTime': '2026-10-15T00:00:00.000Z'},
      ),
    );

    expect(await first, SyncRunResult.success);
    expect(await second, SyncRunResult.success);
    // start, the held cycle and one more pass for the joined request.
    expect(harness.pullCount(), lessThanOrEqualTo(3));
  });

  test('an engine that was never started starts and reports', () async {
    harness.setUp();
    final sync = harness.engine();

    expect(await sync.syncNow(), SyncRunResult.success);
    verify(() => harness.connectivity.onlineStream).called(1);
  });
}
