import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import '../entities/date_amount.dart';
import '../repositories/reports_repository.dart';

class GetSpendingTrend {
  final ReportsRepository repository;

  GetSpendingTrend({required this.repository});

  Future<Either<Failure, List<DateAmount>>> call({
    required DateTime startDate,
    required DateTime endDate,
    required Granularity granularity,
  }) {
    return repository.getSpendingTrend(
      startDate: startDate,
      endDate: endDate,
      granularity: granularity,
    );
  }
}
