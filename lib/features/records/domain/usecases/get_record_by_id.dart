import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import '../entities/record.dart';
import '../repositories/record_repository.dart';

class GetRecordById extends UseCase<Record, int> {
  final RecordRepository repository;

  GetRecordById(this.repository);

  @override
  Future<Either<Failure, Record>> call(int id) {
    return repository.getRecordById(id);
  }
}
