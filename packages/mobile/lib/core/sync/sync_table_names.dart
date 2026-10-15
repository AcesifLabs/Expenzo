/// Sync table names other code looks up before the table's own handler
/// exists. The handler's `tableName` must return the same constant.
abstract final class SyncTableNames {
  /// Goals (SAAP-74). Delete all data shows its row once a handler with
  /// this name is registered.
  static const goals = 'goals';
}
