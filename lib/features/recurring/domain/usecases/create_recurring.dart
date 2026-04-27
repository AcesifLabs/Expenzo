import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import '../entities/recurring_transaction.dart';
import '../repositories/recurring_repository.dart';

class CreateRecurring
    extends UseCase<RecurringTransaction, RecurringTransaction> {
  final RecurringRepository repository;

  CreateRecurring(this.repository);

  @override
  Future<Either<Failure, RecurringTransaction>> call(
    RecurringTransaction recurring,
  ) {
    return repository.createRecurring(recurring);
  }
}
