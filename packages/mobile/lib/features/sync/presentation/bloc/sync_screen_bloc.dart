import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/core/bloc/transformers.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import 'package:expense_tracker/core/sync/sync_run_result.dart';

import '../../domain/repositories/sync_overview_repository.dart';
import '../../domain/usecases/get_sync_overview.dart';
import '../../domain/usecases/sync_now.dart';
import 'sync_screen_event.dart';
import 'sync_screen_state.dart';

/// Drives the Sync screen: status, live pending count and syncing flag, and
/// "Sync now".
class SyncScreenBloc extends Bloc<SyncScreenEvent, SyncScreenState> {
  final GetSyncOverview getOverview;
  final SyncNow syncNow;
  final SyncOverviewRepository repository;

  StreamSubscription<int>? _pendingSub;
  StreamSubscription<int>? _failedSub;
  bool _listeningToSyncing = false;

  SyncScreenBloc({
    required this.getOverview,
    required this.syncNow,
    required this.repository,
  }) : super(const SyncScreenState()) {
    on<SyncScreenStarted>(_onStarted);
    on<SyncNowRequested>(_onSyncNowRequested, transformer: droppable());
    on<_PendingCountChanged>(_onPendingCountChanged);
    on<_FailedCountChanged>(_onFailedCountChanged);
    on<FailedChangesRetryRequested>(
      _onFailedRetryRequested,
      transformer: droppable(),
    );
    on<_SyncingChanged>(_onSyncingChanged);
    // A newer read replaces one in flight, so an older overview never lands
    // last.
    on<_ReloadRequested>(_onReloadRequested, transformer: restartable());
  }

  @override
  Future<void> close() async {
    await _pendingSub?.cancel();
    await _failedSub?.cancel();
    if (_listeningToSyncing) repository.isSyncing.removeListener(_onSyncing);

    return super.close();
  }

  void _onStarted(SyncScreenStarted event, Emitter<SyncScreenState> emit) {
    emit(state.copyWith(loadStatus: SyncScreenLoadStatus.loading));
    _listen();
    add(const _ReloadRequested());
  }

  Future<void> _onSyncNowRequested(
    SyncNowRequested event,
    Emitter<SyncScreenState> emit,
  ) async {
    emit(state.copyWith(isSyncing: true, lastResult: null));
    final result = await syncNow();
    add(_ReloadRequested(lastResult: result));
  }

  void _onFailedCountChanged(
    _FailedCountChanged event,
    Emitter<SyncScreenState> emit,
  ) => emit(state.copyWith(failedCount: event.count));

  Future<void> _onFailedRetryRequested(
    FailedChangesRetryRequested event,
    Emitter<SyncScreenState> emit,
  ) async {
    await repository.retryFailed();
    add(const SyncNowRequested());
  }

  void _onPendingCountChanged(
    _PendingCountChanged event,
    Emitter<SyncScreenState> emit,
  ) {
    final overview = state.overview;
    if (overview == null) return;
    emit(
      state.copyWith(overview: overview.copyWith(pendingCount: event.count)),
    );
  }

  /// A background cycle that ends changes "last synced" and the failure
  /// state, so the overview is read again.
  void _onSyncingChanged(_SyncingChanged event, Emitter<SyncScreenState> emit) {
    final finished = state.isSyncing && !event.syncing;
    emit(state.copyWith(isSyncing: event.syncing));
    if (finished) add(const _ReloadRequested());
  }

  /// Subscribes once, on the first start.
  void _listen() {
    _pendingSub ??= repository.watchPendingCount().listen(
      (count) => add(_PendingCountChanged(count)),
    );
    _failedSub ??= repository.watchFailedCount().listen(
      (count) => add(_FailedCountChanged(count)),
    );
    if (_listeningToSyncing) return;
    _listeningToSyncing = true;
    repository.isSyncing.addListener(_onSyncing);
  }

  void _onSyncing() =>
      add(_SyncingChanged(syncing: repository.isSyncing.value));

  Future<void> _onReloadRequested(
    _ReloadRequested event,
    Emitter<SyncScreenState> emit,
  ) async {
    final result = await getOverview(NoParams());
    final lastResult = event.lastResult;
    emit(
      result.fold(
        (_) => lastResult == null
            ? state.copyWith(loadStatus: SyncScreenLoadStatus.error)
            : state.copyWith(
                loadStatus: SyncScreenLoadStatus.error,
                isSyncing: repository.isSyncing.value,
                lastResult: lastResult,
              ),
        (overview) => lastResult == null
            ? state.copyWith(
                loadStatus: SyncScreenLoadStatus.loaded,
                overview: overview,
              )
            : state.copyWith(
                loadStatus: SyncScreenLoadStatus.loaded,
                overview: overview,
                isSyncing: repository.isSyncing.value,
                lastResult: lastResult,
              ),
      ),
    );
  }
}

class _FailedCountChanged extends SyncScreenEvent {
  final int count;

  @override
  List<Object?> get props => [count];

  const _FailedCountChanged(this.count);
}

class _PendingCountChanged extends SyncScreenEvent {
  final int count;

  @override
  List<Object?> get props => [count];

  const _PendingCountChanged(this.count);
}

class _SyncingChanged extends SyncScreenEvent {
  final bool syncing;

  @override
  List<Object?> get props => [syncing];

  const _SyncingChanged({required this.syncing});
}

class _ReloadRequested extends SyncScreenEvent {
  final SyncRunResult? lastResult;

  @override
  List<Object?> get props => [lastResult];

  const _ReloadRequested({this.lastResult});
}
