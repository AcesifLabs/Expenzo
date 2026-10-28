import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import '../repositories/record_repository.dart';

class GetCategoryRecordCounts extends UseCase<Map<String, int>, NoParams> {
  final RecordRepository repository;

  GetCategoryRecordCounts(this.repository);

  @override
  Future<Either<Failure, Map<String, int>>> call(NoParams params) {
    return repository.getCategoryRecordCounts();
  }
}
