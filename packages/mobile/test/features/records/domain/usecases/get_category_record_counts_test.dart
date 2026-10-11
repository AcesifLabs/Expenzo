import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import 'package:expense_tracker/features/records/domain/repositories/record_repository.dart';
import 'package:expense_tracker/features/records/domain/usecases/get_category_record_counts.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRecordRepository extends Mock implements RecordRepository {}

void main() {
  late _MockRecordRepository repository;
  late GetCategoryRecordCounts useCase;

  setUp(() {
    repository = _MockRecordRepository();
    useCase = GetCategoryRecordCounts(repository);
  });

  test('returns the repository map', () async {
    when(
      () => repository.getCategoryRecordCounts(),
    ).thenAnswer((_) async => const Right({'cat-1': 3}));

    final result = await useCase(NoParams());

    expect(result.fold((_) => null, (counts) => counts), {'cat-1': 3});
  });

  test('passes a CacheFailure through as Left', () async {
    const failure = CacheFailure(message: 'db');
    when(
      () => repository.getCategoryRecordCounts(),
    ).thenAnswer((_) async => const Left(failure));

    final result = await useCase(NoParams());

    expect(result, const Left<Failure, Map<String, int>>(failure));
  });
}
