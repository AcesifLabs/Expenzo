import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import '../entities/category.dart';
import '../repositories/category_repository.dart';

class UpdateCategory extends UseCase<Category, Category> {
  final CategoryRepository repository;

  UpdateCategory(this.repository);

  /// Returns [Right(T)] on success, [Left(Failure)] on failure.
  @override
  Future<Either<Failure, Category>> call(Category category) {
    return repository.updateCategory(category);
  }
}
