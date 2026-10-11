import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import '../entities/category.dart';

abstract class CategoryRepository {
  Future<Either<CacheFailure, List<Category>>> getCategories({
    RecordType? type,
    bool sortByUsage = false,
  });

  Future<Either<CacheFailure, Category>> getCategoryById(String id);

  Future<Either<CacheFailure, Category>> createCategory(Category category);

  Future<Either<CacheFailure, Category>> updateCategory(Category category);

  Future<Either<CacheFailure, Unit>> deleteCategory(String id);

  Stream<List<Category>> watchCategories({
    RecordType? type,
    bool sortByUsage = false,
  });

  /// Increments the usage count for a category by [id].
  ///
  /// Returns [Right(unit)] on success, [Left(CacheFailure)] on failure.
  Future<Either<CacheFailure, Unit>> incrementUsageCount(String id);

  /// Searches categories by name.
  ///
  /// Returns [Right(List<Category>)] on success, [Left(CacheFailure)] on failure.
  Future<Either<CacheFailure, List<Category>>> searchCategories({
    required String query,
    RecordType? type,
  });
}
