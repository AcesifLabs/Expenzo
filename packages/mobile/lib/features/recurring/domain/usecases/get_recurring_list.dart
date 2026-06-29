import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import '../entities/recurring_transaction.dart';
import '../repositories/recurring_repository.dart';

class GetRecurringList extends UseCase<List<RecurringTransaction>, NoParams> {
  final RecurringRepository repository;

  GetRecurringList(this.repository);

  /// Returns [Right(T)] on success, [Left(Failure)] on failure.
  @override
  Future<Either<Failure, List<RecurringTransaction>>> call(NoParams params) {
    return repository.getRecurringList();
  }
}
