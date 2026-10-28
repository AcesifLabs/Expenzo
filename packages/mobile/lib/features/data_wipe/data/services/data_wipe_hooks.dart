class DataWipeHooks {
  final Future<void> Function() pauseSync;
  final Future<void> Function() resumeSync;

  final Future<void> Function() resetSyncState;

  final Future<void> Function() cancelScheduledWork;

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
