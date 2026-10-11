import 'dart:convert';

import 'package:expense_tracker/core/database/app_database.dart' as db;
import 'package:expense_tracker/core/database/daos/pending_recurring_dao.dart';
import 'package:expense_tracker/core/database/daos/sync_queue_dao.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/sync/handlers/recurring_transactions_sync_handler.dart';
import 'package:expense_tracker/features/recurring/data/datasources/recurring_local_datasource.dart';
import 'package:expense_tracker/features/recurring/data/repositories/recurring_repository_impl.dart';
import 'package:expense_tracker/features/recurring/domain/entities/recurring_transaction.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/factories/recurring_factory.dart';

class _MockDatasource extends Mock implements RecurringLocalDatasource {}

class _MockPendingDao extends Mock implements PendingRecurringDao {}

class _MockSyncQueueDao extends Mock implements SyncQueueDao {}

void main() {
  late _MockDatasource datasource;
  late _MockSyncQueueDao queue;
  late RecurringRepositoryImpl repository;

  setUpAll(() => registerFallbackValue(makeRecurring()));

  setUp(() {
    datasource = _MockDatasource();
    queue = _MockSyncQueueDao();
    when(
      () => queue.enqueue(
        tableName: any(named: 'tableName'),
        recordId: any(named: 'recordId'),
        action: any(named: 'action'),
        payload: any(named: 'payload'),
      ),
    ).thenAnswer((_) async {});
    when(() => datasource.createRecurring(any())).thenAnswer((_) async {});
    when(() => datasource.updateRecurring(any())).thenAnswer((_) async {});
    when(() => datasource.updateRecurringBatch(any())).thenAnswer((_) async {});
    when(() => datasource.deleteRecurring(any())).thenAnswer((_) async {});
    repository = RecurringRepositoryImpl(
      localDatasource: datasource,
      pendingRecurringDao: _MockPendingDao(),
      syncQueueDao: queue,
    );
  });

  /// Each queued row as (action, recordId, payload).
  List<(String, String, String)> queued() {
    final captured = verify(
      () => queue.enqueue(
        tableName: 'recurring_transactions',
        recordId: captureAny(named: 'recordId'),
        action: captureAny(named: 'action'),
        payload: captureAny(named: 'payload'),
      ),
    ).captured;

    return [
      for (var i = 0; i < captured.length; i += 3)
        (
          captured[i + 1] as String,
          captured[i] as String,
          captured[i + 2] as String,
        ),
    ];
  }

  test(
    'create without an id stores, returns and queues the same new id',
    () async {
      final input = RecurringTransaction(
        description: 'Rent',
        amount: 500,
        frequency: RecurringFrequency.monthly,
        startDate: DateTime.utc(2026, 1, 1),
        nextOccurrence: DateTime.utc(2026, 2, 1),
      );

      final result = await repository.createRecurring(input);

      final created = result.getOrElse(() => throw StateError('failed'));
      final stored =
          verify(() => datasource.createRecurring(captureAny())).captured.single
              as RecurringTransaction;
      final (action, id, _) = queued().single;
      expect(created.id, isNotNull);
      expect(stored.id, created.id);
      expect(id, created.id);
      expect(action, 'insert');
    },
  );

  test('create with an id keeps it', () async {
    await repository.createRecurring(makeRecurring(id: 'rec-1'));

    expect(queued().single.$2, 'rec-1');
  });

  test('update queues an update with the payload', () async {
    await repository.updateRecurring(
      makeRecurring(id: 'rec-1', description: 'Gym'),
    );

    final (action, id, payload) = queued().single;
    expect((action, id), ('update', 'rec-1'));
    expect(jsonDecode(payload)['description'], 'Gym');
  });

  test('updateRecurringBatch queues one update per item', () async {
    await repository.updateRecurringBatch([
      makeRecurring(id: 'rec-1'),
      makeRecurring(id: 'rec-2'),
    ]);

    expect(queued().map((q) => (q.$1, q.$2)), [
      ('update', 'rec-1'),
      ('update', 'rec-2'),
    ]);
  });

  test('delete queues a delete with an empty payload', () async {
    await repository.deleteRecurring('rec-1');

    expect(queued().single, ('delete', 'rec-1', ''));
  });

  test('a failed local write queues nothing', () async {
    when(
      () => datasource.updateRecurring(any()),
    ).thenThrow(const CacheException(message: 'write failed'));

    final result = await repository.updateRecurring(makeRecurring());

    expect(result.isLeft(), isTrue);
    verifyNever(
      () => queue.enqueue(
        tableName: any(named: 'tableName'),
        recordId: any(named: 'recordId'),
        action: any(named: 'action'),
        payload: any(named: 'payload'),
      ),
    );
  });

  test('payload has the sync handler fields the server does not set', () async {
    final row = db.RecurringTransaction(
      id: 'rec-1',
      description: 'Rent',
      amount: 500,
      categoryId: null,
      frequency: 'monthly',
      startDate: DateTime.utc(2026, 1, 1),
      endDate: null,
      nextOccurrence: DateTime.utc(2026, 2, 1),
      isActive: true,
      autoCreateExpense: true,
      dayOfMonth: null,
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
    );
    final handlerKeys = RecurringTransactionsSyncHandler()
        .toSyncPayload(row)
        .keys
        .toSet()
        .difference({'id', 'createdAt', 'updatedAt'});

    await repository.updateRecurring(makeRecurring(id: 'rec-1'));

    final payload = jsonDecode(queued().single.$3) as Map<String, dynamic>;
    expect(payload.keys.toSet(), handlerKeys);
  });

  test('writes still succeed without a sync queue', () async {
    final local = RecurringRepositoryImpl(
      localDatasource: datasource,
      pendingRecurringDao: _MockPendingDao(),
    );

    final result = await local.createRecurring(makeRecurring());

    expect(result.isRight(), isTrue);
  });
}
