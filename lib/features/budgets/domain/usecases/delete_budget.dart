import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/budget_repository.dart';

class DeleteBudget {
  final BudgetRepository repository;

  DeleteBudget({required this.repository});

  Future<Either<Failure, Unit>> call(String id) {
    return repository.deleteBudget(id);
  }
}
