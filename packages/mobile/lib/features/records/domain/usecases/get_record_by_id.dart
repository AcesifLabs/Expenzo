import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import '../entities/record.dart';
import '../repositories/record_repository.dart';

class GetRecordById extends UseCase<Record, String> {
  final RecordRepository repository;

  GetRecordById(this.repository);

  /// Returns [Right(T)] on success, [Left(Failure)] on failure.
  @override
  Future<Either<Failure, Record>> call(String id) {
    return repository.getRecordById(id);
  }
}
