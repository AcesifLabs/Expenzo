import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/categories_table.dart';

part 'category_dao.g.dart';

@DriftAccessor(tables: [Categories])
class CategoryDao extends DatabaseAccessor<AppDatabase>
    with _$CategoryDaoMixin {
  CategoryDao(super.db);

  Stream<List<Category>> watchCategories({
    String? type,
    bool sortByUsage = false,
  }) {
    var query = select(categories);

    if (sortByUsage) {
      query.orderBy([
        (t) => OrderingTerm.desc(t.usageCount),
        (t) => OrderingTerm.asc(t.name),
      ]);
    } else {
      query.orderBy([(t) => OrderingTerm.asc(t.name)]);
    }

    if (type != null) {
      query.where((t) => t.categoryType.equals(type));
    }

    return query.watch();
  }

  Future<List<Category>> getAllCategories({
    String? type,
    bool sortByUsage = false,
  }) {
    var query = select(categories);

    if (sortByUsage) {
      query.orderBy([
        (t) => OrderingTerm.desc(t.usageCount),
        (t) => OrderingTerm.asc(t.name),
      ]);
    } else {
      query.orderBy([(t) => OrderingTerm.asc(t.name)]);
    }

    if (type != null) {
      query.where((t) => t.categoryType.equals(type));
    }

    return query.get();
  }

  Future<void> incrementUsageCount(String id) async {
    final category = await getCategoryById(id);
    if (category != null) {
      await (update(categories)..where((t) => t.id.equals(id))).write(
        CategoriesCompanion(usageCount: Value(category.usageCount + 1)),
      );
    }
  }

  Future<Category?> getCategoryById(String id) {
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

  Future<int> deleteCategory(String id) {
    return (delete(categories)..where((t) => t.id.equals(id))).go();
  }
}
