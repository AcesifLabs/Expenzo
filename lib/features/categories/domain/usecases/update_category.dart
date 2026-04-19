import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/usecase.dart';
import '../entities/category.dart';
import '../repositories/category_repository.dart';

class UpdateCategory extends UseCase<Category, Category> {
  final CategoryRepository repository;

  UpdateCategory(this.repository);

  @override
  Future<Either<Failure, Category>> call(Category category) {
    return repository.updateCategory(category);
  }
}
