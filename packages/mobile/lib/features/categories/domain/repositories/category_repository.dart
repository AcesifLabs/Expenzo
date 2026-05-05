import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import '../entities/category.dart';

abstract class CategoryRepository {
  Future<Either<CacheFailure, List<Category>>> getCategories({
    RecordType? type,
    bool sortByUsage = false,
  });
  Future<Either<CacheFailure, Category>> getCategoryById(int id);
  Future<Either<CacheFailure, Category>> createCategory(Category category);
  Future<Either<CacheFailure, Category>> updateCategory(Category category);
  Future<Either<CacheFailure, Unit>> deleteCategory(int id);
  Stream<List<Category>> watchCategories({
    RecordType? type,
    bool sortByUsage = false,
  });
  Future<Either<CacheFailure, void>> incrementUsageCount(int id);
}
