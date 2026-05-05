import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import '../entities/spending_insights.dart';
import '../repositories/reports_repository.dart';

class GetSpendingInsights {
  final ReportsRepository repository;

  GetSpendingInsights({required this.repository});

  Future<Either<Failure, SpendingInsights>> call({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return repository.getSpendingInsights(
      startDate: startDate,
      endDate: endDate,
    );
  }
}
