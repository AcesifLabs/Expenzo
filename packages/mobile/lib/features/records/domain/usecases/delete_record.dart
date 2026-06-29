import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import '../repositories/record_repository.dart';

class DeleteRecord extends UseCase<Unit, String> {
  final RecordRepository repository;

  DeleteRecord(this.repository);

  /// Returns [Right(T)] on success, [Left(Failure)] on failure.
  @override
  Future<Either<Failure, Unit>> call(String id) {
    return repository.deleteRecord(id);
  }
}
