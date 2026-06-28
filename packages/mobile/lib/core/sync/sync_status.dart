enum SyncStatus {
  success,
  conflict,
  error;

  static SyncStatus fromString(String value) {
    return SyncStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => SyncStatus.error,
    );
  }
}
