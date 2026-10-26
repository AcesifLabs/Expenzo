import 'package:equatable/equatable.dart';

class SyncOverview extends Equatable {
  final bool isSignedIn;
  final DateTime? lastSuccessfulSyncAt;

  final DateTime? lastFailedSyncAt;
  final int consecutiveFailures;

  final int pendingCount;

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
