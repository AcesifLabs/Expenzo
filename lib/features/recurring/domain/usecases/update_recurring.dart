import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/usecase.dart';
import '../entities/recurring_transaction.dart';
import '../repositories/recurring_repository.dart';

class UpdateRecurring
    extends UseCase<RecurringTransaction, RecurringTransaction> {
  final RecurringRepository repository;

  UpdateRecurring(this.repository);

  @override
  Future<Either<Failure, RecurringTransaction>> call(
    RecurringTransaction recurring,
  ) {
    return repository.updateRecurring(recurring);
  }
}
