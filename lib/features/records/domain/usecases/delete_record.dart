import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import '../repositories/record_repository.dart';

class DeleteRecord extends UseCase<Unit, int> {
  final RecordRepository repository;

  DeleteRecord(this.repository);

  @override
  Future<Either<Failure, Unit>> call(int id) {
    return repository.deleteRecord(id);
  }
}
