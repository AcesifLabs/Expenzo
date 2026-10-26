import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import '../api/api_client.dart';
import '../database/app_database.dart';
import '../api/api_constants.dart';
import '../api/token_storage.dart';
import '../database/daos/sync_queue_dao.dart';
import '../di/injection_container.dart' as di;
import '../logger/app_logger.dart';
import 'connectivity_service.dart';
import 'sync_event.dart';
import 'sync_mode.dart';
import 'sync_outcome_store.dart';
import 'sync_run_result.dart';
import 'sync_status.dart';
import 'sync_table_registry.dart';

export 'sync_mode.dart';
export 'sync_run_result.dart';

typedef SyncTask = Future<void> Function();

class SyncEngine {
  void Function(double)? onProgress;

  static const int chunkSize = 500;

  static const List<Duration> _backoffDelays = [
    Duration(seconds: 5),
    Duration(seconds: 15),
    Duration(seconds: 45),
    Duration(minutes: 2),
    Duration(minutes: 5),
    Duration(minutes: 15),
    Duration(minutes: 30),
    Duration(hours: 1),
  ];

  final ApiClient _apiClient;
  final ConnectivityService _connectivity;
  final SyncQueueDao _syncQueueDao;
  final SyncTableRegistry _registry;
  final List<SyncTask> _afterSyncTasks;
  final List<SyncTask> _beforeLocalWipeTasks;
  final List<SyncTask> _stopTasks;
  final Future<bool> Function() _isEnabled;
  StreamSubscription<bool>? _connectivitySub;
  StreamSubscription<SyncTriggered>? _syncEventSub;
  bool _initialized = false;
  bool _lastPullSucceeded = false;
  int _retryCount = 0;
  Duration? _scheduledRetryDelay;
  Timer? _retryTimer;

  final Map<String, int> _pullFailures = {};
  static const _maxPullAttempts = 5;

  static const _epochCursor = '1970-01-01T00:00:00.000Z';

  Duration _clockSkew = Duration.zero;

  final Map<String, Map<String, dynamic>> _heldPulls = {};

  Completer<void>? _syncLock;
  bool _hasPendingTrigger = false;

  bool _active = false;

  int _stopCount = 0;

  Future<bool>? _migrationRun;

  bool _paused = false;

  final ValueNotifier<bool> _isSyncing = ValueNotifier(false);

  bool _cycleErrored = false;
  bool _cycleSkippedOffline = false;

  Future<void> _lifecycle = Future<void>.value();

  final StreamController<void> _firstSyncNeeded =
      StreamController<void>.broadcast();

  bool get lastPullSucceeded => _lastPullSucceeded;

  ValueListenable<bool> get isSyncing => _isSyncing;

  bool get lastCycleErrored => _cycleErrored;

  bool get lastCycleSkippedOffline => _cycleSkippedOffline;

  @visibleForTesting
  bool get hasPendingRetry => _retryTimer?.isActive ?? false;

  @visibleForTesting
  Duration? get scheduledRetryDelay => _scheduledRetryDelay;

  Stream<void> get firstSyncNeeded => _firstSyncNeeded.stream;

  AppDatabase get _db => di.getIt<AppDatabase>();

  SyncEngine({
    required SyncQueueDao syncQueueDao,
    required ApiClient apiClient,
    required ConnectivityService connectivity,
    required SyncTableRegistry registry,

    List<SyncTask> afterSyncTasks = const [],

    List<SyncTask> beforeLocalWipeTasks = const [],

    List<SyncTask> stopTasks = const [],

    Future<bool> Function()? isEnabled,
  }) : _syncQueueDao = syncQueueDao,
       _apiClient = apiClient,
       _connectivity = connectivity,
       _registry = registry,
       _afterSyncTasks = afterSyncTasks,
       _beforeLocalWipeTasks = beforeLocalWipeTasks,
       _stopTasks = stopTasks,
       _isEnabled = isEnabled ?? _alwaysOn;

  Future<void> start() => _queued(_start);

  Future<void> pause() async {
    _paused = true;
    await stop();
  }

  Future<void> resume() {
    _paused = false;

    return start();
  }

  Future<bool> isEnabled() => _isEnabled();

  Future<void> applyEnabled({required bool enabled}) async {
    if (!enabled) return stop();
    if (await TokenStorage.isFirstSync()) {
      if (await TokenStorage.hasToken()) _firstSyncNeeded.add(null);

      return;
    }
    await start();
  }

  @visibleForTesting
  Future<void> runScheduledRetry() {
    _retryTimer?.cancel();

    return _retrySync();
  }

  Future<SyncRunResult> syncNow() async {
    if (!await TokenStorage.hasToken()) return SyncRunResult.signedOut;
    if (!await _firstSyncDone()) return SyncRunResult.firstSyncPending;
    if (_paused || !await _isEnabled()) return SyncRunResult.disabled;
    if (!await _connectivity.checkNow()) return SyncRunResult.offline;
    final lock = _syncLock;
    if (lock != null) {
      _hasPendingTrigger = true;
      await lock.future;
    } else if (_initialized) {
      await _runSyncCycle();
    } else {
      await start();
    }

    return _resultOf(
      errored: _cycleErrored,
      skippedOffline: _cycleSkippedOffline,
    );
  }

  Future<void> stop() {
    _active = false;
    _stopCount++;
    _retryTimer?.cancel();
    _retryTimer = null;
    _retryCount = 0;
    _hasPendingTrigger = false;

    return _queued(_finishStop);
  }

  Future<SyncConflictType> checkConflict() async {
    int localCount = 0;
    for (final handler in _registry.all) {
      localCount += await handler.countRows(_db);
    }

    final response = await _apiClient.dio.get<Object?>(
      ApiConstants.syncSummary,
    );
    final cloudCount = _json(response)['totalCount'];
    if (cloudCount is! int) {
      throw const FormatException('Sync summary has no totalCount');
    }

    if (localCount > 0 && cloudCount > 0) return SyncConflictType.conflict;
    if (localCount > 0) return SyncConflictType.localOnly;
    if (cloudCount > 0) return SyncConflictType.cloudOnly;

    return SyncConflictType.none;
  }

  Future<void> prepareForLocalWipe() async {
    for (final task in _beforeLocalWipeTasks) {
      await task();
    }
  }

  Future<void> executeDecision(SyncMode mode) async {
    switch (mode) {
      case SyncMode.localWins:
        await _apiClient.dio.delete<Object?>(ApiConstants.syncClear);
        await _uploadExistingData();
        await _safePushChanges();
        break;
      case SyncMode.cloudWins:
        await _safePullChanges();
        break;
      case SyncMode.merge:
        await _uploadExistingData();
        await _safePushChanges();
        await _safePullChanges();
        break;
    }
    await TokenStorage.markFirstSyncDone();
  }

  Future<void> _uploadExistingData() async {
    if (!await _migrateExistingData()) {
      throw StateError('Part of the first-sync upload failed');
    }
  }

  Future<void> _queued(Future<void> Function() operation) {
    final run = _lifecycle.then((_) => operation());

    _lifecycle = run.catchError(
      (Object e) => debugPrint('SyncEngine: lifecycle step failed: $e'),
    );

    return run;
  }

  Future<void> _finishStop() async {
    _active = false;
    _retryTimer?.cancel();
    _retryTimer = null;
    await _connectivitySub?.cancel();
    _connectivitySub = null;
    await _syncEventSub?.cancel();
    _syncEventSub = null;
    await _syncLock?.future;
    await _migrationRun;
    _initialized = false;
    _lastPullSucceeded = false;
    for (final task in _stopTasks) {
      try {
        await task();
      } catch (e, s) {
        appLogger.error('SyncEngine: Stop task failed', e, s);
      }
    }
  }

  Future<void> _start() async {
    if (_initialized || _paused) return;
    _active = true;
    final stopCount = _stopCount;
    await _connectivitySub?.cancel();
    await _syncEventSub?.cancel();
    debugPrint('SyncEngine: Starting');
    try {
      final hasToken = await TokenStorage.hasToken();
      if (!hasToken) {
        debugPrint('SyncEngine: No JWT');

        return;
      }

      if (!await _isEnabled()) {
        debugPrint('SyncEngine: Off on this device');
        _active = false;

        return;
      }
      if (stopCount != _stopCount) return;
      await _runSyncCycle();
      if (stopCount != _stopCount) return;
      if (await TokenStorage.isFirstSync()) await _migrateOnce();
      if (stopCount != _stopCount) return;
      _connectivitySub = _connectivity.onlineStream.listen(
        (online) {
          unawaited(_onConnectivityChange(online));
        },
        onError: (Object e, StackTrace s) {
          appLogger.error('Connectivity stream error', e, s);
        },
      );
      _syncEventSub = SyncEventBus().events.listen(
        (_) {
          unawaited(_onSyncEvent());
        },
        onError: (Object e, StackTrace s) {
          appLogger.error('SyncEventBus listener error', e, s);
        },
      );
      _initialized = true;
    } catch (e, s) {
      appLogger.error('SyncEngine start failed', e, s);
      _initialized = false;
    }
  }

  Future<void> _onConnectivityChange(bool online) async {
    if (online) {
      await _runSyncCycle();
    }
  }

  Future<void> _onSyncEvent() async {
    final online = await _connectivity.checkNow();
    if (online) {
      await _runSyncCycle();
    }
  }

  Future<void> _runSyncCycle() async {
    if (!_active) return;
    if (_syncLock != null) {
      _hasPendingTrigger = true;

      return;
    }

    _syncLock = Completer<void>();
    _isSyncing.value = true;

    try {
      do {
        do {
          _hasPendingTrigger = false;
          _cycleErrored = false;
          _cycleSkippedOffline = false;
          await _safePullChanges();
          if (!_active) return;
          await _safePushChanges();
        } while (_hasPendingTrigger && _active);

        if (!_active) return;
        await _recordCycleOutcome();
        await _runAfterSyncTasks();
      } while (_hasPendingTrigger && _active);
    } finally {
      final lock = _syncLock;
      if (lock != null) {
        lock.complete();
      }
      _syncLock = null;
      _isSyncing.value = false;
    }
  }

  static Future<bool> _alwaysOn() async => true;

  static SyncRunResult _resultOf({
    required bool errored,
    required bool skippedOffline,
  }) {
    if (errored) return SyncRunResult.failed;

    return skippedOffline ? SyncRunResult.offline : SyncRunResult.success;
  }

  Future<void> _recordCycleOutcome() async {
    if (_cycleErrored) {
      await SyncOutcomeStore.recordSyncFailure(DateTime.now());
    } else if (!_cycleSkippedOffline) {
      _retryCount = 0;
      await SyncOutcomeStore.recordSyncSuccess(DateTime.now());
    }
  }

  Future<void> _safePushChanges() async {
    try {
      if (!await _connectivity.checkNow()) {
        _cycleSkippedOffline = true;

        return;
      }
      final queue = await _syncQueueDao.getUnsynced();
      if (queue.isEmpty) return;

      await _processPushQueue(queue);
    } catch (e, s) {
      appLogger.error('SyncEngine push failed', e, s);
      _cycleErrored = true;
      _scheduleRetry();
    }
  }

  Future<void> _processPushQueue(List<SyncQueueData> queue) async {
    int processed = 0;
    final total = queue.length;
    final stopCount = _stopCount;

    while (processed < total && stopCount == _stopCount) {
      final end = processed + chunkSize > total ? total : processed + chunkSize;
      final batch = queue.sublist(processed, end);
      debugPrint(
        'SyncEngine: Pushing chunk ${processed ~/ chunkSize + 1} (${batch.length} items)',
      );

      await _pushBatch(batch);

      processed = end;
      onProgress?.call(processed / total);
    }
  }

  Future<void> _pushBatch(List<SyncQueueData> batch) async {
    final changes = batch
        .map(
          (item) => {
            'table': item.entityTable,
            'action': item.action,
            'id': item.recordId,
            'data': item.payload.isNotEmpty ? jsonDecode(item.payload) : null,
            'updatedAt': item.createdAt
                .add(_clockSkew)
                .toUtc()
                .toIso8601String(),
          },
        )
        .toList();

    final response = await _apiClient.dio.post<Object?>(
      ApiConstants.syncPush,
      data: {'changes': changes},
    );
    final results = (_json(response)['results']! as List<Object?>)
        .cast<Map<String, dynamic>>();
    await _applyHeldPullsThatLost(batch, results);

    final syncedIds = <int>[];
    final rejectedIds = <int>[];
    for (final (result, queueIds) in _matchResults(batch, results)) {
      switch (SyncStatus.fromString(result['status'] as String)) {
        case SyncStatus.success:
          syncedIds.addAll(queueIds);
        case SyncStatus.conflict:
          appLogger.info('SyncEngine: Push conflict on ${result['id']}');
          syncedIds.addAll(queueIds);
        case SyncStatus.error:
          rejectedIds.addAll(queueIds);
      }
    }
    await _syncQueueDao.markSynced(syncedIds);
    await _syncQueueDao.recordRejected(rejectedIds);
  }

  static List<(Map<String, dynamic>, List<int>)> _matchResults(
    List<SyncQueueData> batch,
    List<Map<String, dynamic>> results,
  ) {
    if (results.length == batch.length) {
      return [
        for (var i = 0; i < batch.length; i++) (results[i], [batch[i].id]),
      ];
    }
    final idsByRecord = <String, List<int>>{};
    for (final item in batch) {
      idsByRecord.putIfAbsent(item.recordId, () => []).add(item.id);
    }

    return [
      for (final result in results)
        (result, idsByRecord[result['id']?.toString()] ?? const <int>[]),
    ];
  }

  Future<void> _applyHeldPullsThatLost(
    List<SyncQueueData> batch,
    List<Map<String, dynamic>> results,
  ) async {
    final tableById = {
      for (final item in batch) item.recordId: item.entityTable,
    };
    await _db.transaction(() async {
      for (final result in results) {
        if (SyncStatus.fromString(result['status'] as String) !=
            SyncStatus.conflict) {
          continue;
        }
        final id = result['id']?.toString();
        final held = _heldPulls.remove('${tableById[id]}/$id');
        if (held == null) continue;
        appLogger.info(
          'SyncEngine: Server kept its copy of ${tableById[id]}/$id',
        );
        await _applyRemoteChange(held);
      }
    });
  }

  Future<void> _safePullChanges() async {
    _lastPullSucceeded = false;
    try {
      if (!await _connectivity.checkNow()) {
        _cycleSkippedOffline = true;

        return;
      }
      final lastSync = await TokenStorage.getLastSyncAt();
      final response = await _apiClient.dio.get<Object?>(
        ApiConstants.syncPull,
        queryParameters: {'since': lastSync ?? _epochCursor},
      );
      final body = _json(response);
      final serverTime = body['serverTime']! as String;
      final changes = body['changes']! as List<Object?>;
      _measureClockSkew(serverTime);
      debugPrint('SyncEngine: Pulled ${changes.length} changes');
      final failed = await _db.transaction(
        () => _applyPulledChanges(changes.cast<Map<String, dynamic>>()),
      );
      await TokenStorage.saveLastSyncAt(_nextPullCursor(serverTime, failed));
      _lastPullSucceeded = true;
    } catch (e, s) {
      appLogger.error('SyncEngine pull failed', e, s);
      _cycleErrored = true;
      _scheduleRetry();
    }
  }

  static Map<String, Object?> _json(Response<Object?> response) {
    final data = response.data;
    if (data is Map<String, Object?>) return data;

    throw FormatException('Expected a JSON object, got ${data.runtimeType}');
  }

  void _measureClockSkew(String serverTime) {
    final server = DateTime.tryParse(serverTime);
    if (server != null) _clockSkew = server.difference(clock.now());
  }

  Future<List<Map<String, dynamic>>> _applyPulledChanges(
    List<Map<String, dynamic>> pulled,
  ) async {
    final handlers = _handlersWithIds(pulled);
    for (final MapEntry(key: handler, value: ids) in handlers.entries) {
      await handler.beforeApplyingPull(_db, ids);
    }
    final waitingToPush = await _syncQueueDao.pendingKeys();

    _heldPulls.removeWhere((key, _) => !waitingToPush.contains(key));
    final failed = <Map<String, dynamic>>[];
    try {
      for (final change in pulled) {
        final key = '${change['table']}/${change['id']}';
        if (waitingToPush.contains(key)) {
          _heldPulls[key] = change;
          if (_keepPulling(key)) failed.add(change);
          continue;
        }
        if (await _applyRemoteChange(change)) {
          _pullFailures.remove(key);
          continue;
        }
        if (_keepPulling(key)) failed.add(change);
      }
    } finally {
      for (final handler in handlers.keys) {
        await handler.afterApplyingPull();
      }
    }

    return failed;
  }

  bool _keepPulling(String key) {
    final attempts = (_pullFailures[key] ?? 0) + 1;
    if (attempts < _maxPullAttempts) {
      _pullFailures[key] = attempts;

      return true;
    }
    _pullFailures.remove(key);
    appLogger.warning('SyncEngine: Stopped pulling $key again');

    return false;
  }

  static String _nextPullCursor(
    String serverTime,
    List<Map<String, dynamic>> failed,
  ) {
    final times = [
      for (final change in failed)
        ?DateTime.tryParse(change['updatedAt']?.toString() ?? ''),
    ];
    if (times.isEmpty) return serverTime;
    final earliest = times.reduce((a, b) => a.isBefore(b) ? a : b);

    return earliest
        .subtract(const Duration(milliseconds: 1))
        .toUtc()
        .toIso8601String();
  }

  Map<SyncTableHandler, List<String>> _handlersWithIds(
    List<Map<String, dynamic>> changes,
  ) {
    final result = <SyncTableHandler, List<String>>{};
    for (final change in changes) {
      final handler = _registry[change['table']?.toString() ?? ''];
      final id = change['id']?.toString();
      if (handler == null || id == null) continue;
      result.putIfAbsent(handler, () => []).add(id);
    }

    return result;
  }

  Future<void> _runAfterSyncTasks() async {
    if (_afterSyncTasks.isEmpty || !await _connectivity.checkNow()) return;
    for (final task in _afterSyncTasks) {
      try {
        await task();
      } catch (e, s) {
        appLogger.error('SyncEngine: After-sync task failed', e, s);
      }
    }
  }

  Future<bool> _firstSyncDone() async {
    if (!await TokenStorage.isFirstSync()) return true;

    if (!_active && _migrationRun == null) _firstSyncNeeded.add(null);
    if (!_initialized || !_active) return false;

    return _migrateOnce();
  }

  Future<bool> _migrateOnce() async {
    final running = _migrationRun;
    if (running != null) return running;
    final migration = _migrationRun = _migrateExistingData();
    try {
      return await migration;
    } finally {
      _migrationRun = null;
    }
  }

  Future<bool> _migrateExistingData() async {
    debugPrint('SyncEngine: Starting one-time data migration');
    try {
      final changes = await _collectAllChanges();

      if (changes.isEmpty) {
        debugPrint('SyncEngine: No data to migrate');
        await TokenStorage.markFirstSyncDone();

        return true;
      }

      final allSucceeded = await _pushMigrationChunks(changes);

      if (allSucceeded) {
        debugPrint('SyncEngine: Migration complete');
        await TokenStorage.markFirstSyncDone();
      } else {
        debugPrint('SyncEngine: Migration partially failed, will retry');
      }

      return allSucceeded;
    } catch (e, stackTrace) {
      appLogger.error('SyncEngine: Migration failed', e, stackTrace);

      return false;
    }
  }

  Future<List<Map<String, dynamic>>> _collectAllChanges() async {
    final changes = <Map<String, dynamic>>[];

    for (final handler in _registry.all) {
      final rows = await handler.fetchAll(_db);
      for (final row in rows) {
        final payload = handler.toSyncPayload(row);
        final id = payload['id']?.toString() ?? '';
        changes.add({
          'table': handler.tableName,
          'action': 'insert',
          'id': id,
          'data': payload,
          'updatedAt': payload['updatedAt'],
        });
      }
    }

    return changes;
  }

  Future<bool> _pushMigrationChunks(List<Map<String, dynamic>> changes) async {
    var allSucceeded = true;
    final stopCount = _stopCount;
    for (var i = 0; i < changes.length; i += chunkSize) {
      if (stopCount != _stopCount) return false;
      final end = i + chunkSize > changes.length
          ? changes.length
          : i + chunkSize;
      final batch = changes.sublist(i, end);
      debugPrint(
        'SyncEngine: Migrating chunk ${i ~/ chunkSize + 1} (${batch.length} items)',
      );

      final chunkOk = await _pushSingleMigrationChunk(batch);
      if (!chunkOk) allSucceeded = false;

      onProgress?.call(end / changes.length);
    }

    return allSucceeded;
  }

  Future<bool> _pushSingleMigrationChunk(
    List<Map<String, dynamic>> batch,
  ) async {
    try {
      final response = await _apiClient.dio.post<Object?>(
        ApiConstants.syncPush,
        data: {'changes': batch},
      );

      return _validateMigrationResults(
        _json(response)['results'] as List<Object?>?,
      );
    } catch (e, s) {
      appLogger.error('SyncEngine: Migration chunk failed', e, s);

      return false;
    }
  }

  bool _validateMigrationResults(List<Object?>? results) {
    if (results == null) return true;

    var allOk = true;
    for (final result in results) {
      final status = result is Map<String, Object?>
          ? result['status']?.toString()
          : null;
      if (status != 'success' && status != 'conflict') {
        debugPrint('SyncEngine: Migration item failed: $status');
        allOk = false;
      }
    }

    return allOk;
  }

  void _scheduleRetry() {
    if (!_active) return;
    final delay =
        _backoffDelays[_retryCount < _backoffDelays.length
            ? _retryCount
            : _backoffDelays.length - 1];
    debugPrint(
      'SyncEngine: Retrying in ${delay.inSeconds}s (attempt ${_retryCount + 1})',
    );
    _scheduledRetryDelay = delay;
    _retryTimer?.cancel();
    _retryTimer = Timer(delay, () {
      unawaited(_retrySync());
    });
  }

  Future<void> _retrySync() async {
    _retryCount++;
    await _runSyncCycle();
  }

  Future<bool> _applyRemoteChange(Map<String, dynamic> change) async {
    final tableName = change['table']?.toString();
    final id = change['id']?.toString();
    final rawData = change['data'];

    if (tableName == null || id == null) {
      debugPrint('SyncEngine: Malformed remote change (missing table or id)');

      return true;
    }

    final data = rawData is Map<String, dynamic> ? rawData : null;

    final handler = _registry[tableName];
    if (handler == null) {
      debugPrint('SyncEngine: Unknown table in remote change: $tableName');

      return true;
    }

    try {
      if (data == null) {
        await handler.deleteById(_db, id);
      } else {
        final companion = await handler.keepLocalValues(
          _db,
          id,
          handler.fromSyncPayload(id, data),
        );
        await _db.into(handler.tableRef(_db)).insertOnConflictUpdate(companion);
      }

      return true;
    } catch (e, s) {
      appLogger.error('SyncEngine: Could not apply $tableName/$id', e, s);

      return false;
    }
  }
}
