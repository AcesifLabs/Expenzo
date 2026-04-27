import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import '../entities/record.dart';
import '../repositories/record_repository.dart';

class AddRecord extends UseCase<Record, Record> {
  final RecordRepository repository;

  AddRecord(this.repository);

  @override
  Future<Either<Failure, Record>> call(Record record) {
    return repository.addRecord(record);
  }
}
