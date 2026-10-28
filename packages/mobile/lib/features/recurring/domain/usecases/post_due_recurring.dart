import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import 'package:expense_tracker/core/constants/source_types.dart';
import 'package:expense_tracker/core/database/transaction_runner.dart';
import 'package:expense_tracker/core/error/failures.dart';
import '../../../categories/domain/repositories/category_repository.dart';
import '../../../categories/domain/usecases/get_categories.dart';
import '../../../records/domain/repositories/record_repository.dart';
import '../entities/recurring_transaction.dart';
import 'process_recurring.dart';

class PostDueRecurring {
  final ProcessRecurring processRecurring;
  final RecordRepository recordRepository;
  final CategoryRepository categoryRepository;
  final GetCategories getCategories;
  final TransactionRunner transactionRunner;

  Future<Either<Failure, int>>? _inFlight;
  bool _inFlightAutomatic = false;

  PostDueRecurring({
    required this.processRecurring,
    required this.recordRepository,
    required this.categoryRepository,
    required this.getCategories,
    required this.transactionRunner,
  });

  Future<Either<Failure, int>> call({bool automatic = false}) {
    final running = _inFlight;
    if (running != null) {
      if (automatic || !_inFlightAutomatic) return running;

      return running.then((_) => call());
    }

    final run = _run(automatic).whenComplete(() => _inFlight = null);
    _inFlight = run;
    _inFlightAutomatic = automatic;

    return run;
  }

  Future<Either<Failure, int>> _run(bool automatic) async {
    final categoriesResult = await getCategories(const GetCategoriesParams());

    return categoriesResult.fold(
      (failure) async => Left(failure),
      (categories) =>
          _postDue(automatic, {for (final c in categories) ?c.id: c.type}),
    );
  }

  Future<Either<Failure, int>> _postDue(
    bool automatic,
    Map<String, RecordType> typeById,
  ) async {
    final List<Record> records;
    try {
      records = await transactionRunner.run(() async {
        final processed = _orThrow(
          await processRecurring(onlyIncluded: automatic),
        );
        final toAdd = [for (final r in processed) _recordFor(r, typeById)];
        if (toAdd.isNotEmpty) {
          _orThrow(await recordRepository.addRecordsBatch(toAdd));
        }

        return toAdd;
      });
    } on _RolledBack catch (e) {
      return Left(e.failure);
    }

    await _countCategoryUse(records);

    return Right(records.length);
  }

  Future<void> _countCategoryUse(List<Record> records) async {
    for (final record in records) {
      final categoryId = record.categoryId;
      if (categoryId != null) {
        await categoryRepository.incrementUsageCount(categoryId);
      }
    }
  }

  static T _orThrow<T>(Either<Failure, T> result) =>
      result.fold((failure) => throw _RolledBack(failure), (value) => value);

  static Record _recordFor(
    RecurringTransaction recurring,
    Map<String, RecordType> typeById,
  ) {
    final now = DateTime.now().toUtc();

    return Record(
      amount: recurring.amount,
      description: recurring.description,
      date: recurring.nextOccurrence,
      categoryId: recurring.categoryId,
      source: ExpenseSource.recurring,
      recordType: typeById[recurring.categoryId] ?? RecordType.expense,
      createdAt: now,
      updatedAt: now,
    );
  }
}

class _RolledBack implements Exception {
  final Failure failure;

  const _RolledBack(this.failure);
}
