import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import 'package:expense_tracker/core/sync/sync_event.dart';
import 'package:expense_tracker/core/database/daos/sync_queue_dao.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_local_datasource.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryLocalDatasource localDatasource;
  final SyncQueueDao? _syncQueueDao;

  CategoryRepositoryImpl({
    required this.localDatasource,
    SyncQueueDao? syncQueueDao,
  }) : _syncQueueDao = syncQueueDao;

  /// Returns Left(Failure) on error.
  @override
  Future<Either<CacheFailure, List<Category>>> getCategories({
    RecordType? type,
    bool sortByUsage = false,
  }) async {
    try {
      final categories = await localDatasource.getCategories(
        type: type,
        sortByUsage: sortByUsage,
      );

      return Right(categories);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    } catch (e, s) {
      print('Error: $e\n$s');
      return Left(CacheFailure(message: e.toString()));
    }
  }

  /// Returns Left(Failure) on error.
  @override
  Future<Either<CacheFailure, Category>> getCategoryById(String id) async {
    try {
      final category = await localDatasource.getCategoryById(id);
      if (category == null) {
        return const Left(CacheFailure(message: 'Category not found'));
      }

      return Right(category);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    } catch (e, s) {
      print('Error: $e\n$s');
      return Left(CacheFailure(message: e.toString()));
    }
  }

  /// Returns Left(Failure) on error.
  @override
  Future<Either<CacheFailure, Category>> createCategory(
    Category category,
  ) async {
    try {
      final created = await localDatasource.createCategory(category);
      final createdId = created.id;
      if (createdId != null) {
        _enqueueSync('insert', createdId, {
          'name': created.name,
          'emoji': created.emoji,
          'color': created.color,
          'type': created.type.dbValue,
          'isDefault': created.isDefault,
        });
      }

      return Right(created);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    } catch (e, s) {
      print('Error: $e\n$s');
      return Left(CacheFailure(message: e.toString()));
    }
  }

  /// Returns Left(Failure) on error.
  @override
  Future<Either<CacheFailure, Category>> updateCategory(
    Category category,
  ) async {
    try {
      final updated = await localDatasource.updateCategory(category);
      final updatedId = updated.id;
      if (updatedId != null) {
        _enqueueSync('update', updatedId, {
          'name': updated.name,
          'emoji': updated.emoji,
          'color': updated.color,
          'type': updated.type.dbValue,
          'isDefault': updated.isDefault,
        });
      }

      return Right(updated);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    } catch (e, s) {
      print('Error: $e\n$s');
      return Left(CacheFailure(message: e.toString()));
    }
  }

  /// Returns Left(Failure) on error.
  @override
  Future<Either<CacheFailure, Unit>> incrementUsageCount(String id) async {
    try {
      await localDatasource.incrementUsageCount(id);
      _enqueueSync('update', id);

      return const Right(unit);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    } catch (e, s) {
      print('Error: $e\n$s');
      return Left(CacheFailure(message: e.toString()));
    }
  }

  /// Returns Left(Failure) on error.
  @override
  Future<Either<CacheFailure, Unit>> deleteCategory(String id) async {
    try {
      await localDatasource.deleteCategory(id);
      _enqueueSync('delete', id);

      return const Right(unit);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    } catch (e, s) {
      print('Error: $e\n$s');
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Stream<List<Category>> watchCategories({
    RecordType? type,
    bool sortByUsage = false,
  }) {
    return localDatasource.watchCategories(
      type: type,
      sortByUsage: sortByUsage,
    );
  }

  void _enqueueSync(
    String action,
    String recordId, [
    Map<String, dynamic>? data,
  ]) {
    final syncQueueDao = _syncQueueDao;
    if (syncQueueDao == null) return;
    syncQueueDao.enqueue(
      tableName: 'categories',
      recordId: recordId,
      action: action,
      payload: data != null ? jsonEncode(data) : '',
    );
    SyncEventBus().trigger();
  }
}
