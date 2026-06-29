import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import '../repositories/recurring_repository.dart';

class DeleteRecurring extends UseCase<Unit, String> {
  final RecurringRepository repository;

  DeleteRecurring(this.repository);

  /// Returns [Right(T)] on success, [Left(Failure)] on failure.
  @override
  Future<Either<Failure, Unit>> call(String id) {
    return repository.deleteRecurring(id);
  }
}
