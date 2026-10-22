import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import 'package:expense_tracker/core/sync/sync_run_result.dart';
import 'package:expense_tracker/features/sync/domain/entities/sync_overview.dart';
import 'package:expense_tracker/features/sync/domain/repositories/sync_overview_repository.dart';
import 'package:expense_tracker/features/sync/domain/usecases/get_sync_overview.dart';
import 'package:expense_tracker/features/sync/domain/usecases/sync_now.dart';
import 'package:expense_tracker/features/sync/presentation/bloc/sync_screen_bloc.dart';
import 'package:expense_tracker/features/sync/presentation/bloc/sync_screen_event.dart';
import 'package:expense_tracker/features/sync/presentation/bloc/sync_screen_state.dart';

class _MockGetOverview extends Mock implements GetSyncOverview {}

class _MockSyncNow extends Mock implements SyncNow {}

class _MockRepository extends Mock implements SyncOverviewRepository {}

void main() {
  const overview = SyncOverview(
    isSignedIn: true,
    consecutiveFailures: 0,
    pendingCount: 2,
  );
  final synced = SyncOverview(
    isSignedIn: true,
    lastSuccessfulSyncAt: DateTime(2026, 10, 15, 9),
    consecutiveFailures: 0,
    pendingCount: 0,
  );
  final failed = SyncOverview(
    isSignedIn: true,
    lastFailedSyncAt: DateTime(2026, 10, 15, 9),
    consecutiveFailures: 1,
    pendingCount: 2,
  );

  late _MockGetOverview getOverview;
  late _MockSyncNow syncNow;
  late _MockRepository repository;
  late StreamController<int> pending;
  late ValueNotifier<bool> syncing;
  late SyncScreenBloc bloc;

  setUpAll(() => registerFallbackValue(NoParams()));

  setUp(() {
    getOverview = _MockGetOverview();
    syncNow = _MockSyncNow();
    repository = _MockRepository();
    pending = StreamController<int>.broadcast();
    syncing = ValueNotifier(false);
    when(
      () => repository.watchPendingCount(),
    ).thenAnswer((_) => pending.stream);
    when(() => repository.isSyncing).thenReturn(syncing);
    when(
      () => getOverview(any()),
    ).thenAnswer((_) async => const Right(overview));
    bloc = SyncScreenBloc(
      getOverview: getOverview,
      syncNow: syncNow,
      repository: repository,
    );
  });

  tearDown(() async {
    await bloc.close();
    await pending.close();
  });

  Future<void> started() async {
    bloc.add(const SyncScreenStarted());
    await pumpEventQueue();
  }

  test('start loads the overview', () async {
    final states = expectLater(
      bloc.stream,
      emitsInOrder([
        isA<SyncScreenState>().having(
          (s) => s.loadStatus,
          'status',
          SyncScreenLoadStatus.loading,
        ),
        const SyncScreenState(
          loadStatus: SyncScreenLoadStatus.loaded,
          overview: overview,
        ),
      ]),
    );
    bloc.add(const SyncScreenStarted());
    await states;
  });

  test('a failed load gives error and a second start recovers', () async {
    when(
      () => getOverview(any()),
    ).thenAnswer((_) async => const Left(CacheFailure(message: 'storage')));
    await started();
    expect(bloc.state.loadStatus, SyncScreenLoadStatus.error);

    when(
      () => getOverview(any()),
    ).thenAnswer((_) async => const Right(overview));
    await started();
    expect(bloc.state.loadStatus, SyncScreenLoadStatus.loaded);
    verify(() => repository.watchPendingCount()).called(1);
  });

  test('a queue change updates the pending count without a reload', () async {
    await started();

    pending.add(5);
    await pumpEventQueue();

    expect(bloc.state.overview!.pendingCount, 5);
    verify(() => getOverview(any())).called(1);
  });

  test('a background cycle shows syncing and reloads when done', () async {
    await started();
    when(() => getOverview(any())).thenAnswer((_) async => Right(synced));

    syncing.value = true;
    await pumpEventQueue();
    expect(bloc.state.isSyncing, isTrue);

    syncing.value = false;
    await pumpEventQueue();

    expect(bloc.state.isSyncing, isFalse);
    expect(bloc.state.overview, synced);
  });

  test(
    'lastResult survives isSyncing false and a pending-count update',
    () async {
      await started();
      when(() => syncNow()).thenAnswer((_) async {
        syncing.value = true;
        syncing.value = false;

        return SyncRunResult.success;
      });
      when(() => getOverview(any())).thenAnswer((_) async => Right(synced));

      bloc.add(const SyncNowRequested());
      await pumpEventQueue();
      pending.add(4);
      await pumpEventQueue();

      expect(bloc.state.lastResult, SyncRunResult.success);
      expect(bloc.state.overview!.pendingCount, 4);
    },
  );

  test('sync now success reports success with a fresh time', () async {
    await started();
    when(() => syncNow()).thenAnswer((_) async => SyncRunResult.success);
    when(() => getOverview(any())).thenAnswer((_) async => Right(synced));

    final states = expectLater(
      bloc.stream,
      emitsThrough(
        isA<SyncScreenState>()
            .having((s) => s.lastResult, 'result', SyncRunResult.success)
            .having((s) => s.isSyncing, 'syncing', isFalse)
            .having((s) => s.overview, 'overview', synced),
      ),
    );
    bloc.add(const SyncNowRequested());
    await states;
  });

  test(
    'a failed sync now keeps the failure in the reloaded overview',
    () async {
      await started();
      when(() => syncNow()).thenAnswer((_) async => SyncRunResult.failed);
      when(() => getOverview(any())).thenAnswer((_) async => Right(failed));

      bloc.add(const SyncNowRequested());
      await pumpEventQueue();

      expect(bloc.state.lastResult, SyncRunResult.failed);
      expect(bloc.state.overview!.lastSyncFailed, isTrue);
    },
  );

  test('a slow older read never replaces a newer one', () async {
    await started();
    final slow = Completer<Either<Failure, SyncOverview>>();
    when(() => getOverview(any())).thenAnswer((_) => slow.future);
    syncing.value = true;
    await pumpEventQueue();
    syncing.value = false;
    await pumpEventQueue();

    when(() => getOverview(any())).thenAnswer((_) async => Right(synced));
    when(() => syncNow()).thenAnswer((_) async => SyncRunResult.success);
    bloc.add(const SyncNowRequested());
    await pumpEventQueue();
    slow.complete(Right(failed));
    await pumpEventQueue();

    expect(bloc.state.overview, synced);
    expect(bloc.state.lastResult, SyncRunResult.success);
  });

  test('close cancels the stream and removes the listener', () async {
    await started();
    expect(pending.hasListener, isTrue);

    await bloc.close();

    expect(pending.hasListener, isFalse);
    // A listener left behind would add to a closed bloc and throw.
    syncing.value = true;
  });
}
