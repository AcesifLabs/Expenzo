import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/budget.dart';
import '../repositories/budget_repository.dart';

class CreateBudget {
  final BudgetRepository repository;

  CreateBudget({required this.repository});

  Future<Either<Failure, Budget>> call(Budget budget) {
    return repository.createBudget(budget);
  }
}
