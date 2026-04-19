import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/usecase.dart';
import '../entities/category.dart';
import '../repositories/category_repository.dart';

class CreateCategory extends UseCase<Category, Category> {
  final CategoryRepository repository;

  CreateCategory(this.repository);

  @override
  Future<Either<Failure, Category>> call(Category category) {
    return repository.createCategory(category);
  }
}
