import 'package:equatable/equatable.dart';
import 'package:expense_tracker/core/sync/sync_run_result.dart';

import '../../domain/entities/sync_overview.dart';

const _lastResultUnset = Object();

enum SyncScreenLoadStatus { loading, loaded, error }

class SyncScreenState extends Equatable {
  final SyncScreenLoadStatus loadStatus;
  final SyncOverview? overview;
  final bool isSyncing;

  final int failedCount;

  final SyncRunResult? lastResult;

  @override
  List<Object?> get props => [
    loadStatus,
    overview,
    isSyncing,
    failedCount,
    lastResult,
  ];

  const SyncScreenState({
    this.loadStatus = SyncScreenLoadStatus.loading,
    this.overview,
    this.isSyncing = false,
    this.failedCount = 0,
    this.lastResult,
  });

  SyncScreenState copyWith({
    SyncScreenLoadStatus? loadStatus,
    SyncOverview? overview,
    bool? isSyncing,
    int? failedCount,
    Object? lastResult = _lastResultUnset,
  }) {
    return SyncScreenState(
      loadStatus: loadStatus ?? this.loadStatus,
      overview: overview ?? this.overview,
      isSyncing: isSyncing ?? this.isSyncing,
      failedCount: failedCount ?? this.failedCount,
      lastResult: identical(lastResult, _lastResultUnset)
          ? this.lastResult
          : lastResult as SyncRunResult?,
    );
  }
}
