import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/budget.dart';
import '../repositories/budget_repository.dart';

class UpdateBudget {
  final BudgetRepository repository;

  UpdateBudget({required this.repository});

  Future<Either<Failure, Budget>> call(Budget budget) {
    return repository.updateBudget(budget);
  }
}
