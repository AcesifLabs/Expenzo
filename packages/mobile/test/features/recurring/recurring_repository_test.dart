import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/database/daos/pending_recurring_dao.dart';
import 'package:expense_tracker/features/recurring/data/datasources/recurring_local_datasource.dart';
import 'package:expense_tracker/features/recurring/data/repositories/recurring_repository_impl.dart';

import '../../support/factories/recurring_factory.dart';

class MockRecurringLocalDatasource extends Mock
    implements RecurringLocalDatasource {}

class MockPendingRecurringDao extends Mock implements PendingRecurringDao {}

void main() {
  late MockRecurringLocalDatasource mockDatasource;
  late MockPendingRecurringDao mockDao;
  late RecurringRepositoryImpl repository;

  setUp(() {
    mockDatasource = MockRecurringLocalDatasource();
    mockDao = MockPendingRecurringDao();
    repository = RecurringRepositoryImpl(
      localDatasource: mockDatasource,
      pendingRecurringDao: mockDao,
    );
  });

  group('RecurringRepositoryImpl', () {
    group('getRecurringList', () {
      test('returns Right(list) on success', () async {
        final recurrings = [makeRecurring(), makeRecurring(id: 'rec-2')];
        when(
          () => mockDatasource.getRecurringList(),
        ).thenAnswer((_) async => recurrings);

        final result = await repository.getRecurringList();

        expect(result, Right(recurrings));
        verify(() => mockDatasource.getRecurringList()).called(1);
      });

      test('returns Left(CacheFailure) on CacheException', () async {
        when(
          () => mockDatasource.getRecurringList(),
        ).thenThrow(const CacheException(message: 'DB error'));

        final result = await repository.getRecurringList();

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure.message, contains('DB error')),
          (_) => fail('Should not return Right'),
        );
      });
    });

    group('getRecurringById', () {
      test('returns Right(recurring) when found', () async {
        final recurring = makeRecurring();
        when(
          () => mockDatasource.getRecurringById('rec-1'),
        ).thenAnswer((_) async => recurring);

        final result = await repository.getRecurringById('rec-1');

        expect(result, Right(recurring));
      });

      test('returns Left when not found', () async {
        when(
          () => mockDatasource.getRecurringById('missing'),
        ).thenAnswer((_) async => null);

        final result = await repository.getRecurringById('missing');

        expect(result.isLeft(), true);
      });
    });

    group('createRecurring', () {
      test('returns Right(recurring) on success', () async {
        final recurring = makeRecurring();
        when(
          () => mockDatasource.createRecurring(recurring),
        ).thenAnswer((_) async {});

        final result = await repository.createRecurring(recurring);

        expect(result, Right(recurring));
        verify(() => mockDatasource.createRecurring(recurring)).called(1);
      });

      test('returns Left(CacheFailure) on CacheException', () async {
        final recurring = makeRecurring();
        when(
          () => mockDatasource.createRecurring(recurring),
        ).thenThrow(const CacheException(message: 'Insert failed'));

        final result = await repository.createRecurring(recurring);

        expect(result.isLeft(), true);
      });
    });

    group('updateRecurring', () {
      test('returns Right(recurring) on success', () async {
        final recurring = makeRecurring();
        when(
          () => mockDatasource.updateRecurring(recurring),
        ).thenAnswer((_) async {});

        final result = await repository.updateRecurring(recurring);

        expect(result, Right(recurring));
      });
    });

    group('deleteRecurring', () {
      test('returns Right(unit) on success', () async {
        when(
          () => mockDatasource.deleteRecurring('rec-1'),
        ).thenAnswer((_) async {});

        final result = await repository.deleteRecurring('rec-1');

        expect(result, const Right(unit));
      });
    });

    group('getDueRecurring', () {
      test('returns Right(list) of due recurrings', () async {
        final dueRecurrings = [makeRecurring()];
        when(
          () => mockDatasource.getDueRecurring(),
        ).thenAnswer((_) async => dueRecurrings);

        final result = await repository.getDueRecurring();

        expect(result, Right(dueRecurrings));
      });
    });

    group('updateRecurringBatch', () {
      test('returns Right(unit) on success', () async {
        final recurrings = [makeRecurring()];
        when(
          () => mockDatasource.updateRecurringBatch(recurrings),
        ).thenAnswer((_) async {});

        final result = await repository.updateRecurringBatch(recurrings);

        expect(result, const Right(unit));
      });
    });
  });
}
