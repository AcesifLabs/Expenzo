import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/sync_queue_table.dart';

part 'sync_queue_dao.g.dart';

@DriftAccessor(tables: [SyncQueue])
class SyncQueueDao extends DatabaseAccessor<AppDatabase>
    with _$SyncQueueDaoMixin {
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
        createdAt: DateTime.now().toUtc(),
      ),
    );
  }

  Future<List<SyncQueueData>> getUnsynced() {
    return (select(syncQueue)
          ..where((t) => t.syncedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  Future<void> markSynced(List<int> ids) async {
    final now = DateTime.now().toUtc();
    for (final id in ids) {
      await (update(syncQueue)..where((t) => t.id.equals(id))).write(
        SyncQueueCompanion(syncedAt: Value(now)),
      );
    }
  }

  Future<int> getUnsyncedCount() async {
    final c = countAll();
    final query = selectOnly(syncQueue)
      ..addColumns([c])
      ..where(syncQueue.syncedAt.isNull());
    return (await query.getSingle()).read(c) ?? 0;
  }
}
