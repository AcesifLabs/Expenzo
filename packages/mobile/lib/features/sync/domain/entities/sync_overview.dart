import 'package:equatable/equatable.dart';

/// What the Sync screen shows besides the on/off switch, which comes from
/// the settings.
class SyncOverview extends Equatable {
  final bool isSignedIn;
  final DateTime? lastSuccessfulSyncAt;

  /// Cleared by the next success, so a stored failure is the latest outcome.
  final DateTime? lastFailedSyncAt;
  final int consecutiveFailures;

  /// Changes waiting in the sync queue.
  final int pendingCount;

  /// Failed syncs in a row before the screen warns that Sync isn't working.
  static const failureBannerThreshold = 3;

  @override
  List<Object?> get props => [
    isSignedIn,
    lastSuccessfulSyncAt,
    lastFailedSyncAt,
    consecutiveFailures,
    pendingCount,
  ];

  bool get lastSyncFailed => lastFailedSyncAt != null;

  bool get showFailureBanner => consecutiveFailures >= failureBannerThreshold;

  const SyncOverview({
    required this.isSignedIn,
    this.lastSuccessfulSyncAt,
    this.lastFailedSyncAt,
    required this.consecutiveFailures,
    required this.pendingCount,
  });

  SyncOverview copyWith({int? pendingCount}) => SyncOverview(
    isSignedIn: isSignedIn,
    lastSuccessfulSyncAt: lastSuccessfulSyncAt,
    lastFailedSyncAt: lastFailedSyncAt,
    consecutiveFailures: consecutiveFailures,
    pendingCount: pendingCount ?? this.pendingCount,
  );
}
