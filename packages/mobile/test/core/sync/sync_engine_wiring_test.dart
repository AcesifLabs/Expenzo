import 'dart:async';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:expense_tracker/core/api/api_client.dart';
import 'package:expense_tracker/core/api/api_constants.dart';
import 'package:expense_tracker/core/constants/app_constants.dart';
import 'package:expense_tracker/core/database/app_database.dart';
import 'package:expense_tracker/core/database/daos/sync_queue_dao.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/sync/connectivity_service.dart';
import 'package:expense_tracker/core/sync/handlers/budgets_sync_handler.dart';
import 'package:expense_tracker/core/sync/handlers/records_sync_handler.dart';
import 'package:expense_tracker/core/sync/sync_engine.dart';
import 'package:expense_tracker/core/sync/sync_event.dart';
import 'package:expense_tracker/core/sync/sync_table_registry.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockApiClient extends Mock implements ApiClient {}

class _MockDio extends Mock implements Dio {}

class _MockConnectivity extends Mock implements ConnectivityService {}

void main() {
  late AppDatabase db;
  late _MockDio dio;
  late _MockApiClient apiClient;
  late _MockConnectivity connectivity;
  late SyncEngine running;

  void pullReturns(List<Map<String, dynamic>> changes) =>
      when(
        () => dio.get<Object?>(
          ApiConstants.syncPull,
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ApiConstants.syncPull),
          data: {'changes': changes, 'serverTime': '2026-10-11T00:00:00.000Z'},
        ),
      );

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({
      'jwt_access_token': 'token',
      'is_first_sync': 'false',
    });
    db = AppDatabase.forTesting(NativeDatabase.memory());
    di.getIt.registerSingleton<AppDatabase>(db);
    dio = _MockDio();
    apiClient = _MockApiClient();
    when(() => apiClient.dio).thenReturn(dio);
    connectivity = _MockConnectivity();
    when(() => connectivity.checkNow()).thenAnswer((_) async => true);
    when(
      () => connectivity.onlineStream,
    ).thenAnswer((_) => const Stream.empty());
    pullReturns([]);
  });

  tearDown(() async {
    await running.stop();
    await di.getIt.unregister<AppDatabase>();
    await db.close();
  });

  SyncEngine engine({
    bool keepLocalNames = false,
    bool keepLocalBudgetLinks = false,
    List<SyncTask> afterSyncTasks = const [],
    List<SyncTask> beforeLocalWipeTasks = const [],
    List<SyncTask> stopTasks = const [],
  }) => running = SyncEngine(
    syncQueueDao: SyncQueueDao(db),
    apiClient: apiClient,
    connectivity: connectivity,
    registry: SyncTableRegistry()
      ..register(BudgetsSyncHandler(keepLocalNames: () => keepLocalNames))
      ..register(
        RecordsSyncHandler(keepLocalBudgetLinks: () => keepLocalBudgetLinks),
      ),
    afterSyncTasks: afterSyncTasks,
    beforeLocalWipeTasks: beforeLocalWipeTasks,
    stopTasks: stopTasks,
  );

  Map<String, dynamic> pulledBudget(String id, String name) => {
    'table': 'budgets',
    'action': 'insert',
    'id': id,
    'data': {
      'name': name,
      'amount': 400,
      'period': 'monthly',
      'startDate': '2026-10-01T00:00:00.000Z',
    },
  };

  Future<Map<String, String>> localNames() async => {
    for (final b in await db.select(db.budgets).get()) b.id: b.name,
  };

  group('pull', () {
    setUp(() async {
      pullReturns([
        pulledBudget('b1', 'Groceries'),
        pulledBudget('b2', 'Rent'),
      ]);
      await engine().executeDecision(SyncMode.cloudWins);
      pullReturns([
        pulledBudget('b1', AppConstants.defaultBudgetName),
        pulledBudget('b2', AppConstants.defaultBudgetName),
        pulledBudget('b3', AppConstants.defaultBudgetName),
      ]);
    });

    test('keeps local names while the name repair is pending', () async {
      await engine(keepLocalNames: true).executeDecision(SyncMode.cloudWins);

      expect(await localNames(), {
        'b1': 'Groceries',
        'b2': 'Rent',
        'b3': AppConstants.defaultBudgetName,
      });
    });

    test('takes the pulled default once the repair is done', () async {
      await engine().executeDecision(SyncMode.cloudWins);

      expect((await localNames())['b1'], AppConstants.defaultBudgetName);
    });
  });

  group('pull record budget links', () {
    Map<String, dynamic> pulledRecord(String? budgetId) => {
      'table': 'records',
      'action': 'insert',
      'id': 'r1',
      'data': {
        'amount': 10,
        'description': 'Lunch',
        'date': '2026-10-01T00:00:00.000Z',
        'recordType': 'OUT',
        'budgetId': budgetId,
      },
    };

    Future<String?> localBudgetId() async =>
        (await db.select(db.records).getSingle()).budgetId;

    setUp(() async {
      pullReturns([pulledRecord('bud-1')]);
      await engine().executeDecision(SyncMode.cloudWins);
      pullReturns([pulledRecord(null)]);
    });

    test('keeps the local link while the link repair is pending', () async {
      await engine(
        keepLocalBudgetLinks: true,
      ).executeDecision(SyncMode.cloudWins);

      expect(await localBudgetId(), 'bud-1');
    });

    test('clears the local link once the repair is done', () async {
      await engine().executeDecision(SyncMode.cloudWins);

      expect(await localBudgetId(), isNull);
    });
  });

  group('after-sync tasks', () {
    test('run after a sync, even when an earlier one fails', () async {
      final ran = <String>[];

      await engine(
        afterSyncTasks: [
          () async => throw Exception('server down'),
          () async => ran.add('second'),
        ],
      ).start();

      expect(ran, ['second']);
    });

    test('see whether the pull succeeded', () async {
      bool? pulled;
      late SyncEngine sync;
      sync = engine(
        afterSyncTasks: [() async => pulled = sync.lastPullSucceeded],
      );

      await sync.start();

      expect(pulled, isTrue);
    });

    test('see a failed pull as not pulled', () async {
      when(
        () => dio.get<Object?>(
          ApiConstants.syncPull,
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(Exception('server down'));
      bool? pulled;
      late SyncEngine sync;
      sync = engine(
        afterSyncTasks: [() async => pulled = sync.lastPullSucceeded],
      );

      await sync.start();

      expect(pulled, isFalse);
    });

    test('stop runs the stop tasks, even after one fails', () async {
      final ran = <String>[];
      final sync = engine(
        stopTasks: [
          () async => throw Exception('boom'),
          () async => ran.add('second'),
        ],
      );
      await sync.start();

      await sync.stop();

      expect(ran, ['second']);
      expect(sync.lastPullSucceeded, isFalse);
    });

    test('are skipped while offline', () async {
      when(() => connectivity.checkNow()).thenAnswer((_) async => false);
      var ran = false;

      await engine(afterSyncTasks: [() async => ran = true]).start();

      expect(ran, isFalse);
    });
  });

  group('stop', () {
    test('waits for a running cycle and skips its after-sync tasks', () async {
      final pull = Completer<Response<dynamic>>();
      when(
        () => dio.get<Object?>(
          ApiConstants.syncPull,
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) => pull.future);
      var ran = false;
      final sync = engine(afterSyncTasks: [() async => ran = true]);

      final started = sync.start();
      await pumpEventQueue();
      var stopped = false;
      final stopping = sync.stop().then((_) => stopped = true);
      await pumpEventQueue();

      expect(stopped, isFalse, reason: 'stop must wait for the pull');

      pull.complete(
        Response(
          requestOptions: RequestOptions(path: ApiConstants.syncPull),
          data: {
            'changes': <Object>[],
            'serverTime': '2026-10-11T00:00:00.000Z',
          },
        ),
      );
      await stopping;
      await started;

      expect(ran, isFalse);
      verifyNever(() => dio.post<Object?>(any(), data: any(named: 'data')));
      // The interrupted start gave up instead of listening for triggers.
      verifyNever(() => connectivity.onlineStream);
    });

    test('a sync trigger already in flight does nothing after stop', () async {
      final sync = engine();
      await sync.start();
      final online = Completer<bool>();
      when(() => connectivity.checkNow()).thenAnswer((_) => online.future);

      SyncEventBus().trigger();
      await pumpEventQueue();
      await sync.stop();
      online.complete(true);
      await pumpEventQueue();

      verify(
        () => dio.get<Object?>(
          ApiConstants.syncPull,
          queryParameters: any(named: 'queryParameters'),
        ),
      ).called(1);
    });
  });

  group('pause', () {
    test('start does nothing until resume', () async {
      final sync = engine();
      await sync.pause();

      await sync.start();
      verifyNever(
        () => dio.get<Object?>(
          ApiConstants.syncPull,
          queryParameters: any(named: 'queryParameters'),
        ),
      );

      await sync.resume();
      verify(
        () => dio.get<Object?>(
          ApiConstants.syncPull,
          queryParameters: any(named: 'queryParameters'),
        ),
      ).called(1);
    });
  });

  group('prepareForLocalWipe', () {
    test('runs every task', () async {
      final ran = <int>[];

      await engine(
        beforeLocalWipeTasks: [() async => ran.add(1), () async => ran.add(2)],
      ).prepareForLocalWipe();

      expect(ran, [1, 2]);
    });

    test('fails when a task fails so the wipe can be stopped', () async {
      await expectLater(
        engine(
          beforeLocalWipeTasks: [() async => throw Exception('offline')],
        ).prepareForLocalWipe(),
        throwsException,
      );
    });
  });
}
