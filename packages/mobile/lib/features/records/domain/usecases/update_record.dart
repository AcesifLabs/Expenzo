import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import '../entities/record.dart';
import '../repositories/record_repository.dart';

class UpdateRecord extends UseCase<Record, Record> {
  final RecordRepository repository;

  UpdateRecord(this.repository);

  /// Returns [Right(T)] on success, [Left(Failure)] on failure.
  @override
  Future<Either<Failure, Record>> call(Record record) {
    return repository.updateRecord(record);
  }
}
