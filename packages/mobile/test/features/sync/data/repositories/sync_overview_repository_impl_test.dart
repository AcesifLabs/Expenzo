import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/core/database/app_database.dart';
import 'package:expense_tracker/core/database/daos/sync_queue_dao.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/sync/sync_engine.dart';
import 'package:expense_tracker/features/sync/data/repositories/sync_overview_repository_impl.dart';
import 'package:expense_tracker/features/sync/data/services/sync_outcome_reader.dart';
import 'package:expense_tracker/features/sync/domain/entities/sync_overview.dart';

class _MockEngine extends Mock implements SyncEngine {}

void main() {
  late AppDatabase db;
  late SyncQueueDao queue;
  late _MockEngine engine;
  final success = DateTime(2026, 10, 15, 9);
  final failure = DateTime(2026, 10, 15, 10);

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    queue = SyncQueueDao(db);
    engine = _MockEngine();
  });

  tearDown(() => db.close());

  SyncOverviewRepositoryImpl repository({
    bool signedIn = true,
    DateTime? failedAt,
    int failures = 0,
    Future<DateTime?> Function()? lastSuccess,
  }) => SyncOverviewRepositoryImpl(
    engine: engine,
    queue: queue,
    outcomes: SyncOutcomeReader(
      hasToken: () async => signedIn,
      lastSuccessfulSyncAt: lastSuccess ?? () async => success,
      lastFailedSyncAt: () async => failedAt,
      consecutiveFailures: () async => failures,
    ),
  );

  Future<void> enqueue(String id) => queue.enqueue(
    tableName: 'records',
    recordId: id,
    action: 'create',
    payload: '{}',
  );

  Future<SyncOverview?> overviewOf(SyncOverviewRepositoryImpl repo) async =>
      (await repo.getOverview()).fold((_) => null, (o) => o);

  test('the overview combines sign-in, outcomes and the queue', () async {
    await enqueue('a');
    await enqueue('b');

    final overview = await overviewOf(
      repository(failedAt: failure, failures: 1),
    );

    expect(
      overview,
      SyncOverview(
        isSignedIn: true,
        lastSuccessfulSyncAt: success,
        lastFailedSyncAt: failure,
        consecutiveFailures: 1,
        pendingCount: 2,
      ),
    );
    expect(overview!.lastSyncFailed, isTrue);
  });

  test('signed out still reports the pending count', () async {
    await enqueue('a');

    final overview = await overviewOf(repository(signedIn: false));

    expect(overview!.isSignedIn, isFalse);
    expect(overview.pendingCount, 1);
    expect(overview.lastSyncFailed, isFalse);
  });

  test('the banner shows from the third failure in a row', () async {
    final two = await overviewOf(repository(failedAt: failure, failures: 2));
    final three = await overviewOf(repository(failedAt: failure, failures: 3));

    expect(two!.showFailureBanner, isFalse);
    expect(three!.showFailureBanner, isTrue);
  });

  test('the pending count stream follows the queue', () async {
    final counts = <int>[];
    final sub = repository().watchPendingCount().listen(counts.add);
    addTearDown(sub.cancel);
    await pumpEventQueue();

    await enqueue('a');
    await pumpEventQueue();

    expect(counts, [0, 1]);
  });

  test('syncNow returns the engine result', () async {
    when(() => engine.syncNow()).thenAnswer((_) async => SyncRunResult.offline);

    expect(await repository().syncNow(), SyncRunResult.offline);
  });

  test('a reader that throws gives CacheFailure', () async {
    final result = await repository(
      lastSuccess: () async => throw StateError('storage'),
    ).getOverview();

    expect(result.fold((f) => f, (_) => null), isA<CacheFailure>());
  });
}
