import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/api/api_constants.dart';
import 'package:expense_tracker/core/sync/sync_outcome_store.dart';

import 'sync_engine_harness.dart';

void main() {
  late SyncEngineHarness harness;
  final earlier = DateTime(2026, 10, 1, 8);

  setUp(() async {
    harness = SyncEngineHarness()..setUp();
    await SyncOutcomeStore.recordSyncSuccess(earlier);
  });

  tearDown(() => harness.tearDown());

  test('a clean cycle records success and resets failures', () async {
    await SyncOutcomeStore.recordSyncFailure(DateTime(2026, 10, 2));
    await harness.queueChange();

    await harness.engine().start();

    expect(
      (await SyncOutcomeStore.getLastSuccessfulSyncAt())!.isAfter(earlier),
      isTrue,
    );
    expect(await SyncOutcomeStore.getConsecutiveSyncFailures(), 0);
    expect(await SyncOutcomeStore.getLastFailedSyncAt(), isNull);
  });

  test('a pull error records a failure and keeps the success time', () async {
    harness.pullThrows();

    await harness.engine().start();

    expect(await SyncOutcomeStore.getConsecutiveSyncFailures(), 1);
    expect(await SyncOutcomeStore.getLastFailedSyncAt(), isNotNull);
    expect(await SyncOutcomeStore.getLastSuccessfulSyncAt(), earlier);
  });

  test('a push error records a failure', () async {
    await harness.queueChange();
    harness.pushThrows();

    await harness.engine().start();

    expect(await SyncOutcomeStore.getConsecutiveSyncFailures(), 1);
  });

  test('offline records nothing', () async {
    harness.online(false);

    await harness.engine().start();

    expect(await SyncOutcomeStore.getLastSuccessfulSyncAt(), earlier);
    expect(await SyncOutcomeStore.getConsecutiveSyncFailures(), 0);
  });

  test('a cycle stopped part-way records nothing', () async {
    final pull = Completer<Response<dynamic>>();
    harness.pullWith(() => pull.future);
    final sync = harness.engine();

    final started = sync.start();
    await pumpEventQueue();
    final stopping = sync.stop();
    pull.complete(
      Response(
        requestOptions: RequestOptions(path: ApiConstants.syncPull),
        data: {'changes': <Object>[], 'serverTime': '2026-10-15T00:00:00.000Z'},
      ),
    );
    await stopping;
    await started;

    expect(await SyncOutcomeStore.getLastSuccessfulSyncAt(), earlier);
    expect(await SyncOutcomeStore.getConsecutiveSyncFailures(), 0);
  });

  test('isSyncing is true during a cycle and false after', () async {
    final pull = Completer<Response<dynamic>>();
    harness.pullWith(() => pull.future);
    final sync = harness.engine();
    final seen = <bool>[];
    sync.isSyncing.addListener(() => seen.add(sync.isSyncing.value));

    final started = sync.start();
    await pumpEventQueue();
    expect(sync.isSyncing.value, isTrue);

    pull.completeError(Exception('server down'));
    await started;

    expect(seen, [true, false]);
    expect(sync.isSyncing.value, isFalse);
  });
}
