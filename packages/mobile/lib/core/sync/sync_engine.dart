import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../api/api_client.dart';
import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../api/api_constants.dart';
import '../api/token_storage.dart';
import '../database/daos/sync_queue_dao.dart';
import '../database/daos/record_dao.dart';
import '../database/daos/category_dao.dart';
import '../database/daos/budget_dao.dart';
import '../di/injection_container.dart' as di;
import 'connectivity_service.dart';
import 'sync_event.dart';

enum SyncConflictType { none, localOnly, cloudOnly, conflict }
enum SyncMode { localWins, cloudWins, merge }

class SyncEngine {
  AppDatabase get _db => di.getIt<AppDatabase>();
  final ApiClient _apiClient = ApiClient();
  final ConnectivityService _connectivity = ConnectivityService();
  // db accessed via getIt
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
    // db via getIt
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
    // db now accessed via getIt getter
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
      for (final change in changes) {
        await _applyRemoteChange(change as Map<String, dynamic>);
      }
      await TokenStorage.saveLastSyncAt(serverTime);
    } catch (e) { debugPrint('SyncEngine pull failed: $e'); }
  }

  Future<void> _migrateExistingData() async {
    debugPrint('SyncEngine: Starting one-time data migration');
    try {
      final changes = <Map<String, dynamic>>[];
      
      final categories = await _db.select(_db.categories).get();
      for (final cat in categories) {
        changes.add({'table': 'categories', 'action': 'insert', 'id': cat.id.toString(), 'data': {'id': cat.id.toString(), 'name': cat.name, 'emoji': cat.emoji, 'color': cat.color, 'isDefault': cat.isDefault, 'categoryType': cat.categoryType, 'usageCount': cat.usageCount, 'createdAt': cat.createdAt.toUtc().toIso8601String(), 'updatedAt': cat.updatedAt.toUtc().toIso8601String()}, 'updatedAt': cat.updatedAt.toUtc().toIso8601String()});
      }

      final records = await _db.select(_db.records).get();
      for (final r in records) {
        changes.add({'table': 'records', 'action': 'insert', 'id': r.id.toString(), 'data': {'id': r.id.toString(), 'amount': r.amount, 'description': r.description, 'date': r.date.toUtc().toIso8601String(), 'categoryId': r.categoryId?.toString(), 'source': r.source, 'recordType': r.recordType, 'createdAt': r.createdAt.toUtc().toIso8601String(), 'updatedAt': r.updatedAt.toUtc().toIso8601String()}, 'updatedAt': r.updatedAt.toUtc().toIso8601String()});
      }

      final budgets = await _db.select(_db.budgets).get();
      for (final b in budgets) {
        changes.add({'table': 'budgets', 'action': 'insert', 'id': b.id, 'data': {'id': b.id, 'categoryId': b.categoryId, 'amount': b.amount, 'period': b.period, 'startDate': b.startDate.toUtc().toIso8601String(), 'rolloverEnabled': b.rolloverEnabled, 'rolloverAmount': b.rolloverAmount, 'isEnabled': b.isEnabled, 'createdAt': b.createdAt.toUtc().toIso8601String(), 'updatedAt': b.updatedAt.toUtc().toIso8601String()}, 'updatedAt': b.updatedAt.toUtc().toIso8601String()});
      }

      final msgSources = await _db.select(_db.messageSources).get();
      for (final m in msgSources) {
        changes.add({'table': 'message_sources', 'action': 'insert', 'id': m.id, 'data': {'id': m.id, 'contactId': m.contactId, 'contactName': m.contactName, 'isMonitored': m.isMonitored, 'autoCreateOption': m.autoCreateOption, 'createdAt': m.createdAt.toUtc().toIso8601String(), 'updatedAt': m.updatedAt.toUtc().toIso8601String()}, 'updatedAt': m.updatedAt.toUtc().toIso8601String()});
      }

      final templates = await _db.select(_db.expenseTemplates).get();
      for (final t in templates) {
        changes.add({'table': 'expense_templates', 'action': 'insert', 'id': t.id, 'data': {'id': t.id, 'sourceId': t.sourceId, 'sampleMessage': t.sampleMessage, 'triggerWord': t.triggerWord, 'amountPattern': t.amountPattern, 'descriptionPattern': t.descriptionPattern, 'datePattern': t.datePattern, 'categoryId': t.categoryId, 'selectedAmount': t.selectedAmount, 'createdAt': t.createdAt.toUtc().toIso8601String(), 'updatedAt': t.updatedAt.toUtc().toIso8601String()}, 'updatedAt': t.updatedAt.toUtc().toIso8601String()});
      }

      final rules = await _db.select(_db.parsingRules).get();
      for (final r in rules) {
        changes.add({'table': 'parsing_rules', 'action': 'insert', 'id': r.id, 'data': {'id': r.id, 'name': r.name, 'triggerWords': r.triggerWords, 'amountPattern': r.amountPattern, 'datePattern': r.datePattern, 'categoryId': r.categoryId, 'sourceType': r.sourceType, 'isEnabled': r.isEnabled, 'priority': r.priority, 'createdAt': r.createdAt.toUtc().toIso8601String(), 'updatedAt': r.updatedAt.toUtc().toIso8601String()}, 'updatedAt': r.updatedAt.toUtc().toIso8601String()});
      }

      final recurrings = await _db.select(_db.recurringTransactions).get();
      for (final r in recurrings) {
        changes.add({'table': 'recurring_transactions', 'action': 'insert', 'id': r.id, 'data': {'id': r.id, 'description': r.description, 'amount': r.amount, 'categoryId': r.categoryId, 'frequency': r.frequency, 'startDate': r.startDate.toUtc().toIso8601String(), 'endDate': r.endDate?.toUtc().toIso8601String(), 'nextOccurrence': r.nextOccurrence.toUtc().toIso8601String(), 'isActive': r.isActive, 'autoCreateExpense': r.autoCreateExpense, 'dayOfMonth': r.dayOfMonth, 'createdAt': r.createdAt.toUtc().toIso8601String(), 'updatedAt': r.updatedAt.toUtc().toIso8601String()}, 'updatedAt': r.updatedAt.toUtc().toIso8601String()});
      }

      final pendings = await _db.select(_db.pendingRecurring).get();
      for (final p in pendings) {
        changes.add({'table': 'pending_recurring', 'action': 'insert', 'id': p.id.toString(), 'data': {'id': p.id.toString(), 'recurringId': p.recurringId, 'dueDate': p.dueDate.toUtc().toIso8601String(), 'amount': p.amount, 'description': p.description, 'categoryId': p.categoryId, 'createdAt': p.createdAt.toUtc().toIso8601String(), 'updatedAt': p.createdAt.toUtc().toIso8601String()}, 'updatedAt': p.createdAt.toUtc().toIso8601String()});
      }

      if (changes.isEmpty) { debugPrint('SyncEngine: No data to migrate'); await TokenStorage.markFirstSyncDone(); return; }
      debugPrint('SyncEngine: Migrating ${changes.length} items');
      await _apiClient.dio.post(ApiConstants.syncPush, data: {'changes': changes});
      debugPrint('SyncEngine: Migration complete');
      await TokenStorage.markFirstSyncDone();
    } catch (e) { debugPrint('SyncEngine: Migration failed: $e'); }
  }

  Future<void> _applyRemoteChange(Map<String, dynamic> change) async {
    final table = change['table'] as String;
    final data = change['data'] as Map<String, dynamic>?;
    final id = change['id'] as String;

    if (data == null) {
      if (table == 'records') { await (_db.delete(_db.records)..where((t) => t.id.equals(int.parse(id)))).go(); }
      else if (table == 'categories') { await (_db.delete(_db.categories)..where((t) => t.id.equals(int.parse(id)))).go(); }
      else if (table == 'budgets') { await (_db.delete(_db.budgets)..where((t) => t.id.equals(id))).go(); }
      else if (table == 'message_sources') { await (_db.delete(_db.messageSources)..where((t) => t.id.equals(id))).go(); }
      else if (table == 'expense_templates') { await (_db.delete(_db.expenseTemplates)..where((t) => t.id.equals(id))).go(); }
      else if (table == 'parsing_rules') { await (_db.delete(_db.parsingRules)..where((t) => t.id.equals(id))).go(); }
      else if (table == 'recurring_transactions') { await (_db.delete(_db.recurringTransactions)..where((t) => t.id.equals(id))).go(); }
      else if (table == 'pending_recurring') { await (_db.delete(_db.pendingRecurring)..where((t) => t.id.equals(int.parse(id)))).go(); }
      return;
    }

    try {
      if (table == 'records') {
        await _db.into(_db.records).insertOnConflictUpdate(RecordsCompanion.insert(
          id: Value(int.parse(id)), amount: double.parse(data['amount'].toString()), description: data['description'] ?? '',
          date: DateTime.parse(data['date']).toLocal(), categoryId: data['categoryId'] != null ? Value(int.parse(data['categoryId'])) : const Value.absent(),
          source: Value(data['source'] ?? 'manual'), sourceId: data['sourceId'] != null ? Value(data['sourceId']) : const Value.absent(),
          recordType: data['recordType'] ?? 'OUT', createdAt: data['createdAt'] != null ? Value(DateTime.parse(data['createdAt']).toLocal()) : const Value.absent(), updatedAt: data['updatedAt'] != null ? Value(DateTime.parse(data['updatedAt']).toLocal()) : const Value.absent(),
        ));
      } else if (table == 'categories') {
        await _db.into(_db.categories).insertOnConflictUpdate(CategoriesCompanion.insert(
          id: Value(int.parse(id)), name: data['name'] ?? 'Category', emoji: data['emoji'] != null ? Value(data['emoji']) : const Value.absent(),
          color: data['color'] != null ? Value(data['color']) : const Value.absent(), isDefault: data['isDefault'] != null ? Value(data['isDefault']) : const Value.absent(),
          categoryType: data['categoryType'] != null ? Value(data['categoryType']) : const Value.absent(), usageCount: data['usageCount'] != null ? Value(int.parse(data['usageCount'].toString())) : const Value.absent(),
          createdAt: data['createdAt'] != null ? Value(DateTime.parse(data['createdAt']).toLocal()) : const Value.absent(), updatedAt: data['updatedAt'] != null ? Value(DateTime.parse(data['updatedAt']).toLocal()) : const Value.absent(),
        ));
      } else if (table == 'budgets') {
        await _db.into(_db.budgets).insertOnConflictUpdate(BudgetsCompanion.insert(
          id: id, categoryId: data['categoryId'] != null ? Value(data['categoryId']) : const Value.absent(), amount: double.parse(data['amount'].toString()),
          period: data['period'] ?? 'monthly', startDate: DateTime.parse(data['startDate']).toLocal(), rolloverEnabled: data['rolloverEnabled'] != null ? Value(data['rolloverEnabled']) : const Value.absent(),
          rolloverAmount: data['rolloverAmount'] != null ? Value(double.parse(data['rolloverAmount'].toString())) : const Value.absent(), isEnabled: data['isEnabled'] != null ? Value(data['isEnabled']) : const Value.absent(),
          createdAt: data['createdAt'] != null ? Value(DateTime.parse(data['createdAt']).toLocal()) : const Value.absent(), updatedAt: data['updatedAt'] != null ? Value(DateTime.parse(data['updatedAt']).toLocal()) : const Value.absent(),
        ));
      } else if (table == 'message_sources') {
        await _db.into(_db.messageSources).insertOnConflictUpdate(MessageSourcesCompanion.insert(
          id: id, contactId: data['contactId'] ?? '', contactName: data['contactName'] ?? '', isMonitored: data['isMonitored'] != null ? Value(data['isMonitored']) : const Value.absent(),
          autoCreateOption: data['autoCreateOption'] != null ? Value(int.parse(data['autoCreateOption'].toString())) : const Value.absent(),
          createdAt: data['createdAt'] != null ? DateTime.parse(data['createdAt']).toLocal() : DateTime.now(), updatedAt: data['updatedAt'] != null ? DateTime.parse(data['updatedAt']).toLocal() : DateTime.now(),
        ));
      } else if (table == 'expense_templates') {
        await _db.into(_db.expenseTemplates).insertOnConflictUpdate(ExpenseTemplatesCompanion.insert(
          id: id, sourceId: data['sourceId'] ?? '', sampleMessage: data['sampleMessage'] ?? '', triggerWord: data['triggerWord'] ?? '', amountPattern: data['amountPattern'] ?? '',
          descriptionPattern: data['descriptionPattern'] != null ? Value(data['descriptionPattern']) : const Value.absent(), datePattern: data['datePattern'] != null ? Value(data['datePattern']) : const Value.absent(),
          categoryId: data['categoryId'] != null ? Value(data['categoryId']) : const Value.absent(), selectedAmount: data['selectedAmount'] != null ? Value(data['selectedAmount']) : const Value.absent(),
          createdAt: data['createdAt'] != null ? DateTime.parse(data['createdAt']).toLocal() : DateTime.now(), updatedAt: data['updatedAt'] != null ? DateTime.parse(data['updatedAt']).toLocal() : DateTime.now(),
        ));
      } else if (table == 'parsing_rules') {
        await _db.into(_db.parsingRules).insertOnConflictUpdate(ParsingRulesCompanion.insert(
          id: id, name: data['name'] ?? '', triggerWords: data['triggerWords'] ?? '', amountPattern: data['amountPattern'] ?? '', datePattern: data['datePattern'] != null ? Value(data['datePattern']) : const Value.absent(),
          categoryId: data['categoryId'] != null ? Value(data['categoryId']) : const Value.absent(), sourceType: data['sourceType'] ?? 'sms', isEnabled: data['isEnabled'] != null ? Value(data['isEnabled']) : const Value.absent(),
          priority: data['priority'] != null ? Value(int.parse(data['priority'].toString())) : const Value.absent(),
          createdAt: data['createdAt'] != null ? DateTime.parse(data['createdAt']).toLocal() : DateTime.now(), updatedAt: data['updatedAt'] != null ? DateTime.parse(data['updatedAt']).toLocal() : DateTime.now(),
        ));
      } else if (table == 'recurring_transactions') {
        await _db.into(_db.recurringTransactions).insertOnConflictUpdate(RecurringTransactionsCompanion.insert(
          id: id, description: data['description'] ?? '', amount: double.parse(data['amount'].toString()), categoryId: data['categoryId'] != null ? Value(data['categoryId']) : const Value.absent(),
          frequency: data['frequency'] ?? 'monthly', startDate: DateTime.parse(data['startDate']).toLocal(), endDate: data['endDate'] != null ? Value(DateTime.parse(data['endDate']).toLocal()) : const Value.absent(),
          nextOccurrence: DateTime.parse(data['nextOccurrence']).toLocal(), isActive: data['isActive'] != null ? Value(data['isActive']) : const Value.absent(), autoCreateExpense: data['autoCreateExpense'] != null ? Value(data['autoCreateExpense']) : const Value.absent(),
          dayOfMonth: data['dayOfMonth'] != null ? Value(int.parse(data['dayOfMonth'].toString())) : const Value.absent(),
          createdAt: data['createdAt'] != null ? Value(DateTime.parse(data['createdAt']).toLocal()) : const Value.absent(), updatedAt: data['updatedAt'] != null ? Value(DateTime.parse(data['updatedAt']).toLocal()) : const Value.absent(),
        ));
      } else if (table == 'pending_recurring') {
        await _db.into(_db.pendingRecurring).insertOnConflictUpdate(PendingRecurringCompanion.insert(
          id: Value(int.parse(id)), recurringId: data['recurringId'] ?? '', dueDate: DateTime.parse(data['dueDate']).toLocal(), amount: double.parse(data['amount'].toString()),
          description: data['description'] ?? '', categoryId: data['categoryId'] != null ? Value(data['categoryId']) : const Value.absent(),
          createdAt: data['createdAt'] != null ? Value(DateTime.parse(data['createdAt']).toLocal()) : const Value.absent(),
        ));
      }
    } catch (e) {
      debugPrint('Error applying remote change to $table: $e');
    }
  }

  Future<SyncConflictType> checkConflict() async {
    int localCount = 0;
    localCount += await _db.select(_db.records).get().then((r) => r.length);
    localCount += await _db.select(_db.budgets).get().then((r) => r.length);
    localCount += await _db.select(_db.messageSources).get().then((r) => r.length);
    localCount += await _db.select(_db.expenseTemplates).get().then((r) => r.length);
    localCount += await _db.select(_db.parsingRules).get().then((r) => r.length);
    localCount += await _db.select(_db.recurringTransactions).get().then((r) => r.length);
    
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
