import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import 'package:expense_tracker/core/constants/source_types.dart';
import 'package:expense_tracker/core/database/transaction_runner.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/features/categories/domain/repositories/category_repository.dart';
import 'package:expense_tracker/features/categories/domain/usecases/get_categories.dart';
import 'package:expense_tracker/features/records/domain/repositories/record_repository.dart';
import 'package:expense_tracker/features/recurring/domain/entities/recurring_transaction.dart';
import 'package:expense_tracker/features/recurring/domain/usecases/post_due_recurring.dart';
import 'package:expense_tracker/features/recurring/domain/usecases/process_recurring.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../support/factories/category_factory.dart';
import '../../../../support/factories/recurring_factory.dart';

class _MockProcessRecurring extends Mock implements ProcessRecurring {}

class _MockRecordRepository extends Mock implements RecordRepository {}

class _MockCategoryRepository extends Mock implements CategoryRepository {}

class _MockGetCategories extends Mock implements GetCategories {}

class _DirectRunner implements TransactionRunner {
  var runs = 0;

  @override
  Future<T> run<T>(Future<T> Function() action) {
    runs++;

    return action();
  }
}

void main() {
  late _MockProcessRecurring processRecurring;
  late _MockRecordRepository recordRepository;
  late _MockCategoryRepository categoryRepository;
  late _MockGetCategories getCategories;
  late _DirectRunner runner;
  late PostDueRecurring postDueRecurring;

  final salary = makeCategory(id: 'salary', type: RecordType.income);
  final food = makeCategory(id: 'food');

  setUpAll(() {
    registerFallbackValue(<Record>[]);
    registerFallbackValue(const GetCategoriesParams());
  });

  setUp(() {
    processRecurring = _MockProcessRecurring();
    recordRepository = _MockRecordRepository();
    categoryRepository = _MockCategoryRepository();
    getCategories = _MockGetCategories();
    runner = _DirectRunner();
    postDueRecurring = PostDueRecurring(
      processRecurring: processRecurring,
      recordRepository: recordRepository,
      categoryRepository: categoryRepository,
      getCategories: getCategories,
      transactionRunner: runner,
    );
    when(
      () => getCategories(any()),
    ).thenAnswer((_) async => Right([salary, food]));
    when(
      () => recordRepository.addRecordsBatch(any()),
    ).thenAnswer((_) async => const Right(unit));
    when(
      () => categoryRepository.incrementUsageCount(any()),
    ).thenAnswer((_) async => const Right(unit));
  });

  void due(List<RecurringTransaction> items) {
    when(
      () => processRecurring(onlyIncluded: any(named: 'onlyIncluded')),
    ).thenAnswer((_) async => Right(items));
  }

  List<Record> postedRecords() =>
      verify(
            () => recordRepository.addRecordsBatch(captureAny()),
          ).captured.single
          as List<Record>;

  void verifyProcessed(int times) => verify(
    () => processRecurring(onlyIncluded: any(named: 'onlyIncluded')),
  ).called(times);

  test('nothing due adds nothing', () async {
    due([]);

    expect(await postDueRecurring(), const Right<Failure, int>(0));
    verifyNever(() => recordRepository.addRecordsBatch(any()));
  });

  test('due occurrences are added in one batch, in one transaction', () async {
    final first = DateTime(2026, 9, 1);
    final second = DateTime(2026, 10, 1);
    due([
      makeRecurring(categoryId: 'food', nextOccurrence: first),
      makeRecurring(categoryId: 'food', nextOccurrence: second),
    ]);

    expect(await postDueRecurring(), const Right<Failure, int>(2));

    final records = postedRecords();
    expect(records.map((r) => r.date), [first, second]);
    expect(records.every((r) => r.source == ExpenseSource.recurring), isTrue);
    expect(records.first.recordType, RecordType.expense);
    expect(runner.runs, 1);
  });

  test('each added Record counts as a use of its category', () async {
    due([makeRecurring(categoryId: 'food'), makeRecurring()]);

    await postDueRecurring();

    verify(() => categoryRepository.incrementUsageCount('food')).called(1);
  });

  test('an item in an income category posts an income', () async {
    due([makeRecurring(categoryId: 'salary')]);

    await postDueRecurring();

    expect(postedRecords().single.recordType, RecordType.income);
  });

  test('an item without a category posts an expense', () async {
    due([makeRecurring()]);

    await postDueRecurring();

    expect(postedRecords().single.recordType, RecordType.expense);
  });

  test('an item whose category is gone posts an expense', () async {
    due([makeRecurring(categoryId: 'deleted')]);

    await postDueRecurring();

    expect(postedRecords().single.recordType, RecordType.expense);
  });

  test('an automatic run processes only included items', () async {
    due([]);

    await postDueRecurring(automatic: true);
    await postDueRecurring();

    verifyInOrder([
      () => processRecurring(onlyIncluded: true),
      () => processRecurring(onlyIncluded: false),
    ]);
  });

  test('a failed batch is returned and counts no category use', () async {
    const failure = CacheFailure(message: 'disk full');
    due([makeRecurring(categoryId: 'food')]);
    when(
      () => recordRepository.addRecordsBatch(any()),
    ).thenAnswer((_) async => const Left(failure));

    expect(await postDueRecurring(), const Left<Failure, int>(failure));
    verifyNever(() => categoryRepository.incrementUsageCount(any()));
  });

  test('a category load failure posts and advances nothing', () async {
    const failure = CacheFailure(message: 'no categories');
    when(
      () => getCategories(any()),
    ).thenAnswer((_) async => const Left(failure));

    expect(await postDueRecurring(), const Left<Failure, int>(failure));
    verifyNever(
      () => processRecurring(onlyIncluded: any(named: 'onlyIncluded')),
    );
  });

  test('a processing failure adds nothing', () async {
    const failure = CacheFailure(message: 'db');
    when(
      () => processRecurring(onlyIncluded: any(named: 'onlyIncluded')),
    ).thenAnswer((_) async => const Left(failure));

    expect(await postDueRecurring(), const Left<Failure, int>(failure));
    verifyNever(() => recordRepository.addRecordsBatch(any()));
  });

  group('overlapping calls', () {
    late Completer<Either<Failure, List<RecurringTransaction>>> gate;

    setUp(() {
      gate = Completer();
      var calls = 0;
      when(
        () => processRecurring(onlyIncluded: any(named: 'onlyIncluded')),
      ).thenAnswer((_) {
        calls++;

        return calls == 1 ? gate.future : Future.value(const Right([]));
      });
    });

    test('of the same kind process once and share the result', () async {
      final first = postDueRecurring(automatic: true);
      final second = postDueRecurring(automatic: true);
      gate.complete(Right([makeRecurring()]));

      expect(await first, const Right<Failure, int>(1));
      expect(await second, const Right<Failure, int>(1));
      verifyProcessed(1);
    });

    test('an automatic call joins a manual run, which covers it', () async {
      final manual = postDueRecurring();
      final automatic = postDueRecurring(automatic: true);
      gate.complete(Right([makeRecurring()]));

      expect(await automatic, await manual);
      verifyProcessed(1);
    });

    test('a manual call waits for an automatic run, then runs', () async {
      final automatic = postDueRecurring(automatic: true);
      final manual = postDueRecurring();
      gate.complete(Right([makeRecurring()]));

      expect(await automatic, const Right<Failure, int>(1));
      expect(await manual, const Right<Failure, int>(0));
      verifyInOrder([
        () => processRecurring(onlyIncluded: true),
        () => processRecurring(onlyIncluded: false),
      ]);
    });
  });

  test('a later call runs again once the first finished', () async {
    due([]);

    await postDueRecurring();
    await postDueRecurring();

    verifyProcessed(2);
  });
}
