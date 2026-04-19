import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/budget.dart';
import '../repositories/budget_repository.dart';

class GetBudgets {
  final BudgetRepository repository;

  GetBudgets({required this.repository});

  Future<Either<Failure, List<Budget>>> call() {
    return repository.getBudgets();
  }
}
