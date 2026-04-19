import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_local_datasource.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryLocalDatasource localDatasource;

  CategoryRepositoryImpl({required this.localDatasource});

  @override
  Future<Either<CacheFailure, List<Category>>> getCategories() async {
    try {
      final categories = await localDatasource.getCategories();
      return Right(categories);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<CacheFailure, Category>> getCategoryById(int id) async {
    try {
      final category = await localDatasource.getCategoryById(id);
      if (category == null) {
        return const Left(CacheFailure(message: 'Category not found'));
      }
      return Right(category);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<CacheFailure, Category>> createCategory(
    Category category,
  ) async {
    try {
      final created = await localDatasource.createCategory(category);
      return Right(created);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<CacheFailure, Category>> updateCategory(
    Category category,
  ) async {
    try {
      final updated = await localDatasource.updateCategory(category);
      return Right(updated);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<CacheFailure, Unit>> deleteCategory(int id) async {
    try {
      await localDatasource.deleteCategory(id);
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Stream<List<Category>> watchCategories() {
    return localDatasource.watchCategories();
  }
}
