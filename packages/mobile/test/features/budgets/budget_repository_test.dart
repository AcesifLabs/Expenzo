import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:talker/talker.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/database/app_database.dart' as db;
import 'package:expense_tracker/core/database/daos/sync_queue_dao.dart';
import 'package:expense_tracker/core/logger/app_logger.dart';
import 'package:expense_tracker/features/budgets/data/datasources/budget_local_datasource.dart';
import 'package:expense_tracker/features/budgets/data/repositories/budget_repository_impl.dart';
import 'package:expense_tracker/features/budgets/domain/entities/budget.dart';

import '../../support/factories/budget_factory.dart';

class MockBudgetLocalDatasource extends Mock implements BudgetLocalDatasource {}

class MockSyncQueueDao extends Mock implements SyncQueueDao {}

class _BudgetFake extends Fake implements Budget {}

/// Builds a drift Record row (already unlinked) for enqueue assertions.
db.Record _record(String id) {
  final now = DateTime(2026, 1, 1);
  return db.Record(
    id: id,
    amount: -10,
    description: 'x',
    date: now,
    source: 'manual',
    recordType: 'OUT',
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  late MockBudgetLocalDatasource mockDatasource;
  late MockSyncQueueDao mockSyncDao;
  late BudgetRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(_BudgetFake());
    appLogger.configure(settings: TalkerSettings(useConsoleLogs: false));
  });

  setUp(() {
    mockDatasource = MockBudgetLocalDatasource();
    mockSyncDao = MockSyncQueueDao();
    repository = BudgetRepositoryImpl(
      localDatasource: mockDatasource,
      syncQueueDao: mockSyncDao,
    );
  });

  group('BudgetRepositoryImpl', () {
    group('getBudgets', () {
      test('returns Right(list) on success', () async {
        final budgets = [makeBudget(), makeBudget(id: 'budget-2')];
        when(
          () => mockDatasource.getBudgets(),
        ).thenAnswer((_) async => budgets);

        final result = await repository.getBudgets();

        expect(result, Right(budgets));
        verify(() => mockDatasource.getBudgets()).called(1);
      });

      test('returns Left(CacheFailure) on CacheException', () async {
        when(
          () => mockDatasource.getBudgets(),
        ).thenThrow(const CacheException(message: 'DB error'));

        final result = await repository.getBudgets();

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure.message, contains('DB error')),
          (_) => fail('Should not return Right'),
        );
      });
    });

    group('getBudgetById', () {
      test('returns Right(budget) when found', () async {
        final budget = makeBudget();
        when(
          () => mockDatasource.getBudgetById('budget-1'),
        ).thenAnswer((_) async => budget);

        final result = await repository.getBudgetById('budget-1');

        expect(result, Right(budget));
      });

      test('returns Left when not found', () async {
        when(
          () => mockDatasource.getBudgetById('missing'),
        ).thenAnswer((_) async => null);

        final result = await repository.getBudgetById('missing');

        expect(result.isLeft(), true);
      });
    });

    group('createBudget', () {
      test('returns Right(budget) with generated id on success', () async {
        final budget = makeBudget(id: null);
        when(() => mockDatasource.createBudget(any())).thenAnswer((_) async {});
        when(
          () => mockSyncDao.enqueue(
            tableName: any(named: 'tableName'),
            recordId: any(named: 'recordId'),
            action: any(named: 'action'),
            payload: any(named: 'payload'),
          ),
        ).thenAnswer((_) async {});

        final result = await repository.createBudget(budget);

        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Should not return Left'),
          (created) => expect(created.id, isNotNull),
        );
      });

      test('returns Left(CacheFailure) on CacheException', () async {
        final budget = makeBudget();
        when(
          () => mockDatasource.createBudget(any()),
        ).thenThrow(const CacheException(message: 'Insert failed'));

        final result = await repository.createBudget(budget);

        expect(result.isLeft(), true);
      });
    });

    group('updateBudget', () {
      test('returns Right(budget) on success', () async {
        final budget = makeBudget();
        when(
          () => mockDatasource.updateBudget(budget),
        ).thenAnswer((_) async {});
        when(
          () => mockSyncDao.enqueue(
            tableName: any(named: 'tableName'),
            recordId: any(named: 'recordId'),
            action: any(named: 'action'),
            payload: any(named: 'payload'),
          ),
        ).thenAnswer((_) async {});

        final result = await repository.updateBudget(budget);

        expect(result, Right(budget));
      });

      test('returns Left when budget has no id', () async {
        final budget = makeBudget(id: null);
        when(
          () => mockDatasource.updateBudget(budget),
        ).thenAnswer((_) async {});

        final result = await repository.updateBudget(budget);

        expect(result.isLeft(), true);
      });
    });

    group('deleteBudget', () {
      test('returns Right(unit) on success', () async {
        when(
          () => mockDatasource.deleteBudget('budget-1'),
        ).thenAnswer((_) async => <db.Record>[]);
        when(
          () => mockSyncDao.enqueue(
            tableName: any(named: 'tableName'),
            recordId: any(named: 'recordId'),
            action: any(named: 'action'),
            payload: any(named: 'payload'),
          ),
        ).thenAnswer((_) async {});

        final result = await repository.deleteBudget('budget-1');

        expect(result, const Right(unit));
        verify(
          () => mockSyncDao.enqueue(
            tableName: 'budgets',
            recordId: 'budget-1',
            action: 'delete',
            payload: any(named: 'payload'),
          ),
        ).called(1);
      });

      test(
        'enqueues a records-table update for each unlinked record',
        () async {
          final unlinked = [_record('r1'), _record('r2')];
          when(
            () => mockDatasource.deleteBudget('budget-1'),
          ).thenAnswer((_) async => unlinked);
          when(
            () => mockSyncDao.enqueue(
              tableName: any(named: 'tableName'),
              recordId: any(named: 'recordId'),
              action: any(named: 'action'),
              payload: any(named: 'payload'),
            ),
          ).thenAnswer((_) async {});

          await repository.deleteBudget('budget-1');

          for (final id in ['r1', 'r2']) {
            verify(
              () => mockSyncDao.enqueue(
                tableName: 'records',
                recordId: id,
                action: 'update',
                payload: any(named: 'payload'),
              ),
            ).called(1);
          }
        },
      );
    });
  });
}
