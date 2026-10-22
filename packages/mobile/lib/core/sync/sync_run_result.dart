/// What a `SyncEngine.syncNow()` request did.
enum SyncRunResult {
  /// Pulled and pushed without an error.
  success,

  /// No account on this device.
  signedOut,

  /// Signed in, but the first-sync conflict check hasn't finished.
  firstSyncPending,

  /// Sync is switched off on this device, or paused by Delete all data.
  disabled,

  /// The device is offline; nothing was sent.
  offline,

  /// A pull or push request failed; it retries on its own.
  failed,
}
