import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import 'package:expense_tracker/features/data_wipe/domain/entities/local_data_summary.dart';
import 'package:expense_tracker/features/data_wipe/domain/repositories/data_wipe_repository.dart';
import 'package:expense_tracker/features/data_wipe/domain/usecases/delete_all_data.dart';
import 'package:expense_tracker/features/data_wipe/domain/usecases/get_local_data_summary.dart';
import 'package:expense_tracker/features/data_wipe/domain/usecases/wipe_local_data.dart';

class _MockRepository extends Mock implements DataWipeRepository {}

void main() {
  late _MockRepository repository;
  const failure = CacheFailure(message: 'disk');

  setUp(() => repository = _MockRepository());

  test('WipeLocalData forwards the repository result', () async {
    when(
      () => repository.wipeLocalData(),
    ).thenAnswer((_) async => const Left(failure));

    expect(
      await WipeLocalData(repository)(NoParams()),
      const Left<Failure, Unit>(failure),
    );
  });

  test('DeleteAllData forwards the repository result', () async {
    when(
      () => repository.deleteAllData(),
    ).thenAnswer((_) async => const Right(unit));

    expect(
      await DeleteAllData(repository)(NoParams()),
      const Right<Failure, Unit>(unit),
    );
  });

  test('GetLocalDataSummary forwards the repository result', () async {
    const summary = LocalDataSummary(
      transactions: 1,
      budgets: 0,
      categories: 18,
      recurring: 0,
      smsRules: 0,
    );
    when(
      () => repository.countData(),
    ).thenAnswer((_) async => const Right(summary));

    expect(
      await GetLocalDataSummary(repository)(NoParams()),
      const Right<Failure, LocalDataSummary>(summary),
    );
  });
}
