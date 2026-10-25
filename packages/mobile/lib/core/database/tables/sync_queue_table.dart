import 'package:drift/drift.dart';

// The pending-changes queries (push, the unsynced count) read only these.
@TableIndex.sql(
  'CREATE INDEX idx_sync_queue_pending ON sync_queue (created_at) '
  'WHERE synced_at IS NULL AND failed_at IS NULL',
)
// The Failed Sync Change count on the Sync screen.
@TableIndex.sql(
  'CREATE INDEX idx_sync_queue_failed ON sync_queue (created_at) '
  'WHERE failed_at IS NOT NULL AND synced_at IS NULL',
)
// Retrying Failed Sync Changes looks up newer changes of the same row.
@TableIndex.sql(
  'CREATE INDEX idx_sync_queue_record ON sync_queue '
  '(entity_table, record_id, id)',
)
class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entityTable => text()();
  TextColumn get recordId => text()();
  TextColumn get action => text()();
  TextColumn get payload => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  /// Pushes the server rejected. At 5 the change becomes a Failed Sync
  /// Change ([failedAt] set) and is no longer retried on its own.
  IntColumn get attemptCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get failedAt => dateTime().nullable()();
}
