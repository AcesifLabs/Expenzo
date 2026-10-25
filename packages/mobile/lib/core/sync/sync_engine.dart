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

/// A unit of work the engine runs around syncing, e.g. a one-time repair.
typedef SyncTask = Future<void> Function();

class SyncEngine {
  void Function(double)? onProgress;

  static const int chunkSize = 500;

  /// Waits between retries of a failed cycle. After the last one the
  /// engine keeps retrying hourly instead of giving up.
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

  /// Consecutive pulls in which each row ("table/id") failed to apply. A row
  /// holds the pull cursor back until it applies or reaches
  /// [_maxPullAttempts], so one broken row can't stall every later pull.
  final Map<String, int> _pullFailures = {};
  static const _maxPullAttempts = 5;

  /// The pull cursor before the first pull: everything.
  static const _epochCursor = '1970-01-01T00:00:00.000Z';

  /// How far the server's clock is ahead of this phone's, from the last
  /// pull. Push times are moved by it: the server keeps the newer of two
  /// edits by time, and a phone clock set days wrong would otherwise lose
  /// its newer edits or override others' (docs/qa-backlog.md).
  Duration _clockSkew = Duration.zero;

  /// Pulled rows ("table/id") not applied because this device has an edit
  /// of them waiting to be pushed. The push decides: if the server answers
  /// that its copy is newer (a conflict), the held row is applied then.
  /// Memory only: a held row also holds the pull cursor back, so after a
  /// restart the next pull fetches it again.
  final Map<String, Map<String, dynamic>> _heldPulls = {};

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
  Future<bool>? _migrationRun;

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

  @visibleForTesting
  bool get hasPendingRetry => _retryTimer?.isActive ?? false;

  /// The wait before the retry last scheduled.
  @visibleForTesting
  Duration? get scheduledRetryDelay => _scheduledRetryDelay;

  /// Fires when Sync is switched on before the first sync ran (signed in
  /// with Sync off). `AuthBloc` then runs its first-sync conflict check,
  /// which starts sync.
  Stream<void> get firstSyncNeeded => _firstSyncNeeded.stream;

  AppDatabase get _db => di.getIt<AppDatabase>();

  // Optional: tests leave the Sync switch out (always on).
  // ignore: unnecessary-nullable
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

  /// Runs the scheduled retry now instead of after its wait.
  @visibleForTesting
  Future<void> runScheduledRetry() {
    _retryTimer?.cancel();

    return _retrySync();
  }

  /// Runs a cycle now and reports how it went. Never runs before the
  /// first-sync conflict check, so it can't push into an account the user
  /// hasn't chosen to merge with. Starts the engine if it isn't running;
  /// joins a running cycle instead of starting another.
  Future<SyncRunResult> syncNow() async {
    if (!await TokenStorage.hasToken()) return SyncRunResult.signedOut;
    if (!await _firstSyncDone()) return SyncRunResult.firstSyncPending;
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

    // A failure throws: reading it as an empty account would skip the
    // merge choice and push this phone's data into it.
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

  /// Saves to the server anything that exists only on this device, before
  /// local data is wiped (e.g. replacing it with the account copy).
  ///
  /// Throws when a task fails; the caller must not wipe local data then.
  Future<void> prepareForLocalWipe() async {
    for (final task in _beforeLocalWipeTasks) {
      await task();
    }
  }

  /// Throws when part of this device's data didn't upload; the first sync
  /// stays pending so the user can make the choice again.
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
      // Off on this device: also keeps resume() from starting it.
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
      // Also when nothing was pushed: the next failure starts the backoff
      // from its shortest wait again.
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

      // The backoff resets in _recordCycleOutcome, once the whole cycle
      // (pull too) has worked.
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
          // The server kept its copy (see _applyHeldPullsThatLost).
          appLogger.info('SyncEngine: Push conflict on ${result['id']}');
          syncedIds.addAll(queueIds);
        case SyncStatus.error:
          rejectedIds.addAll(queueIds);
      }
    }
    await _syncQueueDao.markSynced(syncedIds);
    await _syncQueueDao.recordRejected(rejectedIds);
  }

  /// Pairs each push result with the queue entries it answers. The server
  /// answers in order, one result per change; otherwise results are matched
  /// by record id, to every queued change of that record.
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

  /// Applies the held pulled copy of each row whose push came back as a
  /// conflict: the server kept its newer version, so this device takes it.
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

  /// [response]'s JSON object; anything else is a format error, handled
  /// like any other failed request.
  static Map<String, Object?> _json(Response<Object?> response) {
    final data = response.data;
    if (data is Map<String, Object?>) return data;

    throw FormatException('Expected a JSON object, got ${data.runtimeType}');
  }

  void _measureClockSkew(String serverTime) {
    final server = DateTime.tryParse(serverTime);
    if (server != null) _clockSkew = server.difference(clock.now());
  }

  /// The changes to pull again: rows that failed to apply, and rows held
  /// back for a local edit that hasn't been pushed yet.
  Future<List<Map<String, dynamic>>> _applyPulledChanges(
    List<Map<String, dynamic>> pulled,
  ) async {
    final handlers = _handlersWithIds(pulled);
    for (final MapEntry(key: handler, value: ids) in handlers.entries) {
      await handler.beforeApplyingPull(_db, ids);
    }
    final waitingToPush = await _syncQueueDao.pendingKeys();
    // Kept until the push settles, even once the row stops being pulled again.
    _heldPulls.removeWhere((key, _) => !waitingToPush.contains(key));
    final failed = <Map<String, dynamic>>[];
    try {
      for (final change in pulled) {
        final key = '${change['table']}/${change['id']}';
        if (waitingToPush.contains(key)) {
          // Pulled again until its push is settled, so the server copy is
          // still at hand if that push turns out to lose.
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

  /// Whether the row [key] should be pulled again, counting this pull. After
  /// [_maxPullAttempts] pulls it stops holding the cursor back, so one row
  /// can't make every pull download the same changes again.
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

  /// Where the next pull starts. The server sends rows changed after the
  /// cursor, so it stops just before the earliest row to pull again, and
  /// that row comes back. A row without a readable time can't be asked for
  /// by time, so it doesn't move the cursor.
  ///
  /// Rows changed after that one come back too and are applied again. That
  /// costs bandwidth, not correctness, and [_maxPullAttempts] bounds it; a
  /// pull by id would avoid it but needs a server endpoint
  /// (docs/qa-backlog.md).
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
      } catch (e, s) {
        appLogger.error('SyncEngine: After-sync task failed', e, s);
      }
    }
  }

  /// Whether the first sync is done, finishing it first if this engine
  /// already passed the conflict check but its upload partly failed.
  Future<bool> _firstSyncDone() async {
    if (!await TokenStorage.isFirstSync()) return true;
    // A stopped engine means the conflict check never passed (it may have
    // failed offline): ask AuthBloc to run it again. A running one already
    // passed it and is uploading this phone's data; asking again would show
    // that data as a conflict with itself.
    if (!_active && _migrationRun == null) _firstSyncNeeded.add(null);
    if (!_initialized || !_active) return false;

    return _migrateOnce();
  }

  /// Runs the first-sync upload, or joins the one already running. True
  /// once every row is uploaded.
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

  /// False when the change should be pulled again. Malformed changes and
  /// unknown tables return true: pulling them again can't fix them.
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
      // Table and id only: the payload is the user's data.
      appLogger.error('SyncEngine: Could not apply $tableName/$id', e, s);

      return false;
    }
  }
}
