import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import '../entities/category.dart';

/// Repository for managing expense/income categories.
abstract class CategoryRepository {
  /// Retrieves all categories, optionally filtered by [type] and sorted by usage.
  ///
  /// Returns [Right(List<Category>)] on success, [Left(CacheFailure)] on failure.
  Future<Either<CacheFailure, List<Category>>> getCategories({
    RecordType? type,
    bool sortByUsage = false,
  });

  /// Retrieves a category by its [id].
  ///
  /// Returns [Right(Category)] on success, [Left(CacheFailure)] on failure.
  Future<Either<CacheFailure, Category>> getCategoryById(String id);

  /// Creates a new [category].
  ///
  /// Returns [Right(Category)] on success, [Left(CacheFailure)] on failure.
  Future<Either<CacheFailure, Category>> createCategory(Category category);

  /// Updates an existing [category].
  ///
  /// Returns [Right(Category)] on success, [Left(CacheFailure)] on failure.
  Future<Either<CacheFailure, Category>> updateCategory(Category category);

  /// Deletes a category by [id].
  ///
  /// Returns [Right(unit)] on success, [Left(CacheFailure)] on failure.
  Future<Either<CacheFailure, Unit>> deleteCategory(String id);

  /// Watches for changes to the category list, optionally filtered by [type].
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
