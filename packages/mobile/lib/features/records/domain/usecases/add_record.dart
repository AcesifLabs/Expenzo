import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import 'package:expense_tracker/features/categories/domain/repositories/category_repository.dart';
import '../entities/record.dart';
import '../repositories/record_repository.dart';

class AddRecord extends UseCase<Record, Record> {
  final RecordRepository repository;
  final CategoryRepository categoryRepository;

  AddRecord(this.repository, this.categoryRepository);

  @override
  Future<Either<Failure, Record>> call(Record record) async {
    final result = await repository.addRecord(record);

    if (result.isRight()) {
      final categoryId = record.categoryId;
      if (categoryId != null) {
        await categoryRepository.incrementUsageCount(categoryId);
      }
    }

    return result;
  }
}
