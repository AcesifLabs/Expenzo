import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/category_amount.dart';
import '../repositories/reports_repository.dart';

class GetCategoryBreakdown {
  final ReportsRepository repository;

  GetCategoryBreakdown({required this.repository});

  Future<Either<Failure, List<CategoryAmount>>> call({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return repository.getCategoryBreakdown(
      startDate: startDate,
      endDate: endDate,
    );
  }
}
