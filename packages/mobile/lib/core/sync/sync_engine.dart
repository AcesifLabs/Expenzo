import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../api/api_client.dart';
import '../database/app_database.dart';
import '../api/api_constants.dart';
import '../api/token_storage.dart';
import '../database/daos/sync_queue_dao.dart';
import '../di/injection_container.dart' as di;
import 'connectivity_service.dart';
import 'sync_event.dart';
import 'sync_mode.dart';
import 'sync_outcome_store.dart';
import 'sync_run_result.dart';
import 'sync_status.dart';
import 'sync_table_registry.dart';

export 'sync_mode.dart';
export 'sync_run_result.dart';

/// A unit of work the engine runs around syncing, e.g. a one-time repair.
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
  ];

  final ApiClient _apiClient;
  final ConnectivityService _connectivity;
  final SyncQueueDao _syncQueueDao;
  final SyncTableRegistry _registry;
  final List<SyncTask> _afterSyncTasks;
  final List<SyncTask> _beforeLocalWipeTasks;
  final List<SyncTask> _stopTasks;
  final Future<bool> Function() _isEnabled;
  StreamSubscription? _connectivitySub;
  StreamSubscription? _syncEventSub;
  bool _initialized = false;
  bool _lastPullSucceeded = false;
  int _retryCount = 0;
  Timer? _retryTimer;

  /// Single-flight lock for sync operations.
  /// When non-null, a sync cycle is in progress. Concurrent triggers
  /// are coalesced: exactly one more cycle will run after the current completes.
  Completer<void>? _syncLock;
  bool _hasPendingTrigger = false;

  /// True from [start] until [stop]. A cycle only runs while active, so an
  /// event handler or retry that fires after [stop] does nothing, and a
  /// running cycle ends after its current pull or push chunk.
  bool _active = false;

  /// Bumped by [stop], so a [start] still in its first cycle gives up and
  /// push or migration loops end after their current chunk.
  int _stopCount = 0;

  /// The first-sync migration [start] runs outside the cycle lock; [stop]
  /// waits for it too.
  Future<void>? _migrationRun;

  /// Set by [pause]: [start] does nothing until [resume].
  bool _paused = false;

  final ValueNotifier<bool> _isSyncing = ValueNotifier(false);

  /// Set by the last pull/push pass: a request threw, or it was skipped
  /// because the device was offline.
  bool _cycleErrored = false;
  bool _cycleSkippedOffline = false;

  /// The last queued [start] or [stop]. Each runs after the one before it
  /// finishes, so a start can't overlap a stop that is still tearing down.
  Future<void> _lifecycle = Future<void>.value();

  final StreamController<void> _firstSyncNeeded =
      StreamController<void>.broadcast();

  /// True when the latest pull reached the server and was applied. After-sync
  /// tasks run even when it failed, so tasks that need fresh data check this.
  bool get lastPullSucceeded => _lastPullSucceeded;

  /// True while a sync cycle runs.
  ValueListenable<bool> get isSyncing => _isSyncing;

  /// Whether the last cycle's pull or push threw. Rejected rows in a pushed
  /// batch don't count.
  bool get lastCycleErrored => _cycleErrored;

  /// Whether the last cycle skipped a pull or push because it was offline.
  bool get lastCycleSkippedOffline => _cycleSkippedOffline;

  /// Fires when Sync is switched on before the first sync ran (signed in
  /// with Sync off). `AuthBloc` then runs its first-sync conflict check,
  /// which starts sync.
  Stream<void> get firstSyncNeeded => _firstSyncNeeded.stream;

  AppDatabase get _db => di.getIt<AppDatabase>();

  SyncEngine({
    required SyncQueueDao syncQueueDao,
    required ApiClient apiClient,
    required ConnectivityService connectivity,
    required SyncTableRegistry registry,

    /// Run after every sync cycle while online; failures are logged and
    /// retried after the next cycle.
    List<SyncTask> afterSyncTasks = const [],

    /// Run by [prepareForLocalWipe] before local data is replaced.
    List<SyncTask> beforeLocalWipeTasks = const [],

    /// Run by [stop] (sign-out), so per-session state is cleared.
    List<SyncTask> stopTasks = const [],

    /// Whether Sync is switched on for this device; defaults to always on.
    Future<bool> Function()? isEnabled,
  }) : _syncQueueDao = syncQueueDao,
       _apiClient = apiClient,
       _connectivity = connectivity,
       _registry = registry,
       _afterSyncTasks = afterSyncTasks,
       _beforeLocalWipeTasks = beforeLocalWipeTasks,
       _stopTasks = stopTasks,
       _isEnabled = isEnabled ?? _alwaysOn;

  /// Starts syncing: one cycle, the first-sync migration when due, then
  /// listening for changes. Runs after any start or stop still in progress;
  /// a second start finds it running and does nothing.
  Future<void> start() => _queued(_start);

  /// Stops sync and keeps it off, even if something calls [start], until
  /// [resume]. Delete all data holds it across the server clear and the local
  /// wipe.
  Future<void> pause() async {
    _paused = true;
    await stop();
  }

  /// Lifts [pause] and starts again; without a token [start] does nothing.
  Future<void> resume() {
    _paused = false;

    return start();
  }

  /// Whether Sync is switched on for this device.
  Future<bool> isEnabled() => _isEnabled();

  /// Applies the device's Sync switch: off stops sync in both directions.
  /// On starts it, except before the first sync: the engine stays idle and
  /// asks [firstSyncNeeded] so [AuthBloc] can run the conflict check, then
  /// start. The switch must not migrate or push.
  Future<void> applyEnabled({required bool enabled}) async {
    if (!enabled) return stop();
    if (await TokenStorage.isFirstSync()) {
      if (await TokenStorage.hasToken()) _firstSyncNeeded.add(null);

      return;
    }
    await start();
  }

  /// Runs a cycle now and reports how it went. Never runs before the
  /// first-sync conflict check, so it can't push into an account the user
  /// hasn't chosen to merge with. Starts the engine if it isn't running;
  /// joins a running cycle instead of starting another.
  Future<SyncRunResult> syncNow() async {
    if (!await TokenStorage.hasToken()) return SyncRunResult.signedOut;
    if (await TokenStorage.isFirstSync()) {
      return SyncRunResult.firstSyncPending;
    }
    if (_paused || !await _isEnabled()) return SyncRunResult.disabled;
    if (!await _connectivity.checkNow()) return SyncRunResult.offline;
    final lock = _syncLock;
    if (lock != null) {
      // The running cycle loops once more for this trigger.
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

  /// Stops syncing and waits for a running cycle or first-sync migration to
  /// reach its next checkpoint (at most one push chunk), so nothing it pulls
  /// or pushes lands after this returns: Delete all data clears the server
  /// and the database next. Never call it from inside a cycle or an
  /// after-sync task: it would wait for itself.
  Future<void> stop() {
    // At once, so a start or cycle in progress gives up at its next check.
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

    int cloudCount = 0;
    try {
      final response = await _apiClient.dio.get(ApiConstants.syncSummary);
      cloudCount = response.data['totalCount'] ?? 0;
    } catch (e, s) {
      debugPrint('Error: $e\n$s');
      debugPrint('SyncEngine: Failed to fetch cloud summary: $e');
      cloudCount = 0;
    }

    if (localCount > 0 && cloudCount > 0) return SyncConflictType.conflict;
    if (localCount > 0) return SyncConflictType.localOnly;
    if (cloudCount > 0) return SyncConflictType.cloudOnly;

    return SyncConflictType.none;
  }

  /// Saves to the server anything that exists only on this device, before
  /// local data is wiped (e.g. replacing it with the account copy).
  ///
  /// Throws when a task fails; the caller must not wipe local data then.
  Future<void> prepareForLocalWipe() async {
    for (final task in _beforeLocalWipeTasks) {
      await task();
    }
  }

  Future<void> executeDecision(SyncMode mode) async {
    switch (mode) {
      case SyncMode.localWins:
        await _apiClient.dio.delete(ApiConstants.syncClear);
        await _migrateExistingData();
        await _safePushChanges();
        break;
      case SyncMode.cloudWins:
        await _safePullChanges();
        break;
      case SyncMode.merge:
        await _migrateExistingData();
        await _safePushChanges();
        await _safePullChanges();
        break;
    }
    await TokenStorage.markFirstSyncDone();
  }

  /// Runs [operation] after the last queued start or stop.
  Future<void> _queued(Future<void> Function() operation) {
    final run = _lifecycle.then((_) => operation());
    // A failure stays with this caller; the next operation still runs.
    _lifecycle = run.catchError(
      (Object e) => debugPrint('SyncEngine: lifecycle step failed: $e'),
    );

    return run;
  }

  Future<void> _finishStop() async {
    // A start queued before this stop may have turned sync back on.
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
      } catch (e) {
        debugPrint('SyncEngine: Stop task failed: ${e.runtimeType}');
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
      // Off on this device: also keeps resume() from starting it.
      if (!await _isEnabled()) {
        debugPrint('SyncEngine: Off on this device');
        _active = false;

        return;
      }
      if (stopCount != _stopCount) return;
      await _runSyncCycle();
      if (stopCount != _stopCount) return;
      if (await TokenStorage.isFirstSync()) {
        final migration = _migrationRun = _migrateExistingData();
        await migration;
        _migrationRun = null;
      }
      if (stopCount != _stopCount) return;
      _connectivitySub = _connectivity.onlineStream.listen(
        (online) {
          unawaited(_onConnectivityChange(online));
        },
        onError: (e) {
          debugPrint('Connectivity stream error: $e');
        },
      );
      _syncEventSub = SyncEventBus().events.listen(
        (_) {
          unawaited(_onSyncEvent());
        },
        onError: (e) {
          debugPrint('SyncEventBus listener error: $e');
        },
      );
      _initialized = true;
    } catch (e, s) {
      debugPrint('Error: $e\n$s');
      debugPrint('SyncEngine start failed: $e');
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

  /// Runs a full sync cycle (pull then push) with single-flight protection.
  /// Concurrent triggers are coalesced: if a cycle is already running,
  /// exactly one more cycle will run after it completes.
  Future<void> _runSyncCycle() async {
    if (!_active) return;
    if (_syncLock != null) {
      _hasPendingTrigger = true;

      return;
    }

    _syncLock = Completer<void>();
    _isSyncing.value = true;

    try {
      // Run cycles until no more pending triggers. After-sync tasks run once
      // the queue is drained; a trigger that arrives while they run starts
      // another pull/push pass instead of being dropped.
      do {
        do {
          _hasPendingTrigger = false;
          _cycleErrored = false;
          _cycleSkippedOffline = false;
          await _safePullChanges();
          if (!_active) return;
          await _safePushChanges();
        } while (_hasPendingTrigger && _active);
        // A stopped cycle is neither a success nor a failure.
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

  /// Offline is neither a success nor a failure, so it records nothing.
  Future<void> _recordCycleOutcome() async {
    if (_cycleErrored) {
      await SyncOutcomeStore.recordSyncFailure(DateTime.now());
    } else if (!_cycleSkippedOffline) {
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
      _retryCount = 0;
    } catch (e) {
      debugPrint('SyncEngine push failed: ${e.runtimeType}');
      _cycleErrored = true;
      _scheduleRetry();
    }
  }

  Future<void> _processPushQueue(List<SyncQueueData> queue) async {
    int processed = 0;
    final total = queue.length;
    final stopCount = _stopCount;

    // A stop ends the push after the current chunk; the rest stays queued.
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
            'updatedAt': item.createdAt.toUtc().toIso8601String(),
          },
        )
        .toList();

    final response = await _apiClient.dio.post(
      ApiConstants.syncPush,
      data: {'changes': changes},
    );
    final results = response.data['results'] as List;
    final syncedIds = <int>[];

    final batchByRecordId = <String, int>{};
    for (int i = 0; i < batch.length; i++) {
      batchByRecordId[batch[i].recordId] = batch[i].id;
    }

    for (int i = 0; i < results.length; i++) {
      final result = results[i] as Map<String, dynamic>;
      final status = SyncStatus.fromString(result['status'] as String);
      if (status == SyncStatus.success || status == SyncStatus.conflict) {
        final resultId = result['id']?.toString();
        int? queueId;
        if (resultId != null) {
          queueId = batchByRecordId[resultId];
        } else if (i < batch.length) {
          queueId = batch[i].id;
        }

        if (queueId != null) {
          syncedIds.add(queueId);
        }
      }
    }
    if (syncedIds.isNotEmpty) await _syncQueueDao.markSynced(syncedIds);
  }

  Future<void> _safePullChanges() async {
    _lastPullSucceeded = false;
    try {
      if (!await _connectivity.checkNow()) {
        _cycleSkippedOffline = true;

        return;
      }
      final lastSync = await TokenStorage.getLastSyncAt();
      final response = await _apiClient.dio.get(
        ApiConstants.syncPull,
        queryParameters: {'since': lastSync ?? '1970-01-01T00:00:00.000Z'},
      );
      final serverTime = response.data['serverTime'] as String;
      final changes = response.data['changes'] as List;
      debugPrint('SyncEngine: Pulled ${changes.length} changes');
      await _db.transaction(
        () => _applyPulledChanges(changes.cast<Map<String, dynamic>>()),
      );
      await TokenStorage.saveLastSyncAt(serverTime);
      _lastPullSucceeded = true;
    } catch (e, s) {
      debugPrint('Error: $e\n$s');
      debugPrint('SyncEngine pull failed: $e');
      _cycleErrored = true;
    }
  }

  Future<void> _applyPulledChanges(List<Map<String, dynamic>> pulled) async {
    final handlers = _handlersWithIds(pulled);
    for (final MapEntry(key: handler, value: ids) in handlers.entries) {
      await handler.beforeApplyingPull(_db, ids);
    }
    try {
      for (final change in pulled) {
        await _applyRemoteChange(change);
      }
    } finally {
      for (final handler in handlers.keys) {
        await handler.afterApplyingPull();
      }
    }
  }

  /// The pulled ids per handler, for [SyncTableHandler.beforeApplyingPull].
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
      } catch (e) {
        debugPrint('SyncEngine: After-sync task failed: ${e.runtimeType}');
      }
    }
  }

  Future<void> _migrateExistingData() async {
    debugPrint('SyncEngine: Starting one-time data migration');
    try {
      final changes = await _collectAllChanges();

      if (changes.isEmpty) {
        debugPrint('SyncEngine: No data to migrate');
        await TokenStorage.markFirstSyncDone();

        return;
      }

      final allSucceeded = await _pushMigrationChunks(changes);

      if (allSucceeded) {
        debugPrint('SyncEngine: Migration complete');
        await TokenStorage.markFirstSyncDone();
      } else {
        debugPrint('SyncEngine: Migration partially failed, will retry');
      }
    } catch (e, stackTrace) {
      debugPrint('SyncEngine: Migration failed: $e\n$stackTrace');
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
      // Stopped: unfinished, so the next start migrates again.
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
      final response = await _apiClient.dio.post(
        ApiConstants.syncPush,
        data: {'changes': batch},
      );

      return _validateMigrationResults(response.data['results'] as List?);
    } catch (e) {
      debugPrint('SyncEngine: Migration chunk failed: ${e.runtimeType}');

      return false;
    }
  }

  bool _validateMigrationResults(List? results) {
    if (results == null) return true;

    var allOk = true;
    for (final result in results) {
      final status = result['status']?.toString();
      if (status != 'success' && status != 'conflict') {
        debugPrint('SyncEngine: Migration item failed: $status');
        allOk = false;
      }
    }

    return allOk;
  }

  void _scheduleRetry() {
    if (!_active) return;
    if (_retryCount >= _backoffDelays.length) {
      _retryCount = 0;

      return;
    }
    final delay = _backoffDelays[_retryCount];
    debugPrint(
      'SyncEngine: Retrying in ${delay.inSeconds}s (attempt ${_retryCount + 1})',
    );
    _retryTimer?.cancel();
    _retryTimer = Timer(delay, () {
      unawaited(_retrySync());
    });
  }

  Future<void> _retrySync() async {
    _retryCount++;
    await _runSyncCycle();
  }

  Future<void> _applyRemoteChange(Map<String, dynamic> change) async {
    final tableName = change['table']?.toString();
    final id = change['id']?.toString();
    final rawData = change['data'];

    if (tableName == null || id == null) {
      debugPrint('SyncEngine: Malformed remote change (missing table or id)');

      return;
    }

    final data = rawData is Map<String, dynamic> ? rawData : null;

    final handler = _registry[tableName];
    if (handler == null) {
      debugPrint('SyncEngine: Unknown table in remote change: $tableName');

      return;
    }

    if (data == null) {
      try {
        await handler.deleteById(_db, id);
      } catch (e) {
        debugPrint(
          'SyncEngine: Error deleting from $tableName: ${e.runtimeType}',
        );
      }

      return;
    }

    try {
      final companion = await handler.keepLocalValues(
        _db,
        id,
        handler.fromSyncPayload(id, data),
      );
      await _db.into(handler.tableRef(_db)).insertOnConflictUpdate(companion);
    } catch (e) {
      debugPrint(
        'SyncEngine: Error applying change to $tableName: ${e.runtimeType}',
      );
    }
  }
}
