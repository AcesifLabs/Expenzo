/// Dart mirror of the backend's SyncStatus enum from sync.types.ts.
/// Used in the sync engine to parse status strings from the server.
enum SyncStatus {
  success,
  conflict,
  error;

  /// Parse a string into a SyncStatus.
  /// Returns [SyncStatus.error] if the string is not recognized.
  static SyncStatus fromString(String value) {
    return SyncStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => SyncStatus.error,
    );
  }
}
