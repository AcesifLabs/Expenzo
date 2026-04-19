import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/usecase.dart';
import '../repositories/recurring_repository.dart';

class DeleteRecurring extends UseCase<Unit, String> {
  final RecurringRepository repository;

  DeleteRecurring(this.repository);

  @override
  Future<Either<Failure, Unit>> call(String id) {
    return repository.deleteRecurring(id);
  }
}
