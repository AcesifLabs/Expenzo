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
import 'sync_status.dart';
import 'sync_table_registry.dart';

export 'sync_mode.dart';

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
  StreamSubscription? _connectivitySub;
  StreamSubscription? _syncEventSub;
  bool _initialized = false;
  int _retryCount = 0;
  Timer? _retryTimer;

  /// Single-flight lock for sync operations.
  /// When non-null, a sync cycle is in progress. Concurrent triggers
  /// are coalesced: exactly one more cycle will run after the current completes.
  Completer<void>? _syncLock;
  bool _hasPendingTrigger = false;

  AppDatabase get _db => di.getIt<AppDatabase>();

  SyncEngine({
    required SyncQueueDao syncQueueDao,
    required ApiClient apiClient,
    required ConnectivityService connectivity,
    required SyncTableRegistry registry,
  }) : _syncQueueDao = syncQueueDao,
       _apiClient = apiClient,
       _connectivity = connectivity,
       _registry = registry;

  Future<void> start() async {
    if (_initialized) return;
    await _connectivitySub?.cancel();
    await _syncEventSub?.cancel();
    debugPrint('SyncEngine: Starting');
    try {
      final hasToken = await TokenStorage.hasToken();
      if (!hasToken) {
        debugPrint('SyncEngine: No JWT');

        return;
      }
      await _runSyncCycle();
      if (await TokenStorage.isFirstSync()) {
        await _migrateExistingData();
      }
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

  Future<void> stop() async {
    _retryTimer?.cancel();
    _retryTimer = null;
    _retryCount = 0;
    await _connectivitySub?.cancel();
    _connectivitySub = null;
    await _syncEventSub?.cancel();
    _syncEventSub = null;
    _initialized = false;
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
    // If a cycle is already in progress, mark a pending trigger and return
    if (_syncLock != null) {
      _hasPendingTrigger = true;

      return;
    }

    // Acquire the lock
    _syncLock = Completer<void>();

    try {
      // Run cycles until no more pending triggers
      do {
        _hasPendingTrigger = false;
        await _safePullChanges();
        await _safePushChanges();
      } while (_hasPendingTrigger);
    } finally {
      // Release the lock
      _syncLock!.complete();
      _syncLock = null;
    }
  }

  Future<void> _safePushChanges() async {
    try {
      if (!await _connectivity.checkNow()) return;
      final queue = await _syncQueueDao.getUnsynced();
      if (queue.isEmpty) return;

      await _processPushQueue(queue);
      _retryCount = 0;
    } catch (e) {
      debugPrint('SyncEngine push failed: ${e.runtimeType}');
      _scheduleRetry();
    }
  }

  Future<void> _processPushQueue(List<SyncQueueData> queue) async {
    int processed = 0;
    final total = queue.length;

    while (processed < total) {
      final end = processed + chunkSize > total ? total : processed + chunkSize;
      final batch = queue.sublist(processed, end);
      debugPrint(
        'SyncEngine: Pushing chunk ${processed ~/ chunkSize + 1} (${batch.length} items)',
      );

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

      // Build a lookup map for id-based correlation if server echoes identifiers
      final batchByRecordId = <String, int>{};
      for (int i = 0; i < batch.length; i++) {
        batchByRecordId[batch[i].recordId] = batch[i].id;
      }

      for (int i = 0; i < results.length; i++) {
        final result = results[i] as Map<String, dynamic>;
        final status = SyncStatus.fromString(result['status'] as String);
        if (status == SyncStatus.success || status == SyncStatus.conflict) {
          // Try id-based correlation first, fall back to positional
          final resultId = result['id']?.toString();
          final queueId = resultId != null
              ? batchByRecordId[resultId]
              : (i < batch.length ? batch[i].id : null);

          if (queueId != null) {
            syncedIds.add(queueId);
          }
        }
      }
      if (syncedIds.isNotEmpty) await _syncQueueDao.markSynced(syncedIds);

      processed = end;
      onProgress?.call(processed / total);
    }
  }

  Future<void> _safePullChanges() async {
    try {
      if (!await _connectivity.checkNow()) return;
      final lastSync = await TokenStorage.getLastSyncAt();
      final response = await _apiClient.dio.get(
        ApiConstants.syncPull,
        queryParameters: {'since': lastSync ?? '1970-01-01T00:00:00.000Z'},
      );
      final serverTime = response.data['serverTime'] as String;
      final changes = response.data['changes'] as List;
      debugPrint('SyncEngine: Pulled ${changes.length} changes');
      await _db.transaction(() async {
        for (final change in changes) {
          await _applyRemoteChange(change as Map<String, dynamic>);
        }
      });
      await TokenStorage.saveLastSyncAt(serverTime);
    } catch (e, s) {
      debugPrint('Error: $e\n$s');
      debugPrint('SyncEngine pull failed: $e');
    }
  }

  Future<void> _migrateExistingData() async {
    debugPrint('SyncEngine: Starting one-time data migration');
    try {
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

      if (changes.isEmpty) {
        debugPrint('SyncEngine: No data to migrate');
        await TokenStorage.markFirstSyncDone();

        return;
      }

      var allSucceeded = true;
      for (var i = 0; i < changes.length; i += chunkSize) {
        final end = i + chunkSize > changes.length
            ? changes.length
            : i + chunkSize;
        final batch = changes.sublist(i, end);
        debugPrint(
          'SyncEngine: Migrating chunk ${i ~/ chunkSize + 1} (${batch.length} items)',
        );

        try {
          final response = await _apiClient.dio.post(
            ApiConstants.syncPush,
            data: {'changes': batch},
          );

          // Validate response: check for errors in results
          final results = response.data['results'] as List?;
          if (results != null) {
            for (final result in results) {
              final status = result['status']?.toString();
              if (status != 'success' && status != 'conflict') {
                debugPrint('SyncEngine: Migration item failed: $status');
                allSucceeded = false;
              }
            }
          }
        } catch (e) {
          debugPrint('SyncEngine: Migration chunk failed: ${e.runtimeType}');
          allSucceeded = false;
        }

        onProgress?.call(end / changes.length);
      }

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

  void _scheduleRetry() {
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
      final companion = handler.fromSyncPayload(id, data);
      await _db.into(handler.tableRef(_db)).insertOnConflictUpdate(companion);
    } catch (e) {
      debugPrint(
        'SyncEngine: Error applying change to $tableName: ${e.runtimeType}',
      );
    }
  }
}
