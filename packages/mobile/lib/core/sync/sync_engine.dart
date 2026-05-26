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
import 'sync_table_registry.dart';

enum SyncConflictType { none, localOnly, cloudOnly, conflict }

enum SyncMode { localWins, cloudWins, merge }

class SyncEngine {
  AppDatabase get _db => di.getIt<AppDatabase>();
  final ApiClient _apiClient;
  final ConnectivityService _connectivity;
  final SyncQueueDao _syncQueueDao;
  final SyncTableRegistry _registry;
  StreamSubscription? _connectivitySub;
  StreamSubscription? _syncEventSub;
  bool _isSyncing = false;
  bool _initialized = false;
  int _retryCount = 0;
  Timer? _retryTimer;
  void Function(double)? onProgress;

  static const List<Duration> _backoffDelays = [
    Duration(seconds: 5),
    Duration(seconds: 15),
    Duration(seconds: 45),
    Duration(minutes: 2),
    Duration(minutes: 5),
  ];

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
      await _safePullChanges();
      await _safePushChanges();
      if (await TokenStorage.isFirstSync()) {
        await _migrateExistingData();
      }
      _connectivitySub = _connectivity.onlineStream.listen(
        (online) async {
          if (online) {
            await _safePullChanges();
            await _safePushChanges();
          }
        },
        onError: (e) {
          debugPrint('Connectivity stream error: $e');
          _isSyncing = false;
        },
      );
      _syncEventSub = SyncEventBus().events.listen(
        (_) async {
          final online = await _connectivity.checkNow();
          if (online) {
            await _safePullChanges();
            await _safePushChanges();
          }
        },
        onError: (e) {
          debugPrint('SyncEventBus listener error: $e');
          _isSyncing = false;
        },
      );
      _initialized = true;
    } catch (e) {
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

  static const int chunkSize = 500;

  Future<void> _safePushChanges() async {
    if (_isSyncing) return;
    _isSyncing = true;
    try {
      if (!await _connectivity.checkNow()) {
        _isSyncing = false;
        return;
      }
      final queue = await _syncQueueDao.getUnsynced();
      if (queue.isEmpty) {
        _isSyncing = false;
        return;
      }

      int processed = 0;
      final total = queue.length;

      while (processed < total) {
        final end = processed + chunkSize > total
            ? total
            : processed + chunkSize;
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
                'data': item.payload.isNotEmpty
                    ? jsonDecode(item.payload)
                    : null,
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
        for (int i = 0; i < results.length; i++) {
          if (results[i]['status'] == 'success' ||
              results[i]['status'] == 'conflict') {
            syncedIds.add(batch[i].id);
          }
        }
        if (syncedIds.isNotEmpty) await _syncQueueDao.markSynced(syncedIds);

        processed = end;
        onProgress?.call(processed / total);
      }
      _retryCount = 0; // reset backoff on success
    } catch (e) {
      debugPrint('SyncEngine push failed: $e');
      _scheduleRetry();
    } finally {
      _isSyncing = false;
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
    } catch (e) {
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

      for (var i = 0; i < changes.length; i += chunkSize) {
        final end = i + chunkSize > changes.length
            ? changes.length
            : i + chunkSize;
        final batch = changes.sublist(i, end);
        debugPrint(
          'SyncEngine: Migrating chunk ${i ~/ chunkSize + 1} (${batch.length} items)',
        );
        await _apiClient.dio.post(
          ApiConstants.syncPush,
          data: {'changes': batch},
        );
        onProgress?.call(end / changes.length);
      }

      debugPrint('SyncEngine: Migration complete');
      await TokenStorage.markFirstSyncDone();
    } catch (e, stackTrace) {
      debugPrint('SyncEngine: Migration failed: $e\n$stackTrace');
    }
  }

  Future<void> _applyRemoteChange(Map<String, dynamic> change) async {
    final tableName = change['table'] as String;
    final data = change['data'] as Map<String, dynamic>?;
    final id = change['id'] as String;

    final handler = _registry[tableName];
    if (handler == null) {
      debugPrint('SyncEngine: Unknown table in remote change: $tableName');
      return;
    }

    if (data == null) {
      try {
        await handler.deleteById(_db, id);
      } catch (e) {
        debugPrint('Error deleting remote change from $tableName: $e');
      }
      return;
    }

    try {
      final companion = handler.fromSyncPayload(id, data);
      await _db.into(handler.tableRef(_db)).insertOnConflictUpdate(companion);
    } catch (e) {
      debugPrint('Error applying remote change to $tableName: $e');
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
    _retryTimer = Timer(delay, () async {
      _retryCount++;
      await _safePullChanges();
      await _safePushChanges();
    });
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
    } catch (e) {
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
}
