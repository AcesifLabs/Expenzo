import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import '../entities/record.dart';
import '../repositories/record_repository.dart';

class GetRecords extends UseCase<List<Record>, GetRecordsParams> {
  final RecordRepository repository;

  GetRecords(this.repository);

  @override
  Future<Either<Failure, List<Record>>> call(GetRecordsParams params) {
    return repository.getRecords(
      dateRange: params.dateRange,
      categoryId: params.categoryId,
      limit: params.limit,
      offset: params.offset,
    );
  }
}

class GetRecordsParams extends Params {
  final DateTimeRange? dateRange;
  final String? categoryId;
  final int? limit;
  final int? offset;

  const GetRecordsParams({
    this.dateRange,
    this.categoryId,
    this.limit,
    this.offset,
  });

  @override
  List<Object?> get props => [dateRange, categoryId, limit, offset];
}
