import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/database/app_database.dart' as db;
import 'package:expense_tracker/core/database/daos/category_dao.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import 'package:expense_tracker/core/logger/app_logger.dart';
import '../../domain/entities/category.dart';
import 'package:expense_tracker/core/utils/category_display_name.dart';

abstract class CategoryLocalDatasource {
  Future<List<Category>> getCategories({
    RecordType? type,
    bool sortByUsage = false,
  });
  Future<Category?> getCategoryById(String id);

  Future<Category> createCategory(Category category);
  Future<Category> updateCategory(Category category);
  Future<void> deleteCategory(String id);
  Stream<List<Category>> watchCategories({
    RecordType? type,
    bool sortByUsage = false,
  });

  Future<void> incrementUsageCount(String id);

  /// Searches categories by name.
  Future<List<Category>> searchCategories({
    required String query,
    RecordType? type,
  });
}

class CategoryLocalDatasourceImpl implements CategoryLocalDatasource {
  final CategoryDao categoryDao;

  CategoryLocalDatasourceImpl({required this.categoryDao});

  @override
  Future<List<Category>> getCategories({
    RecordType? type,
    bool sortByUsage = false,
  }) async {
    try {
      final categories = await categoryDao.getAllCategories(
        type: type?.dbValue,
        sortByUsage: sortByUsage,
      );

      return categories.map(_mapToEntity).toList();
    } catch (e, s) {
      appLogger.error('Error getting categories', e, s);
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<Category?> getCategoryById(String id) async {
    try {
      final category = await categoryDao.getCategoryById(id);

      return category != null ? _mapToEntity(category) : null;
    } catch (e, s) {
      appLogger.error('Error getting category by id', e, s);
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<Category> createCategory(Category category) async {
    try {
      final now = DateTime.now().toUtc();
      final id = category.id ?? const Uuid().v4();
      final companion = db.CategoriesCompanion(
        id: Value(id),
        name: Value(category.name),
        emoji: Value(category.emoji),
        color: Value(category.color),
        isDefault: Value(category.isDefault),
        categoryType: Value(category.type.dbValue),
        usageCount: const Value(0),
        createdAt: Value(now),
        updatedAt: Value(now),
      );
      await categoryDao.insertCategory(companion);

      return category.copyWith(id: id, createdAt: now, updatedAt: now);
    } catch (e, s) {
      appLogger.error('Error creating category', e, s);
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<Category> updateCategory(Category category) async {
    try {
      final now = DateTime.now().toUtc();
      final id = category.id;
      if (id == null) {
        throw CacheException(message: 'Category has no id');
      }

      final companion = db.CategoriesCompanion(
        id: Value(id),
        name: Value(category.name),
        emoji: Value(category.emoji),
        color: Value(category.color),
        isDefault: Value(category.isDefault),
        categoryType: Value(category.type.dbValue),
        createdAt: Value(category.createdAt),
        updatedAt: Value(now),
      );
      await categoryDao.updateCategory(companion);

      return category.copyWith(updatedAt: now);
    } catch (e, s) {
      appLogger.error('Error updating category', e, s);
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    try {
      await categoryDao.deleteCategory(id);
    } catch (e, s) {
      appLogger.error('Error deleting category', e, s);
      throw CacheException(message: e.toString());
    }
  }

  @override
  Stream<List<Category>> watchCategories({
    RecordType? type,
    bool sortByUsage = false,
  }) {
    return categoryDao
        .watchCategories(type: type?.dbValue, sortByUsage: sortByUsage)
        .map((categories) => categories.map(_mapToEntity).toList());
  }

  @override
  Future<void> incrementUsageCount(String id) async {
    try {
      await categoryDao.incrementUsageCount(id);
    } catch (e, s) {
      appLogger.error('Error incrementing usage count', e, s);
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<List<Category>> searchCategories({
    required String query,
    RecordType? type,
  }) async {
    try {
      // Match the stored name and the name shown in the app language, so a
      // translated default category is found by what the user sees.
      final needle = query.trim().toLowerCase();
      final categories = await categoryDao.getAllCategories(
        type: type?.dbValue,
      );

      return categories
          .map(_mapToEntity)
          .where(
            (category) =>
                category.name.toLowerCase().contains(needle) ||
                categoryDisplayName(
                  id: category.id,
                  name: category.name,
                ).toLowerCase().contains(needle),
          )
          .toList();
    } catch (e, s) {
      appLogger.error('Error searching categories', e, s);
      throw CacheException(message: e.toString());
    }
  }

  Category _mapToEntity(db.Category category) {
    return Category(
      id: category.id,
      name: category.name,
      emoji: category.emoji,
      color: category.color,
      isDefault: category.isDefault,
      type: RecordType.fromDbValue(category.categoryType),
      createdAt: category.createdAt,
      updatedAt: category.updatedAt,
    );
  }
}
