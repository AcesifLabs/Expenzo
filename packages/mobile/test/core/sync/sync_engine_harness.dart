import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/core/api/api_client.dart';
import 'package:expense_tracker/core/api/api_constants.dart';
import 'package:expense_tracker/core/database/app_database.dart';
import 'package:expense_tracker/core/database/daos/sync_queue_dao.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/sync/connectivity_service.dart';
import 'package:expense_tracker/core/sync/sync_engine.dart';
import 'package:expense_tracker/core/sync/sync_table_registry.dart';

class _MockApiClient extends Mock implements ApiClient {}

class _MockDio extends Mock implements Dio {}

class _MockConnectivity extends Mock implements ConnectivityService {}

/// A [SyncEngine] over an in-memory database with a mocked server and
/// connectivity, signed in and past the first sync unless told otherwise.
class SyncEngineHarness {
  final AppDatabase db = AppDatabase.forTesting(NativeDatabase.memory());
  final Dio dio = _MockDio();
  final ApiClient apiClient = _MockApiClient();
  final ConnectivityService connectivity = _MockConnectivity();
  late final SyncQueueDao queue = SyncQueueDao(db);
  SyncEngine? _engine;

  void setUp({bool signedIn = true, bool firstSyncDone = true}) {
    FlutterSecureStorage.setMockInitialValues({
      if (signedIn) 'jwt_access_token': 'token',
      if (firstSyncDone) 'is_first_sync': 'false',
    });
    di.getIt.registerSingleton<AppDatabase>(db);
    when(() => apiClient.dio).thenReturn(dio);
    online(true);
    when(
      () => connectivity.onlineStream,
    ).thenAnswer((_) => const Stream.empty());
    pullReturns();
    pushSucceeds();
  }

  Future<void> tearDown() async {
    await _engine?.stop();
    await di.getIt.unregister<AppDatabase>();
    await db.close();
  }

  SyncEngine engine({
    Future<bool> Function()? isEnabled,
    List<SyncTask> stopTasks = const [],
    SyncTableRegistry? registry,
  }) => _engine = SyncEngine(
    syncQueueDao: queue,
    apiClient: apiClient,
    connectivity: connectivity,
    registry: registry ?? SyncTableRegistry(),
    isEnabled: isEnabled,
    stopTasks: stopTasks,
  );

  void online(bool value) =>
      when(() => connectivity.checkNow()).thenAnswer((_) async => value);

  void pullReturns() => when(
    () => dio.get<Object?>(
      ApiConstants.syncPull,
      queryParameters: any(named: 'queryParameters'),
    ),
  ).thenAnswer((_) async => _pullResponse());

  void pullThrows() => when(
    () => dio.get<Object?>(
      ApiConstants.syncPull,
      queryParameters: any(named: 'queryParameters'),
    ),
  ).thenThrow(Exception('server down'));

  void pullWith(Future<Response<dynamic>> Function() answer) => when(
    () => dio.get<Object?>(
      ApiConstants.syncPull,
      queryParameters: any(named: 'queryParameters'),
    ),
  ).thenAnswer((_) => answer());

  void pushSucceeds() =>
      when(() => dio.post<Object?>(any(), data: any(named: 'data'))).thenAnswer(
        (invocation) async => Response(
          requestOptions: RequestOptions(path: ApiConstants.syncPush),
          data: {'results': _okResults(invocation)},
        ),
      );

  void pushThrows() => when(
    () => dio.post<Object?>(any(), data: any(named: 'data')),
  ).thenThrow(Exception('server down'));

  /// Queues one change so a push sends something.
  Future<void> queueChange([String id = 'r1']) => queue.enqueue(
    tableName: 'records',
    recordId: id,
    action: 'create',
    payload: '{}',
  );

  int pullCount() => verify(
    () => dio.get<Object?>(
      ApiConstants.syncPull,
      queryParameters: any(named: 'queryParameters'),
    ),
  ).callCount;

  static Response<dynamic> _pullResponse() => Response(
    requestOptions: RequestOptions(path: ApiConstants.syncPull),
    data: {'changes': <Object>[], 'serverTime': '2026-10-15T00:00:00.000Z'},
  );

  static List<Map<String, dynamic>> _okResults(Invocation invocation) {
    final data = invocation.namedArguments[#data] as Map<String, dynamic>;
    final changes = data['changes'] as List;

    return [
      for (final change in changes)
        {'id': (change as Map<String, dynamic>)['id'], 'status': 'success'},
    ];
  }
}
