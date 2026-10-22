/// The stored sync state the overview reads, as functions so tests don't
/// need secure storage. Production passes the `TokenStorage` statics.
class SyncOutcomeReader {
  final Future<bool> Function() hasToken;
  final Future<DateTime?> Function() lastSuccessfulSyncAt;
  final Future<DateTime?> Function() lastFailedSyncAt;
  final Future<int> Function() consecutiveFailures;

  const SyncOutcomeReader({
    required this.hasToken,
    required this.lastSuccessfulSyncAt,
    required this.lastFailedSyncAt,
    required this.consecutiveFailures,
  });
}
