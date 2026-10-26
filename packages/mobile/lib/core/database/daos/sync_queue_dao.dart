import 'package:clock/clock.dart';
import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/sync_queue_table.dart';

part 'sync_queue_dao.g.dart';

@DriftAccessor(tables: [SyncQueue])
class SyncQueueDao extends DatabaseAccessor<AppDatabase>
    with _$SyncQueueDaoMixin {
  static const maxAttempts = 5;

  static const keepSent = Duration(days: 30);

  SyncQueueDao(super.db);

  Future<void> enqueue({
    required String tableName,
    required String recordId,
    required String action,
    required String payload,
  }) async {
    await into(syncQueue).insert(
      SyncQueueCompanion.insert(
        entityTable: tableName,
        recordId: recordId,
        action: action,
        payload: payload,
        createdAt: Value(clock.now().toUtc()),
      ),
    );
  }

  Future<void> enqueueAll(
    List<({String tableName, String recordId, String action, String payload})>
    changes,
  ) {
    final createdAt = Value(clock.now().toUtc());

    return batch(
      (b) => b.insertAll(syncQueue, [
        for (final change in changes)
          SyncQueueCompanion.insert(
            entityTable: change.tableName,
            recordId: change.recordId,
            action: change.action,
            payload: change.payload,
            createdAt: createdAt,
          ),
      ]),
    );
  }

  Future<List<SyncQueueData>> getUnsynced() {
    return (select(syncQueue)
          ..where((t) => t.syncedAt.isNull() & t.failedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  Future<int> deleteSentBefore(DateTime now) =>
      (delete(syncQueue)..where(
            (t) =>
                t.syncedAt.isSmallerThanValue(now.toUtc().subtract(keepSent)),
          ))
          .go();

  Future<Set<String>> pendingKeys() async {
    final rows =
        await (selectOnly(syncQueue, distinct: true)
              ..addColumns([syncQueue.entityTable, syncQueue.recordId])
              ..where(
                syncQueue.syncedAt.isNull() & syncQueue.failedAt.isNull(),
              ))
            .get();

    return {
      for (final row in rows)
        '${row.read(syncQueue.entityTable)}/${row.read(syncQueue.recordId)}',
    };
  }

  Future<void> recordRejected(List<int> ids) async {
    if (ids.isEmpty) return;
    await customUpdate(
      'UPDATE sync_queue SET attempt_count = attempt_count + 1, '
      'failed_at = CASE WHEN attempt_count + 1 >= ? THEN ? ELSE failed_at END '
      'WHERE id IN (${List.filled(ids.length, '?').join(', ')})',
      variables: [
        Variable.withInt(maxAttempts),
        Variable.withDateTime(clock.now().toUtc()),
        for (final id in ids) Variable.withInt(id),
      ],
      updates: {syncQueue},
    );
  }

  Stream<int> watchFailedCount() {
    final c = countAll();

    return (selectOnly(syncQueue)
          ..addColumns([c])
          ..where(syncQueue.syncedAt.isNull() & syncQueue.failedAt.isNotNull()))
        .watchSingle()
        .map((row) => row.read(c) ?? 0);
  }

  Future<void> retryFailed() => transaction(() async {
    await customUpdate(
      'DELETE FROM sync_queue AS failed '
      'WHERE failed.failed_at IS NOT NULL AND failed.synced_at IS NULL '
      'AND EXISTS (SELECT 1 FROM sync_queue AS newer '
      'WHERE newer.entity_table = failed.entity_table '
      'AND newer.record_id = failed.record_id AND newer.id > failed.id '
      "AND (newer.action = 'delete' OR (newer.payload <> '' "
      "AND failed.action <> 'insert')))",
      updates: {syncQueue},
      updateKind: UpdateKind.delete,
    );
    await (update(
      syncQueue,
    )..where((t) => t.failedAt.isNotNull() & t.syncedAt.isNull())).write(
      const SyncQueueCompanion(attemptCount: Value(0), failedAt: Value(null)),
    );
  });

  Future<Set<String>> pendingRecordIds(String table) async {
    final rows =
        await (selectOnly(syncQueue, distinct: true)
              ..addColumns([syncQueue.recordId])
              ..where(
                syncQueue.entityTable.equals(table) &
                    syncQueue.syncedAt.isNull(),
              ))
            .get();

    return {for (final row in rows) ?row.read(syncQueue.recordId)};
  }

  Future<void> markSynced(List<int> ids) async {
    if (ids.isEmpty) return;
    final now = clock.now().toUtc();
    await (update(syncQueue)..where((t) => t.id.isIn(ids))).write(
      SyncQueueCompanion(syncedAt: Value(now)),
    );
  }

  Future<int> getUnsyncedCount() async {
    final c = countAll();

    return (await _unsyncedCountQuery(c).getSingle()).read(c) ?? 0;
  }

  Stream<int> watchUnsyncedCount() {
    final c = countAll();

    return _unsyncedCountQuery(c).watchSingle().map((row) => row.read(c) ?? 0);
  }

  JoinedSelectStatement<HasResultSet, dynamic> _unsyncedCountQuery(
    Expression<int> c,
  ) {
    return selectOnly(syncQueue)
      ..addColumns([c])
      ..where(syncQueue.syncedAt.isNull() & syncQueue.failedAt.isNull());
  }
}
