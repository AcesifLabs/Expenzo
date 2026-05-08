import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../api/api_client.dart';
import '../api/api_constants.dart';
import '../api/token_storage.dart';
import '../database/daos/sync_queue_dao.dart';
import '../database/daos/record_dao.dart';
import '../database/daos/category_dao.dart';
import '../database/daos/budget_dao.dart';
import 'connectivity_service.dart';
import 'sync_event.dart';

enum SyncConflictType { none, localOnly, cloudOnly, conflict }
enum SyncMode { localWins, cloudWins, merge }

class SyncEngine {
  final ApiClient _apiClient = ApiClient();
  final ConnectivityService _connectivity = ConnectivityService();
  final SyncQueueDao _syncQueueDao;
  final RecordDao? _recordDao;
  final CategoryDao? _categoryDao;
  final BudgetDao? _budgetDao;
  StreamSubscription? _connectivitySub;
  StreamSubscription? _syncEventSub;
  bool _isSyncing = false;
  bool _initialized = false;
  void Function(double)? _onProgress;

  void Function(double)? get onProgress => _onProgress;
  set onProgress(void Function(double)? cb) => _onProgress = cb;

  SyncEngine({
    required SyncQueueDao syncQueueDao,
    RecordDao? recordDao,
    CategoryDao? categoryDao,
    BudgetDao? budgetDao,
  }) : _syncQueueDao = syncQueueDao,
       _recordDao = recordDao,
       _categoryDao = categoryDao,
       _budgetDao = budgetDao;

  Future<void> start() async {
    if (_initialized) return; _initialized = true;
    debugPrint('SyncEngine: Starting');
    final hasToken = await TokenStorage.hasToken();
    if (!hasToken) { debugPrint('SyncEngine: No JWT'); return; }
    await _safePullChanges();
    await _safePushChanges();
    if (await TokenStorage.isFirstSync()) { await _migrateExistingData(); }
    _connectivitySub = _connectivity.onlineStream.listen((online) { if (online) _safePushChanges(); });
    _syncEventSub = SyncEventBus().events.listen((_) => _safePushChanges());
  }

  Future<void> stop() async { _connectivitySub?.cancel(); _syncEventSub?.cancel(); _initialized = false; }

  static const int chunkSize = 500;

  Future<void> _safePushChanges() async {
    if (_isSyncing) return;
    _isSyncing = true;
    try {
      if (!await _connectivity.checkNow()) { _isSyncing = false; return; }
      final queue = await _syncQueueDao.getUnsynced();
      if (queue.isEmpty) { _isSyncing = false; return; }

      int processed = 0;
      final total = queue.length;
      
      while (processed < total) {
        final end = processed + chunkSize > total ? total : processed + chunkSize;
        final batch = queue.sublist(processed, end);
        debugPrint('SyncEngine: Pushing chunk ${processed ~/ chunkSize + 1} (${batch.length} items)');
        
        final changes = batch.map((item) => {
          'table': item.entityTable, 'action': item.action, 'id': item.recordId,
          'data': item.payload.isNotEmpty ? jsonDecode(item.payload) : null,
          'updatedAt': item.createdAt.toUtc().toIso8601String()
        }).toList();
        
        final response = await _apiClient.dio.post(ApiConstants.syncPush, data: {'changes': changes});
        final results = response.data['results'] as List;
        final syncedIds = <int>[];
        for (int i = 0; i < results.length; i++) {
          if (results[i]['status'] == 'success' || results[i]['status'] == 'conflict') {
            syncedIds.add(batch[i].id);
          }
        }
        if (syncedIds.isNotEmpty) await _syncQueueDao.markSynced(syncedIds);
        
        processed = end;
        _onProgress?.call(processed / total);
      }
    } catch (e) { debugPrint('SyncEngine push failed: $e'); }
    finally { _isSyncing = false; }
  }

  Future<void> _safePullChanges() async {
    try {
      if (!await _connectivity.checkNow()) return;
      final lastSync = await TokenStorage.getLastSyncAt();
      final response = await _apiClient.dio.get(ApiConstants.syncPull, queryParameters: {'since': lastSync ?? '1970-01-01T00:00:00.000Z'});
      final serverTime = response.data['serverTime'] as String;
      final changes = response.data['changes'] as List;
      debugPrint('SyncEngine: Pulled ${changes.length} changes');
      await TokenStorage.saveLastSyncAt(serverTime);
    } catch (e) { debugPrint('SyncEngine pull failed: $e'); }
  }

  Future<void> _migrateExistingData() async {
    debugPrint('SyncEngine: Starting one-time data migration');
    try {
      final changes = <Map<String, dynamic>>[];
      if (_categoryDao != null) {
        final categories = await _categoryDao!.getAllCategories();
        for (final cat in categories) {
          changes.add({'table': 'categories', 'action': 'insert', 'id': cat.id.toString(), 'data': {'id': cat.id.toString(), 'name': cat.name, 'emoji': cat.emoji, 'color': cat.color, 'isDefault': cat.isDefault, 'categoryType': cat.categoryType, 'usageCount': cat.usageCount, 'createdAt': cat.createdAt.toUtc().toIso8601String(), 'updatedAt': cat.updatedAt.toUtc().toIso8601String()}, 'updatedAt': cat.updatedAt.toUtc().toIso8601String()});
        }
      }
      if (_recordDao != null) {
        final records = await _recordDao!.getAllRecords();
        for (final r in records) {
          changes.add({'table': 'records', 'action': 'insert', 'id': r.id.toString(), 'data': {'id': r.id.toString(), 'amount': r.amount, 'description': r.description, 'date': r.date.toUtc().toIso8601String(), 'categoryId': r.categoryId?.toString(), 'source': r.source, 'recordType': r.recordType, 'createdAt': r.createdAt.toUtc().toIso8601String(), 'updatedAt': r.updatedAt.toUtc().toIso8601String()}, 'updatedAt': r.updatedAt.toUtc().toIso8601String()});
        }
      }
      if (_budgetDao != null) {
        final budgets = await _budgetDao!.getAllBudgets();
        for (final b in budgets) {
          changes.add({'table': 'budgets', 'action': 'insert', 'id': b.id, 'data': {'id': b.id, 'categoryId': b.categoryId, 'amount': b.amount, 'period': b.period, 'startDate': b.startDate.toUtc().toIso8601String(), 'rolloverEnabled': b.rolloverEnabled, 'rolloverAmount': b.rolloverAmount, 'isEnabled': b.isEnabled, 'createdAt': b.createdAt.toUtc().toIso8601String(), 'updatedAt': b.updatedAt.toUtc().toIso8601String()}, 'updatedAt': b.updatedAt.toUtc().toIso8601String()});
        }
      }
      if (changes.isEmpty) { debugPrint('SyncEngine: No data to migrate'); await TokenStorage.markFirstSyncDone(); return; }
      debugPrint('SyncEngine: Migrating ${changes.length} items');
      await _apiClient.dio.post(ApiConstants.syncPush, data: {'changes': changes});
      debugPrint('SyncEngine: Migration complete');
      await TokenStorage.markFirstSyncDone();
    } catch (e) { debugPrint('SyncEngine: Migration failed: $e'); }
  }

  Future<SyncConflictType> checkConflict() async {
    int localCount = 0;
    if (_recordDao != null) localCount += await _recordDao!.getAllRecords().then((r) => r.length);
    if (_categoryDao != null) localCount += await _categoryDao!.getAllCategories().then((r) => r.length);
    if (_budgetDao != null) localCount += await _budgetDao!.getAllBudgets().then((r) => r.length);
    
    int cloudCount = 0;
    try {
      final response = await _apiClient.dio.get('/sync/summary');
      cloudCount = response.data['totalCount'] ?? 0;
    } catch (_) { cloudCount = 0; }

    if (localCount > 0 && cloudCount > 0) return SyncConflictType.conflict;
    if (localCount > 0) return SyncConflictType.localOnly;
    if (cloudCount > 0) return SyncConflictType.cloudOnly;
    return SyncConflictType.none;
  }

  Future<void> executeDecision(SyncMode mode) async {
    switch (mode) {
      case SyncMode.localWins:
        await _apiClient.dio.delete('/sync/clear');
        await _safePushChanges();
        break;
      case SyncMode.cloudWins:
        // Database reset handled externally by caller
        await _safePullChanges();
        break;
      case SyncMode.merge:
        await _safePushChanges();
        await _safePullChanges();
        break;
    }
    await TokenStorage.markFirstSyncDone();
  }
}
