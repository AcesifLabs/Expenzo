/// Sync conflict resolution outcome.
enum SyncConflictType { none, localOnly, cloudOnly, conflict }

/// Sync strategy for conflict resolution.
enum SyncMode { localWins, cloudWins, merge }
