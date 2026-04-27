import 'package:drift/drift.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/database/app_database.dart' hide Category;
import 'package:expense_tracker/core/database/daos/category_dao.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import '../../domain/entities/category.dart';

abstract class CategoryLocalDatasource {
  Future<List<Category>> getCategories({RecordType? type});
  Future<Category?> getCategoryById(int id);
  Future<Category> createCategory(Category category);
  Future<Category> updateCategory(Category category);
  Future<void> deleteCategory(int id);
  Stream<List<Category>> watchCategories({RecordType? type});
}

class CategoryLocalDatasourceImpl implements CategoryLocalDatasource {
  final CategoryDao categoryDao;

  CategoryLocalDatasourceImpl({required this.categoryDao});

  @override
  Future<List<Category>> getCategories({RecordType? type}) async {
    try {
      final categories = await categoryDao.getAllCategories(
        type: type?.dbValue,
      );
      return categories.map(_mapToEntity).toList();
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<Category?> getCategoryById(int id) async {
    try {
      final category = await categoryDao.getCategoryById(id);
      return category != null ? _mapToEntity(category) : null;
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<Category> createCategory(Category category) async {
    try {
      final now = DateTime.now().toUtc();
      final companion = CategoriesCompanion(
        name: Value(category.name),
        emoji: Value(category.emoji),
        color: Value(category.color),
        isDefault: Value(category.isDefault),
        categoryType: Value(category.type.dbValue),
        createdAt: Value(now),
        updatedAt: Value(now),
      );
      final id = await categoryDao.insertCategory(companion);
      return category.copyWith(id: id, createdAt: now, updatedAt: now);
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<Category> updateCategory(Category category) async {
    try {
      final now = DateTime.now().toUtc();
      final companion = CategoriesCompanion(
        id: Value(category.id!),
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
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<void> deleteCategory(int id) async {
    try {
      await categoryDao.deleteCategory(id);
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Stream<List<Category>> watchCategories({RecordType? type}) {
    return categoryDao
        .watchCategories(type: type?.dbValue)
        .map((categories) => categories.map(_mapToEntity).toList());
  }

  Category _mapToEntity(dynamic category) {
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
