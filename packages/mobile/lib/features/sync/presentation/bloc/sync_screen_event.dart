import 'package:equatable/equatable.dart';

abstract class SyncScreenEvent extends Equatable {
  @override
  List<Object?> get props => [];

  const SyncScreenEvent();
}

class SyncScreenStarted extends SyncScreenEvent {
  const SyncScreenStarted();
}

class SyncNowRequested extends SyncScreenEvent {
  const SyncNowRequested();
}

class FailedChangesRetryRequested extends SyncScreenEvent {
  const FailedChangesRetryRequested();
}
