import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/categories_table.dart';

part 'category_dao.g.dart';

@DriftAccessor(tables: [Categories])
class CategoryDao extends DatabaseAccessor<AppDatabase>
    with _$CategoryDaoMixin {
  CategoryDao(super.db);

  Stream<List<Category>> watchCategories() {
    return (select(
      categories,
    )..orderBy([(t) => OrderingTerm.asc(t.name)])).watch();
  }

  Future<List<Category>> getAllCategories() {
    return (select(
      categories,
    )..orderBy([(t) => OrderingTerm.asc(t.name)])).get();
  }

  Future<Category?> getCategoryById(int id) {
    return (select(
      categories,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertCategory(CategoriesCompanion category) {
    return into(categories).insert(category);
  }

  Future<bool> updateCategory(CategoriesCompanion category) {
    return update(
      categories,
    ).replace(category.copyWith(updatedAt: Value(DateTime.now().toUtc())));
  }

  Future<int> deleteCategory(int id) {
    return (delete(categories)..where((t) => t.id.equals(id))).go();
  }
}
