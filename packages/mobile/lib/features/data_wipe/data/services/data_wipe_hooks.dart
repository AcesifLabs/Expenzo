/// The app-wide side effects of a delete, as functions so the repository can
/// be tested without the sync engine, secure storage or plugins.
class DataWipeHooks {
  /// Stops sync and keeps it off until [resumeSync], waiting for a running
  /// cycle.
  final Future<void> Function() pauseSync;
  final Future<void> Function() resumeSync;

  /// Forgets the sync cursor, so the next start pushes this device's data.
  final Future<void> Function() resetSyncState;

  /// Cancels local notifications and background tasks.
  final Future<void> Function() cancelScheduledWork;

  /// `LocalDataPrefs.clear`: repair flags and sent-alert logs.
  final Future<void> Function() clearLocalPrefs;
  final Future<bool> Function() isSignedIn;

  const DataWipeHooks({
    required this.pauseSync,
    required this.resumeSync,
    required this.resetSyncState,
    required this.cancelScheduledWork,
    required this.clearLocalPrefs,
    required this.isSignedIn,
  });
}
