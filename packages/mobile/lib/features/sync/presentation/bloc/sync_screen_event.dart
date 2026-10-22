import 'package:equatable/equatable.dart';

abstract class SyncScreenEvent extends Equatable {
  @override
  List<Object?> get props => [];

  const SyncScreenEvent();
}

/// Loads the overview; also the Retry after a failed load.
class SyncScreenStarted extends SyncScreenEvent {
  const SyncScreenStarted();
}

/// "Sync now", and Retry after a failed sync.
class SyncNowRequested extends SyncScreenEvent {
  const SyncNowRequested();
}
